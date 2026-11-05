import 'package:flutter/foundation.dart';
import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:flutter_edge_ai_litertlm/flutter_edge_ai_litertlm.dart';

bool _pronto = false;
Future<void>? _iniciando;

/// Garante que o motor de IA local foi iniciado. O `main` tenta no começo, mas
/// se falhar lá o erro "FlutterEdgeAi not initialized" aparecia só ao baixar ou
/// perguntar; aqui a inicialização é refeita sob demanda até dar certo.
Future<void> garantirMotorEdgeAi() {
  if (_pronto) return Future.value();
  return _iniciando ??= () async {
    try {
      await FlutterEdgeAi.initialize(
        inferenceEngines: [LiteRtLmEngine()],
      ).timeout(const Duration(seconds: 8));
      _pronto = true;
    } catch (e) {
      // Se já estava iniciado pelo main, o plugin recusa a segunda chamada.
      if ('$e'.toLowerCase().contains('already')) {
        _pronto = true;
      } else {
        debugPrint('Motor de IA local não iniciou: ${e.runtimeType}: $e');
        rethrow;
      }
    } finally {
      _iniciando = null;
    }
  }();
}
