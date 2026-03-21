import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ojaewa/core/errors/app_exception.dart';
import 'package:ojaewa/features/auth/data/auth_api.dart';
import 'package:ojaewa/features/auth/data/logout_endpoints.dart';

void main() {
  group('AuthApi', () {
    late _MockDio dio;
    late AuthApi api;

    setUp(() {
      dio = _MockDio();
      api = AuthApi(dio);
    });

    test('login extracts a direct token response', () async {
      when(
        () => dio.post(
          '/api/login',
          data: {'email': 'tester@example.com', 'password': 'secret'},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/login'),
          data: {'token': 'token-1'},
        ),
      );

      final token = await api.login(
        email: 'tester@example.com',
        password: 'secret',
      );

      expect(token, 'token-1');
    });

    test('register extracts a nested token and includes referral code when present', () async {
      when(
        () => dio.post(
          '/api/register',
          data: {
            'firstname': 'Ada',
            'lastname': 'Lovelace',
            'email': 'ada@example.com',
            'password': 'secret',
            'referral_code': 'REF-42',
          },
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/register'),
          data: {
            'data': {'token': 'token-2'},
          },
        ),
      );

      final token = await api.register(
        firstname: 'Ada',
        lastname: 'Lovelace',
        email: 'ada@example.com',
        password: 'secret',
        referralCode: 'REF-42',
      );

      expect(token, 'token-2');
    });

    test('googleSignIn omits referral_code when absent', () async {
      when(
        () => dio.post(
          '/api/oauth/google',
          data: {'idToken': 'google-token'},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/oauth/google'),
          data: {'token': 'token-3'},
        ),
      );

      final token = await api.googleSignIn(idToken: 'google-token');

      expect(token, 'token-3');
    });

    test('logout posts to the configured logout path', () async {
      when(() => dio.post(userLogoutPath)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: userLogoutPath),
          data: const {},
        ),
      );

      await api.logout();

      verify(() => dio.post(userLogoutPath)).called(1);
    });

    test('maps a missing login token into an AppException', () async {
      when(
        () => dio.post(
          '/api/login',
          data: {'email': 'tester@example.com', 'password': 'secret'},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/login'),
          data: {'data': {'unexpected': true}},
        ),
      );

      expect(
        () => api.login(email: 'tester@example.com', password: 'secret'),
        throwsA(
          isA<AppException>().having(
            (error) => error.message,
            'message',
            'Unexpected error',
          ),
        ),
      );
    });

    test('maps backend failures to AppException', () async {
      when(
        () => dio.post(
          '/api/password/forgot',
          data: {'email': 'tester@example.com'},
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/password/forgot'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/password/forgot'),
            statusCode: 422,
            data: {'message': 'Email is invalid'},
          ),
        ),
      );

      expect(
        () => api.forgotPassword(email: 'tester@example.com'),
        throwsA(
          isA<NetworkException>().having(
            (error) => error.message,
            'message',
            'Email is invalid',
          ),
        ),
      );
    });
  });
}

class _MockDio extends Mock implements Dio {}
