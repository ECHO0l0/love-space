-- 海行专用；不删除已有表，不使用其他项目的 setup.sql。
begin;
create table if not exists public.haixing_events (
 seq bigint generated always as identity primary key,
 user_id uuid not null references auth.users(id) on delete cascade,
 event_id uuid not null,
 device uuid not null,
 clock bigint not null check(clock>=0),
 payload jsonb not null,
 created_at timestamptz not null default now(),
 unique(user_id,event_id)
);
create index if not exists haixing_events_user_seq on public.haixing_events(user_id,seq);
alter table public.haixing_events enable row level security;
drop policy if exists haixing_read_own on public.haixing_events;
create policy haixing_read_own on public.haixing_events for select to authenticated using ((select auth.uid())=user_id);
revoke all on public.haixing_events from anon,authenticated;
grant select on public.haixing_events to authenticated;
create or replace function public.haixing_push_events(batch jsonb) returns void
language plpgsql security definer set search_path='' as $$
declare uid uuid:=auth.uid(); item jsonb;
begin
 if uid is null then raise exception 'Authentication required'; end if;
 if jsonb_typeof(batch)<>'array' or jsonb_array_length(batch)>100 then raise exception 'Invalid batch'; end if;
 -- Serialize inserts per account so committed incremental cursors cannot skip events.
 perform pg_advisory_xact_lock(hashtextextended(uid::text,0));
 for item in select * from jsonb_array_elements(batch) loop
  if (item->'payload'->>'store') not in ('records','settings','sessions','history')
     or (item->'payload'->>'store') is null
     or (item->'payload'->>'key') is null
     or octet_length(item::text)>524288 then raise exception 'Invalid learning event'; end if;
  insert into public.haixing_events(user_id,event_id,device,clock,payload)
   values(uid,(item->>'id')::uuid,(item->>'device')::uuid,(item->>'clock')::bigint,item->'payload')
   on conflict(user_id,event_id) do nothing;
 end loop;
end; $$;
revoke all on function public.haixing_push_events(jsonb) from public,anon;
grant execute on function public.haixing_push_events(jsonb) to authenticated;
do $$ begin
 if not exists(select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='haixing_events') then
  alter publication supabase_realtime add table public.haixing_events;
 end if;
end $$;
commit;
