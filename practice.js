import {score} from './core.js';

export function practicePool(questions, records, config={}) {
  const chapters=config.chapters?.map(String);
  const ids=config.ids ? new Set(config.ids) : null;
  return questions.filter(q=>{
    const r=records[q.uid]||{};
    if(r.hidden || (chapters?.length && !chapters.includes(String(q.chapterId))))return false;
    if(ids && !ids.has(q.uid))return false;
    return config.source==='learned' ? r.attempts>0 : config.source==='wrong' ? !!r.wrong : config.source==='favorites' ? !!r.favorite : config.source==='unseen' ? !r.attempts : true;
  });
}

export function practiceReport(session, questions, now=Date.now()) {
  const positions=questions.map((_,i)=>i).filter(i=>session.mode==='exam'||(session.mode==='memorize'?session.viewed?.[i]:session.graded?.[i]&&session.answers?.[i]));
  const answers={},graded={};
  positions.forEach((old,i)=>{if(session.answers?.[old])answers[i]=session.answers[old];graded[i]=true;});
  const chosen=positions.map(i=>questions[i]);
  return {...session,indices:positions.map(i=>session.indices[i]),answers,graded,index:0,finished:true,finishedAt:now,plannedTotal:questions.length,result:session.mode==='memorize'?{right:0,answered:0,total:chosen.length,score:0}:score(chosen,answers)};
}

export function remainingPractice(session) {
  const keep=session.indices.map((_,i)=>i).filter(i=>session.mode==='memorize'?!session.viewed?.[i]:!(session.graded?.[i]&&session.answers?.[i]));
  if(!keep.length)return null;
  const answers={};
  keep.forEach((old,i)=>{if(session.answers?.[old])answers[i]=session.answers[old];});
  const next=keep.findIndex(i=>i>=session.index);
  return {...session,id:crypto.randomUUID(),indices:keep.map(i=>session.indices[i]),index:Math.max(0,next),answers,graded:{},viewed:{},started:Date.now(),finished:false,finishedAt:undefined,result:undefined};
}
