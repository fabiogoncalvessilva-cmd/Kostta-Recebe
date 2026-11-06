# Kostta Loja

Aplicativo web (PWA) de operação de loja do Mercado Kostta, com dois módulos sobre a mesma Grade do ERP:

- **Recebe** — conferência de recebimento: lê o XML da NF-e, cruza com a Grade e indica, por item, cadastro, margem, variação de custo e ação necessária.
- **Modo Blecaute** — venda sem energia: lê o código de barras do produto, monta a lista com quantidades, fecha vendas e gera o relatório do período.

- **Repositório:** https://github.com/fabiogoncalvessilva-cmd/Kostta-Recebe
- **Aplicativo (GitHub Pages):** https://fabiogoncalvessilva-cmd.github.io/Kostta-Recebe/
- **Versão:** 2026.11.06 (mostrada em Ajustes) · arquivo único `index.html`, sem servidor, dados só no aparelho

## 1. Fluxo de uso

1. **Grade** (computador): aba *Grade* > Carregar Grade (relatório do ERP). No celular hospedado, o mesmo botão aparece na aba *Grade*.
2. **Chave** (opcional): *Tirar foto da chave* / *Foto da galeria*. A leitura é automática e tenta, nesta ordem, código de barras, QR Code e os 44 números impressos (OCR, baixa uma biblioteca na primeira vez). Também aceita colar os 44 dígitos. A chave é validada e copiada.
3. **XML**: *Abrir Meu DANFE* (manual), baixar o XML, depois *Buscar XML* (dispositivo ou Drive).
4. **Conferir** cada item (cartões ou lista resumida), marcar *Preço ajustado*, compartilhar a lista ou exportar o CSV.

## 2. Regras de negócio

**Cruzamento com a Grade**
- EAN da unidade (`cEANTrib`), depois `cEAN`. EAN-14 (DUN-14) gera o EAN da unidade pelo dígito verificador.
- Sem correspondência: busca manual na Grade por código ou nome, com associação salva por EAN.

**Custo unitário** = (`vProd` + ICMS-ST + IPI) ÷ quantidade tributável. *Somar ICMS-ST e IPI* é parâmetro.
- Unidade de embalagem (Fd, Cx, Display etc.): divide pelas unidades por embalagem, na ordem: valor salvo (manual) > fator da descrição ("x 30", "C/12", "12x500g") > sugestão pelo custo do ERP (exige confirmação) > informar manualmente.
- Unidade em KG: custo por kg × peso por unidade da descrição ("170g"). Item vendido por kg (Grade com "KG", ou peso = caixa) fica em custo por kg. Peso editável (`56`, `56g`, `0,056kg`; `0` = por kg).
- Perfil por fornecedor (CNPJ): Automático, Embalagem ou Unidade. Valores aprendidos são salvos por fornecedor + EAN.

**Margem e preço**
- Lucro sobre a venda = 1 − custo ÷ preço (igual ao "Lucro sobre a venda" do ERP). Markup atual = preço ÷ custo − 1.
- Faixa esperada padrão: **37,5% a 40,5%** (equivale a markup de 60% e margem líquida de 30% a 33% com 7,5 pontos de deduções).
- Preço sugerido = custo × (1 + markup), com arredondamento opcional (final ,90).

**Status do item**

| Status | Condição | Ação |
|---|---|---|
| Cadastrar Item | Não está na Grade | Cadastrar no ERP |
| Informar embalagem | Unidade de embalagem sem fator | Informar unidades por embalagem |
| Ajustar | Lucro abaixo da faixa | Ajustar o preço para o sugerido |
| Atenção | Lucro acima da faixa | Verificar o preço |
| Liberado | Dentro da faixa | Liberar para venda |

**Variação de custo vs ERP:** custo da nota ÷ custo com encargos da Grade. Acima de 1% (parâmetro): subiu ou caiu. Acima de 40%: aviso para conferir unidades. Item com marca "OF" na Grade: aviso de oferta.

**Chave da nota:** confere a chave informada com o XML carregado e avisa se a nota já foi carregada antes (neste aparelho).

## 3. Telas

| Aba | Conteúdo |
|---|---|
| Vendas | Modo Blecaute (ver seção 4) |
| Conferir | Chave, XML, resumo, visualização completa/resumida, filtros (inclui *Custo alterado*), compartilhar lista, exportar CSV, limpar nota |
| Grade | Produtos, data, origem, idade (alerta após 7 dias), margem da Grade (% dentro/abaixo/acima) com histórico de cargas; carregar Grade e salvar página com a Grade (computador) |
| Ajustes | Parâmetros, exemplo com dados fictícios, instalação do app |

A lista resumida mostra código interno, descrição e status. O texto compartilhado é agrupado por status e inclui a seção de custo alterado.

## 4. Modo Blecaute (venda sem energia)

Objetivo: registrar vendas no celular quando o caixa está fora do ar, usando a mesma Grade.

