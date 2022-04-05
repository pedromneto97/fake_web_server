import 'dart:convert';

import 'package:fake_web_server/fake_web_server.dart';
import 'package:http/http.dart';

const data = {
  'test': 1,
};

void main() async {
  final server = FakeWebServer(port: 3000);

  await server.start();

  server.mockRequestForPath(
    '/home',
    body: json.encode(data),
  );

  final response = await get(Uri.parse('http://localhost:3000/home'));

  print(response.body);
  assert(response.body == json.encode(data));

  await server.stop();
}
