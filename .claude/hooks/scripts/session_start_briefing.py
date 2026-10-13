#!/usr/bin/env python3
"""SessionStart — injeta um lembrete curto do checklist obrigatorio (CLAUDE.md)."""
import json
import sys


def main():
    try:
        json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        pass

    message = (
        "TeoFinance — lembrete de sessao: antes de gerar codigo, releia CLAUDE.md + a regra "
        "especifica em .claude/rules/ (architecture.md, riverpod.md, naming.md, material3.md, "
        "security.md, testing.md). Decisao local x remoto de dado sincronizavel pertence ao "
        "Repository, nunca ao Notifier/Screen. Firestore e a fonte de verdade; drift e so cache "
        "offline. features/ai_assistant/ nunca acessa Firestore/rede diretamente — so dados ja "
        "expostos por outras features (privacidade on-device e a proposta de valor central do produto)."
    )
    output = {"hookSpecificOutput": {"additionalContext": message}}
    print(json.dumps(output))
    sys.exit(0)


if __name__ == "__main__":
    main()
