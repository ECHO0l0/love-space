import test from 'node:test';
import assert from 'node:assert/strict';
import {practiceReport,remainingPractice,practicePool} from '../practice.js';
const qs=Array.from({length:3000},(_,i)=>({uid:'b:'+i,answer:'A',chapterId:i<100?1:2}));
test('ending 30 answers out of 3000 reports only 30 and preserves the remainder',()=>{
 const s={id:'s',mode:'sequence',indices:qs.map((_,i)=>i),index:29,answers:Object.fromEntries(Array.from({length:30},(_,i)=>[i,'A'])),graded:Object.fromEntries(Array.from({length:30},(_,i)=>[i,true]))};
 const r=practiceReport(s,qs);assert.equal(r.result.total,30);assert.equal(r.result.score,100);assert.equal(r.indices.length,30);
 const next=remainingPractice(s);assert.equal(next.indices[0],30);assert.equal(next.indices.length,2970);assert.equal(next.index,0);assert.deepEqual(next.answers,{});
});
test('unsubmitted multi-choice draft stays in next practice, not in report',()=>{
 const s={mode:'sequence',indices:[0,1,2],index:1,answers:{0:'A',1:'A'},graded:{0:true}};
 assert.equal(practiceReport(s,qs.slice(0,3)).result.total,1);
 const next=remainingPractice(s);assert.deepEqual(next.indices,[1,2]);assert.deepEqual(next.answers,{0:'A'});
});
test('small quiz counts unanswered only within selected paper',()=>{
 const s={mode:'exam',indices:[1,4,8],answers:{0:'A'},graded:{}};
 assert.deepEqual(practiceReport(s,qs.slice(0,3)).result,{right:1,answered:1,total:3,score:33});
});
test('learned chapter pool excludes unseen and hidden questions and respects manual picks',()=>{
 const r={'b:0':{attempts:1},'b:1':{attempts:2,hidden:true},'b:101':{attempts:1}};
 assert.deepEqual(practicePool(qs,r,{source:'learned',chapters:['1']}).map(q=>q.uid),['b:0']);
 assert.equal(practicePool(qs,r,{source:'learned',ids:[]}).length,0);
});
