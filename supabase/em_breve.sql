-- Riviera Serviços: "Quero ser avisado" e sugestões (Comprar / Alugar em breve)
-- Cole tudo no Supabase em: SQL Editor -> New query -> Run

create table if not exists public.interessados (
  id         uuid primary key default gen_random_uuid(),
  criado_em  timestamptz not null default now(),
  nome       text not null check (char_length(btrim(nome)) between 2 and 60),
  casa       text not null check (char_length(btrim(casa)) between 2 and 40),
  whatsapp   text not null default '' check (whatsapp ~ '^[0-9]{0,11}$'),
  interesse  text not null check (interesse in ('compras', 'aluguel'))
);

create table if not exists public.sugestoes (
  id         uuid primary key default gen_random_uuid(),
  criado_em  timestamptz not null default now(),
  tipo       text not null check (tipo in ('compras', 'aluguel')),
  item       text not null check (char_length(btrim(item)) between 2 and 80),
  motivo     text not null default '' check (char_length(motivo) <= 300),
  nome       text not null default '' check (char_length(nome) <= 60)
);

-- Segurança: o site só consegue ENVIAR. Ninguém de fora consegue ler, editar ou apagar.
-- Vocês veem tudo no painel do Supabase (Table Editor).
alter table public.interessados enable row level security;
alter table public.sugestoes enable row level security;

drop policy if exists "enviar interesse" on public.interessados;
create policy "enviar interesse" on public.interessados
  for insert to anon, authenticated
  with check (interesse in ('compras', 'aluguel'));

drop policy if exists "enviar sugestao" on public.sugestoes;
create policy "enviar sugestao" on public.sugestoes
  for insert to anon, authenticated
  with check (tipo in ('compras', 'aluguel'));

revoke all on public.interessados from anon, authenticated;
revoke all on public.sugestoes from anon, authenticated;
grant insert (nome, casa, whatsapp, interesse) on public.interessados to anon, authenticated;
grant insert (tipo, item, motivo, nome) on public.sugestoes to anon, authenticated;
