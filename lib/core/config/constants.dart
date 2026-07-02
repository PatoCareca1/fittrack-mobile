/// Configuração de ambiente.
///
/// `10.0.2.2` é o alias do host quando rodando no emulador Android;
/// sobrescreva com `--dart-define=API_BASE_URL=...` em builds reais.
abstract class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );
}
