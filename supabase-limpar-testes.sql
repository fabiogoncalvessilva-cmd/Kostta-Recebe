-- Kostta Loja · apagar os lançamentos de teste da nuvem
-- Use ANTES de começar a operação real. Apaga pedidos, conferências e histórico.
-- NÃO apaga a Grade, as embalagens, as associações nem os usuários.
--
-- Onde rodar: painel do Supabase > SQL Editor > New query > colar > Run
-- Se aparecer "Potential issue detected", confirme em Run query.
-- Atenção: isto não tem volta. Rode só quando quiser zerar mesmo.

delete from public.pedidos;
delete from public.entregas;
delete from public.conferencias;

-- Se também quiser apagar as vendas do Modo Blecaute feitas em teste,
-- tire os dois tracinhos da linha abaixo antes de rodar:
-- delete from public.vendas;

-- Conferir o que sobrou:
select 'pedidos' as tabela, count(*) from public.pedidos
union all select 'entregas', count(*) from public.entregas
union all select 'conferencias', count(*) from public.conferencias
union all select 'vendas', count(*) from public.vendas;
