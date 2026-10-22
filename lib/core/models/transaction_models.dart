/// Data models for Phase 4: Commercial Transactions & Reviews
/// Adhering strictly to OpenAPI specification `mujeeb24-dashboard-v1.generated.yaml`
library;

import 'package:mujeeb24_app/core/models/crm_models.dart';

export 'package:mujeeb24_app/core/models/crm_models.dart'
    show CommercialTransaction;

/// Order line snapshot representation within a CommercialTransaction
/// Schema: `#/components/schemas/OrderLineSnapshot`
class OrderLineSnapshot {
  final String id;
  final String catalogItemId;
  final String itemNameSnapshot;
  final double quantity;
  final double? unitPriceSnapshot;
  final String? currency;
  final String? offerId;
  final String? variantId;

  const OrderLineSnapshot({
    required this.id,
    required this.catalogItemId,
    required this.itemNameSnapshot,
    required this.quantity,
    this.unitPriceSnapshot,
    this.currency,
    this.offerId,
    this.variantId,
  });

  factory OrderLineSnapshot.fromJson(Map<String, dynamic> json) {
    return OrderLineSnapshot(
      id: json['id'] as String? ?? '',
      catalogItemId: json['catalog_item_id'] as String? ?? '',
      itemNameSnapshot: json['item_name_snapshot'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unitPriceSnapshot: (json['unit_price_snapshot'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      offerId: json['offer_id'] as String?,
      variantId: json['variant_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'catalog_item_id': catalogItemId,
    'item_name_snapshot': itemNameSnapshot,
    'quantity': quantity,
    if (unitPriceSnapshot != null) 'unit_price_snapshot': unitPriceSnapshot,
    if (currency != null) 'currency': currency,
    if (offerId != null) 'offer_id': offerId,
    if (variantId != null) 'variant_id': variantId,
  };
}

/// Transaction line input used when creating or updating transaction drafts
/// Schema: `#/components/schemas/TransactionLineInput`
class TransactionLineInput {
  final String catalogItemId;
  final double quantity;
  final String? offerId;
  final String? variantId;
  final Map<String, dynamic>? selectedAttributes;

  const TransactionLineInput({
    required this.catalogItemId,
    required this.quantity,
    this.offerId,
    this.variantId,
    this.selectedAttributes,
  });

  factory TransactionLineInput.fromJson(Map<String, dynamic> json) {
    return TransactionLineInput(
      catalogItemId: json['catalog_item_id'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      offerId: json['offer_id'] as String?,
      variantId: json['variant_id'] as String?,
      selectedAttributes: json['selected_attributes'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'catalog_item_id': catalogItemId,
    'quantity': quantity,
    if (offerId != null && offerId!.isNotEmpty) 'offer_id': offerId,
    if (variantId != null && variantId!.isNotEmpty) 'variant_id': variantId,
    if (selectedAttributes != null && selectedAttributes!.isNotEmpty)
      'selected_attributes': selectedAttributes,
  };
}

/// Request to create a new commercial transaction draft:
/// POST /businesses/{business_id}/transactions
/// Schema: `#/components/schemas/CreateTransactionDraftRequest`
class CreateTransactionDraftRequest {
  final String customerId;
  final String transactionType;
  final List<TransactionLineInput> lines;
  final String? currency;
  final String? leadId;

  const CreateTransactionDraftRequest({
    required this.customerId,
    required this.transactionType,
    required this.lines,
    this.currency,
    this.leadId,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'customer_id': customerId,
      'transaction_type': transactionType,
      'lines': lines.map((l) => l.toJson()).toList(),
    };
    if (currency != null && currency!.trim().isNotEmpty) {
      map['currency'] = currency!.trim();
    }
    if (leadId != null && leadId!.trim().isNotEmpty) {
      map['lead_id'] = leadId!.trim();
    }
    return map;
  }
}

/// Request to update an existing commercial transaction draft:
/// PATCH /businesses/{business_id}/transactions/{transaction_id}
/// Schema: `#/components/schemas/UpdateTransactionDraftRequest`
class UpdateTransactionDraftRequest {
  final List<TransactionLineInput>? lines;
  final String? currency;

  const UpdateTransactionDraftRequest({this.lines, this.currency});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (lines != null) {
      map['lines'] = lines!.map((l) => l.toJson()).toList();
    }
    if (currency != null && currency!.trim().isNotEmpty) {
      map['currency'] = currency!.trim();
    }
    return map;
  }
}

/// Request to cancel a transaction:
/// POST /businesses/{business_id}/transactions/{transaction_id}/cancel
/// Schema: `#/components/schemas/TransactionReasonRequest`
class TransactionReasonRequest {
  final String reason;

  const TransactionReasonRequest({required this.reason});

  factory TransactionReasonRequest.fromJson(Map<String, dynamic> json) {
    return TransactionReasonRequest(reason: json['reason'] as String? ?? '');
  }

  Map<String, dynamic> toJson() => {'reason': reason};
}

/// Request to confirm a transaction:
/// POST /businesses/{business_id}/transactions/{transaction_id}/confirm
/// Schema: `#/components/schemas/ConfirmTransactionRequest`
class ConfirmTransactionRequest {
  final String evidenceReference;
  final String? policyVersion;

  const ConfirmTransactionRequest({
    required this.evidenceReference,
    this.policyVersion,
  });

  factory ConfirmTransactionRequest.fromJson(Map<String, dynamic> json) {
    return ConfirmTransactionRequest(
      evidenceReference: json['evidence_reference'] as String? ?? '',
      policyVersion: json['policy_version'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'evidence_reference': evidenceReference,
    if (policyVersion != null && policyVersion!.trim().isNotEmpty)
      'policy_version': policyVersion!.trim(),
  };
}

/// Request to submit transaction for review:
/// POST /businesses/{business_id}/transactions/{transaction_id}/submit-review
/// Schema: `#/components/schemas/SubmitReviewRequest`
class SubmitReviewRequest {
  final List<String> reasonCodes;

  const SubmitReviewRequest({required this.reasonCodes});

  factory SubmitReviewRequest.fromJson(Map<String, dynamic> json) {
    final list = json['reason_codes'] as List?;
    return SubmitReviewRequest(
      reasonCodes: list?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {'reason_codes': reasonCodes};
}

/// Request to approve or reject a transaction review:
/// POST /businesses/{business_id}/transactions/{transaction_id}/reviews/approve
/// POST /businesses/{business_id}/transactions/{transaction_id}/reviews/reject
/// Schema: `#/components/schemas/ReviewDecisionRequest`
class ReviewDecisionRequest {
  final String reviewerReference;
  final String? reason;

  const ReviewDecisionRequest({required this.reviewerReference, this.reason});

  factory ReviewDecisionRequest.fromJson(Map<String, dynamic> json) {
    return ReviewDecisionRequest(
      reviewerReference: json['reviewer_reference'] as String? ?? '',
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'reviewer_reference': reviewerReference,
    if (reason != null && reason!.trim().isNotEmpty) 'reason': reason!.trim(),
  };
}

/// Transaction review entity representation:
/// GET /businesses/{business_id}/transactions/{transaction_id}/reviews
/// Schema: `#/components/schemas/TransactionReview`
class TransactionReview {
  final bool required;
  final String status;
  final List<String>? reasonCodes;
  final String? reviewerReference;

  const TransactionReview({
    required this.required,
    required this.status,
    this.reasonCodes,
    this.reviewerReference,
  });

  factory TransactionReview.fromJson(Map<String, dynamic> json) {
    final codes = (json['reason_codes'] as List?)
        ?.map((e) => e.toString())
        .toList();

    return TransactionReview(
      required: json['required'] as bool? ?? false,
      status: json['status'] as String? ?? 'pending',
      reasonCodes: codes,
      reviewerReference: json['reviewer_reference'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'required': required,
    'status': status,
    if (reasonCodes != null) 'reason_codes': reasonCodes,
    if (reviewerReference != null) 'reviewer_reference': reviewerReference,
  };

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';
}

/// Extension for CommercialTransaction to provide strongly-typed parsedLines
extension CommercialTransactionExtension on CommercialTransaction {
  List<OrderLineSnapshot> get parsedLines {
    if (lines == null) {
      return [];
    }
    return lines!.map((item) {
      if (item is OrderLineSnapshot) {
        return item;
      }
      if (item is Map<String, dynamic>) {
        return OrderLineSnapshot.fromJson(item);
      }
      return OrderLineSnapshot.fromJson(Map<String, dynamic>.from(item as Map));
    }).toList();
  }
}

/// Paginated list of commercial transactions
class TransactionPage {
  final List<CommercialTransaction> items;
  final bool hasMore;
  final String? nextCursor;
  final String? requestId;

  const TransactionPage({
    required this.items,
    required this.hasMore,
    this.nextCursor,
    this.requestId,
  });
}
