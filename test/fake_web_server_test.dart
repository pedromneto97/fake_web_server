import 'dart:convert';
import 'dart:io';

import 'package:fake_web_server/fake_web_server.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';

void main() {
  const path = '/home?foo=bar';
  const port = 3000;
  const url = 'http://localhost:$port$path';
  const headers = {
    'content-type': 'application/json; charset=utf-8',
  };
  final encodedBody = json.encode(
    const {
      'foo': 'bar',
    },
  );
  final client = Client();
  final server = FakeWebServer(port: 3000);

  setUpAll(server.start);

  tearDownAll(server.stop);

  tearDown(server.clear);

  test('Request should return mocked data', () async {
    server.mockRequestForPath(
      path,
      body: encodedBody,
      httpCode: HttpStatus.created,
      headers: headers,
    );

    final response = await client.get(Uri.parse(url));

    expect(response.body, encodedBody);
    expect(response.statusCode, HttpStatus.created);
    expect(response.headers['content-type'], headers['content-type']);
  });

  group('Test take request', () {
    test('Should save the data for path', () async {
      server.mockRequestForPath(
        path,
        httpCode: HttpStatus.accepted,
        headers: headers,
      );

      await client.post(
        Uri.parse(url),
        body: encodedBody,
        headers: headers,
      );

      final request = server.takeRequest(path);

      expect(request.body, encodedBody);
      expect(request.headers['content-type'], headers['content-type']);
      expect(request.method, 'POST');
      expect(request.uri.path, Uri.parse(url).path);
    });

    test('Should throw and exception if no data for path', () {
      expect(
        () => server.takeRequest(''),
        throwsA(
          isA<Exception>().having(
            (exception) => exception.toString(),
            'exception',
            'Exception: Request doesn\'t exist',
          ),
        ),
      );
    });
  });
}
