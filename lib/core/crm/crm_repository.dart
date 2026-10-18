import 'package:mujeeb24_app/core/api/api_client.dart';
import 'package:mujeeb24_app/core/models/crm_models.dart';
import 'package:mujeeb24_app/core/models/merchant_models.dart';

/// CRM Repository implementing Phase 3 operations:
/// Customers:
/// - GET /businesses/{business_id}/customers
/// - POST /businesses/{business_id}/customers
/// - GET /businesses/{business_id}/customers/{customer_id}
/// - PATCH /businesses/{business_id}/customers/{customer_id}
/// - GET /businesses/{business_id}/customers/{customer_id}/conversations
/// - POST /businesses/{business_id}/customers/{customer_id}/merge
/// - GET /businesses/{business_id}/customers/{customer_id}/transactions
/// Leads:
/// - GET /businesses/{business_id}/leads
/// - POST /businesses/{business_id}/leads
/// - GET /businesses/{business_id}/leads/{lead_id}
/// - PATCH /businesses/{business_id}/leads/{lead_id}
/// - GET /businesses/{business_id}/leads/{lead_id}/attributions
/// - POST /businesses/{business_id}/leads/{lead_id}/mark-lost
/// - POST /businesses/{business_id}/leads/{lead_id}/qualify
/// - GET /businesses/{business_id}/leads/{lead_id}/scores
class CrmRepository {
  final ApiClient apiClient;

  CrmRepository({required this.apiClient});

  // ==========================================
  // CUSTOMERS (7 Operations)
  // ==========================================

  /// GET /businesses/{business_id}/customers
  Future<List<Customer>> listCustomers({
    required String businessId,
    String? search,
    String? status,
    String? cursor,
    int limit = 25,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit};
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (status != null && status.isNotEmpty && status != 'all') {
      queryParams['status'] = status;
    }
    if (cursor != null && cursor.isNotEmpty) {
      queryParams['cursor'] = cursor;
    }

    final response = await apiClient.get(
      '/businesses/$businessId/customers',
      queryParameters: queryParams,
      requiresAuth: true,
    );

    final rawList = response['data'] as List?;
    if (rawList == null) {
      return [];
    }
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(Customer.fromJson)
        .toList();
  }

  /// POST /businesses/{business_id}/customers
  Future<Customer> createCustomer({
    required String businessId,
    required CreateCustomerRequest request,
    String? idempotencyKey,
    String? requestId,
  }) async {
    final headers = <String, String>{};
    if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
      headers['Idempotency-Key'] = idempotencyKey;
    }
    if (requestId != null && requestId.isNotEmpty) {
      headers['X-Request-ID'] = requestId;
    }

    final response = await apiClient.post(
      '/businesses/$businessId/customers',
      body: request.toJson(),
      headers: headers.isNotEmpty ? headers : null,
      requiresAuth: true,
    );

