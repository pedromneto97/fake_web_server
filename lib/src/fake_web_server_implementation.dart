import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'entities/requests.dart';
import 'entities/response.dart';
import 'fake_web_server_base.dart';

class FakeWebServerImplementation implements FakeWebServer {
  final int port;
  final InternetAddressType internetAddressType;
  late final HttpServer _server;
  final Map<String, FakeWebServerResponse> _responses = {};
  final Map<String, FakeWebServerRequest> _requests = {};

  FakeWebServerImplementation({
    required this.port,
    this.internetAddressType = InternetAddressType.IPv4,
  });

  @override
  Future<void> start() async {
    final internetAddress = internetAddressType == InternetAddressType.IPv4
        ? InternetAddress.loopbackIPv4
        : InternetAddress.loopbackIPv6;

    _server = await HttpServer.bind(internetAddress, port);

    _run();
  }

  @override
  Future<void> stop() => _server.close();

  @override
  void mockRequestForPath(
    String path, {
    dynamic body = "",
    int httpCode = HttpStatus.ok,
    Map<String, String> headers = const {},
  }) =>
      _responses[path] = FakeWebServerResponse(
        httpCode: httpCode,
        body: body,
        headers: headers,
      );

  @override
  FakeWebServerRequest takeRequest(String path) {
    if (!_requests.containsKey(path)) {
      throw Exception("Request doesn't exist");
    }
    return _requests.remove(path)!;
  }

  @override
  void clear() {
    _requests.clear();
    _responses.clear();
  }

  void _run() async {
    await for (final request in _server) {
      _storeRequest(request);
      if (!_responses.containsKey(request.uri.toString())) {
        throw HttpException(
          "No response for path ${request.uri}",
          uri: request.uri,
        );
      }

      final response = _responses[request.uri.toString()]!;

      response.headers.forEach((name, value) {
        request.response.headers.add(name, value);
      });

      request.response
        ..statusCode = response.httpCode
        ..write(response.body)
        ..close();
    }
  }

  void _storeRequest(HttpRequest request) async {
    final bodyBuffer = StringBuffer();
    final bodyCompleter = Completer<String>();

    utf8.decoder.bind(request).listen(
          bodyBuffer.write,
          onDone: () => bodyCompleter.complete(bodyBuffer.toString()),
        );

    final headers = <String, String>{};
    request.headers.forEach((key, values) {
      headers[key] = values.join(", ");
    });

    final body = await bodyCompleter.future;

    _requests[request.uri.toString()] = FakeWebServerRequest(
      uri: request.uri,
      headers: headers,
      body: body,
      method: request.method,
    );
  }
}
