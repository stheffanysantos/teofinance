#!/usr/bin/env python3
"""PreToolUse (Write|Edit) — AVISO nao bloqueante sobre hardcode de cor/tipografia/espacamento.
Ver .claude/rules/material3.md. Falso-positivo real existe (ex.: Colors.transparent) -- por isso
este hook nunca bloqueia, so injeta um lembrete de contexto.
"""
import json
import re
import sys

PATTERNS = [
    r"Color\(0x[0-9A-Fa-f]{6,8}\)",
    r"TextStyle\([^)]*fontSize:\s*\d",
    r"\bColors\.(?!transparent)\w+",
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

    if "/app/theme/" in file_path or "/core/widgets/" in file_path:
        sys.exit(0)

    hits = [p for p in PATTERNS if re.search(p, content)]

    reminders = []
    if hits:
        reminders.append(
            "Lembrete (nao bloqueante): possivel hardcode de cor/tipografia/espacamento em "
            f"{file_path}. Confirme se o valor deveria vir de app/theme/ em vez de literal — "
            "ver .claude/rules/material3.md."
        )

    if re.search(r"\bAppColors\.(error|success)\b", content) and re.search(
        r"(valor|amount|saldo|transacao)", content, re.IGNORECASE
    ):
        reminders.append(
            "Lembrete: valor monetario usando AppColors.error/success — confirme se nao deveria ser "
            "AppColors.income/expense (semantica financeira distinta de erro/sucesso do app). "
            "Ver .claude/rules/material3.md."
        )

    if not reminders:
        sys.exit(0)

    output = {"hookSpecificOutput": {"additionalContext": " ".join(reminders)}}
    print(json.dumps(output))
    sys.exit(0)


if __name__ == "__main__":
    main()
