export const avatarPresets=['⚓','⛵','🧭','🌊','🚢','🐬'];
export const profileColors=['#34786b','#547bc1','#9964a5','#b97b42','#52845e','#b76573'];
export function chapterProgress(questions,records,chapter){
 const ids=new Set(questions.filter(q=>String(q.chapterId)===String(chapter)).map(q=>q.uid));
 const learned=[...ids].filter(id=>(records[id]?.attempts||0)>0).length,total=ids.size;
 return{learned,total,pct:total?Math.round(learned/total*100):0};
}
export function cleanProfile(value={}){
 const nickname=String(value.nickname||'').trim().slice(0,24),bio=String(value.bio||'').trim().slice(0,120);
 const avatar=avatarPresets.includes(value.avatar)||/^data:image\/(webp|png|jpeg);base64,[A-Za-z0-9+/=]+$/.test(value.avatar||'')&&value.avatar.length<100000?value.avatar:'⚓';
 return{nickname,bio,avatar,color:profileColors.includes(value.color)?value.color:profileColors[0]};
}
export function authMessage(error){
 const code=error?.code||'',message=error?.message||'';
 if(/fetch|network|连接/i.test(message))return'暂时无法连接，请稍后重试';
 if(code==='invalid_credentials')return'邮箱或密码不正确';
 if(code==='email_not_confirmed')return'请先在邮箱中确认注册，再登录';
 if(/rate_limit/.test(code))return'操作频繁，请稍后再试';
 if(/email_address_not_authorized/.test(code))return'这个邮箱暂未开放注册，请联系管理员';
 return message||'操作未完成，请重试';
}
