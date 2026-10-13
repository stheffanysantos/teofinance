#!/usr/bin/env python3
"""PreToolUse (Write|Edit) — bloqueia violacoes da regra de dependencia entre camadas.
Ver .claude/rules/architecture.md. Checagem por substring/regex, nao um linter semantico completo.
"""
import json
import re
import sys

FORBIDDEN_IN_DOMAIN = [
    r"import\s+['\"]package:flutter/",
    r"import\s+['\"]package:flutter_riverpod/",
    r"import\s+['\"]package:riverpod/",
    r"import\s+['\"]package:cloud_firestore/",
    r"import\s+['\"]package:firebase_",
    r"import\s+['\"]package:drift/",
]

FORBIDDEN_IN_CORE = [
    r"import\s+['\"]package:teofinance/features/",
    r"import\s+['\"]\.\./\.\./features/",
]

AI_ASSISTANT_FORBIDDEN = [
    r"import\s+['\"]package:cloud_firestore/",
    r"import\s+['\"]package:firebase_storage/",
    r"import\s+['\"]package:dio/",
    r"import\s+['\"]package:http/",
]


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

    violations = []

    if "/domain/" in file_path:
        for pattern in FORBIDDEN_IN_DOMAIN:
            if re.search(pattern, content):
                violations.append(
                    f"'domain/' nao pode importar Flutter/Riverpod/Firebase/drift (encontrado: {pattern}) — "
                    f"ver .claude/rules/architecture.md"
                )

    if "/core/" in file_path and "/features/" not in file_path:
        for pattern in FORBIDDEN_IN_CORE:
            if re.search(pattern, content):
                violations.append(
                    "'core/' nao pode importar de 'features/' — ver .claude/rules/architecture.md"
                )

    if "/features/ai_assistant/" in file_path and "/presentation/" not in file_path:
        for pattern in AI_ASSISTANT_FORBIDDEN:
            if re.search(pattern, content):
                violations.append(
                    "'features/ai_assistant/' nao pode acessar Firestore/Storage/rede diretamente — "
                    "a IA local so consome dados ja expostos pelos repositories de outras features. "
                    "Ver .claude/rules/architecture.md (regra de privacidade da IA) e decisao 0004 em "
                    ".claude/memory/decisions.md."
                )

    if violations:
        sys.stderr.write("\n".join(violations) + "\n")
        sys.exit(2)

    sys.exit(0)


if __name__ == "__main__":
    main()
