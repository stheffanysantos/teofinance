#!/usr/bin/env python3
"""PostToolUse (Write|Edit) — injeta lembretes de contexto apos gerar/alterar codigo.
Nao edita nada sozinho; so lembra o Claude de agir na mesma resposta.
"""
import json
import sys

CODEGEN_MARKERS = ("@freezed", "@JsonSerializable", "@riverpod", "@DataClassName", "class Tables extends")


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

    reminders = []

    if any(marker in content for marker in CODEGEN_MARKERS):
        reminders.append(
            "Arquivo usa @freezed/@JsonSerializable/@riverpod/tabela drift — rode "
            "`dart run build_runner build --delete-conflicting-outputs` antes de considerar pronto."
        )

    if "/features/" in file_path:
        reminders.append(
            "Alteracao em uma feature — verifique se .claude/plans/Features.md precisa de atualizacao "
            "de escopo, e se o checklist relevante em .claude/reviews/ foi seguido."
        )

    if "/data/repositories/" in file_path or "/domain/entities/" in file_path:
        reminders.append(
            "Alteracao em entidade/repository — verifique se .claude/docs/DATABASE.md ainda reflete "
            "o schema real (Firestore + cache drift)."
        )

    if "firestore.rules" in file_path or "/data/datasources/" in file_path and "remote" in file_path:
        reminders.append(
            "Alteracao tocando Firestore — confirme que firestore.rules continua restringindo cada "
            "usuario aos proprios dados (ver .claude/rules/security.md)."
        )

    if "/features/import/" in file_path:
        reminders.append(
            "Alteracao no parser de importacao — confirme que nenhum conteudo de arquivo de extrato "
            "e enviado para fora do dispositivo, e que perfil incompativel falha explicitamente "
            "(ver .claude/rules/architecture.md, regra de importacao)."
        )

    if not reminders:
        sys.exit(0)

    output = {"hookSpecificOutput": {"additionalContext": " ".join(reminders)}}
    print(json.dumps(output))
    sys.exit(0)


if __name__ == "__main__":
    main()
