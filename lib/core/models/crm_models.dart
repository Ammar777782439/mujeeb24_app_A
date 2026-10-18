/// Data models for Phase 3: Customers & Leads (CRM operations)
/// Adhering strictly to OpenAPI specification `mujeeb24-dashboard-v1.generated.yaml`
library;

/// Contact point input used when creating or updating customers
class ContactPointInput {
  final String kind;
  final String value;

  const ContactPointInput({required this.kind, required this.value});

  factory ContactPointInput.fromJson(Map<String, dynamic> json) {
    return ContactPointInput(
      kind: json['kind'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'kind': kind, 'value': value};
}

/// Contact point representation in Customer object
class ContactPoint {
  final String kind;
  final String valueNormalized;
  final String verificationStatus;

  const ContactPoint({
    required this.kind,
    required this.valueNormalized,
    required this.verificationStatus,
  });

  factory ContactPoint.fromJson(Map<String, dynamic> json) {
    return ContactPoint(
      kind: json['kind'] as String? ?? '',
      valueNormalized: json['value_normalized'] as String? ?? '',
      verificationStatus:
          json['verification_status'] as String? ?? 'unverified',
    );
  }

  Map<String, dynamic> toJson() => {
    'kind': kind,
    'value_normalized': valueNormalized,
    'verification_status': verificationStatus,
  };
}

/// Customer entity: GET /businesses/{business_id}/customers/{customer_id}
class Customer {
  final String id;
  final String businessId;
  final String? displayName;
  final List<ContactPoint>? contactPoints;
  final Map<String, dynamic>? profile;
  final String status;
  final String resourceVersion;
  final String createdAt;
  final String updatedAt;

  const Customer({
    required this.id,
    required this.businessId,
    this.displayName,
    this.contactPoints,
    this.profile,
    required this.status,
    required this.resourceVersion,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    List<ContactPoint>? points;
    if (json['contact_points'] is List) {
      points = (json['contact_points'] as List)
          .whereType<Map<String, dynamic>>()
          .map(ContactPoint.fromJson)
          .toList();
    }

    return Customer(
      id: json['id'] as String? ?? '',
      businessId: json['business_id'] as String? ?? '',
      displayName: json['display_name'] as String?,
      contactPoints: points,
      profile: json['profile'] as Map<String, dynamic>?,
      status: json['status'] as String? ?? 'active',
      resourceVersion: json['resource_version'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'business_id': businessId,
    if (displayName != null) 'display_name': displayName,
    if (contactPoints != null)
      'contact_points': contactPoints!.map((p) => p.toJson()).toList(),
    if (profile != null) 'profile': profile,
    'status': status,
    'resource_version': resourceVersion,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  /// Returns primary phone if available in contact points
  String? get primaryPhone {
    if (contactPoints == null || contactPoints!.isEmpty) {
      return null;
    }
    for (final point in contactPoints!) {
      final kind = point.kind.toLowerCase();
      if (kind == 'phone' || kind == 'mobile' || kind == 'whatsapp') {
        return point.valueNormalized;
      }
    }
    return null;
  }

  /// Returns primary email if available in contact points
  String? get primaryEmail {
    if (contactPoints == null || contactPoints!.isEmpty) {
      return null;
    }
    for (final point in contactPoints!) {
      if (point.kind.toLowerCase() == 'email') {
        return point.valueNormalized;
      }
    }
    return null;
  }
}

/// Request to create a customer: POST /businesses/{business_id}/customers
class CreateCustomerRequest {
  final List<ContactPointInput>? contactPoints;
  final String? localePreference;
  final Map<String, dynamic>? profile;

  const CreateCustomerRequest({
    this.contactPoints,
    this.localePreference,
    this.profile,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (contactPoints != null) {
      map['contact_points'] = contactPoints!.map((p) => p.toJson()).toList();
    }
    if (localePreference != null && localePreference!.isNotEmpty) {
      map['locale_preference'] = localePreference;
    }
    if (profile != null && profile!.isNotEmpty) {
      map['profile'] = profile;
    }
    return map;
  }
}

/// Request to update a customer: PATCH /businesses/{business_id}/customers/{customer_id}
class UpdateCustomerRequest {
  final List<ContactPointInput>? contactPoints;
  final String? localePreference;
  final Map<String, dynamic>? profile;

  const UpdateCustomerRequest({
    this.contactPoints,
    this.localePreference,
    this.profile,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (contactPoints != null) {
      map['contact_points'] = contactPoints!.map((p) => p.toJson()).toList();
    }
    if (localePreference != null && localePreference!.isNotEmpty) {
      map['locale_preference'] = localePreference;
    }
    if (profile != null && profile!.isNotEmpty) {
      map['profile'] = profile;
    }
    return map;
  }
}

/// Request to merge customers: POST /businesses/{business_id}/customers/{customer_id}/merge
class MergeCustomerRequest {
  final String targetCustomerId;
  final String reason;

  const MergeCustomerRequest({
    required this.targetCustomerId,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
    'target_customer_id': targetCustomerId,
    'reason': reason,
  };
}

/// Commercial transaction read-only summary for Customer:
/// GET /businesses/{business_id}/customers/{customer_id}/transactions
class CommercialTransaction {
  final String id;
  final String businessId;
  final String customerId;
  final String? leadId;
  final String transactionType;
  final String state;
  final double? totalAmount;
  final String? currency;
  final List<dynamic>? lines;
  final int schemaVersion;
  final String resourceVersion;
  final String createdAt;
  final String updatedAt;

  const CommercialTransaction({
    required this.id,
    required this.businessId,
    required this.customerId,
    this.leadId,
    required this.transactionType,
    required this.state,
    this.totalAmount,
    this.currency,
    this.lines,
    required this.schemaVersion,
    required this.resourceVersion,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommercialTransaction.fromJson(Map<String, dynamic> json) {
    return CommercialTransaction(
      id: json['id'] as String? ?? '',
      businessId: json['business_id'] as String? ?? '',
      customerId: json['customer_id'] as String? ?? '',
      leadId: json['lead_id'] as String?,
      transactionType: json['transaction_type'] as String? ?? '',
      state: json['state'] as String? ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      lines: json['lines'] as List<dynamic>?,
      schemaVersion: (json['schema_version'] as num?)?.toInt() ?? 1,
      resourceVersion: json['resource_version'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'business_id': businessId,
    'customer_id': customerId,
    if (leadId != null) 'lead_id': leadId,
    'transaction_type': transactionType,
    'state': state,
    if (totalAmount != null) 'total_amount': totalAmount,
    if (currency != null) 'currency': currency,
    if (lines != null) 'lines': lines,
    'schema_version': schemaVersion,
    'resource_version': resourceVersion,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

/// Lead entity: GET /businesses/{business_id}/leads/{lead_id}
class Lead {
  final String id;
  final String businessId;
  final String customerId;
  final String status;
  final String createdBy;
  final String resourceVersion;
  final String? scoreBand;
  final double? currentScore;

  const Lead({
    required this.id,
    required this.businessId,
    required this.customerId,
    required this.status,
    required this.createdBy,
    required this.resourceVersion,
    this.scoreBand,
    this.currentScore,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'] as String? ?? '',
      businessId: json['business_id'] as String? ?? '',
      customerId: json['customer_id'] as String? ?? '',
      status: json['status'] as String? ?? 'new',
      createdBy: json['created_by'] as String? ?? '',
      resourceVersion: json['resource_version'] as String? ?? '',
      scoreBand: json['score_band'] as String?,
      currentScore: (json['current_score'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'business_id': businessId,
    'customer_id': customerId,
    'status': status,
    'created_by': createdBy,
    'resource_version': resourceVersion,
    if (scoreBand != null) 'score_band': scoreBand,
    if (currentScore != null) 'current_score': currentScore,
  };
}

/// Request to create a lead: POST /businesses/{business_id}/leads
class CreateLeadRequest {
  final String customerId;
  final Map<String, dynamic>? qualificationContext;

  const CreateLeadRequest({
    required this.customerId,
    this.qualificationContext,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'customer_id': customerId};
    if (qualificationContext != null && qualificationContext!.isNotEmpty) {
      map['qualification_context'] = qualificationContext;
    }
    return map;
  }
}

/// Request to update a lead: PATCH /businesses/{business_id}/leads/{lead_id}
class UpdateLeadRequest {
  final Map<String, dynamic>? qualificationContext;

  const UpdateLeadRequest({this.qualificationContext});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (qualificationContext != null && qualificationContext!.isNotEmpty) {
      map['qualification_context'] = qualificationContext;
    }
    return map;
  }
}

/// Request to mark lead lost: POST /businesses/{business_id}/leads/{lead_id}/mark-lost
class MarkLeadLostRequest {
  final String lostReason;

  const MarkLeadLostRequest({required this.lostReason});

  Map<String, dynamic> toJson() => {'lost_reason': lostReason};
}

/// Request to qualify lead: POST /businesses/{business_id}/leads/{lead_id}/qualify
class LeadDecisionRequest {
  final String? reason;
  final List<String>? evidenceReferences;

  const LeadDecisionRequest({this.reason, this.evidenceReferences});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (reason != null && reason!.isNotEmpty) {
      map['reason'] = reason;
    }
    if (evidenceReferences != null && evidenceReferences!.isNotEmpty) {
      map['evidence_references'] = evidenceReferences;
    }
    return map;
  }
}

/// Lead score entry: GET /businesses/{business_id}/leads/{lead_id}/scores
class LeadScore {
  final String id;
  final String leadId;
  final double value;
  final String band;
  final Map<String, dynamic> factors;
  final String calculatedAt;

  const LeadScore({
    required this.id,
    required this.leadId,
    required this.value,
    required this.band,
    required this.factors,
    required this.calculatedAt,
  });

  factory LeadScore.fromJson(Map<String, dynamic> json) {
    return LeadScore(
      id: json['id'] as String? ?? '',
      leadId: json['lead_id'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      band: json['band'] as String? ?? 'low',
      factors: json['factors'] as Map<String, dynamic>? ?? {},
      calculatedAt: json['calculated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'lead_id': leadId,
    'value': value,
    'band': band,
    'factors': factors,
    'calculated_at': calculatedAt,
  };
}

/// Lead attribution entry: GET /businesses/{business_id}/leads/{lead_id}/attributions
class LeadAttribution {
  final String id;
  final String leadId;
  final String? sourceChannel;
  final String? sourceConversationId;
  final String? catalogItemId;
  final String? offerId;
  final String capturedAt;

  const LeadAttribution({
    required this.id,
    required this.leadId,
    this.sourceChannel,
    this.sourceConversationId,
    this.catalogItemId,
    this.offerId,
    required this.capturedAt,
  });

  factory LeadAttribution.fromJson(Map<String, dynamic> json) {
    return LeadAttribution(
      id: json['id'] as String? ?? '',
      leadId: json['lead_id'] as String? ?? '',
      sourceChannel: json['source_channel'] as String?,
      sourceConversationId: json['source_conversation_id'] as String?,
      catalogItemId: json['catalog_item_id'] as String?,
      offerId: json['offer_id'] as String?,
      capturedAt: json['captured_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'lead_id': leadId,
    if (sourceChannel != null) 'source_channel': sourceChannel,
    if (sourceConversationId != null)
      'source_conversation_id': sourceConversationId,
    if (catalogItemId != null) 'catalog_item_id': catalogItemId,
    if (offerId != null) 'offer_id': offerId,
    'captured_at': capturedAt,
  };
}
