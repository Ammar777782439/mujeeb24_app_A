import 'package:flutter/foundation.dart';

/// ==========================================
/// Channels & Connections Models
/// ==========================================

/// Capability projection for a connection.
/// Matches OpenAPI `#/components/schemas/Capability`.
@immutable
class Capability {
  final String name;
  final bool enabled;
  final String? evidenceSource;
  final String? checkedAt;

  const Capability({
    required this.name,
    required this.enabled,
    this.evidenceSource,
    this.checkedAt,
  });

  factory Capability.fromJson(Map<String, dynamic> json) {
    return Capability(
      name: json['name']?.toString() ?? '',
      enabled: json['enabled'] == true,
      evidenceSource: json['evidence_source']?.toString(),
      checkedAt: json['checked_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'enabled': enabled,
      if (evidenceSource != null) 'evidence_source': evidenceSource,
      if (checkedAt != null) 'checked_at': checkedAt,
    };
  }

  bool get supported => enabled;
  String? get description => evidenceSource;
}

/// ChannelConnection projection.
/// Matches OpenAPI `#/components/schemas/ChannelConnection`.
@immutable
class ChannelConnection {
  final String id;
  final String businessId;
  final String provider;
  final String channel;
  final String status;
  final String? externalAccountReference;
  final List<Capability> capabilities;
  final String resourceVersion;
  final String? createdAt;
  final String? updatedAt;

  const ChannelConnection({
    required this.id,
    required this.businessId,
    required this.provider,
    required this.channel,
    required this.status,
    this.externalAccountReference,
    this.capabilities = const [],
    required this.resourceVersion,
    this.createdAt,
    this.updatedAt,
  });

  factory ChannelConnection.fromJson(Map<String, dynamic> json) {
    var rawCaps = json['capabilities'];
    List<Capability> capsList = [];
    if (rawCaps is List) {
      capsList = rawCaps
          .whereType<Map<String, dynamic>>()
          .map((c) => Capability.fromJson(c))
          .toList();
    }

    return ChannelConnection(
      id: json['id']?.toString() ?? '',
      businessId: json['business_id']?.toString() ?? '',
      provider: json['provider']?.toString() ?? '',
      channel: json['channel']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      externalAccountReference: json['external_account_reference']?.toString(),
      capabilities: capsList,
      resourceVersion: json['resource_version']?.toString() ?? '1',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'provider': provider,
      'channel': channel,
      'status': status,
      if (externalAccountReference != null)
        'external_account_reference': externalAccountReference,
      'capabilities': capabilities.map((c) => c.toJson()).toList(),
      'resource_version': resourceVersion,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }

  bool get isConnected => status == 'connected' || status == 'active';
  bool get isDisconnected => status == 'disconnected';
  bool get isPending => status == 'pending' || status == 'provisioning';
  bool get hasError => status == 'error' || status == 'failed';
  String? get displayName => externalAccountReference;
}

/// Request body for initiating channel provisioning.
/// Matches OpenAPI `#/components/schemas/BeginChannelConnectionRequest`.
@immutable
class BeginChannelConnectionRequest {
  final String provider;
  final String channel;
  final String? displayName;

  const BeginChannelConnectionRequest({
    required this.provider,
    required this.channel,
    this.displayName,
  });

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'channel': channel,
      if (displayName != null && displayName!.isNotEmpty)
        'display_name': displayName,
    };
  }
}

/// Result of initiating channel provisioning.
/// Matches OpenAPI `#/components/schemas/ChannelProvisioning`.
@immutable
class ChannelProvisioning {
  final String provisioningId;
  final String businessId;
  final String provider;
  final String channel;
  final String status;
  final String? authorizationUrl;
  final String? createdAt;
  final String? updatedAt;

