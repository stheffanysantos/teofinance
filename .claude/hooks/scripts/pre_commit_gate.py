#!/usr/bin/env python3
"""PreToolUse (Bash) — intercepta 'git commit' e roda 'dart analyze --fatal-infos'.
Bloqueio real e deterministico: se o analyzer falhar, o commit e bloqueado.
"""
import json
import subprocess
import sys


def main():
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)

    command = payload.get("tool_input", {}).get("command", "")

    if "git commit" not in command:
        sys.exit(0)

    try:
        result = subprocess.run(
            ["dart", "analyze", "--fatal-infos"],
            capture_output=True,
            text=True,
            timeout=180,
        )
    except FileNotFoundError:
        sys.stderr.write(
            "pre_commit_gate: comando 'dart' nao encontrado no PATH — commit liberado sem checagem "
            "(ajuste o ambiente para nao perder esta garantia).\n"
        )
        sys.exit(0)
    except subprocess.TimeoutExpired:
        sys.stderr.write("pre_commit_gate: 'dart analyze' excedeu o tempo limite — commit bloqueado.\n")
        sys.exit(2)

    if result.returncode != 0:
        sys.stderr.write(
            "Commit bloqueado: 'dart analyze --fatal-infos' encontrou apontamentos.\n\n"
            + result.stdout
            + result.stderr
            + "\nCorrija os apontamentos e tente novamente. Nao use --no-verify para contornar.\n"
        )
        sys.exit(2)

    sys.exit(0)


if __name__ == "__main__":
    main()
