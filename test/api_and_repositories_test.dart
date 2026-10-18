import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mujeeb24_app/core/api/api_client.dart';
import 'package:mujeeb24_app/core/auth/auth_repository.dart';
import 'package:mujeeb24_app/core/auth/workspace_repository.dart';
import 'package:mujeeb24_app/core/errors/api_error.dart';

void main() {
  group('ApiClient & AuthRepository Integration Tests', () {
    test('successful login sets Bearer token and extracts Cookie', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/v1/auth/login') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['email'], 'admin@alufuq.com');
          expect(body['password'], 'Password123!');

          return http.Response(
            jsonEncode({
              'data': {
                'access_token': 'jwt_access_token_123',
                'token_type': 'Bearer',
                'expires_at': '2026-10-15T00:00:00Z',
                'is_platform_admin': false,
                'principal': {
                  'principal_id': 'prn_1',
                  'display_name': 'Admin User',
                  'email': 'admin@alufuq.com',
                },
              },
              'request_id': 'req_login_success',
            }),
            200,
            headers: {
              'set-cookie': 'mujeeb_refresh=opaque_cookie_value; Path=/api/v1/auth; HttpOnly; SameSite=Strict',
            },
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(client: mockClient);
      final authRepo = AuthRepository(apiClient: apiClient);

      final result = await authRepo.login(
        email: 'admin@alufuq.com',
        password: 'Password123!',
      );

      expect(result.accessToken, 'jwt_access_token_123');
      expect(result.principal.displayName, 'Admin User');
      expect(apiClient.accessToken, 'jwt_access_token_123');
      expect(apiClient.refreshCookie, 'mujeeb_refresh=opaque_cookie_value');
    });

    test('failed login throws ApiErrorEnvelope with 401', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'error': {
              'code': 'UNAUTHORIZED',
              'message': 'Invalid credentials provided',
              'retryable': false,
            },
            'request_id': 'req_login_fail',
          }),
          401,
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final authRepo = AuthRepository(apiClient: apiClient);

      expect(
        () => authRepo.login(email: 'wrong@test.com', password: 'bad'),
        throwsA(
          isA<ApiErrorEnvelope>().having(
            (e) => e.error.code,
            'error code',
            'UNAUTHORIZED',
          ),
        ),
      );
    });

    test('refreshSession sends Cookie and rotates token', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/v1/auth/refresh') {
          expect(request.headers['Cookie'], 'mujeeb_refresh=old_cookie');

          return http.Response(
            jsonEncode({
              'data': {
                'access_token': 'new_rotated_jwt',
                'token_type': 'Bearer',
                'expires_at': '2026-10-16T00:00:00Z',
                'is_platform_admin': false,
                'principal': {
                  'principal_id': 'prn_1',
                  'display_name': 'Admin User',
                },
              },
              'request_id': 'req_refresh',
            }),
            200,
            headers: {
              'set-cookie': 'mujeeb_refresh=new_rotated_cookie; HttpOnly',
            },
          );
        }
        return http.Response('Unauthorized', 401);
      });

      final apiClient = ApiClient(client: mockClient);
      apiClient.setRefreshCookie('mujeeb_refresh=old_cookie');
      final authRepo = AuthRepository(apiClient: apiClient);

      final res = await authRepo.refreshSession();
      expect(res.accessToken, 'new_rotated_jwt');
      expect(apiClient.accessToken, 'new_rotated_jwt');
      expect(apiClient.refreshCookie, 'mujeeb_refresh=new_rotated_cookie');
    });

    test('logout calls POST /auth/logout and clears session locally', () async {
      bool logoutCalled = false;
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/v1/auth/logout') {
          logoutCalled = true;
          return http.Response('', 204);
        }
        return http.Response('', 404);
      });

      final apiClient = ApiClient(client: mockClient);
      apiClient.setAccessToken('token_123');
      apiClient.setRefreshCookie('cookie_123');
      final authRepo = AuthRepository(apiClient: apiClient);

      await authRepo.logout();
      expect(logoutCalled, true);
      expect(apiClient.accessToken, isNull);
      expect(apiClient.refreshCookie, isNull);
    });

    test('getCurrentPrincipal GET /me returns Principal', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/v1/me') {
          expect(request.headers['Authorization'], 'Bearer current_token');
          return http.Response(
            jsonEncode({
              'data': {
                'principal_id': 'prn_42',
                'display_name': 'Sarah Analyst',
                'email': 'sarah@alufuq.com',
              },
              'request_id': 'req_me',
            }),
            200,
          );
        }
        return http.Response('', 401);
      });

      final apiClient = ApiClient(client: mockClient);
      apiClient.setAccessToken('current_token');
      final authRepo = AuthRepository(apiClient: apiClient);

      final principal = await authRepo.getCurrentPrincipal();
      expect(principal.principalId, 'prn_42');
      expect(principal.displayName, 'Sarah Analyst');
    });

    test(
      'getAccessibleBusinesses GET /me/businesses returns memberships',
      () async {
        final mockClient = MockClient((request) async {
          if (request.url.path == '/api/v1/me/businesses') {
            return http.Response(
              jsonEncode({
                'data': [
                  {
                    'business': {
                      'id': 'biz_1',
                      'name': 'Al-Ufuq Store',
                      'slug': 'alufuq',
                    },
                    'permissions': ['*'],
                    'role': 'owner',
                  },
                  {
                    'business': {
                      'id': 'biz_2',
                      'name': 'Branch 2',
                      'slug': 'branch-2',
                    },
                    'permissions': ['conversations:read'],
                    'role': 'agent',
                  },
                ],
                'pagination': {'has_more': false},
                'request_id': 'req_businesses',
              }),
              200,
            );
          }
          return http.Response('', 404);
        });

        final apiClient = ApiClient(client: mockClient);
        apiClient.setAccessToken('token');
        final wsRepo = WorkspaceRepository(apiClient: apiClient);

        final list = await wsRepo.getAccessibleBusinesses();
        expect(list.length, 2);
        expect(list[0].business.name, 'Al-Ufuq Store');
        expect(list[1].business.name, 'Branch 2');
      },
    );

    test('inspectInvitation inspects token successfully', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/v1/auth/invitations/inspect') {
          final body = jsonDecode(request.body);
          expect(body['acceptance_token'], 'valid_token_123');
          return http.Response(
            jsonEncode({
              'data': {
                'id': 'inv_1',
                'business_id': 'biz_1',
                'business_name': 'Al-Ufuq Store',
                'email': 'newbie@alufuq.com',
                'display_name': 'Newbie',
                'account_state': 'new',
                'role': 'agent',
                'permissions': ['conversations:read'],
                'created_at': '2026-10-14T00:00:00Z',
                'expires_at': '2026-10-21T00:00:00Z',
              },
              'request_id': 'req_inspect',
            }),
            200,
          );
        }
        return http.Response('', 404);
      });

      final apiClient = ApiClient(client: mockClient);
      final authRepo = AuthRepository(apiClient: apiClient);

      final inv = await authRepo.inspectInvitation(
        acceptanceToken: 'valid_token_123',
      );
      expect(inv.businessName, 'Al-Ufuq Store');
      expect(inv.accountState, 'new');
    });

    test('baseUrl normalization handles root domain and trailing slashes', () {
      expect(
        ApiClient.normalizeBaseUrl('https://mujeeb24-api.onrender.com'),
        'https://mujeeb24-api.onrender.com/api/v1',
      );
      expect(
        ApiClient.normalizeBaseUrl('https://mujeeb24-api.onrender.com/'),
        'https://mujeeb24-api.onrender.com/api/v1',
      );
      expect(
        ApiClient.normalizeBaseUrl('https://mujeeb24-api.onrender.com/api/v1'),
        'https://mujeeb24-api.onrender.com/api/v1',
      );
      expect(
        ApiClient.normalizeBaseUrl('http://localhost:8080'),
        'http://localhost:8080/api/v1',
      );
    });

    test(
      'RFC 7807 validation error detail and errors are parsed in ApiClient',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'title': 'Unprocessable Entity',
              'status': 422,
              'detail': 'validation failed',
              'errors': [
                {
                  'message': 'expected required property email to be present',
                  'location': 'body',
                },
              ],
            }),
            422,
          );
        });

        final apiClient = ApiClient(client: mockClient);
        try {
          await apiClient.post('/auth/login', body: {});
          fail('Should have thrown ApiErrorEnvelope');
        } on ApiErrorEnvelope catch (e) {
          expect(e.statusCode, 422);
          expect(
            e.error.message,
            'validation failed: expected required property email to be present',
          );
        }
      },
    );
  });
}
