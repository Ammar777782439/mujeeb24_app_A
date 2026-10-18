import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mujeeb24_app/core/api/api_client.dart';
import 'package:mujeeb24_app/core/crm/crm_repository.dart';
import 'package:mujeeb24_app/core/models/crm_models.dart';

void main() {
  const businessId = 'biz_test_123';
  const customerId = 'cust_test_456';
  const leadId = 'lead_test_789';

  group('Phase 3 Models Tests', () {
    test('ContactPoint and ContactPointInput serialization', () {
      const input = ContactPointInput(kind: 'phone', value: '+966501112233');
      final inputJson = input.toJson();
      expect(inputJson['kind'], 'phone');
      expect(inputJson['value'], '+966501112233');

      final deserializedInput = ContactPointInput.fromJson(inputJson);
      expect(deserializedInput.kind, 'phone');
      expect(deserializedInput.value, '+966501112233');

      final pointJson = {
        'kind': 'email',
        'value_normalized': 'user@example.com',
        'verification_status': 'verified',
      };
      final point = ContactPoint.fromJson(pointJson);
      expect(point.kind, 'email');
      expect(point.valueNormalized, 'user@example.com');
      expect(point.verificationStatus, 'verified');
      expect(point.toJson(), pointJson);
    });

    test('Customer model serialization and primary getters', () {
      final customerJson = {
        'id': customerId,
        'business_id': businessId,
        'display_name': 'خالد السالم',
        'status': 'active',
        'resource_version': 'v1',
        'created_at': '2026-10-15T10:00:00Z',
        'updated_at': '2026-10-15T12:00:00Z',
        'contact_points': [
          {
            'kind': 'phone',
            'value_normalized': '+966500000001',
            'verification_status': 'verified',
          },
          {
            'kind': 'email',
            'value_normalized': 'khaled@alufuq.com',
            'verification_status': 'unverified',
          },
        ],
        'profile': {'vip': true},
      };

      final customer = Customer.fromJson(customerJson);
      expect(customer.id, customerId);
      expect(customer.businessId, businessId);
      expect(customer.displayName, 'خالد السالم');
      expect(customer.primaryPhone, '+966500000001');
      expect(customer.primaryEmail, 'khaled@alufuq.com');
      expect(customer.status, 'active');
      expect(customer.resourceVersion, 'v1');

      final serialized = customer.toJson();
      expect(serialized['id'], customerId);
      expect(serialized['display_name'], 'خالد السالم');
    });

    test('CommercialTransaction model serialization', () {
      final txJson = {
        'id': 'tx_999',
        'business_id': businessId,
        'customer_id': customerId,
        'lead_id': leadId,
        'transaction_type': 'order',
        'state': 'confirmed',
        'total_amount': 250.75,
        'currency': 'SAR',
        'lines': [],
        'schema_version': 1,
        'resource_version': 'v3',
        'created_at': '2026-10-15T14:00:00Z',
        'updated_at': '2026-10-15T14:30:00Z',
      };

      final tx = CommercialTransaction.fromJson(txJson);
      expect(tx.id, 'tx_999');
      expect(tx.totalAmount, 250.75);
      expect(tx.currency, 'SAR');
      expect(tx.state, 'confirmed');

      final serialized = tx.toJson();
      expect(serialized['id'], 'tx_999');
      expect(serialized['total_amount'], 250.75);
    });

    test('Lead model serialization', () {
      final leadJson = {
        'id': leadId,
        'business_id': businessId,
        'customer_id': customerId,
        'status': 'new',
        'created_by': 'agent_01',
        'resource_version': 'v2',
        'score_band': 'high',
        'current_score': 92.5,
      };

      final lead = Lead.fromJson(leadJson);
      expect(lead.id, leadId);
      expect(lead.scoreBand, 'high');
      expect(lead.currentScore, 92.5);
      expect(lead.status, 'new');

      final serialized = lead.toJson();
      expect(serialized['id'], leadId);
      expect(serialized['score_band'], 'high');
      expect(serialized['current_score'], 92.5);
    });

    test('LeadScore and LeadAttribution model serialization', () {
      final scoreJson = {
        'id': 'score_01',
        'lead_id': leadId,
        'value': 88.0,
        'band': 'high',
        'factors': {'budget': 'high', 'intent': 'immediate'},
        'calculated_at': '2026-10-15T15:00:00Z',
      };
      final score = LeadScore.fromJson(scoreJson);
      expect(score.value, 88.0);
      expect(score.band, 'high');
      expect(score.factors['budget'], 'high');

      final attrJson = {
        'id': 'attr_01',
        'lead_id': leadId,
        'source_channel': 'whatsapp',
        'source_conversation_id': 'conv_123',
        'catalog_item_id': 'item_456',
        'offer_id': 'offer_789',
        'captured_at': '2026-10-15T15:10:00Z',
      };
      final attr = LeadAttribution.fromJson(attrJson);
      expect(attr.sourceChannel, 'whatsapp');
      expect(attr.sourceConversationId, 'conv_123');
      expect(attr.catalogItemId, 'item_456');
    });
  });

  group('Phase 3 CrmRepository 15 API Endpoints Tests', () {
    test(
      '1. listCustomers GET /businesses/{business_id}/customers with filters',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/api/v1/businesses/$businessId/customers');
          expect(request.url.queryParameters['search'], 'خالد');
          expect(request.url.queryParameters['status'], 'active');
          expect(request.url.queryParameters['limit'], '25');

          return http.Response(
            jsonEncode({
              'data': [
                {
                  'id': customerId,
                  'business_id': businessId,
                  'display_name': 'خالد السالم',
                  'status': 'active',
                  'resource_version': 'v1',
                  'created_at': '2026-10-15T10:00:00Z',
                  'updated_at': '2026-10-15T10:00:00Z',
                },
              ],
              'pagination': {'has_more': false},
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(client: mockClient);
        final repo = CrmRepository(apiClient: apiClient);

        final result = await repo.listCustomers(
          businessId: businessId,
          search: 'خالد',
          status: 'active',
        );
        expect(result.length, 1);
        expect(result.first.displayName, 'خالد السالم');
      },
    );

    test(
      '2. createCustomer POST /businesses/{business_id}/customers with headers',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/api/v1/businesses/$businessId/customers');
          expect(request.headers['Idempotency-Key'], 'idem_cust_123');
          expect(request.headers['X-Request-ID'], 'req_cust_123');

          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['contact_points'], isNotNull);

          return http.Response(
            jsonEncode({
              'data': {
                'id': customerId,
                'business_id': businessId,
                'display_name': 'عميل جديد',
                'status': 'active',
                'resource_version': 'v1',
                'created_at': '2026-10-15T10:00:00Z',
                'updated_at': '2026-10-15T10:00:00Z',
              },
              'request_id': 'req_cust_123',
            }),
            201,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(client: mockClient);
        final repo = CrmRepository(apiClient: apiClient);

        final req = const CreateCustomerRequest(
          contactPoints: [
            ContactPointInput(kind: 'phone', value: '+966511112222'),
          ],
          localePreference: 'ar',
        );

        final customer = await repo.createCustomer(
          businessId: businessId,
          request: req,
          idempotencyKey: 'idem_cust_123',
          requestId: 'req_cust_123',
        );
        expect(customer.id, customerId);
        expect(customer.displayName, 'عميل جديد');
      },
    );

    test(
      '3. getCustomer GET /businesses/{business_id}/customers/{customer_id}',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.path,
            '/api/v1/businesses/$businessId/customers/$customerId',
          );

          return http.Response(
            jsonEncode({
              'data': {
                'id': customerId,
                'business_id': businessId,
                'display_name': 'خالد السالم',
                'status': 'active',
                'resource_version': 'v1',
                'created_at': '2026-10-15T10:00:00Z',
                'updated_at': '2026-10-15T10:00:00Z',
              },
              'request_id': 'req_get_cust',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(client: mockClient);
        final repo = CrmRepository(apiClient: apiClient);

        final customer = await repo.getCustomer(
          businessId: businessId,
          customerId: customerId,
        );
        expect(customer.id, customerId);
      },
    );

    test('4. updateCustomer PATCH /businesses/{business_id}/customers/{customer_id} with If-Match', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(
          request.url.path,
          '/api/v1/businesses/$businessId/customers/$customerId',
        );
        expect(request.headers['If-Match'], 'v1');

        return http.Response(
          jsonEncode({
            'data': {
              'id': customerId,
              'business_id': businessId,
              'display_name': 'خالد السالم - محدث',
              'status': 'active',
              'resource_version': 'v2',
              'created_at': '2026-10-15T10:00:00Z',
              'updated_at': '2026-10-15T11:00:00Z',
            },
            'request_id': 'req_patch_cust',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = CrmRepository(apiClient: apiClient);

      final req = const UpdateCustomerRequest(localePreference: 'en');
      final updated = await repo.updateCustomer(
        businessId: businessId,
        customerId: customerId,
        request: req,
        ifMatch: 'v1',
      );
      expect(updated.resourceVersion, 'v2');
      expect(updated.displayName, 'خالد السالم - محدث');
    });

    test('5. listCustomerConversations GET /businesses/{business_id}/customers/{customer_id}/conversations', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(
          request.url.path,
          '/api/v1/businesses/$businessId/customers/$customerId/conversations',
        );

        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 'conv_cust_01',
                'business_id': businessId,
                'customer': {'id': customerId, 'display_name': 'خالد'},
                'state': 'open',
                'ownership': 'ai',
                'ai_mode': 'copilot',
                'priority': 'high',
                'last_activity_at': '2026-10-15T10:00:00Z',
                'resource_version': 'v1',
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = CrmRepository(apiClient: apiClient);

      final convs = await repo.listCustomerConversations(
        businessId: businessId,
        customerId: customerId,
      );
      expect(convs.length, 1);
      expect(convs.first.id, 'conv_cust_01');
    });

    test('6. mergeCustomer POST /businesses/{business_id}/customers/{customer_id}/merge with 202', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(
          request.url.path,
          '/api/v1/businesses/$businessId/customers/$customerId/merge',
        );
        expect(request.headers['If-Match'], 'v2');

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['target_customer_id'], 'cust_target_999');
        expect(body['reason'], 'حساب مكرر');

        return http.Response(
          jsonEncode({
            'data': {
              'id': 'cust_target_999',
              'business_id': businessId,
              'display_name': 'خالد المستهدف',
              'status': 'active',
              'resource_version': 'v3',
              'created_at': '2026-10-15T10:00:00Z',
              'updated_at': '2026-10-15T12:00:00Z',
            },
            'request_id': 'req_merge',
          }),
          202,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = CrmRepository(apiClient: apiClient);

      const mergeReq = MergeCustomerRequest(
        targetCustomerId: 'cust_target_999',
        reason: 'حساب مكرر',
      );

      final merged = await repo.mergeCustomer(
        businessId: businessId,
        customerId: customerId,
        request: mergeReq,
        ifMatch: 'v2',
      );
      expect(merged.id, 'cust_target_999');
      expect(merged.resourceVersion, 'v3');
    });

    test('7. listCustomerTransactions GET /businesses/{business_id}/customers/{customer_id}/transactions', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(
          request.url.path,
          '/api/v1/businesses/$businessId/customers/$customerId/transactions',
        );

        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 'tx_001',
                'business_id': businessId,
                'customer_id': customerId,
                'transaction_type': 'order',
                'state': 'completed',
                'total_amount': 500.0,
                'currency': 'SAR',
                'lines': [],
                'schema_version': 1,
                'resource_version': 'v1',
                'created_at': '2026-10-15T10:00:00Z',
                'updated_at': '2026-10-15T10:00:00Z',
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = CrmRepository(apiClient: apiClient);

      final txs = await repo.listCustomerTransactions(
        businessId: businessId,
        customerId: customerId,
      );
      expect(txs.length, 1);
      expect(txs.first.totalAmount, 500.0);
    });

    test(
      '8. listLeads GET /businesses/{business_id}/leads with filters',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/api/v1/businesses/$businessId/leads');
          expect(request.url.queryParameters['status'], 'qualified');
          expect(request.url.queryParameters['score_band'], 'high');

          return http.Response(
            jsonEncode({
              'data': [
                {
                  'id': leadId,
                  'business_id': businessId,
                  'customer_id': customerId,
                  'status': 'qualified',
                  'created_by': 'agent_1',
                  'resource_version': 'v1',
                  'score_band': 'high',
                  'current_score': 95.0,
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(client: mockClient);
        final repo = CrmRepository(apiClient: apiClient);

        final leads = await repo.listLeads(
          businessId: businessId,
          status: 'qualified',
          scoreBand: 'high',
        );
        expect(leads.length, 1);
        expect(leads.first.status, 'qualified');
        expect(leads.first.scoreBand, 'high');
      },
    );

    test(
      '9. createLead POST /businesses/{business_id}/leads with Idempotency-Key',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/api/v1/businesses/$businessId/leads');
          expect(request.headers['Idempotency-Key'], 'idem_lead_123');

          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['customer_id'], customerId);

          return http.Response(
            jsonEncode({
              'data': {
                'id': leadId,
                'business_id': businessId,
                'customer_id': customerId,
                'status': 'new',
                'created_by': 'system',
                'resource_version': 'v1',
              },
              'request_id': 'req_lead_create',
            }),
            201,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(client: mockClient);
        final repo = CrmRepository(apiClient: apiClient);

        const req = CreateLeadRequest(
          customerId: customerId,
          qualificationContext: {'notes': 'مهتم بالمنتج'},
        );

        final lead = await repo.createLead(
          businessId: businessId,
          request: req,
          idempotencyKey: 'idem_lead_123',
        );
        expect(lead.id, leadId);
        expect(lead.customerId, customerId);
      },
    );

    test('10. getLead GET /businesses/{business_id}/leads/{lead_id}', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(
          request.url.path,
          '/api/v1/businesses/$businessId/leads/$leadId',
        );

        return http.Response(
          jsonEncode({
            'data': {
              'id': leadId,
              'business_id': businessId,
              'customer_id': customerId,
              'status': 'contacted',
              'created_by': 'system',
              'resource_version': 'v2',
            },
            'request_id': 'req_get_lead',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = CrmRepository(apiClient: apiClient);

      final lead = await repo.getLead(businessId: businessId, leadId: leadId);
      expect(lead.id, leadId);
      expect(lead.status, 'contacted');
    });

    test('11. updateLead PATCH /businesses/{business_id}/leads/{lead_id} with If-Match', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(
          request.url.path,
          '/api/v1/businesses/$businessId/leads/$leadId',
        );
        expect(request.headers['If-Match'], 'v2');

        return http.Response(
          jsonEncode({
            'data': {
              'id': leadId,
              'business_id': businessId,
              'customer_id': customerId,
              'status': 'contacted',
              'created_by': 'system',
              'resource_version': 'v3',
            },
            'request_id': 'req_patch_lead',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = CrmRepository(apiClient: apiClient);

      const req = UpdateLeadRequest(
        qualificationContext: {'notes': 'تم التحديث'},
      );

      final updated = await repo.updateLead(
        businessId: businessId,
        leadId: leadId,
        request: req,
        ifMatch: 'v2',
      );
      expect(updated.resourceVersion, 'v3');
    });

    test('12. listLeadAttributions GET /businesses/{business_id}/leads/{lead_id}/attributions', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(
          request.url.path,
          '/api/v1/businesses/$businessId/leads/$leadId/attributions',
        );

        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 'attr_01',
                'lead_id': leadId,
                'source_channel': 'whatsapp',
                'captured_at': '2026-10-15T12:00:00Z',
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = CrmRepository(apiClient: apiClient);

      final attrs = await repo.listLeadAttributions(
        businessId: businessId,
        leadId: leadId,
      );
      expect(attrs.length, 1);
      expect(attrs.first.sourceChannel, 'whatsapp');
    });

    test('13. markLeadLost POST /businesses/{business_id}/leads/{lead_id}/mark-lost with If-Match', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(
          request.url.path,
          '/api/v1/businesses/$businessId/leads/$leadId/mark-lost',
        );
        expect(request.headers['If-Match'], 'v3');

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['lost_reason'], 'الميزانية غير كافية');

        return http.Response(
          jsonEncode({
            'data': {
              'id': leadId,
              'business_id': businessId,
              'customer_id': customerId,
              'status': 'lost',
              'created_by': 'system',
              'resource_version': 'v4',
            },
            'request_id': 'req_lost',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = CrmRepository(apiClient: apiClient);

      final lost = await repo.markLeadLost(
        businessId: businessId,
        leadId: leadId,
        lostReason: 'الميزانية غير كافية',
        ifMatch: 'v3',
      );
      expect(lost.status, 'lost');
      expect(lost.resourceVersion, 'v4');
    });

    test('14. qualifyLead POST /businesses/{business_id}/leads/{lead_id}/qualify with If-Match', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(
          request.url.path,
          '/api/v1/businesses/$businessId/leads/$leadId/qualify',
        );
        expect(request.headers['If-Match'], 'v4');

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['reason'], 'تم تأكيد الطلب');
        expect(body['evidence_references'], ['conv_123']);

        return http.Response(
          jsonEncode({
            'data': {
              'id': leadId,
              'business_id': businessId,
              'customer_id': customerId,
              'status': 'qualified',
              'created_by': 'system',
              'resource_version': 'v5',
            },
            'request_id': 'req_qualify',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = CrmRepository(apiClient: apiClient);

      final qualified = await repo.qualifyLead(
        businessId: businessId,
        leadId: leadId,
        reason: 'تم تأكيد الطلب',
        evidenceReferences: ['conv_123'],
        ifMatch: 'v4',
      );
      expect(qualified.status, 'qualified');
      expect(qualified.resourceVersion, 'v5');
    });

    test(
      '15. listLeadScores GET /businesses/{business_id}/leads/{lead_id}/scores',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.path,
            '/api/v1/businesses/$businessId/leads/$leadId/scores',
          );

          return http.Response(
            jsonEncode({
              'data': [
                {
                  'id': 'score_101',
                  'lead_id': leadId,
                  'value': 96.0,
                  'band': 'high',
                  'factors': {'urgency': 'immediate'},
                  'calculated_at': '2026-10-15T16:00:00Z',
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(client: mockClient);
        final repo = CrmRepository(apiClient: apiClient);

        final scores = await repo.listLeadScores(
          businessId: businessId,
          leadId: leadId,
        );
        expect(scores.length, 1);
        expect(scores.first.value, 96.0);
        expect(scores.first.band, 'high');
      },
    );
  });
}
