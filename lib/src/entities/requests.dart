class FakeWebServerRequest {
  String body;
  String method;
  Uri uri;
  Map<String, String> headers;

  FakeWebServerRequest({
    required this.body,
    required this.method,
    required this.uri,
    required this.headers,
  });
}