  const ChannelProvisioning({
    required this.provisioningId,
    required this.businessId,
    required this.provider,
    required this.channel,
    required this.status,
    this.authorizationUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory ChannelProvisioning.fromJson(Map<String, dynamic> json) {
    return ChannelProvisioning(
      provisioningId: json['provisioning_id']?.toString() ?? '',
      businessId: json['business_id']?.toString() ?? '',
      provider: json['provider']?.toString() ?? '',
      channel: json['channel']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      authorizationUrl: json['authorization_url']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provisioning_id': provisioningId,
      'business_id': businessId,
      'provider': provider,
      'channel': channel,
      'status': status,
      if (authorizationUrl != null) 'authorization_url': authorizationUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }
}

/// Summary of conversations and messages in a channel before or after purge.
/// Matches OpenAPI `#/components/schemas/ChannelHistorySummary`.
@immutable
class ChannelHistorySummary {
  final String businessId;
  final String connectionId;
  final int conversations;
  final int messages;
  final String? purgedAt;

  const ChannelHistorySummary({
    required this.businessId,
    required this.connectionId,
    required this.conversations,
    required this.messages,
    this.purgedAt,
  });

  factory ChannelHistorySummary.fromJson(Map<String, dynamic> json) {
    return ChannelHistorySummary(
      businessId: json['business_id']?.toString() ?? '',
      connectionId: json['connection_id']?.toString() ?? '',
      conversations: (json['conversations'] as num?)?.toInt() ?? 0,
      messages: (json['messages'] as num?)?.toInt() ?? 0,
      purgedAt: json['purged_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_id': businessId,
      'connection_id': connectionId,
      'conversations': conversations,
      'messages': messages,
      if (purgedAt != null) 'purged_at': purgedAt,
    };
  }

  int get conversationsCount => conversations;
  int get messagesCount => messages;
}

/// Request body for irreversible channel history purge.
/// Matches OpenAPI `#/components/schemas/PurgeChannelHistoryRequest`.
@immutable
class PurgeChannelHistoryRequest {
  static const String requiredConfirmation = 'DELETE_ALL_CHANNEL_HISTORY';

  final String confirmation;
  final String expectedVersion;

  const PurgeChannelHistoryRequest({
    this.confirmation = requiredConfirmation,
    required this.expectedVersion,
  });

  Map<String, dynamic> toJson() {
    return {'confirmation': confirmation, 'expected_version': expectedVersion};
  }
}

/// Request body for connection actions like reconnect and disconnect.
/// Matches OpenAPI `#/components/schemas/ConnectionActionRequest`.
@immutable
class ConnectionActionRequest {
  final String reason;

  const ConnectionActionRequest({required this.reason});

  Map<String, dynamic> toJson() {
    return {'reason': reason};
  }
}

/// Paginated page of channel connections.
@immutable
class ChannelConnectionPage {
  final List<ChannelConnection> items;
  final String? nextCursor;
  final bool hasMore;

  const ChannelConnectionPage({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });

  factory ChannelConnectionPage.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'] ?? json['data'];
    List<ChannelConnection> list = [];
    if (rawItems is List) {
      list = rawItems
          .whereType<Map<String, dynamic>>()
          .map((c) => ChannelConnection.fromJson(c))
          .toList();
    }
    final pagination = json['pagination'] is Map
        ? json['pagination'] as Map
        : null;
    return ChannelConnectionPage(
      items: list,
      nextCursor:
          pagination?['next_cursor']?.toString() ??
          json['next_cursor']?.toString(),
      hasMore: pagination?['has_more'] == true || json['has_more'] == true,
    );
  }
}

/// ==========================================
/// Automation Rules Models
/// ==========================================

/// Inbound automation rule projection.
/// Matches OpenAPI `#/components/schemas/AutomationRule`.
@immutable
class AutomationRule {
  final String id;
  final String businessId;
  final String name;
  final String status; // active | disabled
  final String triggerKind;
  final Map<String, dynamic> conditions;
  final String actionKind; // add_label | set_priority | assign_human
  final Map<String, dynamic> actionPayload;
  final int position;
  final String resourceVersion;
  final String? createdAt;
  final String? updatedAt;

  const AutomationRule({
    required this.id,
    required this.businessId,
    required this.name,
    required this.status,
    required this.triggerKind,
    this.conditions = const {},
    required this.actionKind,
    this.actionPayload = const {},
    required this.position,
    required this.resourceVersion,
    this.createdAt,
    this.updatedAt,
  });

  factory AutomationRule.fromJson(Map<String, dynamic> json) {
    return AutomationRule(
      id: json['id']?.toString() ?? '',
      businessId: json['business_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      triggerKind: json['trigger_kind']?.toString() ?? '',
      conditions: json['conditions'] is Map
          ? Map<String, dynamic>.from(json['conditions'] as Map)
          : {},
      actionKind: json['action_kind']?.toString() ?? '',
      actionPayload: json['action_payload'] is Map
          ? Map<String, dynamic>.from(json['action_payload'] as Map)
          : {},
      position: (json['position'] as num?)?.toInt() ?? 1,
      resourceVersion: json['resource_version']?.toString() ?? '1',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      'status': status,
      'trigger_kind': triggerKind,
      'conditions': conditions,
      'action_kind': actionKind,
      'action_payload': actionPayload,
      'position': position,
      'resource_version': resourceVersion,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }

  bool get isActive => status == 'active';
  bool get isDisabled => status == 'disabled';
}

/// Request body for creating an automation rule.
/// Matches OpenAPI `#/components/schemas/CreateAutomationRuleRequest`.
@immutable
class CreateAutomationRuleRequest {
  final String name;
  final String triggerKind;
  final Map<String, dynamic> conditions;
  final String actionKind;
  final Map<String, dynamic> actionPayload;
  final int? position;

  const CreateAutomationRuleRequest({
    required this.name,
    this.triggerKind = 'inbound_message',
    required this.conditions,
    required this.actionKind,
    required this.actionPayload,
    this.position,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'conditions': conditions,
      'action_kind': actionKind,
      'action_payload': actionPayload,
      if (position != null) 'position': position,
    };
  }
}

/// Request body for updating an automation rule.
/// Matches OpenAPI `#/components/schemas/UpdateAutomationRuleRequest`.
@immutable
class UpdateAutomationRuleRequest {
  final String? name;
  final String? status; // active | disabled
  final String? actionKind;
  final Map<String, dynamic>? actionPayload;
  final Map<String, dynamic>? conditions;
  final int? position;

  const UpdateAutomationRuleRequest({
    this.name,
    this.status,
    this.actionKind,
    this.actionPayload,
    this.conditions,
    this.position,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (status != null) 'status': status,
      if (actionKind != null) 'action_kind': actionKind,
      if (actionPayload != null) 'action_payload': actionPayload,
      if (conditions != null) 'conditions': conditions,
      if (position != null) 'position': position,
    };
  }
}

/// Paginated page of automation rules.
@immutable
class AutomationRulePage {
  final List<AutomationRule> items;
  final String? nextCursor;
  final bool hasMore;

  const AutomationRulePage({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });

  factory AutomationRulePage.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'] ?? json['data'];
    List<AutomationRule> list = [];
    if (rawItems is List) {
      list = rawItems
          .whereType<Map<String, dynamic>>()
          .map((r) => AutomationRule.fromJson(r))
          .toList();
    }
    final pagination = json['pagination'] is Map
        ? json['pagination'] as Map
        : null;
    return AutomationRulePage(
      items: list,
      nextCursor:
          pagination?['next_cursor']?.toString() ??
          json['next_cursor']?.toString(),
      hasMore: pagination?['has_more'] == true || json['has_more'] == true,
    );
  }
}

/// ==========================================
/// Structured AI Decisions Models
/// ==========================================

/// Structured AI Decision projection.
/// Matches OpenAPI `#/components/schemas/AIDecision`.
@immutable
class AIDecision {
  final String id;
  final String businessId;
  final String? conversationId;
  final String intentBase;
  final Map<String, dynamic> entities;
  final List<String> evidenceReferences;
  final String? requestedAction;
  final String? requestedCapability;
  final String? effectiveCapability;
  final bool requiresHuman;
  final String? policyVersion;
  final List<String> missingInformation;
  final String? lifecycle;
  final String? createdAt;

  const AIDecision({
    required this.id,
    required this.businessId,
    this.conversationId,
    required this.intentBase,
    this.entities = const {},
    this.evidenceReferences = const [],
    this.requestedAction,
    this.requestedCapability,
    this.effectiveCapability,
    this.requiresHuman = false,
    this.policyVersion,
    this.missingInformation = const [],
    this.lifecycle,
    this.createdAt,
  });

  factory AIDecision.fromJson(Map<String, dynamic> json) {
    var rawEv = json['evidence_references'];
    List<String> evList = [];
    if (rawEv is List) {
      evList = rawEv.map((e) => e.toString()).toList();
    }

    var rawMissing = json['missing_information'];
    List<String> missingList = [];
    if (rawMissing is List) {
      missingList = rawMissing.map((m) => m.toString()).toList();
    }

    return AIDecision(
      id: json['id']?.toString() ?? '',
      businessId: json['business_id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString(),
      intentBase: json['intent_base']?.toString() ?? '',
      entities: json['entities'] is Map
          ? Map<String, dynamic>.from(json['entities'] as Map)
          : {},
      evidenceReferences: evList,
      requestedAction: json['requested_action']?.toString(),
      requestedCapability: json['requested_capability']?.toString(),
      effectiveCapability: json['effective_capability']?.toString(),
      requiresHuman: json['requires_human'] == true,
      policyVersion: json['policy_version']?.toString(),
      missingInformation: missingList,
      lifecycle: json['lifecycle']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      if (conversationId != null) 'conversation_id': conversationId,
      'intent_base': intentBase,
      'entities': entities,
      'evidence_references': evidenceReferences,
      if (requestedAction != null) 'requested_action': requestedAction,
      if (requestedCapability != null)
        'requested_capability': requestedCapability,
      if (effectiveCapability != null)
        'effective_capability': effectiveCapability,
      'requires_human': requiresHuman,
      if (policyVersion != null) 'policy_version': policyVersion,
      'missing_information': missingInformation,
      if (lifecycle != null) 'lifecycle': lifecycle,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  String? get intent => intentBase;
}

/// Request body for requesting human review on an AI decision.
/// Matches OpenAPI `#/components/schemas/AIHumanRequest`.
@immutable
class AIHumanRequest {
  final String reason;

  const AIHumanRequest({required this.reason});

  Map<String, dynamic> toJson() {
    return {'reason': reason};
  }
}

/// Paginated page of AI decisions.
@immutable
class AIDecisionPage {
  final List<AIDecision> items;
  final String? nextCursor;
  final bool hasMore;

  const AIDecisionPage({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });

  factory AIDecisionPage.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'] ?? json['data'];
    List<AIDecision> list = [];
    if (rawItems is List) {
      list = rawItems
          .whereType<Map<String, dynamic>>()
          .map((d) => AIDecision.fromJson(d))
          .toList();
    }
    final pagination = json['pagination'] is Map
        ? json['pagination'] as Map
        : null;
    return AIDecisionPage(
      items: list,
      nextCursor:
          pagination?['next_cursor']?.toString() ??
          json['next_cursor']?.toString(),
      hasMore: pagination?['has_more'] == true || json['has_more'] == true,
    );
  }
}

/// ==========================================
/// Canned Replies Requests & DTOs
/// ==========================================

/// Request body for creating a reusable canned reply.
/// Matches OpenAPI `#/components/schemas/CreateCannedReplyRequest`.
@immutable
class CreateCannedReplyRequest {
  final String title;
  final String shortcut;
  final String body;

  const CreateCannedReplyRequest({
    required this.title,
    required this.shortcut,
    required this.body,
  });

  Map<String, dynamic> toJson() {
    return {'title': title, 'shortcut': shortcut, 'body': body};
  }
}

/// Request body for updating a reusable canned reply.
/// Matches OpenAPI `#/components/schemas/UpdateCannedReplyRequest`.
@immutable
class UpdateCannedReplyRequest {
  final String? title;
  final String? shortcut;
  final String? body;
  final String? status; // active | archived

  const UpdateCannedReplyRequest({
    this.title,
    this.shortcut,
    this.body,
    this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      if (shortcut != null) 'shortcut': shortcut,
      if (body != null) 'body': body,
      if (status != null) 'status': status,
    };
  }
}
