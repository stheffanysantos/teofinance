# Checklist — Novo Service (`core/`)

- [ ] Genuinamente cross-cutting (usado por 2+ features) — senão pertence à feature, não a `core/`.
- [ ] Nenhum import de `features/*` dentro do service.
- [ ] Exposto via `core/providers/core_providers.dart`, instanciado uma única vez (nunca recriado por feature).
- [ ] Se envolve credencial/biometria/chave: segue `.claude/rules/security.md`.
- [ ] Teste unitário cobrindo o comportamento público.
