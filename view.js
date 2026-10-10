import morphdom from'./vendor/morphdom.js';
export function patchView(root,html){
 const template=document.createElement('template');template.innerHTML=html;
 const target=root.cloneNode(false);target.append(template.content);
 morphdom(root,target,{childrenOnly:true,onBeforeElUpdated(from,to){
  if(from.isEqualNode(to))return false;
  if(from===document.activeElement&&['INPUT','TEXTAREA','SELECT'].includes(from.tagName))return false;
  return true;
 }});
}
export function viewStore(account='guest'){
 const prefix='haixing-view:'+account+':';
 return{get(route){try{return JSON.parse(sessionStorage.getItem(prefix+route))||{};}catch{return{};}},set(route,value){try{sessionStorage.setItem(prefix+route,JSON.stringify(value));}catch{}}};
}