    final data = response['data'] as Map<String, dynamic>;
    return Customer.fromJson(data);
  }

  /// GET /businesses/{business_id}/customers/{customer_id}
  Future<Customer> getCustomer({
    required String businessId,
    required String customerId,
  }) async {
    final response = await apiClient.get(
      '/businesses/$businessId/customers/$customerId',
      requiresAuth: true,
    );

    final data = response['data'] as Map<String, dynamic>;
    return Customer.fromJson(data);
  }

  /// PATCH /businesses/{business_id}/customers/{customer_id}
  Future<Customer> updateCustomer({
    required String businessId,
    required String customerId,
    required UpdateCustomerRequest request,
    String? ifMatch,
  }) async {
    final headers = <String, String>{};
    if (ifMatch != null && ifMatch.isNotEmpty) {
      headers['If-Match'] = ifMatch;
    }

    final response = await apiClient.patch(
      '/businesses/$businessId/customers/$customerId',
      body: request.toJson(),
      headers: headers.isNotEmpty ? headers : null,
      requiresAuth: true,
    );

    final data = response['data'] as Map<String, dynamic>;
    return Customer.fromJson(data);
  }

  /// GET /businesses/{business_id}/customers/{customer_id}/conversations
  Future<List<Conversation>> listCustomerConversations({
    required String businessId,
    required String customerId,
    String? cursor,
    int limit = 25,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit};
    if (cursor != null && cursor.isNotEmpty) {
      queryParams['cursor'] = cursor;
    }

    final response = await apiClient.get(
      '/businesses/$businessId/customers/$customerId/conversations',
      queryParameters: queryParams,
      requiresAuth: true,
    );

    final rawList = response['data'] as List?;
    if (rawList == null) {
      return [];
    }
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(Conversation.fromJson)
        .toList();
  }

  /// POST /businesses/{business_id}/customers/{customer_id}/merge
  Future<Customer> mergeCustomer({
    required String businessId,
    required String customerId,
    required MergeCustomerRequest request,
    String? ifMatch,
  }) async {
    final headers = <String, String>{};
    if (ifMatch != null && ifMatch.isNotEmpty) {
      headers['If-Match'] = ifMatch;
    }

    final response = await apiClient.post(
      '/businesses/$businessId/customers/$customerId/merge',
      body: request.toJson(),
      headers: headers.isNotEmpty ? headers : null,
      requiresAuth: true,
    );

    final data = response['data'] as Map<String, dynamic>;
    return Customer.fromJson(data);
  }

  /// GET /businesses/{business_id}/customers/{customer_id}/transactions
  Future<List<CommercialTransaction>> listCustomerTransactions({
    required String businessId,
    required String customerId,
    String? cursor,
    int limit = 25,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit};
    if (cursor != null && cursor.isNotEmpty) {
      queryParams['cursor'] = cursor;
    }

    final response = await apiClient.get(
      '/businesses/$businessId/customers/$customerId/transactions',
      queryParameters: queryParams,
      requiresAuth: true,
    );

    final rawList = response['data'] as List?;
    if (rawList == null) {
      return [];
    }
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(CommercialTransaction.fromJson)
        .toList();
  }

  // ==========================================
  // LEADS (8 Operations)
  // ==========================================

  /// GET /businesses/{business_id}/leads
  Future<List<Lead>> listLeads({
    required String businessId,
    String? status,
    String? customerId,
    String? scoreBand,
    String? cursor,
    int limit = 25,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit};
    if (status != null && status.isNotEmpty && status != 'all') {
      queryParams['status'] = status;
    }
    if (customerId != null && customerId.isNotEmpty) {
      queryParams['customer_id'] = customerId;
    }
    if (scoreBand != null && scoreBand.isNotEmpty && scoreBand != 'all') {
      queryParams['score_band'] = scoreBand;
    }
    if (cursor != null && cursor.isNotEmpty) {
      queryParams['cursor'] = cursor;
    }

    final response = await apiClient.get(
      '/businesses/$businessId/leads',
      queryParameters: queryParams,
      requiresAuth: true,
    );

    final rawList = response['data'] as List?;
    if (rawList == null) {
      return [];
    }
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(Lead.fromJson)
        .toList();
  }

  /// POST /businesses/{business_id}/leads
  Future<Lead> createLead({
    required String businessId,
    required CreateLeadRequest request,
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{};
    if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
      headers['Idempotency-Key'] = idempotencyKey;
    }

    final response = await apiClient.post(
      '/businesses/$businessId/leads',
      body: request.toJson(),
      headers: headers.isNotEmpty ? headers : null,
      requiresAuth: true,
    );

    final data = response['data'] as Map<String, dynamic>;
    return Lead.fromJson(data);
  }

  /// GET /businesses/{business_id}/leads/{lead_id}
  Future<Lead> getLead({
    required String businessId,
    required String leadId,
  }) async {
    final response = await apiClient.get(
      '/businesses/$businessId/leads/$leadId',
      requiresAuth: true,
    );

    final data = response['data'] as Map<String, dynamic>;
    return Lead.fromJson(data);
  }

  /// PATCH /businesses/{business_id}/leads/{lead_id}
  Future<Lead> updateLead({
    required String businessId,
    required String leadId,
    required UpdateLeadRequest request,
    String? ifMatch,
  }) async {
    final headers = <String, String>{};
    if (ifMatch != null && ifMatch.isNotEmpty) {
      headers['If-Match'] = ifMatch;
    }

    final response = await apiClient.patch(
      '/businesses/$businessId/leads/$leadId',
      body: request.toJson(),
      headers: headers.isNotEmpty ? headers : null,
      requiresAuth: true,
    );

    final data = response['data'] as Map<String, dynamic>;
    return Lead.fromJson(data);
  }

  /// GET /businesses/{business_id}/leads/{lead_id}/attributions
  Future<List<LeadAttribution>> listLeadAttributions({
    required String businessId,
    required String leadId,
    String? cursor,
    int limit = 25,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit};
    if (cursor != null && cursor.isNotEmpty) {
      queryParams['cursor'] = cursor;
    }

    final response = await apiClient.get(
      '/businesses/$businessId/leads/$leadId/attributions',
      queryParameters: queryParams,
      requiresAuth: true,
    );

    final rawList = response['data'] as List?;
    if (rawList == null) {
      return [];
    }
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(LeadAttribution.fromJson)
        .toList();
  }

  /// POST /businesses/{business_id}/leads/{lead_id}/mark-lost
  Future<Lead> markLeadLost({
    required String businessId,
    required String leadId,
    required String lostReason,
    String? ifMatch,
  }) async {
    final headers = <String, String>{};
    if (ifMatch != null && ifMatch.isNotEmpty) {
      headers['If-Match'] = ifMatch;
    }

    final response = await apiClient.post(
      '/businesses/$businessId/leads/$leadId/mark-lost',
      body: MarkLeadLostRequest(lostReason: lostReason).toJson(),
      headers: headers.isNotEmpty ? headers : null,
      requiresAuth: true,
    );

    final data = response['data'] as Map<String, dynamic>;
    return Lead.fromJson(data);
  }

  /// POST /businesses/{business_id}/leads/{lead_id}/qualify
  Future<Lead> qualifyLead({
    required String businessId,
    required String leadId,
    String? reason,
    List<String>? evidenceReferences,
    String? ifMatch,
  }) async {
    final headers = <String, String>{};
    if (ifMatch != null && ifMatch.isNotEmpty) {
      headers['If-Match'] = ifMatch;
    }

    final response = await apiClient.post(
      '/businesses/$businessId/leads/$leadId/qualify',
      body: LeadDecisionRequest(
        reason: reason,
        evidenceReferences: evidenceReferences,
      ).toJson(),
      headers: headers.isNotEmpty ? headers : null,
      requiresAuth: true,
    );

    final data = response['data'] as Map<String, dynamic>;
    return Lead.fromJson(data);
  }

  /// GET /businesses/{business_id}/leads/{lead_id}/scores
  Future<List<LeadScore>> listLeadScores({
    required String businessId,
    required String leadId,
    String? cursor,
    int limit = 25,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit};
    if (cursor != null && cursor.isNotEmpty) {
      queryParams['cursor'] = cursor;
    }

    final response = await apiClient.get(
      '/businesses/$businessId/leads/$leadId/scores',
      queryParameters: queryParams,
      requiresAuth: true,
    );

    final rawList = response['data'] as List?;
    if (rawList == null) {
      return [];
    }
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(LeadScore.fromJson)
        .toList();
  }
}
