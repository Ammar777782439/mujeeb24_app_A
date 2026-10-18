import '../api/api_client.dart';
import '../models/channel_automation_models.dart';
import '../models/merchant_models.dart';

/// Repository for handling all Phase 6 operations:
/// - Channel Connections provisioning, status, capabilities, reconnect, disconnect, history purge
/// - Automation Rules list, create, update
/// - Structured AI Decisions list, detail, request human review
/// - Reusable Canned Replies list, create, update
class ChannelAutomationRepository {
  final ApiClient apiClient;

  ChannelAutomationRepository({required this.apiClient});

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

  List<dynamic> _extractDataList(dynamic response) {
    if (response is Map) {
      if (response['data'] is List) return response['data'] as List;
      if (response['items'] is List) return response['items'] as List;
    } else if (response is List) {
      return response;
    }
    return const [];
  }

  // ==========================================
  // Channel Connections
  // ==========================================

  /// Lists all channel connections for a business.
  /// `GET /businesses/{business_id}/channel-connections`
  Future<ChannelConnectionPage> listChannelConnections({
    required String businessId,
    String? status,
    String? channel,
    String? cursor,
    int limit = 25,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit.toString(),
    };
    if (status != null && status.isNotEmpty && status != 'all') {
      queryParams['status'] = status;
    }
    if (channel != null && channel.isNotEmpty && channel != 'all') {
      queryParams['channel'] = channel;
    }
    if (cursor != null && cursor.isNotEmpty) {
      queryParams['cursor'] = cursor;
    }

    final response = await apiClient.get(
      '/businesses/$businessId/channel-connections',
      queryParameters: queryParams,
      requiresAuth: true,
    );

    final itemsList = _extractDataList(response)
        .whereType<Map<String, dynamic>>()
        .map((c) => ChannelConnection.fromJson(c))
        .toList();

    final pagination = response is Map && response['pagination'] is Map
        ? response['pagination'] as Map
        : null;

    return ChannelConnectionPage(
      items: itemsList,
      nextCursor: pagination?['next_cursor']?.toString(),
      hasMore: pagination?['has_more'] == true,
    );
  }

