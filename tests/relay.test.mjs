import test from'node:test';import assert from'node:assert/strict';
import{cloudFetch}from'../cloud-fetch.js';import handler from'../api/cloud.js';
test('browser relay preserves auth body and token without contacting Supabase directly',async()=>{
 let sent;const fetcher=cloudFetch({url:'https://example.supabase.co',relay:'https://www.szq823.xyz'},async r=>{sent=r;return new Response('{}');},'http://127.0.0.1:8239');
 await fetcher('https://example.supabase.co/auth/v1/token?grant_type=password',{method:'POST',headers:{Authorization:'Bearer test','Content-Type':'application/json'},body:'{"password":"dummy"}'});
 const url=new URL(sent.url);assert.equal(url.origin,'https://www.szq823.xyz');assert.equal(url.searchParams.get('path'),'/auth/v1/token');assert.equal(url.searchParams.get('query'),'?grant_type=password');assert.equal(sent.headers.get('authorization'),'Bearer test');assert.equal(await sent.text(),'{"password":"dummy"}');assert.equal(sent.cache,'no-store');
});
test('relay forwards upstream status, forbids arbitrary endpoints, and never caches auth responses',async()=>{
 const original=globalThis.fetch;const response=()=>({headers:{},setHeader(k,v){this.headers[k]=v;},end(body){this.body=body;}});
 try{globalThis.fetch=async()=>new Response('{"message":"required"}',{status:400,headers:{'Content-Type':'application/json'}});let res=response();await handler({method:'POST',url:'/api/cloud?path=%2Fauth%2Fv1%2Fsignup',headers:{origin:'https://www.szq823.xyz'},body:{}},res);assert.equal(res.statusCode,400);assert.match(res.headers['Cache-Control'],/no-store/);assert.equal(res.body,'{"message":"required"}');
 res=response();await handler({method:'GET',url:'/api/cloud?path=https://other.example',headers:{}},res);assert.equal(res.statusCode,400);
 res=response();await handler({method:'GET',url:'/api/cloud?path=%2Fauth%2Fv1%2Fsettings',headers:{origin:'https://other.example'}},res);assert.equal(res.statusCode,403);
 }finally{globalThis.fetch=original;}
});
