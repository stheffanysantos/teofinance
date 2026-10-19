import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teofinance/core/app_info.dart';

/// Versão e build do app, para "Sobre o app" e o Perfil.
final appInfoProvider = Provider<AppInfo>((ref) => const AppInfo());
