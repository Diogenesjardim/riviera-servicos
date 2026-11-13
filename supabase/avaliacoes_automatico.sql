-- Riviera Serviços: avaliações publicadas automaticamente, com filtro de palavrões
-- Cole tudo no Supabase em: SQL Editor -> New query -> Run

-- 1) Filtro: se tiver palavrão ou link, a avaliação fica escondida (aprovado = false)
--    para vocês olharem. O resto aparece no site na hora.
create or replace function public.avaliacao_moderar()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  t text;
begin
  t := translate(lower(coalesce(new.nome, '') || ' ' || coalesce(new.comentario, '')),
                 'áàâãäéèêëíìîïóòôõöúùûüç',
                 'aaaaaeeeeiiiiooooouuuuc');
  new.aprovado := not (t ~ '(\m(porra|caralho|merda|bosta|puta|puto|putaria|fdp|pqp|vsf|vtnc|cu|cuzao|viado|arrombad\w*|desgraca\w*|otari\w*|idiota\w*|imbecil\w*|babaca\w*|vagabund\w*|safad\w*|ladr(ao|oes|a|as)|golpista\w*|corno\w*)\M|https?://|www\.)');
  return new;
end;
$$;

drop trigger if exists avaliacao_moderar on public.avaliacoes;
create trigger avaliacao_moderar
  before insert on public.avaliacoes
  for each row execute function public.avaliacao_moderar();

-- 2) Novas avaliações entram publicadas (o filtro acima decide)
alter table public.avaliacoes alter column aprovado set default true;

-- 3) O site pode enviar avaliações; quem decide "aprovado" é só o filtro
--    (o site não tem permissão de mexer nessa coluna)
drop policy if exists "enviar avaliacao" on public.avaliacoes;
create policy "enviar avaliacao" on public.avaliacoes
  for insert to anon, authenticated
  with check (true);
