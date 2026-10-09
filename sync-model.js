const counts=['attempts','correctCount','wrongCount'];
const equal=(a,b)=>JSON.stringify(a)===JSON.stringify(b);
export function operation(store,key,previous,value,deleted=false,seed=false){
 const op={store,key,deleted,seed,previousId:previous?.id};
 if(deleted)return op;
 if(seed){op.value=value;return op;}
 op.patch={};
 for(const [field,next] of Object.entries(value||{}))if(!equal(previous?.[field],next))op.patch[field]=next;
 if(store==='records'){
  op.delta={};for(const field of counts){const n=(value?.[field]||0)-(previous?.[field]||0);if(n>0)op.delta[field]=n;delete op.patch[field];}if(op.delta.attempts){op.patch.lastCorrect=value.lastCorrect;op.patch.lastAt=value.lastAt;}
 }
 if(store==='settings'&&key==='daily'){
  op.delta={};for(const [day,row]of Object.entries(value||{})){const old=previous?.[day]||{};const answered=(row.answered||0)-(old.answered||0),correct=(row.correct||0)-(old.correct||0);if(answered>0||correct>0)op.delta[day]={answered:Math.max(0,answered),correct:Math.max(0,correct)};}
  op.patch={};
 }
 if(store==='settings'&&key==='practice-plans'){
  const old=new Map((previous||[]).map(p=>[p.id,p]));op.plans=[];
  for(const p of value||[]){if(!equal(old.get(p.id),p))op.plans.push({id:p.id,value:p});old.delete(p.id);}
  for(const id of old.keys())op.plans.push({id,deleted:true});op.patch={};
 }
 if(store==='sessions'){
  if(previous?.id!==value.id)op.patch=structuredClone(value);
  op.patch.id=value.id;
  for(const field of ['answers','graded','viewed'])if(op.patch[field]){const changed={};for(const[k,v]of Object.entries(value[field]||{}))if(previous?.id!==value.id||!equal(previous?.[field]?.[k],v))changed[k]=v;op.patch[field]=changed;}
 }
 return op;
}
export function orderEvents(events){return [...new Map(events.map(e=>[e.id,e])).values()].sort((a,b)=>a.clock-b.clock||a.device.localeCompare(b.device)||a.id.localeCompare(b.id));}
export function materialize(events){
 const rows=new Map(),sessionVersions=new Map();
 for(const e of orderEvents(events)){
  const p=e.payload,k=p.store+'\u0000'+p.key,old=rows.get(k);
  if(p.deleted){if(p.store!=='sessions'||!old||!p.previousId||old.id===p.previousId)rows.delete(k);continue;}
  if(p.seed){
   if(!old){rows.set(k,structuredClone(p.value));continue;}
   if(p.store==='records'){const merged={...p.value,...old};for(const f of counts)merged[f]=Math.max(old[f]||0,p.value[f]||0);rows.set(k,merged);}
   else if(p.store==='settings'&&p.key==='daily'){const merged=structuredClone(old);for(const[d,r]of Object.entries(p.value||{}))merged[d]={answered:Math.max(old[d]?.answered||0,r.answered||0),correct:Math.max(old[d]?.correct||0,r.correct||0)};rows.set(k,merged);}
   else if(p.store==='settings'&&p.key==='practice-plans'){rows.set(k,[...new Map([...(p.value||[]),...old].map(x=>[x.id,x])).values()]);}
   continue;
  }
  let next={...(p.store==='sessions'&&old?.id!==p.patch?.id?{}:old),...p.patch};
  if(p.store==='records'){
   for(const f of counts)next[f]=(old?.[f]||0)+(p.delta?.[f]||0);
   if(p.delta?.attempts){next.streak=next.lastCorrect?(old?.streak||0)+1:0;next.wrong=next.lastCorrect?(next.streak>=3?false:!!old?.wrong):true;next.due=(next.lastAt||0)+(next.lastCorrect?[1,3,7,14,30][Math.min(next.streak-1,4)]:0)*86400000;}
  }
  if(p.store==='settings'&&p.key==='daily'){next=structuredClone(old||{});for(const[d,r]of Object.entries(p.delta||{}))next[d]={answered:(next[d]?.answered||0)+(r.answered||0),correct:(next[d]?.correct||0)+(r.correct||0)};}
  if(p.store==='settings'&&p.key==='practice-plans'){const plans=new Map((old||[]).map(x=>[x.id,x]));for(const p1 of p.plans||[])p1.deleted?plans.delete(p1.id):plans.set(p1.id,p1.value);next=[...plans.values()];}
  if(p.store==='sessions'&&next.id){
   const identity=next.id,prior=sessionVersions.get(identity)||(old?.id===identity?old:{});
   next={...prior,...next,answers:{...prior.answers,...p.patch.answers},graded:{...prior.graded,...p.patch.graded},viewed:{...prior.viewed,...p.patch.viewed}};
   sessionVersions.set(identity,next);
  }
  rows.set(k,next);
 }
 return rows;
}