  /// Begins channel provisioning (e.g. WhatsApp, Instagram, Telegram).
  /// `POST /businesses/{business_id}/channel-connections`
  Future<ChannelProvisioning> beginChannelConnection({
    required String businessId,
    required BeginChannelConnectionRequest request,
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('prov_channel'),
    };

    final response = await apiClient.post(
      '/businesses/$businessId/channel-connections',
      body: request.toJson(),
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return ChannelProvisioning.fromJson(data);
  }

  /// Gets single channel connection projection.
  /// `GET /businesses/{business_id}/channel-connections/{connection_id}`
  Future<ChannelConnection> getChannelConnection({
    required String businessId,
    required String connectionId,
  }) async {
    final response = await apiClient.get(
      '/businesses/$businessId/channel-connections/$connectionId',
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return ChannelConnection.fromJson(data);
  }

  /// Lists connection capabilities.
  /// `GET /businesses/{business_id}/channel-connections/{connection_id}/capabilities`
  Future<List<Capability>> getConnectionCapabilities({
    required String businessId,
    required String connectionId,
  }) async {
    final response = await apiClient.get(
      '/businesses/$businessId/channel-connections/$connectionId/capabilities',
      requiresAuth: true,
    );

    final list = _extractDataList(response);
    return list
        .whereType<Map<String, dynamic>>()
        .map((c) => Capability.fromJson(c))
        .toList();
  }

  /// Disconnects a channel connection.
  /// `POST /businesses/{business_id}/channel-connections/{connection_id}/disconnect`
  Future<ChannelConnection> disconnectChannel({
    required String businessId,
    required String connectionId,
    required String reason,
    String? ifMatch,
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('disc_channel'),
    };
    if (ifMatch != null && ifMatch.isNotEmpty) {
      headers['If-Match'] = ifMatch;
    }

    final response = await apiClient.post(
      '/businesses/$businessId/channel-connections/$connectionId/disconnect',
      body: ConnectionActionRequest(reason: reason).toJson(),
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return ChannelConnection.fromJson(data);
  }

  /// Reconnects a channel connection.
  /// `POST /businesses/{business_id}/channel-connections/{connection_id}/reconnect`
  Future<ChannelConnection> reconnectChannel({
    required String businessId,
    required String connectionId,
    required String reason,
    String? ifMatch,
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('reconn_channel'),
    };
    if (ifMatch != null && ifMatch.isNotEmpty) {
      headers['If-Match'] = ifMatch;
    }

    final response = await apiClient.post(
      '/businesses/$businessId/channel-connections/$connectionId/reconnect',
      body: ConnectionActionRequest(reason: reason).toJson(),
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return ChannelConnection.fromJson(data);
  }

  /// Previews irreversible local channel history deletion.
  /// `GET /businesses/{business_id}/channel-connections/{connection_id}/history-purge`
  Future<ChannelHistorySummary> previewChannelHistoryPurge({
    required String businessId,
    required String connectionId,
  }) async {
    final response = await apiClient.get(
      '/businesses/$businessId/channel-connections/$connectionId/history-purge',
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return ChannelHistorySummary.fromJson(data);
  }

  /// Irreversibly deletes entire local conversation history for one connection.
  /// `POST /businesses/{business_id}/channel-connections/{connection_id}/history-purge`
  Future<ChannelHistorySummary> purgeChannelHistory({
    required String businessId,
    required String connectionId,
    required String expectedVersion,
    String confirmation = PurgeChannelHistoryRequest.requiredConfirmation,
    String? ifMatch,
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('purge_channel'),
    };
    if (ifMatch != null && ifMatch.isNotEmpty) {
      headers['If-Match'] = ifMatch;
    }

    final request = PurgeChannelHistoryRequest(
      confirmation: confirmation,
      expectedVersion: expectedVersion,
    );

    final response = await apiClient.post(
      '/businesses/$businessId/channel-connections/$connectionId/history-purge',
      body: request.toJson(),
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return ChannelHistorySummary.fromJson(data);
  }

  // ==========================================
  // Automation Rules
  // ==========================================

  /// Lists constrained inbound automation rules.
  /// `GET /businesses/{business_id}/automation-rules`
  Future<AutomationRulePage> listAutomationRules({
    required String businessId,
    String? status, // active | disabled
    String? cursor,
    int limit = 25,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit.toString(),
    };
    if (status != null && status.isNotEmpty && status != 'all') {
      queryParams['status'] = status;
    }
    if (cursor != null && cursor.isNotEmpty) {
      queryParams['cursor'] = cursor;
    }

    final response = await apiClient.get(
      '/businesses/$businessId/automation-rules',
      queryParameters: queryParams,
      requiresAuth: true,
    );

    final itemsList = _extractDataList(response)
        .whereType<Map<String, dynamic>>()
        .map((r) => AutomationRule.fromJson(r))
        .toList();

    final pagination = response is Map && response['pagination'] is Map
        ? response['pagination'] as Map
        : null;

    return AutomationRulePage(
      items: itemsList,
      nextCursor: pagination?['next_cursor']?.toString(),
      hasMore: pagination?['has_more'] == true,
    );
  }

  /// Creates a constrained inbound automation rule.
  /// `POST /businesses/{business_id}/automation-rules`
  Future<AutomationRule> createAutomationRule({
    required String businessId,
    required CreateAutomationRuleRequest request,
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('create_rule'),
    };

    final response = await apiClient.post(
      '/businesses/$businessId/automation-rules',
      body: request.toJson(),
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return AutomationRule.fromJson(data);
  }

  /// Updates a constrained inbound automation rule.
  /// `PATCH /businesses/{business_id}/automation-rules/{automation_rule_id}`
  Future<AutomationRule> updateAutomationRule({
    required String businessId,
    required String automationRuleId,
    required UpdateAutomationRuleRequest request,
    String? ifMatch,
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{};
    if (ifMatch != null && ifMatch.isNotEmpty) {
      headers['If-Match'] = ifMatch;
    }
    if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
      headers['Idempotency-Key'] = idempotencyKey;
    }

    final response = await apiClient.patch(
      '/businesses/$businessId/automation-rules/$automationRuleId',
      body: request.toJson(),
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return AutomationRule.fromJson(data);
  }

  // ==========================================
  // AI Decisions
  // ==========================================

  /// Lists structured AI decisions.
  /// `GET /businesses/{business_id}/ai-decisions`
  Future<AIDecisionPage> listAIDecisions({
    required String businessId,
    String? lifecycle,
    String? conversationId,
    bool? requiresHuman,
    String? cursor,
    int limit = 25,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit.toString(),
    };
    if (lifecycle != null && lifecycle.isNotEmpty && lifecycle != 'all') {
      queryParams['lifecycle'] = lifecycle;
    }
    if (conversationId != null && conversationId.isNotEmpty) {
      queryParams['conversation_id'] = conversationId;
    }
    if (requiresHuman != null) {
      queryParams['requires_human'] = requiresHuman.toString();
    }
    if (cursor != null && cursor.isNotEmpty) {
      queryParams['cursor'] = cursor;
    }

    final response = await apiClient.get(
      '/businesses/$businessId/ai-decisions',
      queryParameters: queryParams,
      requiresAuth: true,
    );

    final itemsList = _extractDataList(response)
        .whereType<Map<String, dynamic>>()
        .map((d) => AIDecision.fromJson(d))
        .toList();

    final pagination = response is Map && response['pagination'] is Map
        ? response['pagination'] as Map
        : null;

    return AIDecisionPage(
      items: itemsList,
      nextCursor: pagination?['next_cursor']?.toString(),
      hasMore: pagination?['has_more'] == true,
    );
  }

  /// Gets a structured AI decision.
  /// `GET /businesses/{business_id}/ai-decisions/{decision_id}`
  Future<AIDecision> getAIDecision({
    required String businessId,
    required String decisionId,
  }) async {
    final response = await apiClient.get(
      '/businesses/$businessId/ai-decisions/$decisionId',
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return AIDecision.fromJson(data);
  }

  /// Requests human review for an AI decision.
  /// `POST /businesses/{business_id}/ai-decisions/{decision_id}/request-human`
  Future<AIDecision> requestHumanReview({
    required String businessId,
    required String decisionId,
    required String reason,
    String? ifMatch,
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('req_human'),
    };
    if (ifMatch != null && ifMatch.isNotEmpty) {
      headers['If-Match'] = ifMatch;
    }

    final response = await apiClient.post(
      '/businesses/$businessId/ai-decisions/$decisionId/request-human',
      body: AIHumanRequest(reason: reason).toJson(),
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return AIDecision.fromJson(data);
  }

  // ==========================================
  // Canned Replies CRUD
  // ==========================================

  /// Lists reusable merchant replies.
  /// `GET /businesses/{business_id}/canned-replies`
  Future<List<CannedReply>> listCannedReplies({
    required String businessId,
    String? status, // active | archived
    String? cursor,
    int limit = 50,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit.toString(),
    };
    if (status != null && status.isNotEmpty && status != 'all') {
      queryParams['status'] = status;
    }
    if (cursor != null && cursor.isNotEmpty) {
      queryParams['cursor'] = cursor;
    }

    final response = await apiClient.get(
      '/businesses/$businessId/canned-replies',
      queryParameters: queryParams,
      requiresAuth: true,
    );

    final dataList = _extractDataList(response);
    return dataList
        .whereType<Map<String, dynamic>>()
        .map((e) => CannedReply.fromJson(e))
        .toList();
  }

  /// Creates a reusable merchant reply.
  /// `POST /businesses/{business_id}/canned-replies`
  Future<CannedReply> createCannedReply({
    required String businessId,
    required CreateCannedReplyRequest request,
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('create_canned'),
    };

    final response = await apiClient.post(
      '/businesses/$businessId/canned-replies',
      body: request.toJson(),
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return CannedReply.fromJson(data);
  }

  /// Updates a reusable merchant reply.
  /// `PATCH /businesses/{business_id}/canned-replies/{canned_reply_id}`
  Future<CannedReply> updateCannedReply({
    required String businessId,
    required String cannedReplyId,
    required UpdateCannedReplyRequest request,
    String? ifMatch,
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{};
    if (ifMatch != null && ifMatch.isNotEmpty) {
      headers['If-Match'] = ifMatch;
    }
    if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
      headers['Idempotency-Key'] = idempotencyKey;
    }

    final response = await apiClient.patch(
      '/businesses/$businessId/canned-replies/$cannedReplyId',
      body: request.toJson(),
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return CannedReply.fromJson(data);
  }
}
