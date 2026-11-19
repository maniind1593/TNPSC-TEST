create extension if not exists pgcrypto with schema extensions;

create table if not exists public.quiz_players (
  id uuid primary key default gen_random_uuid(),
  test_code text not null,
  player_name text not null,
  token_hash text not null,
  answers jsonb,
  score integer,
  submitted_at timestamptz,
  created_at timestamptz not null default now()
);
create index if not exists quiz_players_test_code_idx on public.quiz_players(test_code);
alter table public.quiz_players enable row level security;
revoke all on public.quiz_players from anon, authenticated;

create or replace function public.quiz_join(p_test_code text, p_name text)
returns jsonb language plpgsql security definer set search_path=public, extensions as $$
declare v_count integer; v_id uuid; v_token text;
begin
  if length(trim(coalesce(p_test_code,''))) < 3 or length(trim(coalesce(p_name,''))) < 1 then
    raise exception 'Test Code மற்றும் பெயர் சரிபார்க்கவும்.';
  end if;
  if length(p_name)>40 then raise exception 'பெயர் 40 எழுத்துகளுக்குள் இருக்க வேண்டும்.'; end if;
  perform pg_advisory_xact_lock(hashtext(upper(trim(p_test_code))));
  select count(*) into v_count from public.quiz_players where test_code=upper(trim(p_test_code));
  if v_count >= 2 then raise exception 'இந்த Test Code-ல் இரண்டு பேர் ஏற்கனவே சேர்ந்துவிட்டனர்.'; end if;
  v_token := encode(gen_random_bytes(24),'hex');
  insert into public.quiz_players(test_code,player_name,token_hash)
  values(upper(trim(p_test_code)),trim(p_name),encode(digest(v_token,'sha256'),'hex'))
  returning id into v_id;
  return jsonb_build_object('participant_id',v_id,'token',v_token);
end $$;

create or replace function public.quiz_submit(p_test_code text,p_participant_id uuid,p_token text,p_answers jsonb)
returns jsonb language plpgsql security definer set search_path=public, extensions as $$
declare v_row public.quiz_players%rowtype; v_key integer[] := array[1,1,1,1,0,1,1,1,1,2]; v_score integer:=0; i integer;
begin
  select * into v_row from public.quiz_players
  where id=p_participant_id and test_code=upper(trim(p_test_code))
  and token_hash=encode(digest(p_token,'sha256'),'hex') for update;
  if not found then raise exception 'Participant verification failed.'; end if;
  if v_row.submitted_at is not null then raise exception 'நீங்கள் ஏற்கனவே Submit செய்துவிட்டீர்கள்.'; end if;
  if jsonb_typeof(p_answers)<>'array' or jsonb_array_length(p_answers)<>10 then raise exception '10 பதில்கள் தேவை.'; end if;
  for i in 0..9 loop
    if (p_answers->>i)::integer not between 0 and 3 then raise exception 'ஒவ்வொரு கேள்விக்கும் A-D பதில் தேவை.'; end if;
    if (p_answers->>i)::integer=v_key[i+1] then v_score:=v_score+1; end if;
  end loop;
  update public.quiz_players set answers=p_answers,score=v_score,submitted_at=now() where id=p_participant_id;
  return jsonb_build_object('submitted',true);
end $$;

create or replace function public.quiz_status(p_test_code text)
returns jsonb language plpgsql security definer set search_path=public as $$
declare v_count integer; v_submitted integer; v_players jsonb;
begin
  select count(*),count(*) filter(where submitted_at is not null)
  into v_count,v_submitted from public.quiz_players where test_code=upper(trim(p_test_code));
  if v_count<2 or v_submitted<2 then
    return jsonb_build_object('released',false,'submitted_count',v_submitted);
  end if;
  select jsonb_agg(jsonb_build_object(
    'name',player_name,'score',score,
    'answers',(select jsonb_agg(jsonb_build_object('selected',(answers->>g)::integer,'correct',((answers->>g)::integer = (array[1,1,1,1,0,1,1,1,1,2])[g+1])) order by g from generate_series(0,9) g)
  ) order by created_at)
  into v_players from public.quiz_players where test_code=upper(trim(p_test_code));
  return jsonb_build_object('released',true,'submitted_count',2,'players',v_players);
end $$;

revoke all on function public.quiz_join(text,text) from public;
revoke all on function public.quiz_submit(text,uuid,text,jsonb) from public;
revoke all on function public.quiz_status(text) from public;
grant execute on function public.quiz_join(text,text) to anon, authenticated;
grant execute on function public.quiz_submit(text,uuid,text,jsonb) to anon, authenticated;
grant execute on function public.quiz_status(text) to anon, authenticated;
