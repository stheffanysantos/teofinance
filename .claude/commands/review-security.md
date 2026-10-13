---
description: Revisão de segurança e privacidade focada em credenciais, firestore.rules e isolamento da IA local
argument-hint: [feature]
allowed-tools: Read, Grep, Glob, Bash
---

Aja como o agente **Security & Privacy Engineer** (`.claude/agents/security-privacy-engineer.md`) e revise $ARGUMENTS (ou o diff atual, se nenhum argumento for passado) seguindo `.claude/rules/security.md`:

1. Toda credencial/token persiste via `flutter_secure_storage`? Biometria como segunda camada antes de ação sensível?
2. `firestore.rules` restringe cada coleção tocada ao próprio usuário (`request.auth.uid`)?
3. Se a mudança toca `features/ai_assistant/`: nenhum import de `cloud_firestore`/`firebase_storage`/cliente HTTP fora do consumo via repositories de outras features? Nenhuma chamada de rede no caminho de inferência?
4. Se a mudança toca `features/import/`: o conteúdo do arquivo de extrato nunca é enviado para fora do dispositivo durante o parsing?
5. Nenhum log de valor financeiro completo, token ou conteúdo bruto de extrato?
6. Chaves/URLs de Firebase vêm de config por flavor + `--dart-define`, nunca hardcoded?

Liste cada violação citando arquivo/linha.
