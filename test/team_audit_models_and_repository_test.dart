import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mujeeb24_app/core/api/api_client.dart';
import 'package:mujeeb24_app/core/errors/api_error.dart';
import 'package:mujeeb24_app/core/models/team_audit_models.dart';
import 'package:mujeeb24_app/core/team/team_audit_repository.dart';
import 'package:mujeeb24_app/features/team/providers/team_audit_provider.dart';

void main() {
  group('Phase 7 Team & Audit Models Unit Tests', () {
    test('TeamRoles presets and default permissions conform to contract', () {
      expect(TeamRoles.assignableRoles, contains('admin'));
      expect(TeamRoles.assignableRoles, contains('manager'));
      expect(TeamRoles.assignableRoles, contains('agent'));
      expect(TeamRoles.assignableRoles, contains('analyst'));
      expect(TeamRoles.assignableRoles, contains('viewer'));
      expect(TeamRoles.assignableRoles.contains('owner'), isFalse);

      final adminPerms = TeamRoles.defaultPermissionsForRole(TeamRoles.admin);
      expect(adminPerms.length, equals(TeamPermissions.all.length));
      expect(adminPerms, contains(TeamPermissions.teamManage));

      final agentPerms = TeamRoles.defaultPermissionsForRole(TeamRoles.agent);
      expect(agentPerms, contains(TeamPermissions.conversationsReply));
      expect(agentPerms.contains(TeamPermissions.teamManage), isFalse);
    });

    test('TeamMember parses from and converts to JSON correctly', () {
      final json = {
        'principal_id': 'user-123',
        'email': 'sarah@business.com',
        'display_name': 'Sarah Al-Ahmad',
        'role': 'manager',
        'permissions': ['conversations:read', 'conversations:reply'],
        'status': 'active',
      };

      final member = TeamMember.fromJson(json);
      expect(member.principalId, equals('user-123'));
      expect(member.email, equals('sarah@business.com'));
      expect(member.displayName, equals('Sarah Al-Ahmad'));
      expect(member.role, equals('manager'));
      expect(member.permissions, hasLength(2));
      expect(member.isActive, isTrue);
      expect(member.isOwner, isFalse);

      final serialized = member.toJson();
      expect(serialized['principal_id'], equals('user-123'));
      expect(serialized['email'], equals('sarah@business.com'));
      expect(serialized['role'], equals('manager'));
    });

    test('TeamMember owner identification works correctly', () {
      const ownerMember = TeamMember(
        principalId: 'owner-999',
        email: 'owner@business.com',
        displayName: 'Owner Boss',
        role: 'owner',
        permissions: ['*'],
        status: 'active',
      );
      expect(ownerMember.isOwner, isTrue);
    });

    test('TeamInvitationDetails parses and serializes correctly', () {
      final json = {
        'id': 'inv-123',
        'business_id': 'biz-001',
        'business_name': 'Al-Ufuq Store',
        'email': 'newguy@business.com',
        'display_name': 'New Employee',
        'role': 'agent',
        'permissions': ['conversations:read'],
        'status': 'pending',
        'invited_by': 'owner-999',
        'expires_at': '2026-10-25T12:00:00Z',
        'created_at': '2026-10-22T12:00:00Z',
        'updated_at': '2026-10-22T12:00:00Z',
      };

      final inv = TeamInvitationDetails.fromJson(json);
      expect(inv.id, equals('inv-123'));
      expect(inv.businessId, equals('biz-001'));
      expect(inv.email, equals('newguy@business.com'));
      expect(inv.isPending, isTrue);
      expect(inv.isAccepted, isFalse);
      expect(inv.isRevoked, isFalse);

      final serialized = inv.toJson();
      expect(serialized['id'], equals('inv-123'));
      expect(serialized['role'], equals('agent'));
    });

    test('TeamInvitationCreated parses with acceptance token', () {
      final json = {
        'invitation': {
          'id': 'inv-456',
          'business_id': 'biz-001',
          'email': 'agent@business.com',
          'display_name': 'Agent One',
          'role': 'agent',
          'permissions': ['conversations:reply'],
          'status': 'pending',
          'invited_by': 'admin-1',
          'expires_at': '2026-10-25T12:00:00Z',
          'created_at': '2026-10-22T12:00:00Z',
          'updated_at': '2026-10-22T12:00:00Z',
        },
        'acceptance_token': 'secret-token-xyz-789',
      };

      final created = TeamInvitationCreated.fromJson(json);
      expect(created.acceptanceToken, equals('secret-token-xyz-789'));
      expect(created.invitation.id, equals('inv-456'));
    });

    test('AuditEvent parses and preserves metadata properly', () {
      final json = {
        'id': 'audit-001',
        'business_id': 'biz-001',
        'actor_type': 'principal',
        'actor_reference': 'admin@business.com',
        'action': 'team.member.role_updated',
        'resource_type': 'team_member',
        'resource_id': 'user-123',
        'metadata': {
          'previous_role': 'agent',
          'new_role': 'manager',
          'ip': '192.168.1.1',
        },
        'occurred_at': '2026-10-22T14:30:00Z',
      };

      final event = AuditEvent.fromJson(json);
      expect(event.id, equals('audit-001'));
      expect(event.actorType, equals('principal'));
      expect(event.action, equals('team.member.role_updated'));
      expect(event.metadata['previous_role'], equals('agent'));
      expect(event.metadata['new_role'], equals('manager'));

      final serialized = event.toJson();
      expect(serialized['id'], equals('audit-001'));
      expect(serialized['action'], equals('team.member.role_updated'));
    });

    test('Pagination pages parse list data and next_cursor correctly', () {
      final json = {
        'data': [
          {
            'principal_id': 'p-1',
            'email': 'one@biz.com',
            'display_name': 'One',
            'role': 'agent',
            'permissions': ['conversations:read'],
            'status': 'active',
          }
        ],
        'pagination': {'next_cursor': 'cur_99', 'has_more': true},
        'request_id': 'req-abc-123',
      };

      final page = TeamMemberPage.fromJson(json);
      expect(page.items, hasLength(1));
      expect(page.pagination.nextCursor, equals('cur_99'));
      expect(page.pagination.hasMore, isTrue);
      expect(page.requestId, equals('req-abc-123'));
    });
  });

  group('Phase 7 TeamAuditRepository Integration Tests with MockClient', () {
    test('listTeamMembers calls GET with query parameters', () async {
      final mock = MockClient((request) async {
        expect(request.method, equals('GET'));
        expect(
          request.url.path,
          equals('/api/v1/businesses/biz-001/team/members'),
        );
        expect(request.url.queryParameters['limit'], equals('25'));

        final body = {
          'data': [
            {
              'principal_id': 'u-1',
              'email': 'user1@biz.com',
              'display_name': 'User 1',
              'role': 'manager',
              'permissions': ['team:read'],
              'status': 'active',
            }
          ],
          'pagination': {'has_more': false},
          'request_id': 'req-team-list',
        };
        return http.Response(jsonEncode(body), 200,
            headers: {'content-type': 'application/json'});
      });

      final repo = TeamAuditRepository(apiClient: ApiClient(client: mock));
      final result = await repo.listTeamMembers(businessId: 'biz-001');

      expect(result.items, hasLength(1));
      expect(result.items.first.displayName, equals('User 1'));
      expect(result.requestId, equals('req-team-list'));
    });

    test('updateTeamMemberRole sends PATCH with Idempotency-Key and If-Match',
        () async {
      final mock = MockClient((request) async {
        expect(request.method, equals('PATCH'));
        expect(
          request.url.path,
          equals('/api/v1/businesses/biz-001/team/members/u-1/role'),
        );
        expect(request.headers['Idempotency-Key'], isNotEmpty);
        expect(request.headers['If-Match'], equals('ver-3'));

        final parsedBody = jsonDecode(request.body) as Map;
        expect(parsedBody['role'], equals('admin'));

        final body = {
          'data': {
            'principal_id': 'u-1',
            'email': 'user1@biz.com',
            'display_name': 'User 1',
            'role': 'admin',
            'permissions': ['team:manage'],
            'status': 'active',
          },
          'request_id': 'req-role-patch',
        };
        return http.Response(jsonEncode(body), 200,
            headers: {'content-type': 'application/json'});
      });

      final repo = TeamAuditRepository(apiClient: ApiClient(client: mock));
      final updated = await repo.updateTeamMemberRole(
        businessId: 'biz-001',
        principalId: 'u-1',
        request: const UpdateTeamMemberRoleRequest(role: 'admin'),
        ifMatch: 'ver-3',
      );

      expect(updated.role, equals('admin'));
    });

    test('updateTeamMemberAccess sends PATCH with role and permissions',
        () async {
      final mock = MockClient((request) async {
        expect(request.method, equals('PATCH'));
        expect(
          request.url.path,
          equals('/api/v1/businesses/biz-001/team/members/u-1/access'),
        );
        final parsedBody = jsonDecode(request.body) as Map;
        expect(parsedBody['role'], equals('manager'));
        expect(parsedBody['permissions'], contains('sales:read'));

        final body = {
          'data': {
            'principal_id': 'u-1',
            'email': 'user1@biz.com',
            'display_name': 'User 1',
            'role': 'manager',
            'permissions': ['sales:read', 'sales:write'],
            'status': 'active',
          },
          'request_id': 'req-access-patch',
        };
        return http.Response(jsonEncode(body), 200,
            headers: {'content-type': 'application/json'});
      });

      final repo = TeamAuditRepository(apiClient: ApiClient(client: mock));
      final updated = await repo.updateTeamMemberAccess(
        businessId: 'biz-001',
        principalId: 'u-1',
        request: const UpdateTeamMemberAccessRequest(
          role: 'manager',
          permissions: ['sales:read', 'sales:write'],
        ),
      );

      expect(updated.permissions, hasLength(2));
    });

    test('revokeTeamMember sends POST and updates status to revoked', () async {
      final mock = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(
          request.url.path,
          equals('/api/v1/businesses/biz-001/team/members/u-1/revoke'),
        );
        expect(request.headers['Idempotency-Key'], isNotEmpty);

        final body = {
          'data': {
            'principal_id': 'u-1',
            'email': 'user1@biz.com',
            'display_name': 'User 1',
            'role': 'agent',
            'permissions': [],
            'status': 'revoked',
          },
          'request_id': 'req-revoke-member',
        };
        return http.Response(jsonEncode(body), 200,
            headers: {'content-type': 'application/json'});
      });

      final repo = TeamAuditRepository(apiClient: ApiClient(client: mock));
      final member = await repo.revokeTeamMember(
        businessId: 'biz-001',
        principalId: 'u-1',
      );

      expect(member.status, equals('revoked'));
    });

    test('createTeamInvitation sends POST and receives acceptance token',
        () async {
      final mock = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(
          request.url.path,
          equals('/api/v1/businesses/biz-001/team/invitations'),
        );
        expect(request.headers['Idempotency-Key'], isNotEmpty);

        final parsedBody = jsonDecode(request.body) as Map;
        expect(parsedBody['email'], equals('agent@biz.com'));
        expect(parsedBody['role'], equals('agent'));
        expect(parsedBody['expires_in_hours'], equals(72));

        final body = {
          'data': {
            'invitation': {
              'id': 'inv-created-1',
              'business_id': 'biz-001',
              'email': 'agent@biz.com',
              'display_name': 'New Agent',
              'role': 'agent',
              'permissions': ['conversations:reply'],
              'status': 'pending',
              'invited_by': 'admin-1',
              'expires_at': '2026-10-25T12:00:00Z',
              'created_at': '2026-10-22T12:00:00Z',
              'updated_at': '2026-10-22T12:00:00Z',
            },
            'acceptance_token': 'new-token-12345',
          },
          'request_id': 'req-create-inv',
        };
        return http.Response(jsonEncode(body), 201,
            headers: {'content-type': 'application/json'});
      });

      final repo = TeamAuditRepository(apiClient: ApiClient(client: mock));
      final created = await repo.createTeamInvitation(
        businessId: 'biz-001',
        request: const CreateTeamInvitationRequest(
          email: 'agent@biz.com',
          displayName: 'New Agent',
          role: 'agent',
          permissions: ['conversations:reply'],
          expiresInHours: 72,
        ),
      );

      expect(created.acceptanceToken, equals('new-token-12345'));
      expect(created.invitation.email, equals('agent@biz.com'));
    });

    test('resendTeamInvitation and revokeTeamInvitation work properly',
        () async {
      final mock = MockClient((request) async {
        if (request.url.path.endsWith('/resend')) {
          final body = {
            'data': {
              'invitation': {
                'id': 'inv-1',
                'business_id': 'biz-001',
                'email': 'agent@biz.com',
                'display_name': 'Agent',
                'role': 'agent',
                'permissions': [],
                'status': 'pending',
                'invited_by': 'admin',
                'expires_at': '2026-10-28T12:00:00Z',
                'created_at': '2026-10-22T12:00:00Z',
                'updated_at': '2026-10-22T12:00:00Z',
              },
              'acceptance_token': 'renewed-token-999',
            },
            'request_id': 'req-resend',
          };
          return http.Response(jsonEncode(body), 201,
              headers: {'content-type': 'application/json'});
        } else if (request.url.path.endsWith('/revoke')) {
          final body = {
            'data': {
              'id': 'inv-1',
              'business_id': 'biz-001',
              'email': 'agent@biz.com',
              'display_name': 'Agent',
              'role': 'agent',
              'permissions': [],
              'status': 'revoked',
              'invited_by': 'admin',
              'expires_at': '2026-10-28T12:00:00Z',
              'created_at': '2026-10-22T12:00:00Z',
              'updated_at': '2026-10-22T12:00:00Z',
            },
            'request_id': 'req-revoke',
          };
          return http.Response(jsonEncode(body), 200,
              headers: {'content-type': 'application/json'});
        }
        return http.Response('Not Found', 404);
      });

      final repo = TeamAuditRepository(apiClient: ApiClient(client: mock));

      final resent = await repo.resendTeamInvitation(
        businessId: 'biz-001',
        invitationId: 'inv-1',
        expiresInHours: 48,
      );
      expect(resent.acceptanceToken, equals('renewed-token-999'));

      final revoked = await repo.revokeTeamInvitation(
        businessId: 'biz-001',
        invitationId: 'inv-1',
      );
      expect(revoked.status, equals('revoked'));
    });

    test('listAuditEvents sends filter queries and parses audit page',
        () async {
      final mock = MockClient((request) async {
        expect(request.method, equals('GET'));
        expect(
          request.url.path,
          equals('/api/v1/businesses/biz-001/audit-events'),
        );
        expect(request.url.queryParameters['actor_type'], equals('principal'));
        expect(
          request.url.queryParameters['action'],
          equals('team.member.created'),
        );
        expect(
          request.url.queryParameters['resource_type'],
          equals('team_member'),
        );

        final body = {
          'data': [
            {
              'id': 'audit-ev-1',
              'business_id': 'biz-001',
              'actor_type': 'principal',
              'actor_reference': 'admin@biz.com',
              'action': 'team.member.created',
              'resource_type': 'team_member',
              'resource_id': 'u-1',
              'metadata': {'role': 'agent'},
              'occurred_at': '2026-10-22T15:00:00Z',
            }
          ],
          'pagination': {'has_more': false},
          'request_id': 'req-audit-list',
        };
        return http.Response(jsonEncode(body), 200,
            headers: {'content-type': 'application/json'});
      });

      final repo = TeamAuditRepository(apiClient: ApiClient(client: mock));
      final page = await repo.listAuditEvents(
        businessId: 'biz-001',
        actorType: 'principal',
        action: 'team.member.created',
        resourceType: 'team_member',
      );

      expect(page.items, hasLength(1));
      expect(page.items.first.action, equals('team.member.created'));
      expect(page.requestId, equals('req-audit-list'));
    });

    test('throws ApiErrorEnvelope on HTTP 409 Conflict', () async {
      final mock = MockClient((request) async {
        final errorBody = {
          'error': {
            'code': 'CONFLICT',
            'message': 'Cannot revoke the only active owner in this business',
          },
          'request_id': 'req-err-409',
        };
        return http.Response(jsonEncode(errorBody), 409,
            headers: {'content-type': 'application/json'});
      });

      final repo = TeamAuditRepository(apiClient: ApiClient(client: mock));
      expect(
        () => repo.revokeTeamMember(
          businessId: 'biz-001',
          principalId: 'owner-principal',
        ),
        throwsA(isA<ApiErrorEnvelope>().having(
          (e) => e.error.message,
          'error message',
          contains('Cannot revoke the only active owner'),
        )),
      );
    });
  });

  group('Phase 7 TeamAuditProvider State Management Tests', () {
    test('Provider safeguards owner from revocation before calling API',
        () async {
      final mock = MockClient((request) async {
        return http.Response(
            jsonEncode({
              'data': [
                {
                  'principal_id': 'owner-1',
                  'email': 'owner@biz.com',
                  'display_name': 'The Owner',
                  'role': 'owner',
                  'permissions': ['*'],
                  'status': 'active',
                }
              ],
              'pagination': {'has_more': false},
              'request_id': 'req-1',
            }),
            200,
            headers: {'content-type': 'application/json'});
      });

      final repo = TeamAuditRepository(apiClient: ApiClient(client: mock));
      final provider = TeamAuditProvider(repository: repo);

      await provider.fetchMembers('biz-001', refresh: true);
      expect(provider.members, hasLength(1));

      // Attempting to revoke owner
      final success = await provider.revokeMember(
        businessId: 'biz-001',
        principalId: 'owner-1',
      );

      expect(success, isFalse);
      expect(provider.actionError, contains('المالك'));
    });

    test('Provider filters members by role and status', () async {
      final mock = MockClient((request) async {
        return http.Response(
            jsonEncode({
              'data': [
                {
                  'principal_id': 'u-1',
                  'email': 'admin@biz.com',
                  'display_name': 'Admin User',
                  'role': 'admin',
                  'permissions': ['*'],
                  'status': 'active',
                },
                {
                  'principal_id': 'u-2',
                  'email': 'agent@biz.com',
                  'display_name': 'Agent User',
                  'role': 'agent',
                  'permissions': [],
                  'status': 'revoked',
                }
              ],
              'pagination': {'has_more': false},
              'request_id': 'req-2',
            }),
            200,
            headers: {'content-type': 'application/json'});
      });

      final repo = TeamAuditRepository(apiClient: ApiClient(client: mock));
      final provider = TeamAuditProvider(repository: repo);

      await provider.fetchMembers('biz-001', refresh: true);
      expect(provider.members, hasLength(2));

      // Filter by role
      provider.setMemberFilters(role: 'admin');
      expect(provider.members, hasLength(1));
      expect(provider.members.first.role, equals('admin'));

      // Filter by status
      provider.setMemberFilters(role: 'all', status: 'revoked');
      expect(provider.members, hasLength(1));
      expect(provider.members.first.status, equals('revoked'));
    });
  });
}
