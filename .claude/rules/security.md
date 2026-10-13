# Regra: Segurança e Privacidade

## Credenciais e sessão
- **Nunca** persistir token/sessão em `SharedPreferences`, `drift`/SQLite sem criptografia, ou qualquer texto puro. Usar `flutter_secure_storage` (`core/storage/secure_storage_service.dart`) para qualquer credencial/token local.
- Autenticação via Firebase Authentication; biometria local (`local_auth`, Face ID/impressão digital) é uma **segunda camada** obrigatória antes de abrir o app ou confirmar uma ação sensível (ex.: excluir conta, exportar dados) — nunca o único fator.

## Regras do Firestore (ponto crítico)
- `firestore.rules` deve garantir que **cada usuário só lê/escreve seus próprios dados** (`request.auth.uid == resource.data.userId` ou equivalente por coleção) — este é o ponto mais crítico de segurança do produto, já que o Firestore guarda a maior parte dos dados financeiros.
- Toda coleção nova precisa de uma regra explícita revisada antes de ir para produção — nunca depender da regra padrão/aberta do emulador em produção.
- Mudança em `firestore.rules` é revisada com o mesmo rigor que código Dart (ver `.claude/reviews/checklist-feature.md`).

## Ambiente (dev vs. produção)
- Chaves/config do Firebase por ambiente vêm dos arquivos padrão do FlutterFire (`google-services.json`/`GoogleService-Info.plist` por flavor) + `--dart-define` para flags de app, **nunca hardcoded** em código-fonte versionado.
- Usar **flavors** do Flutter (`--flavor dev`/`--flavor prod`) para separar projetos Firebase de desenvolvimento e produção — nunca apontar o app de desenvolvimento para o projeto Firebase de produção.

## Rede
- Toda chamada de rede fora do SDK do Firebase (ex.: busca de cotação/indicador econômico para o comparador de investimentos) usa um client HTTP configurado com timeout explícito — nunca uma chamada sem timeout que possa travar a UI indefinidamente.
- IA local (Gemma/MediaPipe): **nenhuma chamada de rede** é permitida no caminho de gerar uma resposta — ver `.claude/rules/architecture.md`, regra de privacidade da IA, e decisão 0004 em `.claude/memory/decisions.md`.

## Importação de extrato
- O arquivo de extrato (CSV/OFX) é lido e processado **inteiramente no dispositivo** — nunca enviado a nenhum servidor (nem Firebase Storage) durante o parsing. Só as Transações resultantes (já estruturadas) são sincronizadas.

## Validação de entrada
- Toda entrada de usuário validada na UI (feedback imediato) **e** no usecase (regra de negócio real) — nunca confiar só em validação client-side, especialmente para valores monetários e datas de importação.

## Dados sensíveis em log
- Nunca `print()`/logar valores de transação completos, CPF/CNPJ (se cadastrado), token de autenticação ou conteúdo bruto de arquivo de extrato.

## LGPD
- O app deve oferecer, de forma acessível ao usuário, exportação e exclusão completa dos dados do Firebase mediante solicitação (ver especificação, seção 8). Qualquer feature nova que colete dado pessoal novo deve considerar esse direito desde o desenho, não como um retrofit.

## Revisão
Ver o agente **Security & Privacy Engineer** (`.claude/agents/security-privacy-engineer.md`) e o comando `/review-security`.
