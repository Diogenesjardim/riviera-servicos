# Riviera Serviços

Site de serviços residenciais, compras rápidas e aluguel de equipamentos para os moradores do condomínio Riviera de Santa Cristina III.

**Site no ar:** https://diogenesjardim.github.io/riviera-servicos/

## Como funciona
- Página única (`index.html`), sem servidor nem banco de dados.
- Os pedidos são enviados pelo WhatsApp: (11) 96735-3508 ou (11) 95852-9823.
- Área da empresa, acompanhamento e sugestões ficam salvos no navegador de quem usa (versão de teste).
- **Avaliações públicas:** ficam no Supabase quando `SB_URL` e `SB_KEY` estão preenchidos no `index.html`. Script do banco em `supabase/avaliacoes.sql`. Para aprovar: Supabase → Table Editor → `avaliacoes` → marcar `aprovado`.
- Preços de compras e aluguel são de exemplo.

## Como alterar
- Números de WhatsApp: procure `WA_NUMBERS` no `index.html`.
- Produtos das compras rápidas: procure `const SHOP = [`.
- Equipamentos para alugar: procure `const RENT = [`.
- Categorias de serviços: procure `const CATS = [`.
