import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/core/app_info.dart';

void main() {
  test('a versão exibida no app é a do pubspec.yaml', () {
    final linha = File('pubspec.yaml')
        .readAsLinesSync()
        .firstWhere((l) => RegExp(r'^version:\s*\S+').hasMatch(l));
    final m = RegExp(r'^version:\s*([^+\s]+)(?:\+(\S+))?').firstMatch(linha)!;

    expect(
      kAppVersion,
      m.group(1),
      reason: 'Atualize kAppVersion em lib/core/app_info.dart para a versão do pubspec.yaml.',
    );
    expect(
      kAppBuild,
      m.group(2) ?? '',
      reason: 'Atualize kAppBuild em lib/core/app_info.dart para o build do pubspec.yaml.',
    );
  });

  test('AppInfo padrão usa as constantes', () {
    const info = AppInfo();

    expect(info.version, kAppVersion);
    expect(info.build, kAppBuild);
  });
}
