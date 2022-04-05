class FakeWebServerResponse {
  dynamic body;
  int httpCode;
  Map<String, String> headers;

  FakeWebServerResponse({
    this.body,
    required this.httpCode,
    required this.headers,
  });
}
