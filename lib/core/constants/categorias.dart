/// Categorias padrão pré-cadastradas (ver `.claude/plans/MVP.md`, item 4).
/// `kCategoriasBase` inclui "Todas" como opção de filtro; `kCategorias`
/// (sem "Todas") é a lista real de categorias atribuíveis a uma transação.
const kCategoriasBase = ['Todas', 'Mercado', 'Moradia', 'Transporte', 'Lazer', 'Renda'];

List<String> get kCategorias => kCategoriasBase.skip(1).toList();

/// Categoria da transação que acerta o saldo do app com o saldo real da conta
/// (ver `AjustarSaldoUseCase`). Entra no saldo total, mas nunca em receitas,
/// despesas, relatórios ou score: não é dinheiro que entrou ou saiu no mês.
const kCategoriaAjusteSaldo = 'Ajuste de saldo';
