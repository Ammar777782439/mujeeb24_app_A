import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mujeeb24_app/core/api/api_client.dart';
import 'package:mujeeb24_app/core/errors/api_error.dart';
import 'package:mujeeb24_app/core/models/transaction_models.dart';
import 'package:mujeeb24_app/core/transactions/transaction_repository.dart';

void main() {
  const testBusinessId = 'b1111111-1111-1111-1111-111111111111';
  const testTransactionId = 't2222222-2222-2222-2222-222222222222';
  const testCustomerId = 'c3333333-3333-3333-3333-333333333333';

  group('Phase 4 Transaction Models Unit Tests', () {
    test('OrderLineSnapshot parses from and converts to JSON correctly', () {
      final json = {
        'id': 'line_01',
        'catalog_item_id': 'item_uuid_10',
        'item_name_snapshot': 'عطر الفخامة الملكي',
        'quantity': 2.5,
        'unit_price_snapshot': 150.0,
        'currency': 'SAR',
        'offer_id': 'offer_99',
        'variant_id': 'var_88',
      };

      final snapshot = OrderLineSnapshot.fromJson(json);
      expect(snapshot.id, 'line_01');
      expect(snapshot.catalogItemId, 'item_uuid_10');
      expect(snapshot.itemNameSnapshot, 'عطر الفخامة الملكي');
      expect(snapshot.quantity, 2.5);
      expect(snapshot.unitPriceSnapshot, 150.0);
      expect(snapshot.currency, 'SAR');
      expect(snapshot.offerId, 'offer_99');
      expect(snapshot.variantId, 'var_88');

      final serialized = snapshot.toJson();
      expect(serialized['id'], 'line_01');
      expect(serialized['catalog_item_id'], 'item_uuid_10');
      expect(serialized['quantity'], 2.5);
      expect(serialized['unit_price_snapshot'], 150.0);
    });

    test('TransactionLineInput parses from and converts to JSON correctly', () {
      final input = const TransactionLineInput(
        catalogItemId: 'item_01',
        quantity: 3.0,
        offerId: 'off_1',
        variantId: 'var_1',
        selectedAttributes: {'size': 'L', 'color': 'black'},
      );

      final json = input.toJson();
      expect(json['catalog_item_id'], 'item_01');
      expect(json['quantity'], 3.0);
      expect(json['offer_id'], 'off_1');
      expect(json['variant_id'], 'var_1');
      expect(json['selected_attributes'], {'size': 'L', 'color': 'black'});

      final parsed = TransactionLineInput.fromJson(json);
      expect(parsed.catalogItemId, 'item_01');
      expect(parsed.quantity, 3.0);
      expect(parsed.offerId, 'off_1');
      expect(parsed.selectedAttributes?['size'], 'L');
    });

    test('CreateTransactionDraftRequest builds correct JSON payload', () {
      final req = const CreateTransactionDraftRequest(
        customerId: testCustomerId,
        transactionType: 'order',
        lines: [TransactionLineInput(catalogItemId: 'item_101', quantity: 1.0)],
        currency: 'SAR',
        leadId: 'lead_55',
      );

      final json = req.toJson();
      expect(json['customer_id'], testCustomerId);
      expect(json['transaction_type'], 'order');
      expect(json['currency'], 'SAR');
      expect(json['lead_id'], 'lead_55');
      expect((json['lines'] as List).length, 1);
    });

    test('UpdateTransactionDraftRequest builds correct JSON payload', () {
      final req = const UpdateTransactionDraftRequest(
        currency: 'USD',
        lines: [TransactionLineInput(catalogItemId: 'item_202', quantity: 4.0)],
      );

      final json = req.toJson();
      expect(json['currency'], 'USD');
      expect((json['lines'] as List).length, 1);
    });

    test('TransactionReasonRequest, ConfirmTransactionRequest, and SubmitReviewRequest', () {
      final reasonReq = const TransactionReasonRequest(
        reason: 'Customer requested cancellation',
      );
      expect(reasonReq.toJson()['reason'], 'Customer requested cancellation');

      final confirmReq = const ConfirmTransactionRequest(
        evidenceReference: 'bank_transfer_ref_123',
        policyVersion: 'v2.1',
      );
      final confirmJson = confirmReq.toJson();
      expect(confirmJson['evidence_reference'], 'bank_transfer_ref_123');
      expect(confirmJson['policy_version'], 'v2.1');

      final submitReq = const SubmitReviewRequest(
        reasonCodes: ['high_value', 'custom_discount'],
      );
      expect(submitReq.toJson()['reason_codes'], [
        'high_value',
        'custom_discount',
      ]);
    });

    test('ReviewDecisionRequest and TransactionReview properties', () {
      final decisionReq = const ReviewDecisionRequest(
        reviewerReference: 'super_admin_01',
        reason: 'Authorized discount override',
      );
      final dJson = decisionReq.toJson();
      expect(dJson['reviewer_reference'], 'super_admin_01');
      expect(dJson['reason'], 'Authorized discount override');

      final reviewJson = {
        'required': true,
        'status': 'pending',
        'reason_codes': ['requires_approval'],
        'reviewer_reference': 'auditor_01',
      };
      final review = TransactionReview.fromJson(reviewJson);
      expect(review.required, true);
      expect(review.isPending, true);
      expect(review.isApproved, false);
      expect(review.isRejected, false);
      expect(review.reviewerReference, 'auditor_01');

      final approved = TransactionReview.fromJson({
        'required': true,
        'status': 'approved',
      });
      expect(approved.isApproved, true);
    });

    test('CommercialTransactionExtension.parsedLines parses raw dynamic lines properly', () {
      const tx = CommercialTransaction(
        id: 'tx_99',
        businessId: testBusinessId,
        customerId: testCustomerId,
        transactionType: 'order',
        state: 'draft',
        schemaVersion: 1,
        resourceVersion: 'v10',
        createdAt: '2026-10-16T12:00:00Z',
        updatedAt: '2026-10-16T12:00:00Z',
        lines: [
          {
            'id': 'line_1',
            'catalog_item_id': 'item_1',
            'item_name_snapshot': 'ساعة فاخرة',
            'quantity': 1.0,
            'unit_price_snapshot': 500.0,
            'currency': 'SAR',
          },
        ],
      );

      final parsed = tx.parsedLines;
      expect(parsed.length, 1);
      expect(parsed.first.itemNameSnapshot, 'ساعة فاخرة');
      expect(parsed.first.unitPriceSnapshot, 500.0);
    });
  });

  group('Phase 4 TransactionRepository 10 API Endpoints Tests', () {
    test('1. listTransactions GET /businesses/{business_id}/transactions with filters', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(
          request.url.path,
          '/api/v1/businesses/$testBusinessId/transactions',
        );
        expect(request.url.queryParameters['limit'], '25');
        expect(request.url.queryParameters['state'], 'review');
        expect(request.url.queryParameters['transaction_type'], 'order');
        expect(request.headers['Authorization'], 'Bearer mock_token');

        final responseBody = {
          'data': [
            {
              'id': testTransactionId,
              'business_id': testBusinessId,
              'customer_id': testCustomerId,
              'transaction_type': 'order',
              'state': 'review',
              'total_amount': 750.0,
              'currency': 'SAR',
              'lines': [
                {
                  'id': 'line_01',
                  'catalog_item_id': 'item_01',
                  'item_name_snapshot': 'عباية مطرزة',
                  'quantity': 1.0,
                  'unit_price_snapshot': 750.0,
                },
              ],
              'schema_version': 1,
              'resource_version': 'v1',
              'created_at': '2026-10-16T12:00:00Z',
              'updated_at': '2026-10-16T12:00:00Z',
            },
          ],
          'pagination': {'has_more': false, 'next_cursor': null},
          'request_id': 'req_list_tx_01',
        };

        return http.Response.bytes(
          utf8.encode(jsonEncode(responseBody)),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final apiClient = ApiClient(
        baseUrl: 'https://api.test.mujeeb24.com/api/v1',
        client: mockClient,
      );
      apiClient.setAccessToken('mock_token');
      final repo = TransactionRepository(apiClient: apiClient);

      final page = await repo.listTransactions(
        businessId: testBusinessId,
        state: 'review',
        transactionType: 'order',
      );

      expect(page.items.length, 1);
      expect(page.items.first.id, testTransactionId);
      expect(page.items.first.state, 'review');
      expect(page.hasMore, false);
      expect(page.requestId, 'req_list_tx_01');
    });

    test('2. createTransactionDraft POST /businesses/{business_id}/transactions with Idempotency-Key', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(
          request.url.path,
          '/api/v1/businesses/$testBusinessId/transactions',
        );
        expect(request.headers['Idempotency-Key'], 'custom_idemp_key_1');
        final decoded = jsonDecode(request.body) as Map<String, dynamic>;
        expect(decoded['customer_id'], testCustomerId);
        expect(decoded['transaction_type'], 'order');

        final responseBody = {
          'data': {
            'id': testTransactionId,
            'business_id': testBusinessId,
            'customer_id': testCustomerId,
            'transaction_type': 'order',
            'state': 'draft',
            'total_amount': 300.0,
            'currency': 'SAR',
            'lines': [],
            'schema_version': 1,
            'resource_version': 'v1',
            'created_at': '2026-10-16T12:00:00Z',
            'updated_at': '2026-10-16T12:00:00Z',
          },
          'request_id': 'req_create_draft_01',
        };

        return http.Response(
          jsonEncode(responseBody),
          201,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
        );
      });

      final apiClient = ApiClient(
        baseUrl: 'https://api.test.mujeeb24.com/api/v1',
        client: mockClient,
      );
      apiClient.setAccessToken('mock_token');
      final repo = TransactionRepository(apiClient: apiClient);

      final tx = await repo.createTransactionDraft(
        businessId: testBusinessId,
        request: const CreateTransactionDraftRequest(
          customerId: testCustomerId,
          transactionType: 'order',
          lines: [
            TransactionLineInput(catalogItemId: 'item_01', quantity: 1.0),
          ],
        ),
        idempotencyKey: 'custom_idemp_key_1',
      );

      expect(tx.id, testTransactionId);
      expect(tx.state, 'draft');
    });

    test('3. getTransaction GET /businesses/{business_id}/transactions/{transaction_id}', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(
          request.url.path,
          '/api/v1/businesses/$testBusinessId/transactions/$testTransactionId',
        );

        final responseBody = {
          'data': {
            'id': testTransactionId,
            'business_id': testBusinessId,
            'customer_id': testCustomerId,
            'transaction_type': 'order',
            'state': 'draft',
            'total_amount': 450.0,
            'currency': 'SAR',
            'lines': [],
            'schema_version': 1,
            'resource_version': 'v1',
            'created_at': '2026-10-16T12:00:00Z',
            'updated_at': '2026-10-16T12:00:00Z',
          },
          'request_id': 'req_get_tx_01',
        };

        return http.Response(
          jsonEncode(responseBody),
          200,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
        );
      });

      final apiClient = ApiClient(
        baseUrl: 'https://api.test.mujeeb24.com/api/v1',
        client: mockClient,
      );
      apiClient.setAccessToken('mock_token');
      final repo = TransactionRepository(apiClient: apiClient);

      final tx = await repo.getTransaction(
        businessId: testBusinessId,
        transactionId: testTransactionId,
      );

      expect(tx.id, testTransactionId);
      expect(tx.totalAmount, 450.0);
    });

    test('4. updateTransactionDraft PATCH /businesses/{business_id}/transactions/{transaction_id} with If-Match', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(
          request.url.path,
          '/api/v1/businesses/$testBusinessId/transactions/$testTransactionId',
        );
        expect(request.headers['If-Match'], 'v1');
        expect(request.headers['Idempotency-Key'], isNotEmpty);

        final responseBody = {
          'data': {
            'id': testTransactionId,
            'business_id': testBusinessId,
            'customer_id': testCustomerId,
            'transaction_type': 'order',
            'state': 'draft',
            'total_amount': 600.0,
            'currency': 'SAR',
            'lines': [],
            'schema_version': 1,
            'resource_version': 'v2',
            'created_at': '2026-10-16T12:00:00Z',
            'updated_at': '2026-10-16T12:05:00Z',
          },
          'request_id': 'req_update_draft_01',
        };

        return http.Response(
          jsonEncode(responseBody),
          200,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
        );
      });

      final apiClient = ApiClient(
        baseUrl: 'https://api.test.mujeeb24.com/api/v1',
        client: mockClient,
      );
      apiClient.setAccessToken('mock_token');
      final repo = TransactionRepository(apiClient: apiClient);

      final updated = await repo.updateTransactionDraft(
        businessId: testBusinessId,
        transactionId: testTransactionId,
        request: const UpdateTransactionDraftRequest(currency: 'SAR'),
        ifMatch: 'v1',
      );

      expect(updated.resourceVersion, 'v2');
      expect(updated.totalAmount, 600.0);
    });

    test('5. cancelTransaction POST /businesses/{business_id}/transactions/{transaction_id}/cancel with If-Match', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(
          request.url.path,
          '/api/v1/businesses/$testBusinessId/transactions/$testTransactionId/cancel',
        );
        expect(request.headers['If-Match'], 'v2');

        final decoded = jsonDecode(request.body) as Map<String, dynamic>;
        expect(decoded['reason'], 'Customer altered decision');

        final responseBody = {
          'data': {
            'id': testTransactionId,
            'business_id': testBusinessId,
            'customer_id': testCustomerId,
            'transaction_type': 'order',
            'state': 'cancelled',
            'total_amount': 600.0,
            'currency': 'SAR',
            'lines': [],
            'schema_version': 1,
            'resource_version': 'v3',
            'created_at': '2026-10-16T12:00:00Z',
            'updated_at': '2026-10-16T12:10:00Z',
          },
          'request_id': 'req_cancel_01',
        };

        return http.Response(
          jsonEncode(responseBody),
          200,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
        );
      });

      final apiClient = ApiClient(
        baseUrl: 'https://api.test.mujeeb24.com/api/v1',
        client: mockClient,
      );
      apiClient.setAccessToken('mock_token');
      final repo = TransactionRepository(apiClient: apiClient);

      final cancelled = await repo.cancelTransaction(
        businessId: testBusinessId,
        transactionId: testTransactionId,
        request: const TransactionReasonRequest(
          reason: 'Customer altered decision',
        ),
        ifMatch: 'v2',
      );

      expect(cancelled.state, 'cancelled');
      expect(cancelled.resourceVersion, 'v3');
    });

    test('6. confirmTransaction POST /businesses/{business_id}/transactions/{transaction_id}/confirm with If-Match', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(
          request.url.path,
          '/api/v1/businesses/$testBusinessId/transactions/$testTransactionId/confirm',
        );
        expect(request.headers['If-Match'], 'v2');

        final decoded = jsonDecode(request.body) as Map<String, dynamic>;
        expect(decoded['evidence_reference'], 'pos_receipt_554');

        final responseBody = {
          'data': {
            'id': testTransactionId,
            'business_id': testBusinessId,
            'customer_id': testCustomerId,
            'transaction_type': 'order',
            'state': 'confirmed',
            'total_amount': 600.0,
            'currency': 'SAR',
            'lines': [],
            'schema_version': 1,
            'resource_version': 'v3',
            'created_at': '2026-10-16T12:00:00Z',
            'updated_at': '2026-10-16T12:15:00Z',
          },
          'request_id': 'req_confirm_01',
        };

        return http.Response(
          jsonEncode(responseBody),
          200,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
        );
      });

      final apiClient = ApiClient(
        baseUrl: 'https://api.test.mujeeb24.com/api/v1',
        client: mockClient,
      );
      apiClient.setAccessToken('mock_token');
      final repo = TransactionRepository(apiClient: apiClient);

      final confirmed = await repo.confirmTransaction(
        businessId: testBusinessId,
        transactionId: testTransactionId,
        request: const ConfirmTransactionRequest(
          evidenceReference: 'pos_receipt_554',
        ),
        ifMatch: 'v2',
      );

      expect(confirmed.state, 'confirmed');
      expect(confirmed.resourceVersion, 'v3');
    });

    test('7. getTransactionReview GET /businesses/{business_id}/transactions/{transaction_id}/reviews', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(
          request.url.path,
          '/api/v1/businesses/$testBusinessId/transactions/$testTransactionId/reviews',
        );

        final responseBody = {
          'data': {
            'required': true,
            'status': 'pending',
            'reason_codes': ['high_value'],
            'reviewer_reference': null,
          },
          'request_id': 'req_get_rev_01',
        };

        return http.Response(
          jsonEncode(responseBody),
          200,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
        );
      });

      final apiClient = ApiClient(
        baseUrl: 'https://api.test.mujeeb24.com/api/v1',
        client: mockClient,
      );
      apiClient.setAccessToken('mock_token');
      final repo = TransactionRepository(apiClient: apiClient);

      final review = await repo.getTransactionReview(
        businessId: testBusinessId,
        transactionId: testTransactionId,
      );

      expect(review.required, true);
      expect(review.status, 'pending');
      expect(review.reasonCodes, ['high_value']);
    });

    test('8. approveTransactionReview POST /businesses/{business_id}/transactions/{transaction_id}/reviews/approve with If-Match', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(
          request.url.path,
          '/api/v1/businesses/$testBusinessId/transactions/$testTransactionId/reviews/approve',
        );
        expect(request.headers['If-Match'], 'v2');

        final decoded = jsonDecode(request.body) as Map<String, dynamic>;
        expect(decoded['reviewer_reference'], 'manager_ahmed');

        final responseBody = {
          'data': {
            'required': true,
            'status': 'approved',
            'reason_codes': ['high_value'],
            'reviewer_reference': 'manager_ahmed',
          },
          'request_id': 'req_approve_01',
        };

        return http.Response(
          jsonEncode(responseBody),
          200,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
        );
      });

      final apiClient = ApiClient(
        baseUrl: 'https://api.test.mujeeb24.com/api/v1',
        client: mockClient,
      );
      apiClient.setAccessToken('mock_token');
      final repo = TransactionRepository(apiClient: apiClient);

      final review = await repo.approveTransactionReview(
        businessId: testBusinessId,
        transactionId: testTransactionId,
        request: const ReviewDecisionRequest(
          reviewerReference: 'manager_ahmed',
        ),
        ifMatch: 'v2',
      );

      expect(review.status, 'approved');
      expect(review.reviewerReference, 'manager_ahmed');
    });

    test('9. rejectTransactionReview POST /businesses/{business_id}/transactions/{transaction_id}/reviews/reject with If-Match', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(
          request.url.path,
          '/api/v1/businesses/$testBusinessId/transactions/$testTransactionId/reviews/reject',
        );
        expect(request.headers['If-Match'], 'v2');

        final decoded = jsonDecode(request.body) as Map<String, dynamic>;
        expect(decoded['reviewer_reference'], 'manager_ahmed');
        expect(decoded['reason'], 'Discount exceeds 25% limit');

        final responseBody = {
          'data': {
            'required': true,
            'status': 'rejected',
            'reason_codes': ['high_value'],
            'reviewer_reference': 'manager_ahmed',
          },
          'request_id': 'req_reject_01',
        };

        return http.Response(
          jsonEncode(responseBody),
          200,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
        );
      });

      final apiClient = ApiClient(
        baseUrl: 'https://api.test.mujeeb24.com/api/v1',
        client: mockClient,
      );
      apiClient.setAccessToken('mock_token');
      final repo = TransactionRepository(apiClient: apiClient);

      final review = await repo.rejectTransactionReview(
        businessId: testBusinessId,
        transactionId: testTransactionId,
        request: const ReviewDecisionRequest(
          reviewerReference: 'manager_ahmed',
          reason: 'Discount exceeds 25% limit',
        ),
        ifMatch: 'v2',
      );

      expect(review.status, 'rejected');
    });

    test('10. submitTransactionReview POST /businesses/{business_id}/transactions/{transaction_id}/submit-review with If-Match', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(
          request.url.path,
          '/api/v1/businesses/$testBusinessId/transactions/$testTransactionId/submit-review',
        );
        expect(request.headers['If-Match'], 'v1');

        final decoded = jsonDecode(request.body) as Map<String, dynamic>;
        expect(decoded['reason_codes'], ['policy_check']);

        final responseBody = {
          'data': {
            'required': true,
            'status': 'pending',
            'reason_codes': ['policy_check'],
            'reviewer_reference': null,
          },
          'request_id': 'req_submit_rev_01',
        };

        return http.Response(
          jsonEncode(responseBody),
          200,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
        );
      });

      final apiClient = ApiClient(
        baseUrl: 'https://api.test.mujeeb24.com/api/v1',
        client: mockClient,
      );
      apiClient.setAccessToken('mock_token');
      final repo = TransactionRepository(apiClient: apiClient);

      final review = await repo.submitTransactionReview(
        businessId: testBusinessId,
        transactionId: testTransactionId,
        request: const SubmitReviewRequest(reasonCodes: ['policy_check']),
        ifMatch: 'v1',
      );

      expect(review.status, 'pending');
      expect(review.reasonCodes, ['policy_check']);
    });

    test('11. Optimistic Concurrency Failure: 412 Precondition Failed throws ApiErrorEnvelope', () async {
      final mockClient = MockClient((request) async {
        final errorBody = {
          'error': {
            'code': 'PRECONDITION_FAILED',
            'message': 'Resource version mismatch. Transaction was modified by another session.',
          },
          'request_id': 'req_conflict_999',
        };
        return http.Response(
          jsonEncode(errorBody),
          412,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
        );
      });

      final apiClient = ApiClient(
        baseUrl: 'https://api.test.mujeeb24.com/api/v1',
        client: mockClient,
      );
      apiClient.setAccessToken('mock_token');
      final repo = TransactionRepository(apiClient: apiClient);

      expect(
        () => repo.updateTransactionDraft(
          businessId: testBusinessId,
          transactionId: testTransactionId,
          request: const UpdateTransactionDraftRequest(currency: 'SAR'),
          ifMatch: 'stale_version',
        ),
        throwsA(
          isA<ApiErrorEnvelope>().having(
            (e) => e.error.message,
            'message',
            contains('Resource version mismatch'),
          ),
        ),
      );
    });
  });
}
