# Checklist — Novo Widget (Design System ou Feature)

- [ ] Checou `.claude/memory/design-system.md` antes de criar, para não duplicar um componente existente.
- [ ] Zero hardcode de tema — todo token vem de `app/theme/`.
- [ ] Se exibe valor monetário: suporta Modo Discreto.
- [ ] Se é de `core/widgets/`: adicionado ao inventário de `.claude/memory/design-system.md` na mesma PR.
- [ ] Golden test cobrindo light e dark (e Modo Discreto ativo/inativo, se aplicável).
- [ ] Nenhuma regra de negócio dentro do widget — só apresentação.
