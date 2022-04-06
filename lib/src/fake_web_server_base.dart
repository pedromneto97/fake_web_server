import 'dart:async';
import 'dart:io';

import 'entities/requests.dart';

abstract class FakeWebServer {
  Future<void> start();

  Future<void> stop();

  void mockRequestForPath(
    String path, {
    dynamic body = "",
    int httpCode = HttpStatus.ok,
    Map<String, String> headers = const {},
  });

  FakeWebServerRequest takeRequest(String path);

  void clear();
}
