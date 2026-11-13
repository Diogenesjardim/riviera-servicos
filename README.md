# Riviera Serviços

Site de serviços residenciais, compras rápidas e aluguel de equipamentos para os moradores do condomínio Riviera de Santa Cristina III.

**Site no ar:** https://diogenesjardim.github.io/riviera-servicos/

## Como funciona
- Página única (`index.html`), sem servidor nem banco de dados.
- Os pedidos são enviados pelo WhatsApp: (11) 96735-3508 ou (11) 95852-9823.
- Comprar e Alugar estão como **em breve**: "Quero ser avisado" e sugestões vão para o Supabase (tabelas `interessados` e `sugestoes`, script em `supabase/em_breve.sql`).
- Área da empresa e acompanhamento de pedido estão escondidos até a próxima versão (pedidos no Supabase + login).
- **Avaliações públicas:** ficam no Supabase (`supabase/avaliacoes.sql` + `supabase/avaliacoes_automatico.sql`). Publicam na hora; com palavrão ou link ficam escondidas (`aprovado = false`) para conferência no Table Editor.
- Preços de compras e aluguel são de exemplo.

## Como alterar
- Números de WhatsApp: procure `WA_NUMBERS` no `index.html`.
- Produtos das compras rápidas: procure `const SHOP = [`.
- Equipamentos para alugar: procure `const RENT = [`.
- Categorias de serviços: procure `const CATS = [`.
