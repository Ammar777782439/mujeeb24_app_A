import 'package:mujeeb24_app/core/api/api_client.dart';
import 'package:mujeeb24_app/core/models/transaction_models.dart';

/// Transaction Repository implementing Phase 4 operations:
/// - GET /businesses/{business_id}/transactions
/// - POST /businesses/{business_id}/transactions
/// - GET /businesses/{business_id}/transactions/{transaction_id}
/// - PATCH /businesses/{business_id}/transactions/{transaction_id}
/// - POST /businesses/{business_id}/transactions/{transaction_id}/cancel
/// - POST /businesses/{business_id}/transactions/{transaction_id}/confirm
/// - GET /businesses/{business_id}/transactions/{transaction_id}/reviews
/// - POST /businesses/{business_id}/transactions/{transaction_id}/reviews/approve
/// - POST /businesses/{business_id}/transactions/{transaction_id}/reviews/reject
/// - POST /businesses/{business_id}/transactions/{transaction_id}/submit-review
class TransactionRepository {
  final ApiClient apiClient;

  TransactionRepository({required this.apiClient});

  /// Helper to generate default idempotency key
  String _generateIdempotencyKey(String prefix) {
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}';
  }

  /// 1. GET /businesses/{business_id}/transactions
  Future<TransactionPage> listTransactions({
    required String businessId,
    String? state,
    String? transactionType,
    String? customerId,
    String? cursor,
    int limit = 25,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit};
    if (state != null && state.isNotEmpty && state != 'all') {
      queryParams['state'] = state;
    }
    if (transactionType != null &&
        transactionType.isNotEmpty &&
        transactionType != 'all') {
      queryParams['transaction_type'] = transactionType;
    }
    if (customerId != null && customerId.isNotEmpty) {
      queryParams['customer_id'] = customerId;
    }
    if (cursor != null && cursor.isNotEmpty) {
      queryParams['cursor'] = cursor;
    }

    final response = await apiClient.get(
      '/businesses/$businessId/transactions',
      queryParameters: queryParams,
      requiresAuth: true,
    );

    final rawList = response['data'] as List?;
    final items = rawList != null
        ? rawList
              .whereType<Map<String, dynamic>>()
              .map(CommercialTransaction.fromJson)
              .toList()
        : <CommercialTransaction>[];

    final paginationMap = response['pagination'] as Map<String, dynamic>?;
    final hasMore = paginationMap?['has_more'] as bool? ?? false;
    final nextCursor = paginationMap?['next_cursor'] as String?;
    final requestId = response['request_id'] as String?;

    return TransactionPage(
      items: items,
      hasMore: hasMore,
      nextCursor: nextCursor,
      requestId: requestId,
    );
  }

  /// 2. POST /businesses/{business_id}/transactions
  Future<CommercialTransaction> createTransactionDraft({
    required String businessId,
    required CreateTransactionDraftRequest request,
    String? idempotencyKey,
  }) async {
    final key = idempotencyKey ?? _generateIdempotencyKey('create_draft');
    final headers = <String, String>{'Idempotency-Key': key};

    final response = await apiClient.post(
      '/businesses/$businessId/transactions',
      body: request.toJson(),
      headers: headers,
      requiresAuth: true,
    );

    final data = response['data'] as Map<String, dynamic>;
    return CommercialTransaction.fromJson(data);
  }

  /// 3. GET /businesses/{business_id}/transactions/{transaction_id}
  Future<CommercialTransaction> getTransaction({
    required String businessId,
    required String transactionId,
  }) async {
    final response = await apiClient.get(
      '/businesses/$businessId/transactions/$transactionId',
      requiresAuth: true,
    );

    final data = response['data'] as Map<String, dynamic>;
    return CommercialTransaction.fromJson(data);
  }

  /// 4. PATCH /businesses/{business_id}/transactions/{transaction_id}
  Future<CommercialTransaction> updateTransactionDraft({
    required String businessId,
    required String transactionId,
    required UpdateTransactionDraftRequest request,
    required String ifMatch,
    String? idempotencyKey,
  }) async {
    final key = idempotencyKey ?? _generateIdempotencyKey('update_draft');
    final headers = <String, String>{
      'If-Match': ifMatch,
      'Idempotency-Key': key,
    };

    final response = await apiClient.patch(
      '/businesses/$businessId/transactions/$transactionId',
      body: request.toJson(),
      headers: headers,
      requiresAuth: true,
    );

    final data = response['data'] as Map<String, dynamic>;
    return CommercialTransaction.fromJson(data);
  }

  /// 5. POST /businesses/{business_id}/transactions/{transaction_id}/cancel
  Future<CommercialTransaction> cancelTransaction({
    required String businessId,
    required String transactionId,
    required TransactionReasonRequest request,
    required String ifMatch,
    String? idempotencyKey,
  }) async {
    final key = idempotencyKey ?? _generateIdempotencyKey('cancel_tx');
    final headers = <String, String>{
      'If-Match': ifMatch,
      'Idempotency-Key': key,
    };

    final response = await apiClient.post(
      '/businesses/$businessId/transactions/$transactionId/cancel',
      body: request.toJson(),
      headers: headers,
      requiresAuth: true,
    );

    final data = response['data'] as Map<String, dynamic>;
    return CommercialTransaction.fromJson(data);
  }

  /// 6. POST /businesses/{business_id}/transactions/{transaction_id}/confirm
  Future<CommercialTransaction> confirmTransaction({
    required String businessId,
    required String transactionId,
    required ConfirmTransactionRequest request,
    required String ifMatch,
    String? idempotencyKey,
  }) async {
    final key = idempotencyKey ?? _generateIdempotencyKey('confirm_tx');
    final headers = <String, String>{
      'If-Match': ifMatch,
      'Idempotency-Key': key,
    };

    final response = await apiClient.post(
      '/businesses/$businessId/transactions/$transactionId/confirm',
      body: request.toJson(),
      headers: headers,
      requiresAuth: true,
    );

    final data = response['data'] as Map<String, dynamic>;
    return CommercialTransaction.fromJson(data);
  }

  /// 7. GET /businesses/{business_id}/transactions/{transaction_id}/reviews
  Future<TransactionReview> getTransactionReview({
    required String businessId,
    required String transactionId,
  }) async {
    final response = await apiClient.get(
      '/businesses/$businessId/transactions/$transactionId/reviews',
      requiresAuth: true,
    );

    final data = response['data'] as Map<String, dynamic>;
    return TransactionReview.fromJson(data);
  }

  /// 8. POST /businesses/{business_id}/transactions/{transaction_id}/reviews/approve
  Future<TransactionReview> approveTransactionReview({
    required String businessId,
    required String transactionId,
    required ReviewDecisionRequest request,
    required String ifMatch,
    String? idempotencyKey,
  }) async {
    final key = idempotencyKey ?? _generateIdempotencyKey('approve_review');
    final headers = <String, String>{
      'If-Match': ifMatch,
      'Idempotency-Key': key,
    };

    final response = await apiClient.post(
      '/businesses/$businessId/transactions/$transactionId/reviews/approve',
      body: request.toJson(),
      headers: headers,
      requiresAuth: true,
    );

    final data = response['data'] as Map<String, dynamic>;
    return TransactionReview.fromJson(data);
  }

  /// 9. POST /businesses/{business_id}/transactions/{transaction_id}/reviews/reject
  Future<TransactionReview> rejectTransactionReview({
    required String businessId,
    required String transactionId,
    required ReviewDecisionRequest request,
    required String ifMatch,
    String? idempotencyKey,
  }) async {
    final key = idempotencyKey ?? _generateIdempotencyKey('reject_review');
    final headers = <String, String>{
      'If-Match': ifMatch,
      'Idempotency-Key': key,
    };

    final response = await apiClient.post(
      '/businesses/$businessId/transactions/$transactionId/reviews/reject',
      body: request.toJson(),
      headers: headers,
      requiresAuth: true,
    );

    final data = response['data'] as Map<String, dynamic>;
    return TransactionReview.fromJson(data);
  }

  /// 10. POST /businesses/{business_id}/transactions/{transaction_id}/submit-review
  Future<TransactionReview> submitTransactionReview({
    required String businessId,
    required String transactionId,
    required SubmitReviewRequest request,
    required String ifMatch,
    String? idempotencyKey,
  }) async {
    final key = idempotencyKey ?? _generateIdempotencyKey('submit_review');
    final headers = <String, String>{
      'If-Match': ifMatch,
      'Idempotency-Key': key,
    };

    final response = await apiClient.post(
      '/businesses/$businessId/transactions/$transactionId/submit-review',
      body: request.toJson(),
      headers: headers,
      requiresAuth: true,
    );

    final data = response['data'] as Map<String, dynamic>;
    return TransactionReview.fromJson(data);
  }
}
