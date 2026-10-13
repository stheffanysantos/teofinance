# Workflow de Agentes

## Quando acionar qual agente
| Situação | Agente |
|---|---|
| Criar feature nova / decidir onde uma lógica mora / revisar dependência entre camadas | `flutter-architect` |
| Qualquer coisa tocando login, token, `firestore.rules`, dado sensível, ou `features/ai_assistant/` | `security-privacy-engineer` |
| Desenhar/revisar push-pull com Firestore, resolução de conflito, `features/sync/` | `firebase-sync-engineer` |
| Qualquer parte do parser CSV/OFX, Perfil de Banco | `import-parser-engineer` |
| Qualquer parte do assistente Gemma/MediaPipe, geração de insight | `ai-assistant-engineer` |
| Trilhas, carteira simulada, streaks, badges, score financeiro, desafios | `gamification-engineer` |
| Tema, componente de Design System, gráfico, Modo Discreto | `ui-engineer` |
| Cobertura de teste antes de considerar uma PR pronta | `testing-engineer` |
| Revisão geral antes de merge | `code-reviewer` |
| Atualizar `.claude/docs/`/`.claude/memory/` após mudança material | `documentation-writer` |
| Validar se uma feature pertence ao MVP/fase futura/fora de escopo | `product-manager` |

## Ordem recomendada ao criar uma feature nova
1. `product-manager` confirma a fase/escopo.
2. `flutter-architect` desenha a estrutura de pastas/camadas.
3. Implementação segue os comandos `/generate-*` e os prompts em `.claude/prompts/`.
4. `security-privacy-engineer` e/ou `firebase-sync-engineer`/`import-parser-engineer`/`ai-assistant-engineer` revisam conforme a feature tocar os respectivos domínios.
5. `testing-engineer` valida cobertura.
6. `ui-engineer` valida UI se a feature tem tela nova.
7. `code-reviewer` faz a revisão final.
8. `documentation-writer` atualiza `.claude/docs/`/`.claude/memory/` se a mudança for material.
