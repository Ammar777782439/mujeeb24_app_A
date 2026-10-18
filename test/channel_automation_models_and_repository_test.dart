import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mujeeb24_app/core/api/api_client.dart';
import 'package:mujeeb24_app/core/channels/channel_automation_repository.dart';
import 'package:mujeeb24_app/core/errors/api_error.dart';
import 'package:mujeeb24_app/core/models/channel_automation_models.dart';

void main() {
  const testBusinessId = 'b1111111-1111-1111-1111-111111111111';
  const testConnectionId = 'conn-2222-2222-2222-222222222222';
  const testRuleId = 'rule-3333-3333-3333-333333333333';
  const testDecisionId = 'dec-4444-4444-4444-444444444444';
  const testReplyId = 'reply-5555-5555-5555-555555555555';

  group('Phase 6 Channel & Automation Models Unit Tests', () {
    test('Capability parses and serializes correctly', () {
      final json = {
        'name': 'send_messages',
        'enabled': true,
        'evidence_source': 'verified_webhook',
        'checked_at': '2026-10-18T20:00:00Z',
      };

      final cap = Capability.fromJson(json);
      expect(cap.name, 'send_messages');
      expect(cap.enabled, isTrue);
      expect(cap.supported, isTrue);
      expect(cap.evidenceSource, 'verified_webhook');
      expect(cap.description, 'verified_webhook');

      final serialized = cap.toJson();
      expect(serialized['name'], 'send_messages');
      expect(serialized['enabled'], isTrue);
      expect(serialized['evidence_source'], 'verified_webhook');
    });

    test('ChannelConnection parses and handles status getters', () {
      final json = {
        'id': testConnectionId,
        'business_id': testBusinessId,
        'provider': 'meta',
        'channel': 'whatsapp',
        'status': 'active',
        'external_account_reference': '966500000000',
        'capabilities': [
          {'name': 'messages', 'enabled': true}
        ],
        'resource_version': '5',
      };

      final conn = ChannelConnection.fromJson(json);
      expect(conn.id, testConnectionId);
      expect(conn.provider, 'meta');
      expect(conn.channel, 'whatsapp');
      expect(conn.status, 'active');
      expect(conn.isConnected, isTrue);
      expect(conn.isDisconnected, isFalse);
      expect(conn.displayName, '966500000000');
      expect(conn.capabilities.length, 1);
      expect(conn.resourceVersion, '5');

      final serialized = conn.toJson();
      expect(serialized['id'], testConnectionId);
      expect(serialized['channel'], 'whatsapp');
      expect(serialized['resource_version'], '5');
    });

    test('ChannelProvisioning parses from 202 response payload', () {
      final json = {
        'provisioning_id': 'prov-12345',
        'business_id': testBusinessId,
        'provider': 'meta',
        'channel': 'whatsapp',
        'status': 'pending_auth',
        'authorization_url': 'https://business.facebook.com/oauth',
      };

      final prov = ChannelProvisioning.fromJson(json);
      expect(prov.provisioningId, 'prov-12345');
      expect(prov.status, 'pending_auth');
      expect(prov.authorizationUrl, 'https://business.facebook.com/oauth');

      final serialized = prov.toJson();
      expect(serialized['provisioning_id'], 'prov-12345');
      expect(serialized['authorization_url'], 'https://business.facebook.com/oauth');
    });

    test('ChannelHistorySummary parses and supplies count getters', () {
      final json = {
        'business_id': testBusinessId,
        'connection_id': testConnectionId,
        'conversations': 142,
        'messages': 1850,
      };

      final summary = ChannelHistorySummary.fromJson(json);
      expect(summary.businessId, testBusinessId);
      expect(summary.connectionId, testConnectionId);
      expect(summary.conversations, 142);
      expect(summary.messages, 1850);
      expect(summary.conversationsCount, 142);
      expect(summary.messagesCount, 1850);
    });

    test('AutomationRule parses and serializes correctly', () {
      final json = {
        'id': testRuleId,
        'business_id': testBusinessId,
        'name': 'تصنيف استفسارات الأسعار',
        'status': 'active',
        'trigger_kind': 'inbound_message',
        'conditions': {'keyword': 'سعر'},
        'action_kind': 'add_label',
        'action_payload': {'label': 'pricing'},
        'position': 1,
        'resource_version': '2',
      };

      final rule = AutomationRule.fromJson(json);
      expect(rule.id, testRuleId);
      expect(rule.name, 'تصنيف استفسارات الأسعار');
      expect(rule.isActive, isTrue);
      expect(rule.triggerKind, 'inbound_message');
      expect(rule.actionKind, 'add_label');
      expect(rule.resourceVersion, '2');

      final serialized = rule.toJson();
      expect(serialized['name'], 'تصنيف استفسارات الأسعار');
      expect(serialized['action_kind'], 'add_label');
    });

    test('AIDecision parses intent, entities, and flags correctly', () {
      final json = {
        'id': testDecisionId,
        'business_id': testBusinessId,
        'conversation_id': 'conv-999',
        'intent_base': 'inquire_catalog_offer',
        'entities': {'item': 'قهوة', 'quantity': 2},
        'evidence_references': ['msg-1'],
        'requires_human': true,
        'lifecycle': 'suggested',
      };

      final decision = AIDecision.fromJson(json);
      expect(decision.id, testDecisionId);
      expect(decision.intentBase, 'inquire_catalog_offer');
      expect(decision.intent, 'inquire_catalog_offer');
      expect(decision.requiresHuman, isTrue);
      expect(decision.entities['item'], 'قهوة');
      expect(decision.evidenceReferences, contains('msg-1'));
    });
  });

  group('Phase 6 ChannelAutomationRepository HTTP Tests', () {
    test('listChannelConnections makes correct GET request with query filters', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/v1/businesses/$testBusinessId/channel-connections');
        expect(request.url.queryParameters['status'], 'active');
        expect(request.url.queryParameters['limit'], '25');

        final responseBody = {
          'data': [
            {
              'id': testConnectionId,
              'business_id': testBusinessId,
              'provider': 'meta',
              'channel': 'whatsapp',
              'status': 'active',
              'resource_version': '1',
            }
          ],
          'pagination': {'has_more': false}
        };

        return http.Response(jsonEncode(responseBody), 200, headers: {
          'content-type': 'application/json',
          'x-request-id': 'req-channels-list',
        });
      });

      final apiClient = ApiClient(client: client);
      final repo = ChannelAutomationRepository(apiClient: apiClient);

      final result = await repo.listChannelConnections(
        businessId: testBusinessId,
        status: 'active',
      );

      expect(result.items.length, 1);
      expect(result.items.first.id, testConnectionId);
      expect(result.items.first.channel, 'whatsapp');
    });

    test('beginChannelConnection sends POST with Idempotency-Key and receives 202', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/businesses/$testBusinessId/channel-connections');
        expect(request.headers['Idempotency-Key'], isNotEmpty);

        final body = jsonDecode(request.body);
        expect(body['provider'], 'meta');
        expect(body['channel'], 'whatsapp');

        final responseBody = {
          'data': {
            'provisioning_id': 'prov-888',
            'business_id': testBusinessId,
            'provider': 'meta',
            'channel': 'whatsapp',
            'status': 'initiated',
            'authorization_url': 'https://meta.com/auth',
          }
        };

        return http.Response(jsonEncode(responseBody), 202, headers: {
          'content-type': 'application/json',
          'x-request-id': 'req-begin-conn',
        });
      });

      final apiClient = ApiClient(client: client);
      final repo = ChannelAutomationRepository(apiClient: apiClient);

      final prov = await repo.beginChannelConnection(
        businessId: testBusinessId,
        request: const BeginChannelConnectionRequest(
          provider: 'meta',
          channel: 'whatsapp',
        ),
      );

      expect(prov.provisioningId, 'prov-888');
      expect(prov.status, 'initiated');
      expect(prov.authorizationUrl, 'https://meta.com/auth');
    });

    test('reconnectChannel and disconnectChannel send If-Match header and reason', () async {
      int callCount = 0;
      final client = MockClient((request) async {
        callCount++;
        expect(request.method, 'POST');
        expect(request.headers['If-Match'], 'ver-4');

        final body = jsonDecode(request.body);
        expect(body['reason'], isNotEmpty);

        final isReconnect = request.url.path.endsWith('/reconnect');
        final responseBody = {
          'data': {
            'id': testConnectionId,
            'business_id': testBusinessId,
            'provider': 'meta',
            'channel': 'whatsapp',
            'status': isReconnect ? 'active' : 'disconnected',
            'resource_version': 'ver-5',
          }
        };

        return http.Response(jsonEncode(responseBody), 200, headers: {
          'content-type': 'application/json',
          'x-request-id': 'req-action-$callCount',
        });
      });

      final apiClient = ApiClient(client: client);
      final repo = ChannelAutomationRepository(apiClient: apiClient);

      final reconnected = await repo.reconnectChannel(
        businessId: testBusinessId,
        connectionId: testConnectionId,
        reason: 'Credentials updated',
        ifMatch: 'ver-4',
      );
      expect(reconnected.status, 'active');
      expect(reconnected.resourceVersion, 'ver-5');

      final disconnected = await repo.disconnectChannel(
        businessId: testBusinessId,
        connectionId: testConnectionId,
        reason: 'Maintenance pause',
        ifMatch: 'ver-4',
      );
      expect(disconnected.status, 'disconnected');
    });

    test('previewChannelHistoryPurge and purgeChannelHistory with exact confirmation string', () async {
      final client = MockClient((request) async {
        if (request.method == 'GET') {
          expect(request.url.path, '/api/v1/businesses/$testBusinessId/channel-connections/$testConnectionId/history-purge');
          final responseBody = {
            'data': {
              'business_id': testBusinessId,
              'connection_id': testConnectionId,
              'conversations': 50,
              'messages': 400,
            }
          };
          return http.Response(jsonEncode(responseBody), 200, headers: {
            'content-type': 'application/json',
          });
        } else {
          expect(request.method, 'POST');
          expect(request.url.path, '/api/v1/businesses/$testBusinessId/channel-connections/$testConnectionId/history-purge');
          expect(request.headers['If-Match'], 'ver-9');

          final body = jsonDecode(request.body);
          expect(body['confirmation'], 'DELETE_ALL_CHANNEL_HISTORY');
          expect(body['expected_version'], 'ver-9');

          final responseBody = {
            'data': {
              'business_id': testBusinessId,
              'connection_id': testConnectionId,
              'conversations': 0,
              'messages': 0,
              'purged_at': '2026-10-18T21:00:00Z',
            }
          };
          return http.Response(jsonEncode(responseBody), 200, headers: {
            'content-type': 'application/json',
          });
        }
      });

      final apiClient = ApiClient(client: client);
      final repo = ChannelAutomationRepository(apiClient: apiClient);

      final preview = await repo.previewChannelHistoryPurge(
        businessId: testBusinessId,
        connectionId: testConnectionId,
      );
      expect(preview.conversations, 50);
      expect(preview.messages, 400);

      final purged = await repo.purgeChannelHistory(
        businessId: testBusinessId,
        connectionId: testConnectionId,
        expectedVersion: 'ver-9',
        confirmation: 'DELETE_ALL_CHANNEL_HISTORY',
        ifMatch: 'ver-9',
      );
      expect(purged.conversations, 0);
      expect(purged.messages, 0);
      expect(purged.purgedAt, isNotNull);
    });

    test('purgeChannelHistory throws ApiErrorEnvelope on 412 version conflict', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'error': {
              'code': 'PRECONDITION_FAILED',
              'message': 'Resource version mismatch',
            }
          }),
          412,
          headers: {
            'content-type': 'application/json',
            'x-request-id': 'req-conflict-412',
          },
        );
      });

      final apiClient = ApiClient(client: client);
      final repo = ChannelAutomationRepository(apiClient: apiClient);

      expect(
        () => repo.purgeChannelHistory(
          businessId: testBusinessId,
          connectionId: testConnectionId,
          expectedVersion: 'ver-stale',
          confirmation: 'DELETE_ALL_CHANNEL_HISTORY',
          ifMatch: 'ver-stale',
        ),
        throwsA(isA<ApiErrorEnvelope>()),
      );
    });

    test('Automation Rules list, create, and update flow', () async {
      final client = MockClient((request) async {
        if (request.method == 'GET') {
          return http.Response(
            jsonEncode({
              'data': [
                {
                  'id': testRuleId,
                  'business_id': testBusinessId,
                  'name': 'قاعدة تحويل الشكاوى',
                  'status': 'active',
                  'trigger_kind': 'inbound_message',
                  'conditions': {'keyword': 'شكوى'},
                  'action_kind': 'assign_human',
                  'action_payload': {'user_id': 'u-123'},
                  'position': 1,
                  'resource_version': '1',
                }
              ]
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.method == 'POST') {
          final body = jsonDecode(request.body);
          return http.Response(
            jsonEncode({
              'data': {
                'id': 'rule-new-1',
                'business_id': testBusinessId,
                'name': body['name'],
                'status': 'active',
                'trigger_kind': 'inbound_message',
                'conditions': body['conditions'],
                'action_kind': body['action_kind'],
                'action_payload': body['action_payload'],
                'position': 2,
                'resource_version': '1',
              }
            }),
            201,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.method == 'PATCH') {
          expect(request.headers['If-Match'], '1');
          final body = jsonDecode(request.body);
          return http.Response(
            jsonEncode({
              'data': {
                'id': testRuleId,
                'business_id': testBusinessId,
                'name': body['name'] ?? 'قاعدة معدلة',
                'status': body['status'] ?? 'disabled',
                'trigger_kind': 'inbound_message',
                'conditions': {},
                'action_kind': 'assign_human',
                'action_payload': {},
                'position': 1,
                'resource_version': '2',
              }
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not found', 404);
      });

      final apiClient = ApiClient(client: client);
      final repo = ChannelAutomationRepository(apiClient: apiClient);

      final rules = await repo.listAutomationRules(businessId: testBusinessId);
      expect(rules.items.length, 1);
      expect(rules.items.first.name, 'قاعدة تحويل الشكاوى');

      final created = await repo.createAutomationRule(
        businessId: testBusinessId,
        request: const CreateAutomationRuleRequest(
          name: 'قاعدة المبيعات',
          conditions: {'keyword': 'شراء'},
          actionKind: 'add_label',
          actionPayload: {'label': 'lead'},
        ),
      );
      expect(created.name, 'قاعدة المبيعات');
      expect(created.actionKind, 'add_label');

      final updated = await repo.updateAutomationRule(
        businessId: testBusinessId,
        automationRuleId: testRuleId,
        request: const UpdateAutomationRuleRequest(status: 'disabled'),
        ifMatch: '1',
      );
      expect(updated.status, 'disabled');
      expect(updated.resourceVersion, '2');
    });

    test('AIDecisions list and requestHumanReview flow', () async {
      final client = MockClient((request) async {
        if (request.method == 'GET') {
          return http.Response(
            jsonEncode({
              'data': [
                {
                  'id': testDecisionId,
                  'business_id': testBusinessId,
                  'intent_base': 'inquire_booking',
                  'entities': {'date': 'tomorrow'},
                  'requires_human': true,
                  'lifecycle': 'suggested',
                }
              ]
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.method == 'POST') {
          expect(request.url.path.endsWith('/request-human'), isTrue);
          final body = jsonDecode(request.body);
          expect(body['reason'], 'Need supervisor verification');

          return http.Response(
            jsonEncode({
              'data': {
                'id': testDecisionId,
                'business_id': testBusinessId,
                'intent_base': 'inquire_booking',
                'entities': {'date': 'tomorrow'},
                'requires_human': true,
                'lifecycle': 'human_requested',
              }
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not found', 404);
      });

      final apiClient = ApiClient(client: client);
      final repo = ChannelAutomationRepository(apiClient: apiClient);

      final decisions = await repo.listAIDecisions(
        businessId: testBusinessId,
        requiresHuman: true,
      );
      expect(decisions.items.length, 1);
      expect(decisions.items.first.intentBase, 'inquire_booking');

      final humanRequested = await repo.requestHumanReview(
        businessId: testBusinessId,
        decisionId: testDecisionId,
        reason: 'Need supervisor verification',
      );
      expect(humanRequested.lifecycle, 'human_requested');
    });

    test('Canned Replies list, create, and update flow', () async {
      final client = MockClient((request) async {
        if (request.method == 'GET') {
          return http.Response(
            jsonEncode({
              'data': [
                {
                  'id': testReplyId,
                  'business_id': testBusinessId,
                  'title': 'ترحيب بالعميل',
                  'shortcut': '/welcome',
                  'body': 'أهلاً بك في متجرنا! كيف يمكننا مساعدتك؟',
                  'status': 'active',
                  'resource_version': '1',
                }
              ]
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.method == 'POST') {
          final body = jsonDecode(request.body);
          return http.Response(
            jsonEncode({
              'data': {
                'id': 'reply-new-1',
                'business_id': testBusinessId,
                'title': body['title'],
                'shortcut': body['shortcut'],
                'body': body['body'],
                'status': 'active',
                'resource_version': '1',
              }
            }),
            201,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.method == 'PATCH') {
          expect(request.headers['If-Match'], '1');
          final body = jsonDecode(request.body);
          return http.Response(
            jsonEncode({
              'data': {
                'id': testReplyId,
                'business_id': testBusinessId,
                'title': body['title'] ?? 'ترحيب محدث',
                'shortcut': '/hi',
                'body': 'مرحباً بك!',
                'status': 'active',
                'resource_version': '2',
              }
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not found', 404);
      });

      final apiClient = ApiClient(client: client);
      final repo = ChannelAutomationRepository(apiClient: apiClient);

      final replies = await repo.listCannedReplies(businessId: testBusinessId);
      expect(replies.length, 1);
      expect(replies.first.shortcut, '/welcome');

      final created = await repo.createCannedReply(
        businessId: testBusinessId,
        request: const CreateCannedReplyRequest(
          title: 'سياسة الاسترجاع',
          shortcut: '/refund',
          body: 'يمكنك استرجاع المنتجات خلال 14 يوماً.',
        ),
      );
      expect(created.shortcut, '/refund');

      final updated = await repo.updateCannedReply(
        businessId: testBusinessId,
        cannedReplyId: testReplyId,
        request: const UpdateCannedReplyRequest(shortcut: '/hi'),
        ifMatch: '1',
      );
      expect(updated.shortcut, '/hi');
      expect(updated.resourceVersion, '2');
    });
  });
}
