import 'package:mujeeb24_app/core/models/auth_models.dart';

// ==========================================
// Platform Businesses
// ==========================================

class PlatformBusinessView {
  final String id;
  final String name;
  final String slug;
  final String platformStatus; // pending_setup, active, suspended, archived
  final String? ownerIdentitySummary;
  final String? subscriptionSummary;
  final String createdAt;
  final String updatedAt;

  const PlatformBusinessView({
    required this.id,
    required this.name,
    required this.slug,
    required this.platformStatus,
    this.ownerIdentitySummary,
    this.subscriptionSummary,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => platformStatus == 'active';
  bool get isPendingSetup => platformStatus == 'pending_setup';
  bool get isSuspended => platformStatus == 'suspended';
  bool get isArchived => platformStatus == 'archived';

  factory PlatformBusinessView.fromJson(Map<String, dynamic> json) {
    return PlatformBusinessView(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      platformStatus: json['platform_status'] as String? ?? 'active',
      ownerIdentitySummary: json['owner_identity_summary'] as String?,
      subscriptionSummary: json['subscription_summary'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'platform_status': platformStatus,
        'owner_identity_summary': ?ownerIdentitySummary,
        'subscription_summary': ?subscriptionSummary,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}

class PlatformCreateBusinessRequest {
  final String name;
  final String slug;
  final String? defaultCurrency;
  final String? locale;
  final String? timezone;

  const PlatformCreateBusinessRequest({
    required this.name,
    required this.slug,
    this.defaultCurrency,
    this.locale,
    this.timezone,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'slug': slug,
        'default_currency': ?defaultCurrency,
        'locale': ?locale,
        'timezone': ?timezone,
      };
}

class PlatformAssignOwnerRequest {
  final String ownerEmail;
  final String ownerDisplayName;
  final String? ownerPassword;

  const PlatformAssignOwnerRequest({
    required this.ownerEmail,
    required this.ownerDisplayName,
    this.ownerPassword,
  });

  Map<String, dynamic> toJson() => {
        'owner_email': ownerEmail,
        'owner_display_name': ownerDisplayName,
        'owner_password': ?ownerPassword,
      };
}

// ==========================================
// Platform Channels & Providers
// ==========================================

class PlatformChannelView {
  final String businessId;
  final String connectionId;
  final String channel;
  final String provider;
  final String status;
  final String health;
  final String? providerAccountRef;
  final String? providerConnectionRef;
  final String? lastHealthCheckAt;
  final String? lastSuccess;
  final String? lastFailure;
  final String? failureCode;

  const PlatformChannelView({
    required this.businessId,
    required this.connectionId,
    required this.channel,
    required this.provider,
    required this.status,
    required this.health,
    this.providerAccountRef,
    this.providerConnectionRef,
    this.lastHealthCheckAt,
    this.lastSuccess,
    this.lastFailure,
    this.failureCode,
  });

  bool get isHealthy => health.toLowerCase() == 'healthy';

  factory PlatformChannelView.fromJson(Map<String, dynamic> json) {
    return PlatformChannelView(
      businessId: json['business_id'] as String? ?? '',
      connectionId: json['connection_id'] as String? ?? '',
      channel: json['channel'] as String? ?? '',
      provider: json['provider'] as String? ?? '',
      status: json['status'] as String? ?? '',
      health: json['health'] as String? ?? 'unknown',
      providerAccountRef: json['provider_account_ref'] as String?,
      providerConnectionRef: json['provider_connection_ref'] as String?,
      lastHealthCheckAt: json['last_health_check_at'] as String?,
      lastSuccess: json['last_success'] as String?,
      lastFailure: json['last_failure'] as String?,
      failureCode: json['failure_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'business_id': businessId,
        'connection_id': connectionId,
        'channel': channel,
        'provider': provider,
        'status': status,
        'health': health,
        'provider_account_ref': ?providerAccountRef,
        'provider_connection_ref': ?providerConnectionRef,
        'last_health_check_at': ?lastHealthCheckAt,
        'last_success': ?lastSuccess,
        'last_failure': ?lastFailure,
        'failure_code': ?failureCode,
      };
}

class PlatformProviderView {
  final String providerId;
  final String providerType;
  final String status;
  final String health;
  final String? lastHealthCheckAt;

  const PlatformProviderView({
    required this.providerId,
    required this.providerType,
    required this.status,
    required this.health,
    this.lastHealthCheckAt,
  });

  factory PlatformProviderView.fromJson(Map<String, dynamic> json) {
    return PlatformProviderView(
      providerId: json['provider_id'] as String? ?? '',
      providerType: json['provider_type'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      health: json['health'] as String? ?? 'healthy',
      lastHealthCheckAt: json['last_health_check_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'provider_id': providerId,
        'provider_type': providerType,
        'status': status,
        'health': health,
        'last_health_check_at': ?lastHealthCheckAt,
      };
}

// ==========================================
// Platform AI Runtime & Usage
// ==========================================

class PlatformAIRuntime {
  final String status; // enabled, disabled
  final String health;

  const PlatformAIRuntime({required this.status, required this.health});

  bool get isEnabled => status.toLowerCase() == 'enabled';

  factory PlatformAIRuntime.fromJson(Map<String, dynamic> json) {
    return PlatformAIRuntime(
      status: json['status'] as String? ?? 'enabled',
      health: json['health'] as String? ?? 'healthy',
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'health': health,
      };
}

class PlatformAIProviderInfo {
  final String provider;
  final String model;
  final bool enabled;
  final String health;

  const PlatformAIProviderInfo({
    required this.provider,
    required this.model,
    required this.enabled,
    required this.health,
  });

  factory PlatformAIProviderInfo.fromJson(Map<String, dynamic> json) {
    return PlatformAIProviderInfo(
      provider: json['provider'] as String? ?? '',
      model: json['model'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? true,
      health: json['health'] as String? ?? 'healthy',
    );
  }

  Map<String, dynamic> toJson() => {
        'provider': provider,
        'model': model,
        'enabled': enabled,
        'health': health,
      };
}

class PlatformAIOverviewView {
  final PlatformAIRuntime runtime;
  final PlatformAIProviderInfo provider;

  const PlatformAIOverviewView({
    required this.runtime,
    required this.provider,
  });

  factory PlatformAIOverviewView.fromJson(Map<String, dynamic> json) {
    return PlatformAIOverviewView(
      runtime: PlatformAIRuntime.fromJson(
        json['runtime'] as Map<String, dynamic>? ?? {},
      ),
      provider: PlatformAIProviderInfo.fromJson(
        json['provider'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'runtime': runtime.toJson(),
        'provider': provider.toJson(),
      };
}

class PlatformAIHealthCheckResult {
  final String provider;
  final String model;
  final String result;
  final int latencyMs;
  final String checkedAt;
  final String? failureCode;

  const PlatformAIHealthCheckResult({
    required this.provider,
    required this.model,
    required this.result,
    required this.latencyMs,
    required this.checkedAt,
    this.failureCode,
  });

  bool get isSuccess => result.toLowerCase() == 'success';

  factory PlatformAIHealthCheckResult.fromJson(Map<String, dynamic> json) {
    return PlatformAIHealthCheckResult(
      provider: json['provider'] as String? ?? '',
      model: json['model'] as String? ?? '',
      result: json['result'] as String? ?? '',
      latencyMs: (json['latency_ms'] as num?)?.toInt() ?? 0,
      checkedAt: json['checked_at'] as String? ?? '',
      failureCode: json['failure_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'provider': provider,
        'model': model,
        'result': result,
        'latency_ms': latencyMs,
        'checked_at': checkedAt,
        'failure_code': ?failureCode,
      };
}

class PlatformAIUsageOverviewView {
  final int totalInvocations;
  final int totalTokens;
  final int estimatedCostYer;

  const PlatformAIUsageOverviewView({
    required this.totalInvocations,
    required this.totalTokens,
    required this.estimatedCostYer,
  });

  factory PlatformAIUsageOverviewView.fromJson(Map<String, dynamic> json) {
    return PlatformAIUsageOverviewView(
      totalInvocations: (json['total_invocations'] as num?)?.toInt() ?? 0,
      totalTokens: (json['total_tokens'] as num?)?.toInt() ?? 0,
      estimatedCostYer: (json['estimated_cost_yer'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'total_invocations': totalInvocations,
        'total_tokens': totalTokens,
        'estimated_cost_yer': estimatedCostYer,
      };
}

// ==========================================
// Platform Plans & Subscriptions
// ==========================================

class PlanView {
  final String id;
  final String code;
  final String displayName;
  final int priceYer;
  final String billingInterval; // monthly, annual
  final String status; // draft, active, retired
  final int aiReplyLimit;
  final int aiCatalogLimit;
  final int channelLimit;
  final int? internalAiCostBudgetYer;
  final String createdAt;
  final String updatedAt;
  final String? retiredAt;

  const PlanView({
    required this.id,
    required this.code,
    required this.displayName,
    required this.priceYer,
    required this.billingInterval,
    required this.status,
    required this.aiReplyLimit,
    required this.aiCatalogLimit,
    required this.channelLimit,
    this.internalAiCostBudgetYer,
    required this.createdAt,
    required this.updatedAt,
    this.retiredAt,
  });

  bool get isDraft => status == 'draft';
  bool get isActive => status == 'active';
  bool get isRetired => status == 'retired';

  factory PlanView.fromJson(Map<String, dynamic> json) {
    return PlanView(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      priceYer: (json['price_yer'] as num?)?.toInt() ?? 0,
      billingInterval: json['billing_interval'] as String? ?? 'monthly',
      status: json['status'] as String? ?? 'draft',
      aiReplyLimit: (json['ai_reply_limit'] as num?)?.toInt() ?? 0,
      aiCatalogLimit: (json['ai_catalog_limit'] as num?)?.toInt() ?? 0,
      channelLimit: (json['channel_limit'] as num?)?.toInt() ?? 0,
      internalAiCostBudgetYer:
          (json['internal_ai_cost_budget_yer'] as num?)?.toInt(),
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      retiredAt: json['retired_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'display_name': displayName,
        'price_yer': priceYer,
        'billing_interval': billingInterval,
        'status': status,
        'ai_reply_limit': aiReplyLimit,
        'ai_catalog_limit': aiCatalogLimit,
        'channel_limit': channelLimit,
        'internal_ai_cost_budget_yer': ?internalAiCostBudgetYer,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'retired_at': ?retiredAt,
      };
}

class PlatformCreatePlanRequest {
  final String code;
  final String displayName;
  final int priceYer;
  final String billingInterval;
  final int aiReplyLimit;
  final int aiCatalogLimit;
  final int channelLimit;
  final int? internalAiCostBudgetYer;

  const PlatformCreatePlanRequest({
    required this.code,
    required this.displayName,
    required this.priceYer,
    required this.billingInterval,
    required this.aiReplyLimit,
    required this.aiCatalogLimit,
    required this.channelLimit,
    this.internalAiCostBudgetYer,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'display_name': displayName,
        'price_yer': priceYer,
        'billing_interval': billingInterval,
        'ai_reply_limit': aiReplyLimit,
        'ai_catalog_limit': aiCatalogLimit,
        'channel_limit': channelLimit,
        'internal_ai_cost_budget_yer': ?internalAiCostBudgetYer,
      };
}

class SubscriptionView {
  final String id;
  final String businessId;
  final String planId;
  final String planCode;
  final int planVersion;
  final String periodStart;
  final String periodEnd;
  final String status; // active, past_due, cancelled, expired
  final int aiReplyLimit;
  final int aiCatalogLimit;
  final int channelLimit;
  final int? internalAiCostBudgetYer;
  final int? costBudgetOverrideYer;
  final String? costBudgetOverrideReason;
  final String? cancelledAt;
  final String? cancelledReason;
  final String createdAt;
  final String? updatedAt;

  const SubscriptionView({
    required this.id,
    required this.businessId,
    required this.planId,
    required this.planCode,
    required this.planVersion,
    required this.periodStart,
    required this.periodEnd,
    required this.status,
    required this.aiReplyLimit,
    required this.aiCatalogLimit,
    required this.channelLimit,
    this.internalAiCostBudgetYer,
    this.costBudgetOverrideYer,
    this.costBudgetOverrideReason,
    this.cancelledAt,
    this.cancelledReason,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == 'active';
  bool get isCancelled => status == 'cancelled';

  factory SubscriptionView.fromJson(Map<String, dynamic> json) {
    return SubscriptionView(
      id: json['id'] as String? ?? '',
      businessId: json['business_id'] as String? ?? '',
      planId: json['plan_id'] as String? ?? '',
      planCode: json['plan_code'] as String? ?? '',
      planVersion: (json['plan_version'] as num?)?.toInt() ?? 1,
      periodStart: json['period_start'] as String? ?? '',
      periodEnd: json['period_end'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      aiReplyLimit: (json['ai_reply_limit'] as num?)?.toInt() ?? 0,
      aiCatalogLimit: (json['ai_catalog_limit'] as num?)?.toInt() ?? 0,
      channelLimit: (json['channel_limit'] as num?)?.toInt() ?? 0,
      internalAiCostBudgetYer:
          (json['internal_ai_cost_budget_yer'] as num?)?.toInt(),
      costBudgetOverrideYer:
          (json['cost_budget_override_yer'] as num?)?.toInt(),
      costBudgetOverrideReason:
          json['cost_budget_override_reason'] as String?,
      cancelledAt: json['cancelled_at'] as String?,
      cancelledReason: json['cancelled_reason'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'business_id': businessId,
        'plan_id': planId,
        'plan_code': planCode,
        'plan_version': planVersion,
        'period_start': periodStart,
        'period_end': periodEnd,
        'status': status,
        'ai_reply_limit': aiReplyLimit,
        'ai_catalog_limit': aiCatalogLimit,
        'channel_limit': channelLimit,
        'internal_ai_cost_budget_yer': ?internalAiCostBudgetYer,
        'cost_budget_override_yer': ?costBudgetOverrideYer,
        'cost_budget_override_reason': ?costBudgetOverrideReason,
        'cancelled_at': ?cancelledAt,
        'cancelled_reason': ?cancelledReason,
        'created_at': createdAt,
        'updated_at': ?updatedAt,
      };
}

class PlatformOverrideBudgetRequest {
  final int costBudgetOverrideYer;
  final String reason;

  const PlatformOverrideBudgetRequest({
    required this.costBudgetOverrideYer,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
        'cost_budget_override_yer': costBudgetOverrideYer,
        'reason': reason,
      };
}

// ==========================================
// Platform Payments
// ==========================================

class PaymentView {
  final String id;
  final String subscriptionId;
  final String businessId;
  final int amountYer;
  final String method;
  final String reference;
  final String paidAt;
  final String recordedBy;
  final String? createdAt;

  const PaymentView({
    required this.id,
    required this.subscriptionId,
    required this.businessId,
    required this.amountYer,
    required this.method,
    required this.reference,
    required this.paidAt,
    required this.recordedBy,
    this.createdAt,
  });

  factory PaymentView.fromJson(Map<String, dynamic> json) {
    return PaymentView(
      id: json['id'] as String? ?? '',
      subscriptionId: json['subscription_id'] as String? ?? '',
      businessId: json['business_id'] as String? ?? '',
      amountYer: (json['amount_yer'] as num?)?.toInt() ?? 0,
      method: json['method'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      paidAt: json['paid_at'] as String? ?? '',
      recordedBy: json['recorded_by'] as String? ?? '',
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subscription_id': subscriptionId,
        'business_id': businessId,
        'amount_yer': amountYer,
        'method': method,
        'reference': reference,
        'paid_at': paidAt,
        'recorded_by': recordedBy,
        'created_at': ?createdAt,
      };
}

class PlatformRecordPaymentRequest {
  final int amountYer;
  final String method;
  final String reference;
  final String? paidAt;

  const PlatformRecordPaymentRequest({
    required this.amountYer,
    required this.method,
    required this.reference,
    this.paidAt,
  });

  Map<String, dynamic> toJson() => {
        'amount_yer': amountYer,
        'method': method,
        'reference': reference,
        'paid_at': ?paidAt,
      };
}

// ==========================================
// Platform Support Tickets
// ==========================================

class SupportTicketView {
  final String id;
  final String businessId;
  final String subject;
  final String status; // open, in_progress, resolved, closed
  final String priority; // low, normal, high, urgent
  final String category; // billing, technical, ai, other
  final String createdBy;
  final String createdByType;
  final String? resolvedBy;
  final String? resolvedAt;
  final String? closedBy;
  final String? closedAt;
  final String? lastMessageAt;
  final String? createdAt;
  final String? updatedAt;

  const SupportTicketView({
    required this.id,
    required this.businessId,
    required this.subject,
    required this.status,
    required this.priority,
    required this.category,
    required this.createdBy,
    required this.createdByType,
    this.resolvedBy,
    this.resolvedAt,
    this.closedBy,
    this.closedAt,
    this.lastMessageAt,
    this.createdAt,
    this.updatedAt,
  });

  bool get isOpen => status == 'open';
  bool get isInProgress => status == 'in_progress';
  bool get isResolved => status == 'resolved';
  bool get isClosed => status == 'closed';

  factory SupportTicketView.fromJson(Map<String, dynamic> json) {
    return SupportTicketView(
      id: json['id'] as String? ?? '',
      businessId: json['business_id'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      status: json['status'] as String? ?? 'open',
      priority: json['priority'] as String? ?? 'normal',
      category: json['category'] as String? ?? 'technical',
      createdBy: json['created_by'] as String? ?? '',
      createdByType: json['created_by_type'] as String? ?? 'merchant',
      resolvedBy: json['resolved_by'] as String?,
      resolvedAt: json['resolved_at'] as String?,
      closedBy: json['closed_by'] as String?,
      closedAt: json['closed_at'] as String?,
      lastMessageAt: json['last_message_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'business_id': businessId,
        'subject': subject,
        'status': status,
        'priority': priority,
        'category': category,
        'created_by': createdBy,
        'created_by_type': createdByType,
        'resolved_by': ?resolvedBy,
        'resolved_at': ?resolvedAt,
        'closed_by': ?closedBy,
        'closed_at': ?closedAt,
        'last_message_at': ?lastMessageAt,
        'created_at': ?createdAt,
        'updated_at': ?updatedAt,
      };
}

class PlatformCreateTicketRequest {
  final String subject;
  final String category;
  final String priority;
  final String initialMessage;

  const PlatformCreateTicketRequest({
    required this.subject,
    required this.category,
    required this.priority,
    required this.initialMessage,
  });

  Map<String, dynamic> toJson() => {
        'subject': subject,
        'category': category,
        'priority': priority,
        'initial_message': initialMessage,
      };
}

class PlatformTicketMessageRequest {
  final String body;

  const PlatformTicketMessageRequest({required this.body});

  Map<String, dynamic> toJson() => {
        'body': body,
      };
}

// ==========================================
// Platform Audit Events
// ==========================================

class PlatformAuditEventView {
  final String id;
  final String action;
  final String targetType;
  final String? targetId;
  final String? businessId;
  final String? actorPlatformAdminId;
  final String result;
  final String? failureCode;
  final Map<String, dynamic> metadata;
  final String occurredAt;

  const PlatformAuditEventView({
    required this.id,
    required this.action,
    required this.targetType,
    this.targetId,
    this.businessId,
    this.actorPlatformAdminId,
    required this.result,
    this.failureCode,
    required this.metadata,
    required this.occurredAt,
  });

  factory PlatformAuditEventView.fromJson(Map<String, dynamic> json) {
    return PlatformAuditEventView(
      id: json['id'] as String? ?? '',
      action: json['action'] as String? ?? '',
      targetType: json['target_type'] as String? ?? '',
      targetId: json['target_id'] as String?,
      businessId: json['business_id'] as String?,
      actorPlatformAdminId: json['actor_platform_admin_id'] as String?,
      result: json['result'] as String? ?? '',
      failureCode: json['failure_code'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      occurredAt: json['occurred_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'action': action,
        'target_type': targetType,
        'target_id': ?targetId,
        'business_id': ?businessId,
        'actor_platform_admin_id': ?actorPlatformAdminId,
        'result': result,
        'failure_code': ?failureCode,
        'metadata': metadata,
        'occurred_at': occurredAt,
      };
}

// ==========================================
// Paginated Collections
// ==========================================

class PlatformBusinessPage {
  final List<PlatformBusinessView> items;
  final PaginationPage pagination;
  final String requestId;

  const PlatformBusinessPage({
    required this.items,
    required this.pagination,
    required this.requestId,
  });

  factory PlatformBusinessPage.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    return PlatformBusinessPage(
      items: list
          .map((e) => PlatformBusinessView.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: PaginationPage.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
      requestId: json['request_id'] as String? ?? '',
    );
  }
}

class PlatformChannelPage {
  final List<PlatformChannelView> items;
  final PaginationPage pagination;
  final String requestId;

  const PlatformChannelPage({
    required this.items,
    required this.pagination,
    required this.requestId,
  });

  factory PlatformChannelPage.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    return PlatformChannelPage(
      items: list
          .map((e) => PlatformChannelView.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: PaginationPage.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
      requestId: json['request_id'] as String? ?? '',
    );
  }
}

class PlatformPlanPage {
  final List<PlanView> items;
  final PaginationPage pagination;
  final String requestId;

  const PlatformPlanPage({
    required this.items,
    required this.pagination,
    required this.requestId,
  });

  factory PlatformPlanPage.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    return PlatformPlanPage(
      items: list
          .map((e) => PlanView.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: PaginationPage.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
      requestId: json['request_id'] as String? ?? '',
    );
  }
}

class PlatformSubscriptionPage {
  final List<SubscriptionView> items;
  final PaginationPage pagination;
  final String requestId;

  const PlatformSubscriptionPage({
    required this.items,
    required this.pagination,
    required this.requestId,
  });

  factory PlatformSubscriptionPage.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    return PlatformSubscriptionPage(
      items: list
          .map((e) => SubscriptionView.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: PaginationPage.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
      requestId: json['request_id'] as String? ?? '',
    );
  }
}

class PlatformPaymentPage {
  final List<PaymentView> items;
  final PaginationPage pagination;
  final String requestId;

  const PlatformPaymentPage({
    required this.items,
    required this.pagination,
    required this.requestId,
  });

  factory PlatformPaymentPage.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    return PlatformPaymentPage(
      items: list
          .map((e) => PaymentView.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: PaginationPage.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
      requestId: json['request_id'] as String? ?? '',
    );
  }
}

class PlatformTicketPage {
  final List<SupportTicketView> items;
  final PaginationPage pagination;
  final String requestId;

  const PlatformTicketPage({
    required this.items,
    required this.pagination,
    required this.requestId,
  });

  factory PlatformTicketPage.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    return PlatformTicketPage(
      items: list
          .map((e) => SupportTicketView.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: PaginationPage.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
      requestId: json['request_id'] as String? ?? '',
    );
  }
}

class PlatformAuditPage {
  final List<PlatformAuditEventView> items;
  final PaginationPage pagination;
  final String requestId;

  const PlatformAuditPage({
    required this.items,
    required this.pagination,
    required this.requestId,
  });

  factory PlatformAuditPage.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    return PlatformAuditPage(
      items: list
          .map((e) => PlatformAuditEventView.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: PaginationPage.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
      requestId: json['request_id'] as String? ?? '',
    );
  }
}
