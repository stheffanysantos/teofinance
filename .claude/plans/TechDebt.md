# Dívida Técnica — Registro

> Nenhum item implementado ainda (projeto em bootstrap) — este arquivo existe para registrar dívida assim que ela for aceita conscientemente, nunca descoberta tarde demais. Todo item aqui deve citar o motivo de ter sido aceito, não só "fazer depois".

## Riscos conhecidos antecipados pela especificação (seção 10), a monitorar desde já
- **Importação de CSV/OFX por banco**: não existe padrão único entre bancos brasileiros. Risco aceito: o mapeamento de colunas é responsabilidade do usuário na primeira importação de cada banco; se o banco mudar o layout do export, o perfil salvo quebra — o app deve detectar e avisar, nunca importar errado silenciosamente (ver `.claude/rules/architecture.md`).
- **Gemma on-device (Fase 4)**: modelos quantizados (2B-4B) rodam melhor em aparelhos mais novos; desempenho em dispositivos de entrada precisa ser validado antes de assumir viabilidade universal. Tamanho do modelo deve ser baixado sob demanda, não embutido no instalador.
- **Custo Firestore**: camada gratuita (Spark) suficiente no início, mas cobra por leitura/escrita/armazenamento acima do limite — o modelo de dados precisa ser desenhado desde o início para minimizar leituras desnecessárias (ex.: dashboard não deve reler o histórico inteiro de transações a cada abertura).
- **Monetização indefinida** (decisão 0005, em aberto): nenhuma estrutura de assinatura/paywall deve ser antecipada no código antes dessa decisão ser tomada.

## Quando um item entra aqui de verdade
Assim que o projeto tiver código real, qualquer atalho consciente (ex.: "pular paginação no dashboard por enquanto", "adiar teste de regra do Firestore para uma coleção nova") deve ser registrado aqui com: o que foi deixado, por que, e o gatilho que deve disparar a correção (ex.: "corrigir antes de abrir a Fase 2").
