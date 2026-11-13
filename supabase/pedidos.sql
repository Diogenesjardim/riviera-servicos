-- Riviera Serviços: pedidos salvos no banco + área da empresa com login
-- ANTES de rodar: crie o(s) usuário(s) da empresa em Authentication -> Users -> Add user.
-- Depois cole tudo no Supabase em: SQL Editor -> New query -> Run

-- 1) Tabela de pedidos (número RS-1001, RS-1002...)
create sequence if not exists public.pedido_seq start 1001;

create table if not exists public.pedidos (
  id               text primary key,
  criado_em        timestamptz not null default now(),
  atualizado_em    timestamptz not null default now(),
  nome             text not null check (char_length(btrim(nome)) between 2 and 80),
  tel              text not null check (tel ~ '^[0-9]{10,11}$'),
  cat              text not null check (char_length(cat) between 2 and 40),
  sub              text not null check (char_length(sub) between 2 and 80),
  quando           text not null check (char_length(quando) between 2 and 60),
  setor            text not null default '' check (char_length(setor) <= 120),
  descricao        text not null check (char_length(btrim(descricao)) between 3 and 1500),
  status           text not null default 'novo' check (status in ('novo', 'orcamento', 'agendado', 'concluido')),
  valor            numeric(10,2) check (valor is null or valor > 0),
  agenda_data      date,
  agenda_hora      text check (agenda_hora is null or agenda_hora ~ '^[0-2][0-9]:[0-5][0-9]$'),
  enviado_whatsapp boolean not null default false
);
create index if not exists pedidos_criado_em_idx on public.pedidos (criado_em desc);

-- 2) Quem é da empresa (lista de e-mails)
create table if not exists public.admins (email text primary key);
alter table public.admins enable row level security;
revoke all on public.admins from anon, authenticated;

create or replace function public.is_admin()
returns boolean
language sql stable security definer
set search_path = ''
as $$
  select exists (select 1 from public.admins a where a.email = lower(coalesce(auth.jwt() ->> 'email', '')));
$$;

-- 3) Morador cria o pedido (sem conseguir ler nem mexer em nada)
create or replace function public.criar_pedido(p_nome text, p_tel text, p_cat text, p_sub text, p_quando text, p_setor text, p_desc text)
returns text
language plpgsql security definer
set search_path = ''
as $$
declare
  novo text;
begin
  novo := 'RS-' || nextval('public.pedido_seq');
  insert into public.pedidos (id, nome, tel, cat, sub, quando, setor, descricao)
  values (novo, btrim(p_nome), regexp_replace(coalesce(p_tel, ''), '[^0-9]', '', 'g'), p_cat, p_sub, p_quando, coalesce(btrim(p_setor), ''), btrim(p_desc));
  return novo;
end;
$$;

-- Morador tocou em "Enviar no WhatsApp" (só marca, nunca desmarca; só pedidos das últimas 24h)
create or replace function public.marcar_enviado(p_id text)
returns void
language sql security definer
set search_path = ''
as $$
  update public.pedidos set enviado_whatsapp = true
  where id = p_id and criado_em > now() - interval '1 day';
$$;

-- 4) Segurança
alter table public.pedidos enable row level security;
revoke all on public.pedidos from anon, authenticated;
revoke all on function public.criar_pedido(text, text, text, text, text, text, text) from public;
revoke all on function public.marcar_enviado(text) from public;
revoke all on function public.is_admin() from public;
grant execute on function public.criar_pedido(text, text, text, text, text, text, text) to anon, authenticated;
grant execute on function public.marcar_enviado(text) to anon, authenticated;
grant execute on function public.is_admin() to authenticated;

-- Só quem está na lista de admins vê, edita e apaga pedidos
grant select, update, delete on public.pedidos to authenticated;
drop policy if exists "admin ve pedidos" on public.pedidos;
create policy "admin ve pedidos" on public.pedidos for select to authenticated using (public.is_admin());
drop policy if exists "admin edita pedidos" on public.pedidos;
create policy "admin edita pedidos" on public.pedidos for update to authenticated using (public.is_admin()) with check (public.is_admin());
drop policy if exists "admin apaga pedidos" on public.pedidos;
create policy "admin apaga pedidos" on public.pedidos for delete to authenticated using (public.is_admin());

-- 5) Torna administradores TODOS os usuários já criados em Authentication -> Users.
--    (Para colocar alguém novo depois: crie o usuário e rode só esta linha de novo.)
insert into public.admins (email) select lower(email) from auth.users where email is not null on conflict do nothing;
