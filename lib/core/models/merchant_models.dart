/// Data models for Phase 2: Merchant Operations (Dashboard, Policy, Conversations, Messages, Notes, Canned Replies)
library;

/// GET /businesses/{business_id}/dashboard/overview
class DashboardOverview {
  final int openConversations;
  final int waitingHuman;
  final int newCustomers;
  final int newLeads;
  final int transactionsNeedingReview;
  final Map<String, int> connections;

  const DashboardOverview({
    required this.openConversations,
    required this.waitingHuman,
    required this.newCustomers,
    required this.newLeads,
    required this.transactionsNeedingReview,
    this.connections = const {},
  });

  factory DashboardOverview.fromJson(Map<String, dynamic> json) {
    final rawConnections = json['connections'] as Map<String, dynamic>?;
    final parsedConnections = <String, int>{};
    if (rawConnections != null) {
      rawConnections.forEach((key, value) {
        if (value is num) {
          parsedConnections[key] = value.toInt();
        }
      });
    }

    return DashboardOverview(
      openConversations: (json['open_conversations'] as num?)?.toInt() ?? 0,
      waitingHuman: (json['waiting_human'] as num?)?.toInt() ?? 0,
      newCustomers: (json['new_customers'] as num?)?.toInt() ?? 0,
      newLeads: (json['new_leads'] as num?)?.toInt() ?? 0,
      transactionsNeedingReview:
          (json['transactions_needing_review'] as num?)?.toInt() ?? 0,
      connections: parsedConnections,
    );
  }

  Map<String, dynamic> toJson() => {
    'open_conversations': openConversations,
    'waiting_human': waitingHuman,
    'new_customers': newCustomers,
    'new_leads': newLeads,
    'transactions_needing_review': transactionsNeedingReview,
    'connections': connections,
  };
}

/// GET /businesses/{business_id}/policy
class BusinessPolicy {
  final String businessId;
  final String aiMode;
  final bool defaultHumanReview;
  final bool allowAutoReply;
  final bool allowAutoLeadCreation;
  final bool allowAutoTransactionDraft;
  final bool allowAutoConfirmation;
  final String resourceVersion;

  const BusinessPolicy({
    required this.businessId,
    required this.aiMode,
    required this.defaultHumanReview,
    required this.allowAutoReply,
    required this.allowAutoLeadCreation,
    required this.allowAutoTransactionDraft,
    required this.allowAutoConfirmation,
    required this.resourceVersion,
  });

