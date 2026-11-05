import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/core/providers/core_providers.dart';
import 'package:teofinance/features/contas/domain/services/planejar_lembrete_extrato.dart';
import 'package:teofinance/features/contas/domain/usecases/reagendar_lembretes_usecase.dart';
import 'package:teofinance/features/contas/presentation/providers/conta_providers.dart';
import 'package:teofinance/features/lembrete/presentation/providers/lembrete_providers.dart';

const kHoraPadraoLembrete = 9;

class ConfigLembretes {
  const ConfigLembretes({
    this.ativo = true,
    this.hora = kHoraPadraoLembrete,
    this.extratoAtivo = true,
    this.extratoDia = kDiaPadraoLembreteExtrato,
  });

  final bool ativo;

  /// Aviso mensal para enviar o extrato do mês anterior.
  final bool extratoAtivo;

  /// Dia do mês (1–28) em que o aviso do extrato aparece.
  final int extratoDia;

  /// Hora do dia (0–23) em que o lembrete aparece.
  final int hora;

  ConfigLembretes copyWith({
    bool? ativo,
    int? hora,
    bool? extratoAtivo,
    int? extratoDia,
  }) => ConfigLembretes(
    ativo: ativo ?? this.ativo,
    hora: hora ?? this.hora,
    extratoAtivo: extratoAtivo ?? this.extratoAtivo,
    extratoDia: extratoDia ?? this.extratoDia,
  );
}

final configLembretesProvider =
    NotifierProvider<ConfigLembretesNotifier, ConfigLembretes>(
      ConfigLembretesNotifier.new,
    );

/// Preferência dos lembretes, guardada no aparelho (mesmo padrão do Modo Discreto).
class ConfigLembretesNotifier extends Notifier<ConfigLembretes> {
  static const _chaveAtivo = 'lembretes_ativos';
  static const _chaveHora = 'lembretes_hora';
  static const _chaveExtratoAtivo = 'lembretes_extrato_ativo';
  static const _chaveExtratoDia = 'lembretes_extrato_dia';

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
      final extratoAtivo = await storage.read(key: _chaveExtratoAtivo);
      final extratoDia = int.tryParse(
        await storage.read(key: _chaveExtratoDia) ?? '',
      );
      state = ConfigLembretes(
        ativo: ativo != '0',
        hora: (hora != null && hora >= 0 && hora <= 23)
            ? hora
            : kHoraPadraoLembrete,
        extratoAtivo: extratoAtivo != '0',
        extratoDia: extratoDia != null
            ? diaValidoExtrato(extratoDia)
            : kDiaPadraoLembreteExtrato,
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

  Future<void> definirExtratoAtivo(bool ativo) async {
    state = state.copyWith(extratoAtivo: ativo);
    await _salvar(_chaveExtratoAtivo, ativo ? '1' : '0');
  }

  Future<void> definirExtratoDia(int dia) async {
    final valido = diaValidoExtrato(dia);
    state = state.copyWith(extratoDia: valido);
    await _salvar(_chaveExtratoDia, '$valido');
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
    await ref.read(reagendarLembretesUseCaseProvider)(
      contas: contas,
      ativo: config.ativo,
      hora: config.hora,
      extratoAtivo: config.extratoAtivo,
      extratoDia: config.extratoDia,
      personalizados: ref.read(lembretesPersonalizadosProvider).valueOrNull ?? const [],
    );
  }

  ref.listen(
    contasStreamProvider,
    (_, _) => reagendar(),
    fireImmediately: true,
  );
  ref.listen(configLembretesProvider, (_, _) => reagendar());
  ref.listen(lembretesPersonalizadosProvider, (_, _) => reagendar());
});
