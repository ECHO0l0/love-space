import{syncConfig}from'../sync-config.js';
const origins=new Set(['https://www.szq823.xyz','https://szq823.xyz','http://127.0.0.1:8239','http://127.0.0.1:4173']);
export default async function handler(req,res){
 res.setHeader('Cache-Control','private, no-store, max-age=0');res.setHeader('Vary','Origin');
 const origin=req.headers.origin;
 if(origin&&!origins.has(origin)){res.statusCode=403;res.end(JSON.stringify({message:'来源不允许访问'}));return;}
 if(origin)res.setHeader('Access-Control-Allow-Origin',origin);
 res.setHeader('Access-Control-Allow-Methods','GET, POST, PUT, OPTIONS');res.setHeader('Access-Control-Allow-Headers','authorization, apikey, content-type, x-client-info, x-supabase-api-version, prefer, range, accept-profile, content-profile');
 res.setHeader('Access-Control-Expose-Headers','content-range, x-supabase-api-version');
 if(req.method==='OPTIONS'){res.statusCode=204;res.end();return;}
 const url=new URL(req.url,'https://www.szq823.xyz'),path=url.searchParams.get('path')||'',query=url.searchParams.get('query')||'';
 if(!['GET','POST','PUT'].includes(req.method)||!/^\/(auth\/v1\/(settings|token|signup|logout|user|recover|resend|verify)|rest\/v1\/(haixing_events|rpc\/haixing_push_events))$/.test(path)||query&&!query.startsWith('?')){res.statusCode=400;res.end(JSON.stringify({message:'无效的同步请求'}));return;}
 const headers={apikey:syncConfig.publishableKey};for(const name of ['authorization','content-type','x-client-info','x-supabase-api-version','prefer','range','accept-profile','content-profile'])if(req.headers[name])headers[name]=req.headers[name];
 try{
  const response=await fetch(syncConfig.url+path+query,{method:req.method,headers,body:req.method==='GET'?undefined:typeof req.body==='string'?req.body:JSON.stringify(req.body??{}),signal:AbortSignal.timeout(20000),redirect:'error'});
  res.statusCode=response.status;for(const name of ['content-type','content-range','x-supabase-api-version'])if(response.headers.has(name))res.setHeader(name,response.headers.get(name));res.end(await response.text());
 }catch{res.statusCode=502;res.setHeader('Content-Type','application/json');res.end(JSON.stringify({message:'云端暂时连接失败，请稍后重试'}));}
}
