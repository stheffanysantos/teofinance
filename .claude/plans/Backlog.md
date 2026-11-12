# Backlog — estado atual e o que falta

> Atualizado em 2026-10-23 (conferido contra o código). O app é **pessoal (um único usuário)**: flavors dev/prod, LGPD como obrigação legal, monetização e suporte a aparelhos antigos não são prioridade. Escopo: ver `MVP-V2-Revisado.md` (simulação/gamificação removidas) e decisões 0003 (importação sempre manual), 0006 (Gemma) e 0007 (sem Open Finance) em `.claude/memory/decisions.md`.

## Entregue
- **Base:** `core/` (tema, Firebase, Drift schema v10, secure storage), `auth` (e-mail+senha, biometria), `sync` (push/pull Firestore ↔ Drift, `SyncStatus`, exclusão por `pendingDelete`, pausa durante exclusão de conta).
- **Dados:** `transacao` (com divisão de despesa com amigos), `parcelamento` (meses de calendário, centavos fecham o total, exclusão propaga), `renda`, `meta`, `budget` (limites por categoria persistidos e sincronizados), `contas` (a pagar, recorrência com dia-base, lembretes locais).
- **Importação:** CSV com Perfil de Banco e **OFX** (1.x/2.x), detecção de duplicatas ao reimportar.
- **Reconciliação:** extrato × lançamentos, vínculo manual, relatório do período, card no Dashboard. Extrato e vínculos ficam **só no aparelho** (não sincronizam, de propósito).
- **Inteligência:** Score financeiro calculado (orçamento, poupança, metas, extrato conferido), gastos recorrentes/assinaturas com reajuste, assistente por regras sobre dados reais com contratos prontos para o Gemma.
- **Privacidade/dados:** Modo Discreto, exportar e excluir todos os dados (`lgpd`), tela Sobre.
- **Relatórios:** exportação mensal em PDF (`RelatorioPdfService`) e CSV (`RelatorioCsvService`).
- **IA local:** inferência via `flutter_edge_ai` + LiteRT-LM, gerenciador de modelo e banner no chat, com fallback por regras.
- **Segurança:** `firestore.rules` explícitas por coleção, com testes no emulador (já em `develop`).
- **Infra:** CI (`.github/workflows/ci.yml`), `.githooks/pre-commit`, hooks do Claude Code funcionando (`python`).

## Pendente
- **Gemma local — validar em aparelho:** o plugin e o `minSdk` 30 já estão no projeto; falta confirmar download/inferência real e decidir onde hospedar o modelo.
- **Widget de home screen:** não implementado.
- **Validação em aparelho:** sync com Firebase real, biometria, OFX com extrato real, lembretes (botão de teste em Perfil → Notificações).

## Dívida técnica conhecida
- `package_info_plus` 10.x quebra o `build_runner` e a 9.x conflita com `flutter_secure_storage`; a versão do app vem de `lib/core/app_info.dart` (validada por teste contra o `pubspec.yaml`). Reavaliar após atualizar o Flutter.
- Dois aparelhos que criem limite de orçamento da mesma categoria com ids diferentes resultam em um só limite aplicado.
- A deduplicação de importação usa dia + centavos + descrição; o `FITID` do OFX daria identidade exata, mas não é guardado.
- `TODO` em `import_flow_notifier.dart` (mover para um `TransacaoRepository` dedicado) e em `parcelamento_local_data_source.dart` (filtrar por `userId`).

## Fora do escopo (decidido)
Open Finance/agregadores (0007), carteira simulada e gamificação, FCM/push de servidor, flavors dev/prod, monetização (0005).
