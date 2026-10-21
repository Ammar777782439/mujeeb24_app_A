import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mujeeb24_app/core/api/api_client.dart';
import 'package:mujeeb24_app/core/errors/api_error.dart';
import 'package:mujeeb24_app/core/models/platform_models.dart';
import 'package:mujeeb24_app/core/platform/platform_repository.dart';

void main() {
  group('Phase 8 Platform Models Unit Tests', () {
    test('PlatformBusinessView parses from and converts to JSON correctly', () {
      final jsonMap = {
        'id': 'biz_100',
        'name': 'Al-Amal Telecom',
        'slug': 'al-amal-telecom',
        'platform_status': 'active',
        'owner_identity_summary': 'owner@alamal.com',
        'subscription_summary': 'Enterprise Plan (Active)',
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-01-10T00:00:00Z',
      };

      final biz = PlatformBusinessView.fromJson(jsonMap);
      expect(biz.id, 'biz_100');
      expect(biz.name, 'Al-Amal Telecom');
      expect(biz.slug, 'al-amal-telecom');
      expect(biz.platformStatus, 'active');
      expect(biz.isActive, true);
      expect(biz.isSuspended, false);
      expect(biz.ownerIdentitySummary, 'owner@alamal.com');
      expect(biz.subscriptionSummary, 'Enterprise Plan (Active)');

      final serialized = biz.toJson();
      expect(serialized['id'], 'biz_100');
      expect(serialized['name'], 'Al-Amal Telecom');
      expect(serialized['platform_status'], 'active');
    });

    test('PlatformChannelView parses from and converts to JSON correctly', () {
      final jsonMap = {
        'business_id': 'biz_100',
        'connection_id': 'chan_200',
        'channel': 'whatsapp',
        'provider': 'meta',
        'status': 'active',
        'health': 'healthy',
        'provider_account_ref': 'waba_123',
        'provider_connection_ref': 'conn_99',
        'last_health_check_at': '2026-01-15T12:00:00Z',
        'last_success': '2026-01-15T12:00:00Z',
        'last_failure': null,
        'failure_code': null,
      };

      final channel = PlatformChannelView.fromJson(jsonMap);
      expect(channel.connectionId, 'chan_200');
      expect(channel.businessId, 'biz_100');
      expect(channel.provider, 'meta');
      expect(channel.channel, 'whatsapp');
      expect(channel.health, 'healthy');
      expect(channel.isHealthy, true);
      expect(channel.providerAccountRef, 'waba_123');

      final serialized = channel.toJson();
      expect(serialized['connection_id'], 'chan_200');
      expect(serialized['health'], 'healthy');
    });

    test('PlatformAIOverviewView & AIRuntime parse correctly', () {
      final jsonMap = {
        'runtime': {
          'status': 'enabled',
          'health': 'healthy',
        },
        'provider': {
          'provider': 'openrouter',
          'model': 'anthropic/claude-3.5-sonnet',
          'enabled': true,
          'health': 'healthy',
        },
      };

      final overview = PlatformAIOverviewView.fromJson(jsonMap);
      expect(overview.runtime.status, 'enabled');
      expect(overview.runtime.isEnabled, true);
      expect(overview.runtime.health, 'healthy');
      expect(overview.provider.provider, 'openrouter');
      expect(overview.provider.model, 'anthropic/claude-3.5-sonnet');
      expect(overview.provider.enabled, true);

      final serialized = overview.toJson();
      expect(serialized['runtime']['status'], 'enabled');
      expect(serialized['provider']['provider'], 'openrouter');
    });

    test('PlanView, SubscriptionView, and PaymentView parse correctly', () {
      final planMap = {
        'id': 'plan_starter',
        'code': 'STARTER',
        'display_name': 'باقة البداية',
        'price_yer': 25000,
        'billing_interval': 'monthly',
        'status': 'active',
        'ai_reply_limit': 1000,
        'ai_catalog_limit': 500,
        'channel_limit': 2,
        'internal_ai_cost_budget_yer': 20000,
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-01-01T00:00:00Z',
      };

      final plan = PlanView.fromJson(planMap);
      expect(plan.id, 'plan_starter');
      expect(plan.code, 'STARTER');
      expect(plan.displayName, 'باقة البداية');
      expect(plan.priceYer, 25000);
      expect(plan.status, 'active');
      expect(plan.isActive, true);
      expect(plan.aiReplyLimit, 1000);

      final subMap = {
        'id': 'sub_300',
        'business_id': 'biz_100',
        'plan_id': 'plan_starter',
        'plan_code': 'STARTER',
        'plan_version': 1,
        'period_start': '2026-01-01T00:00:00Z',
        'period_end': '2026-02-01T00:00:00Z',
        'status': 'active',
        'ai_reply_limit': 1000,
        'ai_catalog_limit': 500,
        'channel_limit': 2,
        'internal_ai_cost_budget_yer': 20000,
        'cost_budget_override_yer': 30000,
        'cost_budget_override_reason': 'High volume bonus',
        'created_at': '2026-01-01T00:00:00Z',
      };

      final sub = SubscriptionView.fromJson(subMap);
      expect(sub.id, 'sub_300');
      expect(sub.businessId, 'biz_100');
      expect(sub.planId, 'plan_starter');
      expect(sub.costBudgetOverrideYer, 30000);
      expect(sub.isActive, true);

      final payMap = {
        'id': 'pay_400',
        'subscription_id': 'sub_300',
        'business_id': 'biz_100',
        'amount_yer': 25000,
        'method': 'kuraimi',
        'reference': 'REF-998877',
        'paid_at': '2026-01-01T00:00:00Z',
        'recorded_by': 'admin_1',
      };

      final pay = PaymentView.fromJson(payMap);
      expect(pay.id, 'pay_400');
      expect(pay.method, 'kuraimi');
      expect(pay.amountYer, 25000);
      expect(pay.reference, 'REF-998877');
    });

    test('SupportTicketView & PlatformAuditEventView parse correctly', () {
      final ticketMap = {
        'id': 'tkt_500',
        'business_id': 'biz_100',
        'subject': 'استفسار عن تفعيل واتساب',
        'status': 'open',
        'priority': 'urgent',
        'category': 'technical',
        'created_by': 'user_1',
        'created_by_type': 'merchant',
        'created_at': '2026-01-18T10:00:00Z',
      };

      final ticket = SupportTicketView.fromJson(ticketMap);
      expect(ticket.id, 'tkt_500');
      expect(ticket.subject, 'استفسار عن تفعيل واتساب');
      expect(ticket.priority, 'urgent');
      expect(ticket.status, 'open');
      expect(ticket.isOpen, true);

      final auditMap = {
        'id': 'audit_600',
        'action': 'ai.runtime.kill_switch_enabled',
        'target_type': 'ai_runtime',
        'target_id': 'global_ai',
        'business_id': null,
        'actor_platform_admin_id': 'admin_super_1',
        'result': 'success',
        'failure_code': null,
        'occurred_at': '2026-01-20T12:00:00Z',
        'metadata': {'reason': 'Emergency maintenance'},
      };

      final audit = PlatformAuditEventView.fromJson(auditMap);
      expect(audit.id, 'audit_600');
      expect(audit.action, 'ai.runtime.kill_switch_enabled');
      expect(audit.targetType, 'ai_runtime');
      expect(audit.metadata['reason'], 'Emergency maintenance');
    });

    test('Pagination Wrappers parse list and pagination properly', () {
      final pageJson = {
        'data': [
          {
            'id': 'biz_1',
            'name': 'Biz 1',
            'slug': 'biz-1',
            'platform_status': 'active',
            'created_at': '2026-01-01T00:00:00Z',
            'updated_at': '2026-01-01T00:00:00Z',
          }
        ],
        'pagination': {
          'limit': 20,
          'has_more': false,
          'cursor': null,
        },
        'request_id': 'req_page_100',
      };

      final page = PlatformBusinessPage.fromJson(pageJson);
      expect(page.items.length, 1);
      expect(page.pagination.hasMore, false);
      expect(page.requestId, 'req_page_100');
    });
  });

  group('Phase 8 Platform Repository Integration with MockClient', () {
    test('listBusinesses queries businesses and parses page', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/platform/businesses');
        expect(request.url.queryParameters['platform_status'], 'active');
        expect(request.headers['Authorization'], 'Bearer mock_token');

        final body = jsonEncode({
          'data': [
            {
              'id': 'biz_1',
              'name': 'Test Store',
              'slug': 'test-store',
              'platform_status': 'active',
              'created_at': '2026-01-01T00:00:00Z',
              'updated_at': '2026-01-01T00:00:00Z',
            }
          ],
          'pagination': {
            'limit': 20,
            'has_more': false,
          },
          'request_id': 'req-biz-1',
        });

        return http.Response(
          body,
          200,
          headers: {'content-type': 'application/json', 'x-request-id': 'req-biz-1'},
        );
      });

      final apiClient = ApiClient(client: mockClient, baseUrl: 'https://api.mujeeb24.com');
      apiClient.setAccessToken('mock_token');
      final repo = PlatformRepository(apiClient: apiClient);

      final result = await repo.listBusinesses(platformStatus: 'active', limit: 20);
      expect(result.items.length, 1);
      expect(result.items.first.name, 'Test Store');
      expect(result.requestId, 'req-biz-1');
    });

    test('createBusiness, suspendBusiness, reactivateBusiness, archiveBusiness work correctly', () async {
      final mockClient = MockClient((request) async {
        if (request.method == 'POST' && request.url.path == '/api/v1/platform/businesses') {
          final payload = jsonDecode(request.body) as Map<String, dynamic>;
          expect(payload['name'], 'New Enterprise');
          expect(payload['slug'], 'new-ent');
          return http.Response(
            jsonEncode({
              'data': {
                'id': 'biz_new',
                'name': payload['name'],
                'slug': payload['slug'],
                'platform_status': 'pending_setup',
                'created_at': '2026-01-01T00:00:00Z',
                'updated_at': '2026-01-01T00:00:00Z',
              },
              'request_id': 'req_create',
            }),
            201,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.method == 'POST' && request.url.path == '/api/v1/platform/businesses/biz_new/suspend') {
          return http.Response(
            jsonEncode({
              'data': {
                'id': 'biz_new',
                'name': 'New Enterprise',
                'slug': 'new-ent',
                'platform_status': 'suspended',
                'created_at': '2026-01-01T00:00:00Z',
                'updated_at': '2026-01-01T00:00:00Z',
              },
              'request_id': 'req_suspend',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.method == 'POST' && request.url.path == '/api/v1/platform/businesses/biz_new/reactivate') {
          return http.Response(
            jsonEncode({
              'data': {
                'id': 'biz_new',
                'name': 'New Enterprise',
                'slug': 'new-ent',
                'platform_status': 'active',
                'created_at': '2026-01-01T00:00:00Z',
                'updated_at': '2026-01-01T00:00:00Z',
              },
              'request_id': 'req_reactivate',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.method == 'POST' && request.url.path == '/api/v1/platform/businesses/biz_new/archive') {
          return http.Response(
            jsonEncode({
              'data': {
                'id': 'biz_new',
                'name': 'New Enterprise',
                'slug': 'new-ent',
                'platform_status': 'archived',
                'created_at': '2026-01-01T00:00:00Z',
                'updated_at': '2026-01-01T00:00:00Z',
              },
              'request_id': 'req_archive',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('{"message":"not found"}', 404);
      });

      final apiClient = ApiClient(client: mockClient, baseUrl: 'https://api.mujeeb24.com');
      apiClient.setAccessToken('mock_token');
      final repo = PlatformRepository(apiClient: apiClient);

      final created = await repo.createBusiness(
        const PlatformCreateBusinessRequest(name: 'New Enterprise', slug: 'new-ent'),
      );
      expect(created.id, 'biz_new');
      expect(created.isPendingSetup, true);

      final suspended = await repo.suspendBusiness('biz_new');
      expect(suspended.isSuspended, true);

      final reactivated = await repo.reactivateBusiness('biz_new');
      expect(reactivated.isActive, true);

      final archived = await repo.archiveBusiness('biz_new');
      expect(archived.isArchived, true);
    });

    test('AI Emergency Kill Switch and Health Check endpoints work correctly', () async {
      final mockClient = MockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/api/v1/platform/ai') {
          return http.Response(
            jsonEncode({
              'data': {
                'runtime': {
                  'status': 'enabled',
                  'health': 'healthy',
                },
                'provider': {
                  'provider': 'openrouter',
                  'model': 'claude-3.5-sonnet',
                  'enabled': true,
                  'health': 'healthy',
                },
              },
              'request_id': 'req_ai_overview',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.method == 'POST' && request.url.path == '/api/v1/platform/ai/disable') {
          final payload = jsonDecode(request.body) as Map<String, dynamic>;
          expect(payload['reason'], 'Security emergency');
          return http.Response(
            jsonEncode({
              'data': {
                'runtime': {
                  'status': 'disabled',
                  'health': 'unhealthy',
                },
                'provider': {
                  'provider': 'openrouter',
                  'model': 'claude-3.5-sonnet',
                  'enabled': false,
                  'health': 'unhealthy',
                },
              },
              'request_id': 'req_ai_disable',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.method == 'POST' && request.url.path == '/api/v1/platform/ai/enable') {
          return http.Response(
            jsonEncode({
              'data': {
                'runtime': {
                  'status': 'enabled',
                  'health': 'healthy',
                },
                'provider': {
                  'provider': 'openrouter',
                  'model': 'claude-3.5-sonnet',
                  'enabled': true,
                  'health': 'healthy',
                },
              },
              'request_id': 'req_ai_enable',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.method == 'POST' && request.url.path == '/api/v1/platform/ai/health-check') {
          return http.Response(
            jsonEncode({
              'data': {
                'provider': 'openrouter',
                'model': 'claude-3.5-sonnet',
                'result': 'success',
                'latency_ms': 95,
                'checked_at': '2026-01-20T12:00:00Z',
              },
              'request_id': 'req_ai_health',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('{"message":"not found"}', 404);
      });

      final apiClient = ApiClient(client: mockClient, baseUrl: 'https://api.mujeeb24.com');
      apiClient.setAccessToken('mock_token');
      final repo = PlatformRepository(apiClient: apiClient);

      final overview = await repo.getAIOverview();
      expect(overview.runtime.isEnabled, true);

      final disabledRuntime = await repo.disableAI(reason: 'Security emergency');
      expect(disabledRuntime.runtime.isEnabled, false);

      final enabledRuntime = await repo.enableAI();
      expect(enabledRuntime.runtime.isEnabled, true);

      final health = await repo.runAIHealthCheck();
      expect(health.isSuccess, true);
      expect(health.latencyMs, 95);
    });

    test('Plans and Subscriptions lifecycle operations work correctly', () async {
      final mockClient = MockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/api/v1/platform/plans') {
          return http.Response(
            jsonEncode({
              'data': [
                {
                  'id': 'plan_pro',
                  'code': 'PRO',
                  'display_name': 'الخطة الاحترافية',
                  'price_yer': 60000,
                  'status': 'draft',
                  'billing_interval': 'monthly',
                  'ai_reply_limit': 5000,
                  'ai_catalog_limit': 1000,
                  'channel_limit': 5,
                  'created_at': '2026-01-01T00:00:00Z',
                  'updated_at': '2026-01-01T00:00:00Z',
                }
              ],
              'pagination': {
                'limit': 20,
                'has_more': false,
              },
              'request_id': 'req_plans',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.method == 'POST' && request.url.path == '/api/v1/platform/plans/plan_pro/activate') {
          return http.Response(
            jsonEncode({
              'data': {
                'id': 'plan_pro',
                'code': 'PRO',
                'display_name': 'الخطة الاحترافية',
                'price_yer': 60000,
                'status': 'active',
                'billing_interval': 'monthly',
                'ai_reply_limit': 5000,
                'ai_catalog_limit': 1000,
                'channel_limit': 5,
                'created_at': '2026-01-01T00:00:00Z',
                'updated_at': '2026-01-01T00:00:00Z',
              },
              'request_id': 'req_plan_activate',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.method == 'POST' && request.url.path == '/api/v1/platform/subscriptions/sub_1/ai-cost-budget') {
          final payload = jsonDecode(request.body) as Map<String, dynamic>;
          expect(payload['cost_budget_override_yer'], 75000);
          return http.Response(
            jsonEncode({
              'data': {
                'id': 'sub_1',
                'business_id': 'biz_1',
                'plan_id': 'plan_pro',
                'plan_code': 'PRO',
                'plan_version': 1,
                'period_start': '2026-01-01T00:00:00Z',
                'period_end': '2026-02-01T00:00:00Z',
                'status': 'active',
                'ai_reply_limit': 5000,
                'ai_catalog_limit': 1000,
                'channel_limit': 5,
                'cost_budget_override_yer': 75000,
                'cost_budget_override_reason': 'High demand',
                'created_at': '2026-01-01T00:00:00Z',
              },
              'request_id': 'req_sub_budget',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('{"message":"not found"}', 404);
      });

      final apiClient = ApiClient(client: mockClient, baseUrl: 'https://api.mujeeb24.com');
      apiClient.setAccessToken('mock_token');
      final repo = PlatformRepository(apiClient: apiClient);

      final plans = await repo.listPlans();
      expect(plans.items.first.status, 'draft');

      final activated = await repo.activatePlan('plan_pro');
      expect(activated.status, 'active');

      final updatedSub = await repo.overrideAICostBudget(
        'sub_1',
        const PlatformOverrideBudgetRequest(
          costBudgetOverrideYer: 75000,
          reason: 'High demand',
        ),
      );
      expect(updatedSub.costBudgetOverrideYer, 75000);
    });

    test('Support tickets and Audit events operate properly', () async {
      final mockClient = MockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/api/v1/platform/support/tickets') {
          return http.Response(
            jsonEncode({
              'data': [
                {
                  'id': 'tkt_1',
                  'business_id': 'biz_1',
                  'subject': 'Help needed',
                  'priority': 'urgent',
                  'status': 'open',
                  'category': 'technical',
                  'created_by': 'user_1',
                  'created_by_type': 'merchant',
                  'created_at': '2026-01-19T00:00:00Z',
                }
              ],
              'pagination': {
                'limit': 20,
                'has_more': false,
              },
              'request_id': 'req_tickets',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.method == 'POST' && request.url.path == '/api/v1/platform/support/tickets/tkt_1/resolve') {
          return http.Response(
            jsonEncode({
              'data': {
                'id': 'tkt_1',
                'business_id': 'biz_1',
                'subject': 'Help needed',
                'priority': 'urgent',
                'status': 'resolved',
                'category': 'technical',
                'created_by': 'user_1',
                'created_by_type': 'merchant',
                'created_at': '2026-01-19T00:00:00Z',
              },
              'request_id': 'req_ticket_resolve',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.method == 'GET' && request.url.path == '/api/v1/platform/audit-events') {
          return http.Response(
            jsonEncode({
              'data': [
                {
                  'id': 'audit_1',
                  'action': 'ticket.resolved',
                  'target_type': 'support_ticket',
                  'target_id': 'tkt_1',
                  'result': 'success',
                  'metadata': {},
                  'occurred_at': '2026-01-19T01:00:00Z',
                }
              ],
              'pagination': {
                'limit': 20,
                'has_more': false,
              },
              'request_id': 'req_audit',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('{"message":"not found"}', 404);
      });

      final apiClient = ApiClient(client: mockClient, baseUrl: 'https://api.mujeeb24.com');
      apiClient.setAccessToken('mock_token');
      final repo = PlatformRepository(apiClient: apiClient);

      final tickets = await repo.listTickets();
      expect(tickets.items.first.status, 'open');

      final resolved = await repo.resolveTicket('tkt_1');
      expect(resolved.status, 'resolved');

      final audit = await repo.listAuditEvents();
      expect(audit.items.first.action, 'ticket.resolved');
    });

    test('Throws ApiErrorEnvelope on HTTP 403 Forbidden', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'error': {
              'code': 'FORBIDDEN',
              'message': 'Platform admin privileges required',
              'retryable': false,
            },
            'request_id': 'req-forbidden-123',
          }),
          403,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient, baseUrl: 'https://api.mujeeb24.com');
      apiClient.setAccessToken('regular_merchant_token');
      final repo = PlatformRepository(apiClient: apiClient);

      expect(
        () async => await repo.listBusinesses(),
        throwsA(
          isA<ApiErrorEnvelope>().having(
            (e) => e.statusCode,
            'statusCode',
            403,
          ).having(
            (e) => e.error.message,
            'error.message',
            'Platform admin privileges required',
          ),
        ),
      );
    });
  });
}
