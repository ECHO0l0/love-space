import{createClient}from'./vendor/supabase.js';
import{syncConfig}from'./sync-config.js';
import{cloudFetch}from'./cloud-fetch.js';
import{get,put,entries,useAccount,onLearningChange,mergeCloudEvents,markCloudUploaded,seedLearning,guestLearning}from'./core.js';
export class CloudSync{
 constructor(notify=()=>{}){this.notify=notify;this.user=null;this.status='本机自动保存';this.client=null;this.running=null;this.channel=null;this.timer=null;this.poll=null;this.generation=0;}
 configured(){return /^https:\/\/[a-z0-9-]+\.supabase\.co$/.test(syncConfig.url)&&!!syncConfig.publishableKey;}
 emit(status,changed=false,stores=[]){this.status=status;this.notify({status,user:this.user,changed,stores});}
 async init(){
  if(!this.configured())return;
  this.client=createClient(syncConfig.url,syncConfig.publishableKey,{global:{fetch:cloudFetch(syncConfig)},auth:{persistSession:true,autoRefreshToken:true,detectSessionInUrl:true}});
  onLearningChange(()=>this.schedule());
  this.client.auth.onAuthStateChange((event,session)=>{if(['SIGNED_IN','SIGNED_OUT'].includes(event))setTimeout(()=>this.activate(session?.user||null).catch(e=>this.emit('同步失败：'+e.message)),0);});
  const {data,error}=await this.client.auth.getSession();if(error)this.emit('同步失败：'+error.message);else await this.activate(data.session?.user||null,{background:true});
  this.poll=setInterval(()=>{if(!document.hidden)this.schedule();},syncConfig.relay?5000:30000);window.addEventListener('online',()=>this.schedule());window.addEventListener('offline',()=>this.emit(this.user?'等待联网后同步':'离线可用'));document.addEventListener('visibilitychange',()=>{if(!document.hidden)this.schedule();});
 }
 async activate(user,{background=false}={}){
  if((user?.id||null)===(this.user?.id||null))return;
  this.generation++;clearTimeout(this.timer);if(this.running)await this.running;
  if(this.channel){await this.client.removeChannel(this.channel);this.channel=null;}
  this.user=user;await useAccount(user?.id||null);this.emit(user?'正在同步':'本机自动保存',true);
  if(!user)return;
  if(!syncConfig.relay)this.channel=this.client.channel('study-'+user.id).on('postgres_changes',{event:'INSERT',schema:'public',table:'haixing_events',filter:'user_id=eq.'+user.id},()=>this.schedule()).subscribe(status=>{if(status==='SUBSCRIBED')this.schedule();});
  if(background)this.sync();else await this.sync();
 }
 schedule(){if(!this.user)return;clearTimeout(this.timer);this.timer=setTimeout(()=>this.sync(),600);}
 async sync(){
  if(!this.user)return;if(this.running)return this.running;
  if(!navigator.onLine){this.emit('等待联网后同步');return;}
  const generation=this.generation,uid=this.user.id;
  this.running=(async()=>{try{
   const local=(await entries('sync-events')).map(x=>x[1]),known=new Set(local.map(e=>e.id));let pending=local.filter(e=>e.pending);if(pending.length)this.emit('正在同步');
   for(let i=0;i<pending.length;i+=100){if(generation!==this.generation)return;const batch=pending.slice(i,i+100);const{error}=await this.client.rpc('haixing_push_events',{batch:batch.map(({id,device,clock,payload})=>({id,device,clock,payload}))});if(error)throw error;await markCloudUploaded(batch.map(e=>e.id));}
   let cursor=await get('sync-meta','cursor')||0,changed=false;const stores=new Set();
   while(generation===this.generation){const{data,error}=await this.client.from('haixing_events').select('seq,event_id,device,clock,payload').eq('user_id',uid).gt('seq',cursor).order('seq').limit(500);if(error)throw error;if(!data.length)break;
    const incoming=data.filter(e=>!known.has(e.event_id));if(incoming.length){const result=await mergeCloudEvents(incoming.map(e=>({id:e.event_id,device:e.device,clock:e.clock,payload:e.payload})));changed||=result.changed;result.stores.forEach(s=>stores.add(s));incoming.forEach(e=>known.add(e.event_id));}cursor=data.at(-1).seq;await put('sync-meta','cursor',cursor);if(data.length<500)break;
   }
   if(generation===this.generation){const left=(await entries('sync-events')).some(x=>x[1].pending);this.emit(left?'等待同步':'已同步',changed,[...stores]);if(left)this.schedule();}
  }catch(e){if(generation===this.generation)this.emit('同步失败：'+(e.message||'请检查网络'));}finally{this.running=null;}})();return this.running;
 }
 async signIn(email,password){if(!this.client)throw Error('云端尚未配置');const{data,error}=await this.client.auth.signInWithPassword({email,password});if(error)throw error;await this.activate(data.user);}
 async signUp(email,password){if(!this.client)throw Error('云端尚未配置');const{data,error}=await this.client.auth.signUp({email,password});if(error)throw error;if(data.session)await this.activate(data.user);return!!data.session;}
 async signOut(){if(!this.client)return;await this.sync();const{error}=await this.client.auth.signOut({scope:'local'});if(error)throw error;await this.activate(null);}
 async importGuest(){if(!this.user)throw Error('请先登录');await seedLearning(await guestLearning());await this.sync();this.emit(this.status,true);}
}
