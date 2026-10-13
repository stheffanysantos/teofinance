---
description: Gera testes faltantes para uma feature existente, seguindo a cobertura mínima por tipo de artefato
argument-hint: <feature>
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

Analise `lib/features/$ARGUMENTS/` e gere os testes faltantes conforme `.claude/rules/testing.md`:

1. Liste cada usecase/repository/notifier/screen/datasource sem teste correspondente em `test/features/$ARGUMENTS/`.
2. Para cada um, gere o teste seguindo o template correspondente em `.claude/templates/feature/` (`unit_test_template.dart`/`widget_test_template.dart`).
3. Se a feature é `sync`, confirme cobertura dos 3 cenários obrigatórios: sem conexão, conflito local×remoto, falha parcial.
4. Se a feature é `import`, confirme cobertura de separador/encoding/OFX/perfil incompatível.
5. Se a feature é `ai_assistant`, confirme um teste que comprove ausência de chamada de rede no caminho de inferência.
6. Rode `flutter test test/features/$ARGUMENTS/` ao final e reporte o resultado.
