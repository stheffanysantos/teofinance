# Stack Técnica — Por Que Cada Peça Foi Escolhida

> Ver `.claude/memory/decisions.md` para o registro formal (ADR) das decisões mais debatidas. Este arquivo é o resumo de referência rápida, derivado de "App de Finanças Pessoais - Especificação e Arquitetura.md".

| Camada | Escolha | Por quê | Alternativa descartada e motivo |
|---|---|---|---|
| Frontend | **Flutter + Dart** | App nativo único para Android e iOS, um único código-fonte | React Native — ecossistema de IA local on-device (MediaPipe) tem melhor suporte Flutter/nativo |
| Gerência de estado | **Riverpod** | Melhor suporte a testes e injeção de dependência que BLoC/GetX para este projeto | BLoC — mais verboso para o volume de telas do MVP; GetX — acoplamento maior entre DI/estado/rotas, dificulta testes puros de domínio |
| Backend / banco de dados | **Firebase (Firestore)** | Guarda a maior parte dos dados (transações, categorias, metas, orçamentos, perfis de banco); camada gratuita (Spark) suficiente para projeto pessoal no início | Backend próprio (Node/Postgres) — custo de operação e manutenção maior para um app pessoal cloud-first |
| Autenticação | **Firebase Authentication** + `local_auth` (biometria) | Login padrão + segunda camada biométrica antes de abrir o app/confirmar ação sensível | Auth próprio — reinventa um problema resolvido, sem ganho para este escopo |
| Cache offline | **Drift (SQLite)** | Type-safety, migrações declarativas; permite uso sem internet, sincroniza com Firestore quando a conexão volta | Isar — não relacional, dificulta espelhar o schema de sincronização; Hive — sem relações/queries tipadas |
| Arquivos/backup | **Firebase Storage** | Backups exportados e anexos (ex.: comprovantes) | — |
| Notificações | **Firebase Cloud Messaging (FCM)** + `flutter_local_notifications` | Push remoto (resumo semanal/mensal) + lembretes locais (contas a pagar, aportes, limites) | — |
| IA local | **Gemma (quantizado, 2B/3B) via MediaPipe LLM Inference API** | Suporte oficial Google a Android/iOS; processa dados já sincronizados do Firestore sem enviar o conteúdo das perguntas a um servidor de inferência externo — principal garantia de privacidade do produto | llama.cpp via FFI — alternativa viável se o suporte Flutter do MediaPipe for insuficiente; API de LLM em nuvem (OpenAI/Gemini remoto) — quebraria a proposta de valor central de privacidade |
| Gráficos/Dashboard | **`fl_chart`** | Gratuito, suficiente para dashboard, patrimônio líquido, comparativos mensais | `syncfusion_flutter_charts` — recursos extras não necessários no MVP, licenciamento mais restritivo |
| Importação de extrato | Parser local configurável (CSV/OFX) | Evita depender de agregador de Open Finance (custo mensal recorrente) e credenciamento regulatório; mantém fluxo 100% local-first na importação | Integração automática via Open Finance — adiada para decisão futura (fora do roadmap atual) |
| Armazenamento seguro | **`flutter_secure_storage`** | Tokens e chaves locais protegidos no Keystore/Keychain nativo | `SharedPreferences` — texto não protegido, inaceitável para dado financeiro sensível |

## Backend consumido (dentro do mesmo produto, não um serviço externo)
- Firebase é o "backend mínimo" do sistema: Firestore (dados), Firebase Auth (identidade), Firebase Storage (arquivos), FCM (push). Não há servidor de aplicação próprio neste projeto.
- Regras de segurança do Firestore (`firestore.rules`) são parte do código deste repositório e tratadas com o mesmo rigor que código Dart — ver `.claude/rules/security.md`.

## Nota de custo
Firestore cobra por leitura/escrita/armazenamento acima do limite gratuito — o modelo de dados deve ser desenhado para minimizar leituras desnecessárias (ex.: não reler o histórico inteiro de transações a cada abertura do dashboard; usar paginação e agregados pré-computados quando possível).
