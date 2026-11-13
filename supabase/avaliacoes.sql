-- Riviera Serviços: avaliações públicas
-- Cole tudo no Supabase em: SQL Editor -> New query -> Run

create table if not exists public.avaliacoes (
  id          uuid primary key default gen_random_uuid(),
  criado_em   timestamptz not null default now(),
  nome        text not null check (char_length(btrim(nome)) between 2 and 40),
  servico     text not null check (char_length(servico) between 2 and 80),
  nota        smallint not null check (nota between 1 and 5),
  comentario  text not null default '' check (char_length(comentario) <= 600),
  pedido      text not null default '' check (char_length(pedido) <= 20),
  aprovado    boolean not null default false
);

-- Segurança: o site só consegue LER avaliações aprovadas e ENVIAR novas (sempre como não aprovadas).
-- Ninguém de fora consegue editar, apagar ou aprovar. A aprovação é feita por vocês no painel do Supabase.
alter table public.avaliacoes enable row level security;

drop policy if exists "ler aprovadas" on public.avaliacoes;
create policy "ler aprovadas" on public.avaliacoes
  for select to anon, authenticated
  using (aprovado = true);

drop policy if exists "enviar avaliacao" on public.avaliacoes;
create policy "enviar avaliacao" on public.avaliacoes
  for insert to anon, authenticated
  with check (aprovado = false);

-- Permissões por coluna: o site não vê o nº do pedido e não consegue mexer em "aprovado".
revoke all on public.avaliacoes from anon, authenticated;
grant select (id, criado_em, nome, servico, nota, comentario) on public.avaliacoes to anon, authenticated;
grant insert (nome, servico, nota, comentario, pedido) on public.avaliacoes to anon, authenticated;

-- Novas avaliações aparecem primeiro no painel
create index if not exists avaliacoes_criado_em_idx on public.avaliacoes (criado_em desc);
