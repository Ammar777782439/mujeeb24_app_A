import 'package:flutter_test/flutter_test.dart';
import 'package:mujeeb24_app/core/errors/api_error.dart';
import 'package:mujeeb24_app/core/models/auth_models.dart';

void main() {
  group('ApiErrorEnvelope Tests', () {
    test('parses standard OpenAPI ErrorEnvelope correctly', () {
      final json = {
        'error': {
          'code': 'INVALID_CREDENTIALS',
          'message': 'Invalid email or password',
          'retryable': false,
          'fields': {'email': 'not found'},
        },
        'request_id': 'req_xyz123',
      };

      final envelope = ApiErrorEnvelope.fromJson(json, statusCode: 401);

      expect(envelope.error.code, 'INVALID_CREDENTIALS');
      expect(envelope.error.message, 'Invalid email or password');
      expect(envelope.error.retryable, false);
      expect(envelope.requestId, 'req_xyz123');
      expect(envelope.statusCode, 401);
      expect(envelope.error.fields?['email'], 'not found');
    });

    test('fallback parsing for malformed error JSON', () {
      final json = {
        'message': 'Internal Server Error',
        'request_id': 'req_error_99',
      };

      final envelope = ApiErrorEnvelope.fromJson(json, statusCode: 500);

      expect(envelope.error.code, 'INVALID_ERROR_PAYLOAD');
      expect(envelope.error.message, 'Internal Server Error');
      expect(envelope.requestId, 'req_error_99');
      expect(envelope.statusCode, 500);
    });

    test('ApiErrorDetail parsing', () {
      final json = {
        'location': 'body.email',
        'message': 'Email is required',
        'value': '',
      };

      final detail = ApiErrorDetail.fromJson(json);
      expect(detail.location, 'body.email');
      expect(detail.message, 'Email is required');
      expect(detail.value, '');
    });
  });

  group('Auth Models Tests', () {
    test('parses Principal from JSON', () {
      final json = {
        'principal_id': 'prn_1',
        'display_name': 'Ahmad Merchant',
        'email': 'ahmad@example.com',
      };

      final principal = Principal.fromJson(json);
      expect(principal.principalId, 'prn_1');
      expect(principal.displayName, 'Ahmad Merchant');
      expect(principal.email, 'ahmad@example.com');
    });

    test('parses AuthResponse from JSON', () {
      final json = {
        'access_token': 'jwt.token.value',
        'token_type': 'Bearer',
        'expires_at': '2026-10-15T00:00:00Z',
        'is_platform_admin': false,
        'principal': {
          'principal_id': 'prn_1',
          'display_name': 'Ahmad Merchant',
          'email': 'ahmad@example.com',
        },
      };

      final auth = AuthResponse.fromJson(json);
      expect(auth.accessToken, 'jwt.token.value');
      expect(auth.tokenType, 'Bearer');
      expect(auth.isPlatformAdmin, false);
      expect(auth.principal.displayName, 'Ahmad Merchant');
    });

    test('parses Business and BusinessMembership', () {
      final json = {
        'business': {
          'id': 'biz_1',
          'name': 'Al-Ufuq Store',
          'slug': 'alufuq',
          'default_currency': 'SAR',
        },
        'permissions': [
          'conversations:read',
          'conversations:reply',
          'sales:read',
        ],
        'role': 'manager',
      };

      final membership = BusinessMembership.fromJson(json);
      expect(membership.business.id, 'biz_1');
      expect(membership.business.name, 'Al-Ufuq Store');
      expect(membership.role, 'manager');
      expect(membership.permissions.length, 3);
      expect(membership.permissions, contains('conversations:reply'));
    });

    test('parses TeamInvitation', () {
      final json = {
        'id': 'inv_100',
        'business_id': 'biz_1',
        'business_name': 'Al-Ufuq Store',
        'email': 'sales@alufuq.com',
        'display_name': 'Sales Agent',
        'account_state': 'new',
        'role': 'agent',
        'permissions': ['conversations:read'],
        'created_at': '2026-10-14T00:00:00Z',
        'expires_at': '2026-10-21T00:00:00Z',
      };

      final invitation = TeamInvitation.fromJson(json);
      expect(invitation.id, 'inv_100');
      expect(invitation.businessName, 'Al-Ufuq Store');
      expect(invitation.accountState, 'new');
      expect(invitation.role, 'agent');
    });
  });
}
