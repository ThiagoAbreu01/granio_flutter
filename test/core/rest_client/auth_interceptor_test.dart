import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:granio_flutter/core/auth/auth_store.dart';
import 'package:granio_flutter/core/exceptions/session_expired_exception.dart';
import 'package:granio_flutter/core/helpers/constants.dart';
import 'package:granio_flutter/core/local_storage/secure_storage/i_secure_local_storage.dart';
import 'package:granio_flutter/core/logger/logger.dart';
import 'package:granio_flutter/core/rest_client/dio/interceptors/auth_interceptor.dart';
import 'package:granio_flutter/features/user/domain/entities/user.dart';
import 'package:mocktail/mocktail.dart';

class _MockLogger extends Mock implements Logger {}

class _MemoryStorage implements ISecureLocalStorage {
  final values = <String, String>{};
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async => values[key] = value;
  @override
  Future<bool> contains(String key) async => values.containsKey(key);
  @override
  Future<void> remove(String key) async => values.remove(key);
  @override
  Future<void> clear() async => values.clear();
}

/// Responde por path e registra o que foi enviado.
class _FakeAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  final Map<String, (int, Object)> routes;
  _FakeAdapter(this.routes);

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    final (status, body) = routes[options.path] ?? (404, {'message': 'x'});
    return ResponseBody.fromString(jsonEncode(body), status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

String _jwt(Duration expiraEm) {
  final exp = DateTime.now().add(expiraEm).millisecondsSinceEpoch ~/ 1000;
  final payload = base64Url.encode(utf8.encode(jsonEncode({'exp': exp})));
  return 'Bearer h.$payload.s';
}

void main() {
  late _MemoryStorage storage;
  late AuthStore authStore;
  late _FakeAdapter adapter;
  late Dio dio;

  final auth = Options(extra: {Constants.REST_CLIENT_AUTH_REQUIRED_KEY: true});
  final publica =
      Options(extra: {Constants.REST_CLIENT_AUTH_REQUIRED_KEY: false});

  void montar(Map<String, (int, Object)> routes) {
    adapter = _FakeAdapter(routes);
    final refreshDio = Dio()..httpClientAdapter = adapter;
    dio = Dio()
      ..httpClientAdapter = adapter
      ..interceptors.add(AuthInterceptor(
        secureLocalStorage: storage,
        authStore: authStore,
        log: _MockLogger(),
        refreshDio: refreshDio,
      ));
  }

  setUp(() {
    storage = _MemoryStorage();
    authStore = AuthStore()..setUsuario(const User(id: 1, nome: 'a', email: 'a'));
  });

  test('rota pública não leva Authorization; autenticada leva', () async {
    final token = _jwt(const Duration(hours: 20));
    storage.values[Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY] = token;
    montar({'/x': (200, {})});

    await Future.wait([
      dio.get('/x', options: publica),
      dio.get('/x', options: auth),
    ]);

    final headers = adapter.requests.map((r) => r.headers['Authorization']);
    expect(headers, containsAll([null, token]));
  });

  test('token com menos de 12h de vida é renovado antes da requisição',
      () async {
    final velho = _jwt(const Duration(hours: 6));
    final novo = _jwt(const Duration(hours: 24));
    storage.values[Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY] = velho;
    storage.values[Constants.LOCAL_STORAGE_REFRESH_TOKEN_KEY] = 'Bearer r1';
    montar({
      'granio/auth/refresh': (200, {'access_token': novo, 'refresh_token': 'Bearer r2'}),
      '/x': (200, {}),
    });

    await dio.get('/x', options: auth);

    final refresh = adapter.requests.first;
    expect(refresh.path, 'granio/auth/refresh');
    expect(refresh.headers['Authorization'], velho);
    expect(refresh.data, {'refresh_token': 'Bearer r1'});
    expect(adapter.requests.last.headers['Authorization'], novo);
    expect(storage.values[Constants.LOCAL_STORAGE_REFRESH_TOKEN_KEY], 'Bearer r2');
  });

  test('refresh recusado não derruba a sessão enquanto o token vale',
      () async {
    final token = _jwt(const Duration(hours: 6));
    storage.values[Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY] = token;
    storage.values[Constants.LOCAL_STORAGE_REFRESH_TOKEN_KEY] = 'Bearer r1';
    montar({
      'granio/auth/refresh': (401, {'message': 'Sessão expirada.'}),
      '/x': (200, {}),
    });

    await dio.get('/x', options: auth);

    expect(adapter.requests.last.headers['Authorization'], token);
    expect(authStore.isLogado, isTrue);
  });

  test('token vencido: não chama o back e encerra a sessão', () async {
    storage.values[Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY] =
        _jwt(const Duration(hours: -1));
    montar({'/x': (200, {})});

    await expectLater(
      dio.get('/x', options: auth),
      throwsA(isA<DioException>()
          .having((e) => e.error, 'error', isA<SessionExpiredException>())),
    );
    expect(adapter.requests, isEmpty);
    expect(authStore.isLogado, isFalse);
    expect(storage.values, isEmpty);
  });

  test('403 "Login Expirado." encerra a sessão; outro 403 não', () async {
    storage.values[Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY] =
        _jwt(const Duration(hours: 20));
    montar({
      '/regra': (403, {'message': 'Sem permissão.'}),
      '/expirado': (403, {'message': 'Login Expirado.'}),
    });

    await expectLater(dio.get('/regra', options: auth), throwsA(isA<DioException>()));
    expect(authStore.isLogado, isTrue);

    await expectLater(
      dio.get('/expirado', options: auth),
      throwsA(isA<DioException>()
          .having((e) => e.error, 'error', isA<SessionExpiredException>())),
    );
    expect(authStore.isLogado, isFalse);
  });
}
