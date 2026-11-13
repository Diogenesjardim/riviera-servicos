# Riviera Serviços

Site de serviços residenciais, compras rápidas e aluguel de equipamentos para os moradores do condomínio Riviera de Santa Cristina III.

**Site no ar:** https://diogenesjardim.github.io/riviera-servicos/

## Como funciona
- Página única (`index.html`), sem servidor nem banco de dados.
- Os pedidos são enviados pelo WhatsApp: (11) 96735-3508 ou (11) 95852-9823.
- Comprar e Alugar estão como **em breve**: "Quero ser avisado" e sugestões vão para o Supabase (tabelas `interessados` e `sugestoes`, script em `supabase/em_breve.sql`).
- **Pedidos** ficam no Supabase (`supabase/pedidos.sql`) e chegam também pelo WhatsApp. A confirmação fica vermelha até o morador tocar em Enviar no WhatsApp.
- **Fotos dos trabalhos:** publicadas pela aba 📷 Fotos do painel (Supabase Storage, `supabase/fotos.sql`). Sem fotos, o site mostra as ilustrações.
- **Área da empresa:** link "🔒 Área da empresa" no rodapé (ou `#empresa`). Login com e-mail e senha criados no Supabase (Authentication → Users); só e-mails da tabela `admins` entram.
- **Avaliações públicas:** ficam no Supabase (`supabase/avaliacoes.sql` + `supabase/avaliacoes_automatico.sql`). Publicam na hora; com palavrão ou link ficam escondidas (`aprovado = false`) para conferência no Table Editor.
- Preços de compras e aluguel são de exemplo.

## Como alterar
- Números de WhatsApp: procure `WA_NUMBERS` no `index.html`.
- Produtos das compras rápidas: procure `const SHOP = [`.
- Equipamentos para alugar: procure `const RENT = [`.
- Categorias de serviços: procure `const CATS = [`.
