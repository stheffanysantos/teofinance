# Glossário de Domínio — TeoFinance

> Termos de negócio do app de finanças pessoais. Evita ambiguidade de nomenclatura entre código, documentação e conversas. Todo termo novo é adicionado aqui no momento em que a feature correspondente é criada.

| Termo | Significado |
|---|---|
| **Transação** | Lançamento financeiro individual (receita ou despesa), vindo de importação de extrato ou cadastro manual. Campos centrais: data, descrição, valor, categoria, conta/perfil de banco de origem. |
| **Perfil de Banco** | Mapeamento salvo de colunas (Data, Descrição, Valor, Categoria) para um banco específico (ex.: Nubank, Itaú, C6), reaproveitado nas importações seguintes do mesmo banco. Um usuário pode ter múltiplos perfis salvos. |
| **Importação** | Processo de ler um arquivo de extrato (CSV ou OFX) exportado manualmente pelo usuário, aplicar um Perfil de Banco (detectando separador/encoding automaticamente na primeira vez) e gerar Transações. Inteiramente local ao dispositivo — nenhuma integração bancária automática. |
| **Categoria** | Classificação de uma Transação (ex.: Alimentação, Transporte, Lazer). Atribuída por regra automática, aprendizado local, ou correção manual do usuário. |
| **Renda Fixa** | Receita recorrente com data e periodicidade definidas (ex.: salário, aluguel recebido). |
| **Renda Variável** | Receita sem recorrência fixa (ex.: freelas, vendas pontuais). |
| **Orçamento (modo envelope)** | Limite de gasto definido por Categoria em um período (geralmente mensal), com alerta ao se aproximar do teto. |
| **Meta de Investimento** | Objetivo financeiro com valor-alvo, prazo e aporte mensal sugerido (ex.: "reserva de emergência", "viagem"), com acompanhamento visual de progresso. |
| **Desafio** | Compromisso comportamental de prazo definido (ex.: "não gastar com delivery por 15 dias"), customizado pelo usuário ou sugerido pelo app com base no padrão de gastos. Recompensas são sempre simbólicas (badges/pontuação), nunca dinheiro real. |
| **Carteira Simulada** | Conjunto de posições de investimento "de mentirinha" (dinheiro fictício) que o usuário gerencia para aprender antes de investir de verdade, com desempenho calculado a partir de dados de mercado reais. |
| **Trilha de Aprendizado** | Sequência de módulos educacionais por nível (iniciante → avançado), com quizzes ao final de cada módulo. |
| **Score Financeiro** | Pontuação própria do app (não é score de crédito oficial) calculada a partir de hábitos financeiros do usuário (streaks, metas cumpridas, orçamento respeitado). |
| **Streak** | Contador de dias seguidos dentro do orçamento definido — mecanismo central de gamificação comportamental. |
| **Modo Discreto** | Modo de privacidade visual: oculta valores monetários na tela com um toque, para uso em público. Disponível no app nativo e, se existir, no PWA. |
| **Assistente Local (Gemma)** | Assistente conversacional rodando on-device via MediaPipe, que responde perguntas em linguagem natural sobre os dados financeiros já sincronizados do Firestore, sem enviar o conteúdo da pergunta a um servidor de inferência externo. |
| **Insight** | Observação automática gerada a partir do padrão de gastos (ex.: "seus gastos com delivery aumentaram 30% este mês"), gerada localmente pelo Assistente ou por regras determinísticas mais simples (sem IA) no MVP. |
| **Gasto Recorrente / Assinatura** | Padrão de transações semelhantes detectado em intervalos regulares (ex.: "5 assinaturas de streaming, R$120/mês"). |
| **SyncStatus** | Estado de uma entidade sincronizável entre o cache local (Drift) e o Firestore: `pendingCreate` (criada localmente, ainda não confirmada), `pendingUpdate` (alterada localmente após já existir no Firestore), `synced` (em paridade). Mesmo conceito usado em outros apps do portfólio pessoal do autor, adaptado aqui ao domínio financeiro. |
| **Patrimônio Líquido** | Ativos menos dívidas, calculado e exibido como gráfico ao longo do tempo no dashboard. |
| **LGPD / Exportação e Exclusão** | Direito do usuário de exportar e apagar todos os seus dados do Firebase mediante solicitação, conforme a Lei Geral de Proteção de Dados. |
