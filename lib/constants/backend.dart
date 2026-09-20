
class Backend {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://mundra.munsocietympstme.com',
  );
}
