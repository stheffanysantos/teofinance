#!/usr/bin/env python3
"""PreToolUse (Write|Edit) — bloqueia antipadroes de Riverpod descritos em .claude/rules/riverpod.md.
Checagem por substring/regex, nao um linter semantico completo.
"""
import json
import re
import sys


def main():
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)

    tool_input = payload.get("tool_input", {})
    file_path = (tool_input.get("file_path") or "").replace("\\", "/")
    content = tool_input.get("content") or tool_input.get("new_string") or ""

    if not file_path.endswith(".dart"):
        sys.exit(0)

    is_test_file = file_path.endswith("_test.dart")
    violations = []

    is_notifier_file = file_path.endswith("_notifier.dart")

    if is_notifier_file and not is_test_file:
        if re.search(r"=\s*\w+RepositoryImpl\s*\(", content) or re.search(
            r"=\s*\w+DataSource\w*\s*\(", content
        ):
            violations.append(
                "Notifier instanciando Repository/DataSource diretamente em vez de via 'ref.watch'/'ref.read' — "
                "injecao deve vir de um provider. Ver .claude/rules/riverpod.md."
            )

    if "/core/providers/" in file_path and "/features/" not in file_path:
        # provider de feature especifica nao deve morar em core/providers/
        if re.search(r"@riverpod\s+\w*(Transacao|Meta|Orcamento|Importa|Dashboard)", content, re.IGNORECASE):
            violations.append(
                "Provider especifico de feature declarado em core/providers/ — providers de feature "
                "devem morar em '<feature>_providers.dart' dentro da propria feature. Ver .claude/rules/riverpod.md."
            )

    if re.search(r"class\s+\w+State\b", content) and content.count("class ") > 1 and not re.search(
        r"@freezed", content
    ):
        violations.append(
            "Classe de State sem @freezed — este projeto padroniza State como union freezed. "
            "Ver .claude/rules/riverpod.md."
        )

    if violations:
        sys.stderr.write("\n".join(violations) + "\n")
        sys.exit(2)

    sys.exit(0)


if __name__ == "__main__":
    main()
