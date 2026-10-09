export function cloudFetch(config,fetcher=globalThis.fetch,origin=globalThis.location?.origin){
 return async(input,init)=>{
  const request=new Request(input,init),url=new URL(request.url);
  if(!config.relay||url.origin!==config.url)return fetcher(request);
  const base=origin==='https://www.szq823.xyz'||origin==='https://szq823.xyz'?origin:config.relay;
  const relay=new URL('/api/cloud',base);relay.searchParams.set('path',url.pathname);relay.searchParams.set('query',url.search);
  return fetcher(new Request(relay,{method:request.method,headers:request.headers,body:['GET','HEAD'].includes(request.method)?undefined:await request.text(),signal:request.signal,cache:'no-store'}));
 };
}
