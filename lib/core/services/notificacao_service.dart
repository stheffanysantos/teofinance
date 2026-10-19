/// Um lembrete a ser exibido no aparelho em [quando] (horário local).
class NotificacaoAgendada {
  const NotificacaoAgendada({
    required this.id,
    required this.quando,
    required this.titulo,
    required this.corpo,
  });

  /// Identificador estável: reagendar o mesmo id substitui o anterior.
  final int id;
  final DateTime quando;
  final String titulo;
  final String corpo;
}

/// Notificações locais do aparelho. Não tem nada de rede nem de FCM: o lembrete
/// é agendado no próprio celular e dispara mesmo sem conexão.
abstract class NotificacaoService {
  Future<bool> permissaoConcedida();

  /// Pede a permissão ao sistema (Android 13+). Devolve se foi concedida.
  Future<bool> pedirPermissao();

  /// Substitui tudo o que estava agendado por [lembretes].
  Future<void> reagendarTudo(List<NotificacaoAgendada> lembretes);

  Future<void> cancelarTudo();

  /// Exibe uma notificação agora, para o usuário conferir que elas funcionam.
  Future<void> mostrarAgora({required String titulo, required String corpo});
}

/// Implementação que não faz nada: testes e plataformas sem notificação.
class NotificacaoServiceNulo implements NotificacaoService {
  const NotificacaoServiceNulo();

  @override
  Future<bool> permissaoConcedida() async => false;

  @override
  Future<bool> pedirPermissao() async => false;

  @override
  Future<void> reagendarTudo(List<NotificacaoAgendada> lembretes) async {}

  @override
  Future<void> cancelarTudo() async {}

  @override
  Future<void> mostrarAgora({required String titulo, required String corpo}) async {}
}
