import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

final _resident = <String, Object?>{
  'id': 'resident_001',
  'name': 'Lisa Nilman',
  'role': 'RESIDENT',
  'avatarAsset': 'assets/images/private_jet.jpg',
};

final _flights = <Map<String, Object?>>[
  {
    'id': 'flt_001',
    'time': '2:45 PM',
    'priceAmount': 1,
    'currency': 'USD',
    'origin': 'CMN',
    'destination': 'LIS',
  },
  {
    'id': 'flt_002',
    'time': '11:11 PM',
    'priceAmount': 1,
    'currency': 'USD',
    'origin': 'CMN',
    'destination': 'LIS',
  },
];

Response _json(Object body, {int statusCode = HttpStatus.ok}) {
  return Response(
    statusCode,
    body: jsonEncode(body),
    headers: const {
      'content-type': 'application/json',
      'access-control-allow-origin': '*',
      'access-control-allow-methods': 'GET, OPTIONS',
      'access-control-allow-headers': 'origin, content-type, accept',
    },
  );
}

Middleware _corsMiddleware() {
  return (innerHandler) {
    return (request) async {
      if (request.method == 'OPTIONS') {
        return _json({'ok': true});
      }
      return innerHandler(request);
    };
  };
}

void main(List<String> args) async {
  final router = Router()
    ..get('/health', (Request request) {
      return _json({
        'status': 'ok',
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      });
    })
    ..get('/api/resident', (Request request) => _json(_resident))
    ..get('/api/flights', (Request request) => _json({'items': _flights}))
    ..get('/api/destination', (Request request) {
      return _json({'resident': _resident, 'flights': _flights});
    });

  final pipeline = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_corsMiddleware())
      .addHandler(router.call);

  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final server = await io.serve(pipeline, InternetAddress.anyIPv4, port);

  stdout.writeln(
    'Travell backend running on http://${server.address.host}:${server.port}',
  );
}
