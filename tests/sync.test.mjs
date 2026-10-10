import test from'node:test';
import assert from'node:assert/strict';
import{operation,materialize}from'../sync-model.js';
import{indexedDB}from'fake-indexeddb';
import{useAccount,put,get,entries,mergeCloudEvents,markCloudUploaded,onLearningChange,seedLearning,remove,guestLearning,restoreBackup}from'../core.js';
globalThis.indexedDB=indexedDB;
let id=0;
const event=(payload,clock=++id,device='a')=>({id:'e'+(++id),clock,device,payload});
const row=(events,store,key)=>materialize(events).get(store+'\u0000'+key);
test('two offline devices add answers without losing counts; retries are idempotent',()=>{
 const base={uid:'q',attempts:10,correctCount:7,wrongCount:3,streak:0,wrong:true};
 const seed=event(operation('records','q',null,base,false,true),0);
 const a=event(operation('records','q',base,{...base,attempts:11,correctCount:8,lastCorrect:true,lastAt:10}));
 const b=event(operation('records','q',base,{...base,attempts:11,wrongCount:4,lastCorrect:false,lastAt:20}));
 const r=row([b,seed,a,a,b],'records','q');assert.equal(r.attempts,12);assert.equal(r.correctCount,8);assert.equal(r.wrongCount,4);assert.equal(r.streak,0);assert.equal(r.wrong,true);
});
test('reimported legacy snapshots use maxima before new answers are added',()=>{
 const base={attempts:10,correctCount:8,wrongCount:2};
 const events=[event(operation('records','q',null,base,false,true),0),event(operation('records','q',null,base,false,true),0),event(operation('records','q',base,{...base,attempts:11,correctCount:9,lastCorrect:true,lastAt:1}))];
 assert.equal(row(events,'records','q').attempts,11);
});
test('concurrent session answers keep both positions and exact question order',()=>{
 const base={id:'s',indices:[8,4,9],index:0,answers:{},graded:{}};
 const events=[event(operation('sessions','active',null,base)),event(operation('sessions','active',base,{...base,index:1,answers:{0:'A'},graded:{0:true}})),event(operation('sessions','active',base,{...base,index:2,answers:{1:'B'},graded:{1:true}}))];
 const r=row(events,'sessions','active');assert.deepEqual(r.answers,{0:'A',1:'B'});assert.deepEqual(r.indices,[8,4,9]);assert.deepEqual(r.graded,{0:true,1:true});
});
test('different sessions do not mix answers and stale delete cannot delete newer session',()=>{
 const a={id:'a',answers:{0:'A'},indices:[1],index:0},b={id:'b',answers:{1:'B'},indices:[2,3],index:1};
 const events=[event(operation('sessions','active',null,a)),event(operation('sessions','active',a,b)),event(operation('sessions','active',a,null,true))];
 assert.deepEqual(row(events,'sessions','active').answers,{1:'B'});
});
test('favorites cancellation and plan deletion propagate; unrelated plans remain',()=>{
 const events=[event(operation('records','q',null,{favorite:true})),event(operation('records','q',{favorite:true},{favorite:false}))];assert.equal(row(events,'records','q').favorite,false);
 const plans=[{id:'a',name:'A'}];const p=[event(operation('settings','practice-plans',null,plans)),event(operation('settings','practice-plans',plans,[...plans,{id:'b',name:'B'}])),event(operation('settings','practice-plans',plans,[]))];assert.deepEqual(row(p,'settings','practice-plans'),[{id:'b',name:'B'}]);
});
test('daily totals merge increments and do not duplicate retries',()=>{
 const old={'2026-10-08':{answered:10,correct:8}},a={'2026-10-08':{answered:11,correct:9}},b={'2026-10-08':{answered:11,correct:8}};
 const seed=event(operation('settings','daily',null,old,false,true),0),e1=event(operation('settings','daily',old,a)),e2=event(operation('settings','daily',old,b));assert.deepEqual(row([seed,e1,e2,e2],'settings','daily'),{'2026-10-08':{answered:12,correct:9}});
});
test('IndexedDB atomically persists pending changes, isolates accounts, and keeps guest data',async()=>{
 await useAccount(null);await put('records','guest',{attempts:3});await useAccount('alice');
 await put('records','q',{attempts:1,correctCount:1,wrongCount:0,lastCorrect:true,lastAt:1});
 let events=(await entries('sync-events')).map(x=>x[1]);assert.equal(events.length,1);assert.equal(events[0].pending,true);
 await mergeCloudEvents([],events.map(e=>e.id));assert.equal((await get('records','q')).attempts,1);assert.equal((await entries('sync-events'))[0][1].pending,false);
 await useAccount('bob');assert.equal(await get('records','q'),undefined);await useAccount('alice');assert.equal((await get('records','q')).attempts,1);
 const guest=await guestLearning();assert.equal(guest.records[0][1].attempts,3);await seedLearning(guest);assert.equal((await get('records','guest')).attempts,3);
 await remove('records','q');await mergeCloudEvents();assert.equal(await get('records','q'),undefined);
 await restoreBackup({app:'haixing-study',version:1,stores:{records:[['imported',{attempts:4}]]}});assert.equal((await get('records','imported')).attempts,4);
 await useAccount(null);assert.equal((await get('records','guest')).attempts,3);
});
test('unchanged writes do not start another sync; acknowledgements never rewrite learning data',async()=>{
 await useAccount('quiet-test');let notifications=0;onLearningChange(()=>notifications++);
 const profile={nickname:'航海人',avatar:'⚓'};await put('settings','user-profile',profile);await put('settings','user-profile',{...profile});await remove('sessions','missing');assert.equal(notifications,1);
 const events=(await entries('sync-events')).map(x=>x[1]);assert.equal(events.length,1);await markCloudUploaded(events.map(e=>e.id));assert.deepEqual(await get('settings','user-profile'),profile);const merged=await mergeCloudEvents(events.map(({pending,...e})=>e));assert.equal(merged.changed,false);assert.deepEqual(merged.stores,[]);onLearningChange(()=>{});await useAccount(null);
});
