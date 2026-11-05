/// Tipos de lembrete mensal cadastráveis (todo mês, num dia fixo).
enum TipoLembrete {
  faturaFecha('Fatura fecha', 'A fatura fecha hoje. Compras a partir de agora entram na próxima.'),
  faturaVence('Fatura vence', 'A fatura vence hoje. Confira e pague para evitar juros.'),
  faturaAbre('Fatura abre', 'Uma nova fatura do cartão começa hoje.'),
  cartaoMelhorDia(
    'Melhor dia para usar o cartão',
    'Hoje é um bom dia para usar o cartão: a compra só entra na fatura do próximo mês.',
  ),
  outro('Outro', 'Você pediu este lembrete.');

  const TipoLembrete(this.rotulo, this.mensagem);

  final String rotulo;

  /// Texto da notificação.
  final String mensagem;

  static TipoLembrete deNome(String nome) {
    return TipoLembrete.values.firstWhere((t) => t.name == nome, orElse: () => TipoLembrete.outro);
  }
}

/// Lembrete que se repete todo mês no [dia] (1–31; em meses mais curtos vale o
/// último dia). Dispara no horário configurado nos avisos.
class LembretePersonalizado {
  const LembretePersonalizado({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.dia,
    this.ativo = true,
  });

  /// Vazio enquanto ainda não foi salvo; o repositório gera um id.
  final String id;
  final String titulo;
  final TipoLembrete tipo;
  final int dia;
  final bool ativo;

  LembretePersonalizado copyWith({String? titulo, TipoLembrete? tipo, int? dia, bool? ativo}) {
    return LembretePersonalizado(
      id: id,
      titulo: titulo ?? this.titulo,
      tipo: tipo ?? this.tipo,
      dia: dia ?? this.dia,
      ativo: ativo ?? this.ativo,
    );
  }
}
