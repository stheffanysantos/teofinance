import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:teofinance/core/services/notificacao_service.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

const _canalId = 'contas_a_pagar';
const _canalNome = 'Contas a pagar';
const _canalDescricao = 'Lembretes de vencimento das suas contas';
const _idDoTeste = 2147483000;

/// Notificações locais via `flutter_local_notifications`. Só Android e iOS;
/// nas demais plataformas (e nos testes) nada acontece.
class NotificacaoServiceLocal implements NotificacaoService {
  NotificacaoServiceLocal({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  Future<void>? _inicializacao;

  bool get _suportado =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _garantirInicializado() {
    return _inicializacao ??= _inicializar();
  }

  Future<void> _inicializar() async {
    tzdata.initializeTimeZones();
    try {
      final fuso = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(fuso.identifier));
    } catch (_) {
      // sem o fuso do aparelho, usa UTC: o horário do lembrete sai deslocado,
      // mas nenhuma notificação se perde.
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  NotificationDetails get _detalhes => const NotificationDetails(
        android: AndroidNotificationDetails(
          _canalId,
          _canalNome,
          channelDescription: _canalDescricao,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

  @override
  Future<bool> permissaoConcedida() async {
    if (!_suportado) return false;
    await _garantirInicializado();
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) return await android.areNotificationsEnabled() ?? false;
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final permissoes = await ios?.checkPermissions();
    return permissoes?.isEnabled ?? false;
  }

  @override
  Future<bool> pedirPermissao() async {
    if (!_suportado) return false;
    await _garantirInicializado();
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) return await android.requestNotificationsPermission() ?? false;
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    return await ios?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
  }

  @override
  Future<void> reagendarTudo(List<NotificacaoAgendada> lembretes) async {
    if (!_suportado) return;
    await _garantirInicializado();
    await _plugin.cancelAll();

    for (final l in lembretes) {
      await _plugin.zonedSchedule(
        id: l.id,
        title: l.titulo,
        body: l.corpo,
        scheduledDate: tz.TZDateTime.from(l.quando, tz.local),
        notificationDetails: _detalhes,
        // Inexato: não exige a permissão de alarme exato, e um lembrete de
        // conta pode atrasar alguns minutos sem problema.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  @override
  Future<void> cancelarTudo() async {
    if (!_suportado) return;
    await _garantirInicializado();
    await _plugin.cancelAll();
  }

  @override
  Future<void> mostrarAgora({required String titulo, required String corpo}) async {
    if (!_suportado) return;
    await _garantirInicializado();
    await _plugin.show(id: _idDoTeste, title: titulo, body: corpo, notificationDetails: _detalhes);
  }
}
