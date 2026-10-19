import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/core/providers/core_providers.dart';
import 'package:teofinance/features/contas/domain/usecases/reagendar_lembretes_usecase.dart';
import 'package:teofinance/features/contas/presentation/providers/conta_providers.dart';

const kHoraPadraoLembrete = 9;

class ConfigLembretes {
  const ConfigLembretes({this.ativo = true, this.hora = kHoraPadraoLembrete});

  final bool ativo;

  /// Hora do dia (0–23) em que o lembrete aparece.
  final int hora;

  ConfigLembretes copyWith({bool? ativo, int? hora}) => ConfigLembretes(ativo: ativo ?? this.ativo, hora: hora ?? this.hora);
}

final configLembretesProvider = NotifierProvider<ConfigLembretesNotifier, ConfigLembretes>(
  ConfigLembretesNotifier.new,
);

/// Preferência dos lembretes, guardada no aparelho (mesmo padrão do Modo Discreto).
class ConfigLembretesNotifier extends Notifier<ConfigLembretes> {
  static const _chaveAtivo = 'lembretes_ativos';
  static const _chaveHora = 'lembretes_hora';

  @override
  ConfigLembretes build() {
    _carregar();
    return const ConfigLembretes();
  }

  Future<void> _carregar() async {
    try {
      final storage = ref.read(secureStorageProvider);
      final ativo = await storage.read(key: _chaveAtivo);
      final hora = int.tryParse(await storage.read(key: _chaveHora) ?? '');
      state = ConfigLembretes(
        ativo: ativo != '0',
        hora: (hora != null && hora >= 0 && hora <= 23) ? hora : kHoraPadraoLembrete,
      );
    } catch (_) {
      // sem armazenamento seguro (ex.: testes): segue com o padrão.
    }
  }

  Future<void> definirAtivo(bool ativo) async {
    state = state.copyWith(ativo: ativo);
    await _salvar(_chaveAtivo, ativo ? '1' : '0');
  }

  Future<void> definirHora(int hora) async {
    if (hora < 0 || hora > 23) return;
    state = state.copyWith(hora: hora);
    await _salvar(_chaveHora, '$hora');
  }

  Future<void> _salvar(String chave, String valor) async {
    try {
      await ref.read(secureStorageProvider).write(key: chave, value: valor);
    } catch (_) {
      // vale na sessão mesmo sem conseguir persistir.
    }
  }
}

final reagendarLembretesUseCaseProvider = Provider((ref) {
  return ReagendarLembretesUseCase(ref.watch(notificacaoServiceProvider));
});

/// Mantém os lembretes do aparelho em dia: reagenda quando as contas ou a
/// configuração mudam, e na primeira leitura (abertura do app). Quem precisa
/// disso ligado apenas faz `ref.watch(lembretesAutomaticosProvider)`.
final lembretesAutomaticosProvider = Provider<void>((ref) {
  Future<void> reagendar() async {
    final contas = ref.read(contasStreamProvider).valueOrNull;
    if (contas == null) return;
    final config = ref.read(configLembretesProvider);
    await ref.read(reagendarLembretesUseCaseProvider)(contas: contas, ativo: config.ativo, hora: config.hora);
  }

  ref.listen(contasStreamProvider, (_, _) => reagendar(), fireImmediately: true);
  ref.listen(configLembretesProvider, (_, _) => reagendar());
});
