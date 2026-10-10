import test from'node:test';import assert from'node:assert/strict';
import{chapterProgress,cleanProfile,authMessage}from'../product.js';
test('chapter progress uses playable question identities, including child questions',()=>{
 const questions=[{uid:'b:1',chapterId:1},{uid:'b:2',chapterId:1},{uid:'b:2',chapterId:1},{uid:'b:3',chapterId:2}];
 assert.deepEqual(chapterProgress(questions,{'b:2':{attempts:1},'b:3':{attempts:3}},'1'),{learned:1,total:2,pct:50});assert.deepEqual(chapterProgress(questions,{},3),{learned:0,total:0,pct:0});
});
test('profile keeps bounded text and raster avatars; invalid avatar sources are rejected',()=>{
 const p=cleanProfile({nickname:'  航海人  ',bio:'x'.repeat(200),avatar:'javascript:alert(1)',color:'red'});assert.equal(p.nickname,'航海人');assert.equal(p.bio.length,120);assert.equal(p.avatar,'⚓');assert.equal(cleanProfile({avatar:'data:image/webp;base64,YQ=='}).avatar,'data:image/webp;base64,YQ==');
});
test('common authentication failures are actionable in Chinese',()=>{assert.equal(authMessage({code:'invalid_credentials'}),'邮箱或密码不正确');assert.equal(authMessage({message:'Failed to fetch'}),'暂时无法连接，请稍后重试');});