1. **Ler código do produto** (câmera ou galeria): EAN-13, EAN-8, UPC, Code 128, Code 39 e ITF. Ou digitar o código de barras ou o código interno; o campo aceita apenas números e abre o teclado numérico.
2. Cada item entra com **quantidade 1**, editável (aceita fração, ex.: `2,5` para granel). Ler o mesmo produto de novo soma a quantidade e o traz para o topo.
3. **Caixa de seleção** por item: só os marcados entram no total. O **✕** remove o item.
4. **Totalizador**: produtos, itens e total em destaque.
5. **Fechar venda**: grava a venda no período e limpa os itens marcados (os desmarcados ficam na lista). **Compartilhar** e **Exportar CSV** valem para a lista atual; **Zerar lista** limpa tudo.

**Fechamento do período** (bloco abaixo da lista):
- Cartão com vendas, itens, **total vendido**, produtos distintos, ticket médio e período.
- Detalhes: vendas uma a uma (hora, produtos, valor, com ✕ para excluir) e produtos vendidos consolidados.
- **Resumo do período**: texto curto para WhatsApp com vendas, itens, produtos distintos, ticket médio, maior venda, **total vendido** e os 5 mais vendidos — é o que se usa para confrontar com o caixa.
- **Relatório detalhado**: as vendas uma a uma e todos os produtos consolidados.
- **Exportar CSV**: uma linha por item, com o número da venda e a linha de total (`Kostta_blecaute_AAAAMMDD_HHMM.csv`).
- **Encerrar período**: apaga as vendas fechadas, com confirmação. Compartilhe ou exporte antes.

Preço usado: `P.VENDA` da Grade. A lista e as vendas fechadas ficam guardadas no aparelho e sobrevivem a fechar o app ou ficar sem bateria.

## 5. Dados

**Grade (entrada):** relatório do ERP em texto com tabulação (`grade_DDMM.xls`) ou CSV. Colunas usadas: `CODIGO`, `DESCRICAO DO PRODUTO`, `P.VENDA`, `*C/ENC.` (ou `C.COMP`), `COD. BARRA` (8+ dígitos) e a coluna sem nome com "OF" (oferta). O cabeçalho é localizado sozinho.

**Guardado no aparelho** (navegador): Grade, parâmetros, embalagens e pesos por fornecedor, associações EAN > código, perfis de fornecedor, histórico de cargas, chaves já carregadas.

**Exportação (CSV, 29 colunas, `;`, UTF-8):** data, NF, fornecedor, código interno, EANs, descrição, custos, variação, preço, markup, lucro, faixa, preço sugerido, status, preço ajustado, oferta, `chave_linha`, `chave_nfe`. Nome: `Kostta_conferencia_AAAAMMDD_HHMM.csv`.

## 6. Histórico e indicadores (Excel)

- `Kostta_Historico.xlsx`: painel com margem da Grade por data, preços e custos que subiram/caíram entre Grades, conferências por status e mês, ajustes confirmados (preço mudou na Grade seguinte) e itens recorrentes.
- `consultas_power_query.txt`: 6 consultas (Conferencias, GradeHistorico, GradeResumo, PrecoMudancas, AjustesConfirmados, Recorrencia). Leem a pasta de CSVs exportados e a pasta de Grades (`grade_DDMM.xls`).
- Parâmetros da planilha: pastas, faixa de lucro, tolerância de custo (aba *Parametros*, tabela `tblParam`).

## 7. Implantação e atualização

- **Arquivos** (mesma pasta): `index.html`, `manifest.webmanifest`, `sw.js`, `icon-192.png`, `icon-512.png`, `icon-512-maskable.png`, `apple-touch-icon.png`.
- **Hospedagem:** GitHub Pages (repositório público, branch `main`, raiz). O repositório não contém Grade, custos nem preços.
- **Atualizar:** substituir `index.html` (e `sw.js`, se mudar) no repositório. O app pega a versão nova ao abrir com internet; se necessário, abrir duas vezes. Se continuar antigo, usar **Ajustes > Buscar atualização** (limpa o cache e o service worker, sem apagar Grade, embalagens ou vendas). A versão instalada aparece em Ajustes.
- **Instalar (Android/Chrome):** abrir o endereço github.io, menu ⋮ > Adicionar à tela inicial > **Instalar** (a opção "Criar atalho" não instala o app). iPhone (Safari): Compartilhar > Adicionar à Tela de Início.
- **Alternativa sem hospedagem:** *Salvar página com a Grade* gera um HTML com a Grade e as configurações embutidas, para abrir no Chrome do celular (não pela visualização do Drive). **Contém custos e preços: manter privado.**

## 8. Limitações conhecidas

- Dados e memórias ficam por aparelho e navegador; não há compartilhamento entre colaboradores.
- O download do XML no Meu DANFE é manual (o site usa verificação anti-robô). O destino do download é configuração do navegador.
- Leitura por foto: exige imagem nítida e pouco inclinada; na primeira vez baixa uma biblioteca (internet).
- Não há conferência de NCM, CEST ou CST (a Grade exportada não traz esses campos).
- Variação de custo compara com o custo com encargos do ERP, que pode incluir frete ou outras despesas.
- Modo Blecaute não emite documento fiscal nem baixa estoque: é um registro para conferir o caixa e lançar no ERP depois.
- As vendas ficam no aparelho em que foram feitas; com vários celulares, cada um gera o seu relatório.
- Próxima evolução prevista: base compartilhada (Grade e histórico) para vários colaboradores.
