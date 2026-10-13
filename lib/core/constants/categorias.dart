/// Categorias padrão pré-cadastradas (ver `.claude/plans/MVP.md`, item 4).
/// `kCategoriasBase` inclui "Todas" como opção de filtro; `kCategorias`
/// (sem "Todas") é a lista real de categorias atribuíveis a uma transação.
const kCategoriasBase = ['Todas', 'Mercado', 'Moradia', 'Transporte', 'Lazer', 'Renda'];

List<String> get kCategorias => kCategoriasBase.skip(1).toList();
