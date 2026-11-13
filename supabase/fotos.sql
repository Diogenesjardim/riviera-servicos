-- Riviera Serviços: fotos dos trabalhos (publicadas pelo painel da empresa)
-- Cole tudo no Supabase em: SQL Editor -> New query -> Run

-- 1) Lista de fotos (todo mundo vê; só administradores publicam e apagam)
create table if not exists public.fotos (
  id        uuid primary key default gen_random_uuid(),
  criado_em timestamptz not null default now(),
  cat       text not null check (char_length(cat) between 2 and 40),
  legenda   text not null default '' check (char_length(legenda) <= 120),
  caminho   text not null unique check (caminho ~ '^[a-z0-9_-]+/[a-z0-9_-]+[.](jpg|jpeg|png|webp)$')
);
alter table public.fotos enable row level security;
revoke all on public.fotos from anon, authenticated;
grant select on public.fotos to anon, authenticated;
grant insert (cat, legenda, caminho), delete on public.fotos to authenticated;

drop policy if exists "todos veem fotos" on public.fotos;
create policy "todos veem fotos" on public.fotos for select to anon, authenticated using (true);
drop policy if exists "admin publica fotos" on public.fotos;
create policy "admin publica fotos" on public.fotos for insert to authenticated with check (public.is_admin());
drop policy if exists "admin apaga fotos" on public.fotos;
create policy "admin apaga fotos" on public.fotos for delete to authenticated using (public.is_admin());

-- 2) Pasta pública de imagens (até 5 MB por foto)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('fotos', 'fotos', true, 5242880, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update set public = true, file_size_limit = excluded.file_size_limit, allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "admin envia arquivo de foto" on storage.objects;
create policy "admin envia arquivo de foto" on storage.objects for insert to authenticated
  with check (bucket_id = 'fotos' and public.is_admin());
drop policy if exists "admin ve arquivo de foto" on storage.objects;
create policy "admin ve arquivo de foto" on storage.objects for select to authenticated
  using (bucket_id = 'fotos' and public.is_admin());
drop policy if exists "admin apaga arquivo de foto" on storage.objects;
create policy "admin apaga arquivo de foto" on storage.objects for delete to authenticated
  using (bucket_id = 'fotos' and public.is_admin());
