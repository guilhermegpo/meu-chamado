/// Identidade da versão exibida ao usuário.
///
/// Fonte única: a tela de Configurações lê daqui em vez de trazer o número
/// escrito à mão. Um teste compara esta constante com o `pubspec.yaml`, então
/// esquecer de atualizá-la quebra a suíte em vez de aparecer no aparelho de
/// alguém como uma versão que não corresponde ao que está instalado.
abstract final class AppInfo {
  /// Versão SemVer publicada, sem o número de build.
  static const version = '0.2.0-alpha.1';

  /// Ressalva permanente: o app não é oficial nem endossado pela Igreja.
  static const disclaimer = 'projeto independente e não oficial';

  static const versionLine = '$version • $disclaimer';
}
