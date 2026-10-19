import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Nome, versão e build do app, lidos do pacote instalado — nunca um texto
/// fixo na tela, que ficaria desatualizado a cada release.
final appInfoProvider = FutureProvider<PackageInfo>((ref) => PackageInfo.fromPlatform());
