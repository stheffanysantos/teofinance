/// Versão exibida em "Sobre o app". Precisa acompanhar o `version:` do
/// `pubspec.yaml` (`1.0.0+1` = versão `1.0.0`, build `1`): o teste
/// `test/core/app_info_test.dart` falha se os dois divergirem.
///
/// Não usamos o `package_info_plus` porque a versão 10.x quebra o `build_runner`
/// (o analisador do `drift_dev` não entende a sintaxe nova do Dart) e a 9.x
/// conflita com o `flutter_secure_storage`. Reavaliar depois de atualizar o Flutter.
const kAppVersion = '1.0.0';
const kAppBuild = '1';

class AppInfo {
  const AppInfo({this.version = kAppVersion, this.build = kAppBuild});

  final String version;
  final String build;
}
