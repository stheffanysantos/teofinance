# Fluxo de Navegação

## Árvore de rotas (MVP)
```
/                       → SplashScreen (checa sessão)
/login                  → LoginScreen
/dashboard              → DashboardScreen (home, pós-login)
/transacoes             → TransacaoListScreen
/transacoes/novo        → TransacaoFormScreen (criar)
/transacoes/:id/editar  → TransacaoFormScreen (editar)
/importar-extrato       → ImportarExtratoScreen (seleção de arquivo + preview de colunas)
/importar-extrato/perfis→ PerfilBancoListScreen
/rendas                 → RendaListScreen
/metas                  → MetaListScreen
/metas/:id              → MetaDetailScreen
```

## Rotas de fases futuras (não implementadas ainda)
```
/orcamento               (Fase 2)
/contas-a-pagar           (Fase 2)
/educacao/trilhas          (Fase 3)
/carteira-simulada           (Fase 3)
/desafios                      (Fase 3)
/assistente                      (Fase 4)
```

## Guarda de rota
`SplashScreen` e qualquer rota protegida checam o `AuthNotifier` (sessão Firebase + biometria confirmada) antes de permitir navegação — nunca uma Screen individual reimplementa essa checagem isoladamente.

## Modo Discreto
Não é uma rota — é um estado global (provider em `core/`) que qualquer tela com valor monetário observa. Alternado por um botão persistente (ex.: ícone no AppBar do dashboard), nunca por rota própria.
