import '../api/api_client.dart';
import '../models/platform_models.dart';

/// Repository for Phase 8 Platform Administration (Platform.*):
/// - Platform Businesses provisioning, owner assignment, lifecycle (active/suspended/archived)
/// - Platform Channels monitoring & health check
/// - Platform AI Runtime overview, emergency kill switch (disable/enable), health check, aggregate usage
/// - Platform Plans catalog & lifecycle (draft/active/retired)
/// - Platform Subscriptions, cancellation, and AI budget override
/// - Platform Payments recording & history
/// - Platform Support Tickets lifecycle & admin replies
/// - Platform Audit Events trail & inspection
class PlatformRepository {
  final ApiClient apiClient;

  PlatformRepository({required this.apiClient});

  String _generateIdempotencyKey(String prefix) {
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}';
  }

  Map<String, dynamic> _extractDataMap(dynamic response) {
    if (response is Map<String, dynamic>) {
      if (response['data'] is Map) {
        return Map<String, dynamic>.from(response['data'] as Map);
      }
      return response;
    } else if (response is Map) {
      final map = Map<String, dynamic>.from(response);
      if (map['data'] is Map) {
        return Map<String, dynamic>.from(map['data'] as Map);
      }
      return map;
    }
    throw StateError('Unexpected response format: $response');
  }

  // ==========================================
  // 1. Platform.Businesses
  // ==========================================

  /// `GET /platform/businesses`
  Future<PlatformBusinessPage> listBusinesses({
    int limit = 25,
    String? cursor,
    String? platformStatus,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit.toString()};
    if (cursor != null && cursor.isNotEmpty) queryParams['cursor'] = cursor;
    if (platformStatus != null &&
        platformStatus.isNotEmpty &&
        platformStatus != 'all') {
      queryParams['platform_status'] = platformStatus;
    }

    final response = await apiClient.get(
      '/platform/businesses',
      queryParameters: queryParams,
      requiresAuth: true,
    );

    return PlatformBusinessPage.fromJson(
      response is Map<String, dynamic>
          ? response
          : Map<String, dynamic>.from(response as Map),
    );
  }

  /// `POST /platform/businesses`
  Future<PlatformBusinessView> createBusiness(
    PlatformCreateBusinessRequest request, {
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('plat_biz_create'),
    };

    final response = await apiClient.post(
      '/platform/businesses',
      body: request.toJson(),
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return PlatformBusinessView.fromJson(data);
  }

  /// `GET /platform/businesses/{business_id}`
  Future<PlatformBusinessView> getBusiness(String businessId) async {
    final response = await apiClient.get(
      '/platform/businesses/$businessId',
      requiresAuth: true,
    );
    final data = _extractDataMap(response);
    return PlatformBusinessView.fromJson(data);
  }

  /// `POST /platform/businesses/{business_id}/archive`
  Future<PlatformBusinessView> archiveBusiness(
    String businessId, {
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('plat_biz_archive'),
    };

    final response = await apiClient.post(
      '/platform/businesses/$businessId/archive',
      body: <String, dynamic>{},
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return PlatformBusinessView.fromJson(data);
  }

  /// `POST /platform/businesses/{business_id}/owner`
  Future<PlatformBusinessView> assignOwner(
    String businessId,
    PlatformAssignOwnerRequest request, {
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('plat_biz_owner'),
    };

    final response = await apiClient.post(
      '/platform/businesses/$businessId/owner',
      body: request.toJson(),
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return PlatformBusinessView.fromJson(data);
  }

  /// `POST /platform/businesses/{business_id}/reactivate`
  Future<PlatformBusinessView> reactivateBusiness(
    String businessId, {
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('plat_biz_reactivate'),
    };

    final response = await apiClient.post(
      '/platform/businesses/$businessId/reactivate',
      body: <String, dynamic>{},
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return PlatformBusinessView.fromJson(data);
  }

  /// `POST /platform/businesses/{business_id}/suspend`
  Future<PlatformBusinessView> suspendBusiness(
    String businessId, {
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('plat_biz_suspend'),
    };

    final response = await apiClient.post(
      '/platform/businesses/$businessId/suspend',
      body: <String, dynamic>{},
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return PlatformBusinessView.fromJson(data);
  }

  // ==========================================
  // 2. Platform.Channels
  // ==========================================

  /// `GET /platform/channels`
  Future<PlatformChannelPage> listChannels({
    int limit = 25,
    String? cursor,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit.toString()};
    if (cursor != null && cursor.isNotEmpty) queryParams['cursor'] = cursor;

    final response = await apiClient.get(
      '/platform/channels',
      queryParameters: queryParams,
      requiresAuth: true,
    );

    return PlatformChannelPage.fromJson(
      response is Map<String, dynamic>
          ? response
          : Map<String, dynamic>.from(response as Map),
    );
  }

  /// `GET /platform/channels/{connection_id}`
  Future<PlatformChannelView> getChannel(String connectionId) async {
    final response = await apiClient.get(
      '/platform/channels/$connectionId',
      requiresAuth: true,
    );
    final data = _extractDataMap(response);
    return PlatformChannelView.fromJson(data);
  }

  /// `POST /platform/channels/{connection_id}/health-check`
  Future<PlatformChannelView> runChannelHealthCheck(
    String connectionId, {
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('plat_chan_health'),
    };

    final response = await apiClient.post(
      '/platform/channels/$connectionId/health-check',
      body: <String, dynamic>{},
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return PlatformChannelView.fromJson(data);
  }

  // ==========================================
  // 3. Platform.AI
  // ==========================================

  /// `GET /platform/ai`
  Future<PlatformAIOverviewView> getAIOverview() async {
    final response = await apiClient.get(
      '/platform/ai',
      requiresAuth: true,
    );
    final data = _extractDataMap(response);
    return PlatformAIOverviewView.fromJson(data);
  }

  /// `POST /platform/ai/disable` (AI Emergency Kill Switch)
  Future<PlatformAIOverviewView> disableAI({
    String? reason,
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('plat_ai_killswitch'),
    };
    final body = <String, dynamic>{
      'reason': ?reason,
    };

    final response = await apiClient.post(
      '/platform/ai/disable',
      body: body,
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return PlatformAIOverviewView.fromJson(data);
  }

  /// `POST /platform/ai/enable`
  Future<PlatformAIOverviewView> enableAI({String? idempotencyKey}) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('plat_ai_enable'),
    };

    final response = await apiClient.post(
      '/platform/ai/enable',
      body: <String, dynamic>{},
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return PlatformAIOverviewView.fromJson(data);
  }

  /// `POST /platform/ai/health-check`
  Future<PlatformAIHealthCheckResult> runAIHealthCheck({
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('plat_ai_health'),
    };

    final response = await apiClient.post(
      '/platform/ai/health-check',
      body: <String, dynamic>{},
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return PlatformAIHealthCheckResult.fromJson(data);
  }

  /// `GET /platform/ai/usage`
  Future<PlatformAIUsageOverviewView> getAIUsage() async {
    final response = await apiClient.get(
      '/platform/ai/usage',
      requiresAuth: true,
    );
    final data = _extractDataMap(response);
    return PlatformAIUsageOverviewView.fromJson(data);
  }

  // ==========================================
  // 4. Platform.Plans
  // ==========================================

  /// `GET /platform/plans`
  Future<PlatformPlanPage> listPlans({
    int limit = 25,
    String? cursor,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit.toString()};
    if (cursor != null && cursor.isNotEmpty) queryParams['cursor'] = cursor;
    if (status != null && status.isNotEmpty && status != 'all') {
      queryParams['status'] = status;
    }

    final response = await apiClient.get(
      '/platform/plans',
      queryParameters: queryParams,
      requiresAuth: true,
    );

    return PlatformPlanPage.fromJson(
      response is Map<String, dynamic>
          ? response
          : Map<String, dynamic>.from(response as Map),
    );
  }

  /// `POST /platform/plans`
  Future<PlanView> createPlan(
    PlatformCreatePlanRequest request, {
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('plat_plan_create'),
    };

    final response = await apiClient.post(
      '/platform/plans',
      body: request.toJson(),
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return PlanView.fromJson(data);
  }

  /// `GET /platform/plans/{plan_id}`
  Future<PlanView> getPlan(String planId) async {
    final response = await apiClient.get(
      '/platform/plans/$planId',
      requiresAuth: true,
    );
    final data = _extractDataMap(response);
    return PlanView.fromJson(data);
  }

  /// `POST /platform/plans/{plan_id}/activate`
  Future<PlanView> activatePlan(String planId, {String? idempotencyKey}) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('plat_plan_activate'),
    };

    final response = await apiClient.post(
      '/platform/plans/$planId/activate',
      body: <String, dynamic>{},
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return PlanView.fromJson(data);
  }

  /// `POST /platform/plans/{plan_id}/retire`
  Future<PlanView> retirePlan(String planId, {String? idempotencyKey}) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('plat_plan_retire'),
    };

    final response = await apiClient.post(
      '/platform/plans/$planId/retire',
      body: <String, dynamic>{},
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return PlanView.fromJson(data);
  }

  // ==========================================
  // 5. Platform.Subscriptions
  // ==========================================

  /// `GET /platform/subscriptions`
  Future<PlatformSubscriptionPage> listSubscriptions({
    int limit = 25,
    String? cursor,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit.toString()};
    if (cursor != null && cursor.isNotEmpty) queryParams['cursor'] = cursor;
    if (status != null && status.isNotEmpty && status != 'all') {
      queryParams['status'] = status;
    }

    final response = await apiClient.get(
      '/platform/subscriptions',
      queryParameters: queryParams,
      requiresAuth: true,
    );

    return PlatformSubscriptionPage.fromJson(
      response is Map<String, dynamic>
          ? response
          : Map<String, dynamic>.from(response as Map),
    );
  }

  /// `GET /platform/subscriptions/{subscription_id}`
  Future<SubscriptionView> getSubscription(String subscriptionId) async {
    final response = await apiClient.get(
      '/platform/subscriptions/$subscriptionId',
      requiresAuth: true,
    );
    final data = _extractDataMap(response);
    return SubscriptionView.fromJson(data);
  }

  /// `POST /platform/subscriptions/{subscription_id}/cancel`
  Future<SubscriptionView> cancelSubscription(
    String subscriptionId, {
    String? reason,
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('plat_sub_cancel'),
    };
    final body = <String, dynamic>{
      'reason': ?reason,
    };

    final response = await apiClient.post(
      '/platform/subscriptions/$subscriptionId/cancel',
      body: body,
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return SubscriptionView.fromJson(data);
  }

  /// `POST /platform/subscriptions/{subscription_id}/ai-cost-budget`
  Future<SubscriptionView> overrideAICostBudget(
    String subscriptionId,
    PlatformOverrideBudgetRequest request, {
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('plat_sub_budget'),
    };

    final response = await apiClient.post(
      '/platform/subscriptions/$subscriptionId/ai-cost-budget',
      body: request.toJson(),
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return SubscriptionView.fromJson(data);
  }

  // ==========================================
  // 6. Platform.Payments
  // ==========================================

  /// `GET /platform/subscriptions/{subscription_id}/payments`
  Future<PlatformPaymentPage> listPayments(
    String subscriptionId, {
    int limit = 25,
    String? cursor,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit.toString()};
    if (cursor != null && cursor.isNotEmpty) queryParams['cursor'] = cursor;

    final response = await apiClient.get(
      '/platform/subscriptions/$subscriptionId/payments',
      queryParameters: queryParams,
      requiresAuth: true,
    );

    return PlatformPaymentPage.fromJson(
      response is Map<String, dynamic>
          ? response
          : Map<String, dynamic>.from(response as Map),
    );
  }

  /// `POST /platform/subscriptions/{subscription_id}/payments`
  Future<PaymentView> recordPayment(
    String subscriptionId,
    PlatformRecordPaymentRequest request, {
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('plat_payment_record'),
    };

    final response = await apiClient.post(
      '/platform/subscriptions/$subscriptionId/payments',
      body: request.toJson(),
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return PaymentView.fromJson(data);
  }

  // ==========================================
  // 7. Platform.Support
  // ==========================================

  /// `GET /platform/support/tickets`
  Future<PlatformTicketPage> listTickets({
    int limit = 25,
    String? cursor,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit.toString()};
    if (cursor != null && cursor.isNotEmpty) queryParams['cursor'] = cursor;
    if (status != null && status.isNotEmpty && status != 'all') {
      queryParams['status'] = status;
    }

    final response = await apiClient.get(
      '/platform/support/tickets',
      queryParameters: queryParams,
      requiresAuth: true,
    );

    return PlatformTicketPage.fromJson(
      response is Map<String, dynamic>
          ? response
          : Map<String, dynamic>.from(response as Map),
    );
  }

  /// `GET /platform/support/tickets/{ticket_id}`
  Future<SupportTicketView> getTicket(String ticketId) async {
    final response = await apiClient.get(
      '/platform/support/tickets/$ticketId',
      requiresAuth: true,
    );
    final data = _extractDataMap(response);
    return SupportTicketView.fromJson(data);
  }

  /// `POST /platform/support/tickets/{ticket_id}/start`
  Future<SupportTicketView> startTicket(
    String ticketId, {
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('plat_ticket_start'),
    };

    final response = await apiClient.post(
      '/platform/support/tickets/$ticketId/start',
      body: <String, dynamic>{},
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return SupportTicketView.fromJson(data);
  }

  /// `POST /platform/support/tickets/{ticket_id}/resolve`
  Future<SupportTicketView> resolveTicket(
    String ticketId, {
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('plat_ticket_resolve'),
    };

    final response = await apiClient.post(
      '/platform/support/tickets/$ticketId/resolve',
      body: <String, dynamic>{},
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return SupportTicketView.fromJson(data);
  }

  /// `POST /platform/support/tickets/{ticket_id}/close`
  Future<SupportTicketView> closeTicket(
    String ticketId, {
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('plat_ticket_close'),
    };

    final response = await apiClient.post(
      '/platform/support/tickets/$ticketId/close',
      body: <String, dynamic>{},
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return SupportTicketView.fromJson(data);
  }

  /// `POST /platform/support/tickets/{ticket_id}/messages`
  Future<SupportTicketView> appendTicketMessage(
    String ticketId,
    PlatformTicketMessageRequest request, {
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('plat_ticket_msg'),
    };

    final response = await apiClient.post(
      '/platform/support/tickets/$ticketId/messages',
      body: request.toJson(),
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return SupportTicketView.fromJson(data);
  }

  // ==========================================
  // 8. Platform.Audit
  // ==========================================

  /// `GET /platform/audit-events`
  Future<PlatformAuditPage> listAuditEvents({
    int limit = 25,
    String? cursor,
    String? action,
    String? targetType,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit.toString()};
    if (cursor != null && cursor.isNotEmpty) queryParams['cursor'] = cursor;
    if (action != null && action.isNotEmpty && action != 'all') {
      queryParams['action'] = action;
    }
    if (targetType != null && targetType.isNotEmpty && targetType != 'all') {
      queryParams['target_type'] = targetType;
    }

    final response = await apiClient.get(
      '/platform/audit-events',
      queryParameters: queryParams,
      requiresAuth: true,
    );

    return PlatformAuditPage.fromJson(
      response is Map<String, dynamic>
          ? response
          : Map<String, dynamic>.from(response as Map),
    );
  }

  /// `GET /platform/audit-events/{event_id}`
  Future<PlatformAuditEventView> getAuditEvent(String eventId) async {
    final response = await apiClient.get(
      '/platform/audit-events/$eventId',
      requiresAuth: true,
    );
    final data = _extractDataMap(response);
    return PlatformAuditEventView.fromJson(data);
  }
}