  factory BusinessPolicy.fromJson(Map<String, dynamic> json) {
    return BusinessPolicy(
      businessId: json['business_id'] as String? ?? '',
      aiMode: json['ai_mode'] as String? ?? 'assist',
      defaultHumanReview: json['default_human_review'] as bool? ?? false,
      allowAutoReply: json['allow_auto_reply'] as bool? ?? false,
      allowAutoLeadCreation: json['allow_auto_lead_creation'] as bool? ?? false,
      allowAutoTransactionDraft:
          json['allow_auto_transaction_draft'] as bool? ?? false,
      allowAutoConfirmation: json['allow_auto_confirmation'] as bool? ?? false,
      resourceVersion: json['resource_version'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'business_id': businessId,
    'ai_mode': aiMode,
    'default_human_review': defaultHumanReview,
    'allow_auto_reply': allowAutoReply,
    'allow_auto_lead_creation': allowAutoLeadCreation,
    'allow_auto_transaction_draft': allowAutoTransactionDraft,
    'allow_auto_confirmation': allowAutoConfirmation,
    'resource_version': resourceVersion,
  };
}

/// CustomerSummary embedded in Conversation
class CustomerSummary {
  final String id;
  final String? displayName;

  const CustomerSummary({required this.id, this.displayName});

  factory CustomerSummary.fromJson(Map<String, dynamic> json) {
    return CustomerSummary(
      id: json['id'] as String? ?? '',
      displayName: json['display_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (displayName != null) 'display_name': displayName,
  };
}

/// GET /businesses/{business_id}/conversations
class Conversation {
  final String id;
  final String businessId;
  final CustomerSummary customer;
  final String state;
  final String ownership;
  final String aiMode;
  final String priority;
  final String lastActivityAt;
  final String resourceVersion;
  final List<String> labels;
  final Map<String, String>? assignment;

  const Conversation({
    required this.id,
    required this.businessId,
    required this.customer,
    required this.state,
    required this.ownership,
    required this.aiMode,
    required this.priority,
    required this.lastActivityAt,
    required this.resourceVersion,
    this.labels = const [],
    this.assignment,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final rawLabels = json['labels'] as List<dynamic>?;
    final labelsList = rawLabels?.map((e) => e.toString()).toList() ?? [];

    final rawAssign = json['assignment'] as Map<String, dynamic>?;
    final parsedAssign = rawAssign?.map((k, v) => MapEntry(k, v.toString()));

    return Conversation(
      id: json['id'] as String? ?? '',
      businessId: json['business_id'] as String? ?? '',
      customer: CustomerSummary.fromJson(
        json['customer'] as Map<String, dynamic>? ?? {},
      ),
      state: json['state'] as String? ?? 'open',
      ownership: json['ownership'] as String? ?? 'unassigned',
      aiMode: json['ai_mode'] as String? ?? 'off',
      priority: json['priority'] as String? ?? 'normal',
      lastActivityAt: json['last_activity_at'] as String? ?? '',
      resourceVersion: json['resource_version'] as String? ?? '',
      labels: labelsList,
      assignment: parsedAssign,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'business_id': businessId,
    'customer': customer.toJson(),
    'state': state,
    'ownership': ownership,
    'ai_mode': aiMode,
    'priority': priority,
    'last_activity_at': lastActivityAt,
    'resource_version': resourceVersion,
    'labels': labels,
    if (assignment != null) 'assignment': assignment,
  };
}

/// GET /businesses/{business_id}/conversations/{conversation_id}/messages
class Message {
  final String id;
  final String conversationId;
  final String direction; // inbound, outbound
  final String origin; // human_agent, customer, system, ai
  final String status; // queued, accepted, delivered, failed
  final String? text;
  final bool private;
  final String? providerMessageReference;
  final String? createdAt;
  final String? occurredAt;

  const Message({
    required this.id,
    required this.conversationId,
    required this.direction,
    required this.origin,
    required this.status,
    this.text,
    this.private = false,
    this.providerMessageReference,
    this.createdAt,
    this.occurredAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String? ?? '',
      conversationId: json['conversation_id'] as String? ?? '',
      direction: json['direction'] as String? ?? 'inbound',
      origin: json['origin'] as String? ?? 'customer',
      status: json['status'] as String? ?? 'delivered',
      text: json['text'] as String?,
      private: json['private'] as bool? ?? false,
      providerMessageReference: json['provider_message_reference'] as String?,
      createdAt: json['created_at'] as String?,
      occurredAt: json['occurred_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'conversation_id': conversationId,
    'direction': direction,
    'origin': origin,
    'status': status,
    if (text != null) 'text': text,
    'private': private,
    if (providerMessageReference != null)
      'provider_message_reference': providerMessageReference,
    if (createdAt != null) 'created_at': createdAt,
    if (occurredAt != null) 'occurred_at': occurredAt,
  };
}

/// GET /businesses/{business_id}/canned-replies
class CannedReply {
  final String id;
  final String businessId;
  final String title;
  final String shortcut;
  final String body;
  final String status;
  final String resourceVersion;
  final String? createdAt;
  final String? updatedAt;

  const CannedReply({
    required this.id,
    required this.businessId,
    required this.title,
    required this.shortcut,
    required this.body,
    required this.status,
    required this.resourceVersion,
    this.createdAt,
    this.updatedAt,
  });

  factory CannedReply.fromJson(Map<String, dynamic> json) {
    return CannedReply(
      id: json['id'] as String? ?? '',
      businessId: json['business_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      shortcut: json['shortcut'] as String? ?? '',
      body: json['body'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      resourceVersion: json['resource_version'] as String? ?? '',
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'business_id': businessId,
    'title': title,
    'shortcut': shortcut,
    'body': body,
    'status': status,
    'resource_version': resourceVersion,
    if (createdAt != null) 'created_at': createdAt,
    if (updatedAt != null) 'updated_at': updatedAt,
  };
}
