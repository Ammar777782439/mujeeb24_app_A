import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mujeeb24_app/app/localization/app_localizations.dart';
import 'package:mujeeb24_app/app/theme/app_theme.dart';
import 'package:mujeeb24_app/core/models/transaction_models.dart';
import 'package:mujeeb24_app/features/transactions/presentation/transaction_draft_form_screen.dart';
import 'package:mujeeb24_app/features/transactions/providers/transaction_provider.dart';

class TransactionDetailScreen extends StatefulWidget {
  final TransactionProvider transactionProvider;
  final String businessId;
  final String transactionId;

  const TransactionDetailScreen({
    super.key,
    required this.transactionProvider,
    required this.businessId,
    required this.transactionId,
  });

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetails();
    });
  }

  Future<void> _loadDetails() async {
    await widget.transactionProvider.loadTransactionDetail(
      widget.businessId,
      widget.transactionId,
    );
    final tx = widget.transactionProvider.selectedTransaction;
    if (tx != null && (tx.state == 'review' || tx.state == 'confirmed')) {
      await widget.transactionProvider.loadTransactionReview(
        widget.businessId,
        widget.transactionId,
      );
    }
  }

  Color _getStateColor(String state) {
    switch (state.toLowerCase()) {
      case 'confirmed':
        return AppColors.statusSuccess;
      case 'review':
        return AppColors.statusWarning;
      case 'cancelled':
        return AppColors.statusError;
      case 'draft':
      default:
        return AppColors.primary;
    }
  }

  Color _getStateBgColor(String state) {
    switch (state.toLowerCase()) {
      case 'confirmed':
        return AppColors.statusSuccessContainer;
      case 'review':
        return AppColors.statusWarningContainer;
      case 'cancelled':
        return AppColors.statusErrorContainer;
      case 'draft':
      default:
        return AppColors.surfaceContainer;
    }
  }

  String _formatStateLabel(String state, String Function(String) strings) {
    switch (state.toLowerCase()) {
      case 'draft':
        return strings('tx_state_draft');
      case 'review':
        return strings('tx_state_review');
      case 'confirmed':
        return strings('tx_state_confirmed');
      case 'cancelled':
        return strings('tx_state_cancelled');
      default:
        return state;
    }
  }

  String _strings(String key) => AppStrings.get(key, context);

  // ==========================================
  // ACTION DIALOGS
  // ==========================================

  void _showSubmitReviewDialog(CommercialTransaction tx) {
    final reasonController = TextEditingController(text: 'high_value, manual_review');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_strings('submit_for_review')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _strings('confirm_action_prompt'),
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: '${_strings('reason_codes')} *',
                hintText: _strings('reason_codes_hint'),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(_strings('cancel_action')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final rawCodes = reasonController.text.trim();
              final codes = rawCodes
                  .split(',')
                  .map((c) => c.trim())
                  .where((c) => c.isNotEmpty)
                  .toList();

              final result = await widget.transactionProvider.submitForReview(
                widget.businessId,
                tx.id,
                codes,
                ifMatch: tx.resourceVersion,
              );

              if (mounted) {
                if (result != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_strings('review_submitted_success')),
                      backgroundColor: AppColors.statusSuccess,
                    ),
                  );
                  _loadDetails();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        widget.transactionProvider.actionError ??
                            _strings('request_failed'),
                      ),
                      backgroundColor: AppColors.statusError,
                    ),
                  );
                }
              }
            },
            child: Text(_strings('submit_for_review')),
          ),
        ],
      ),
    );
  }

  void _showApproveDialog(CommercialTransaction tx) {
    final reviewerController = TextEditingController(text: 'manager_reviewer');
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_strings('approve_review')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _strings('confirm_action_prompt'),
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reviewerController,
              decoration: InputDecoration(
                labelText: '${_strings('reviewer_reference')} *',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: _strings('review_reason'),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(_strings('cancel_action')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusSuccess,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final result = await widget.transactionProvider.approveReview(
                widget.businessId,
                tx.id,
                reviewerController.text.trim(),
                reason: reasonController.text.trim().isNotEmpty
                    ? reasonController.text.trim()
                    : null,
                ifMatch: tx.resourceVersion,
              );

              if (mounted) {
                if (result != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_strings('review_approved_success')),
                      backgroundColor: AppColors.statusSuccess,
                    ),
                  );
                  _loadDetails();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        widget.transactionProvider.actionError ??
                            _strings('request_failed'),
                      ),
                      backgroundColor: AppColors.statusError,
                    ),
                  );
                }
              }
            },
            child: Text(_strings('approve_review')),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(CommercialTransaction tx) {
    final reviewerController = TextEditingController(text: 'manager_reviewer');
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_strings('reject_review')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _strings('confirm_action_prompt'),
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reviewerController,
              decoration: InputDecoration(
                labelText: '${_strings('reviewer_reference')} *',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: _strings('review_reason'),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(_strings('cancel_action')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusError,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final result = await widget.transactionProvider.rejectReview(
                widget.businessId,
                tx.id,
                reviewerController.text.trim(),
                reason: reasonController.text.trim().isNotEmpty
                    ? reasonController.text.trim()
                    : null,
                ifMatch: tx.resourceVersion,
              );

              if (mounted) {
                if (result != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_strings('review_rejected_success')),
                      backgroundColor: AppColors.statusWarning,
                    ),
                  );
                  _loadDetails();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        widget.transactionProvider.actionError ??
                            _strings('request_failed'),
                      ),
                      backgroundColor: AppColors.statusError,
                    ),
                  );
                }
              }
            },
            child: Text(_strings('reject_review')),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(CommercialTransaction tx) {
    final evidenceController = TextEditingController(text: 'manual_receipt_ref');
    final policyVersionController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_strings('confirm_transaction')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _strings('confirm_action_prompt'),
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: evidenceController,
              decoration: InputDecoration(
                labelText: '${_strings('evidence_reference')} *',
                hintText: 'e.g. receipt_12345',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: policyVersionController,
              decoration: InputDecoration(
                labelText: _strings('policy_version'),
                hintText: 'Optional',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(_strings('cancel_action')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusSuccess,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final result = await widget.transactionProvider.confirmTransaction(
                widget.businessId,
                tx.id,
                evidenceController.text.trim(),
                policyVersion: policyVersionController.text.trim().isNotEmpty
                    ? policyVersionController.text.trim()
                    : null,
                ifMatch: tx.resourceVersion,
              );

              if (mounted) {
                if (result != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_strings('transaction_confirmed_success')),
                      backgroundColor: AppColors.statusSuccess,
                    ),
                  );
                  _loadDetails();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        widget.transactionProvider.actionError ??
                            _strings('request_failed'),
                      ),
                      backgroundColor: AppColors.statusError,
                    ),
                  );
                }
              }
            },
            child: Text(_strings('confirm_transaction')),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(CommercialTransaction tx) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_strings('cancel_transaction')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _strings('confirm_action_prompt'),
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: '${_strings('cancel_reason')} *',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(_strings('cancel_action')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusError,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                return;
              }
              Navigator.of(ctx).pop();
              final result = await widget.transactionProvider.cancelTransaction(
                widget.businessId,
                tx.id,
                reasonController.text.trim(),
                ifMatch: tx.resourceVersion,
              );

              if (mounted) {
                if (result != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_strings('transaction_cancelled_success')),
                      backgroundColor: AppColors.statusError,
                    ),
                  );
                  _loadDetails();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        widget.transactionProvider.actionError ??
                            _strings('request_failed'),
                      ),
                      backgroundColor: AppColors.statusError,
                    ),
                  );
                }
              }
            },
            child: Text(_strings('cancel_transaction')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String strings(String key) => _strings(key);
    final provider = widget.transactionProvider;
    final tx = provider.selectedTransaction;

    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        final currentTx = provider.selectedTransaction ?? tx;
        final isBusy = provider.isPerformingAction;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              strings('transaction_details'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: strings('refresh'),
                onPressed: provider.isLoadingTransactionDetail
                    ? null
                    : _loadDetails,
              ),
            ],
          ),
          body: provider.isLoadingTransactionDetail && currentTx == null
              ? const Center(child: CircularProgressIndicator())
              : currentTx == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            provider.transactionDetailError ??
                                strings('no_transactions'),
                            style: const TextStyle(color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _loadDetails,
                            child: Text(strings('retry')),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadDetails,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (isBusy)
                            const LinearProgressIndicator(
                              color: AppColors.primary,
                            ),

                          // Header Card
                          _buildHeaderCard(currentTx, strings),
                          const SizedBox(height: 16),

                          // Lines Section
                          _buildLinesSection(currentTx, strings),
                          const SizedBox(height: 16),

                          // Review Details Card (if in review or has review info)
                          if (currentTx.state == 'review' ||
                              provider.selectedReview != null)
                            _buildReviewCard(provider.selectedReview, strings),
                          const SizedBox(height: 24),

                          // Action Buttons
                          _buildActionButtons(currentTx, strings, isBusy),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildHeaderCard(
    CommercialTransaction tx,
    String Function(String) strings,
  ) {
    final stateColor = _getStateColor(tx.state);
    final stateBg = _getStateBgColor(tx.state);

    return Card(
      elevation: 0,
      color: AppColors.surfaceCanvas,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderHairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: stateBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: stateColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    _formatStateLabel(tx.state, strings),
                    style: TextStyle(
                      color: stateColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tx.transactionType.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  strings('total_amount'),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  '${tx.totalAmount?.toStringAsFixed(2) ?? '0.00'} ${tx.currency ?? ''}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: AppColors.borderHairline),

            // Meta Info
            _buildInfoRow(
              label: strings('transaction_id'),
              value: tx.id,
              onCopy: () {
                Clipboard.setData(ClipboardData(text: tx.id));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ID copied'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              label: strings('customer_id'),
              value: tx.customerId,
            ),
            if (tx.leadId != null && tx.leadId!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                label: strings('lead_id_optional'),
                value: tx.leadId!,
              ),
            ],
            const SizedBox(height: 8),
            _buildInfoRow(
              label: strings('resource_version'),
              value: tx.resourceVersion,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              label: strings('created_at'),
              value: tx.createdAt,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    VoidCallback? onCopy,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value.length > 24 ? '${value.substring(0, 24)}...' : value,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            if (onCopy != null) ...[
              const SizedBox(width: 4),
              InkWell(
                onTap: onCopy,
                child: const Icon(
                  Icons.copy_rounded,
                  size: 14,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildLinesSection(
    CommercialTransaction tx,
    String Function(String) strings,
  ) {
    final lines = tx.parsedLines;

    return Card(
      elevation: 0,
      color: AppColors.surfaceCanvas,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderHairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  strings('transaction_lines'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  '${lines.length} items',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (lines.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    strings('no_customer_transactions'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              )
            else
              ...lines.map((line) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderHairline),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              line.itemNameSnapshot.isNotEmpty
                                  ? line.itemNameSnapshot
                                  : line.catalogItemId,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              '${strings('quantity')}: ${line.quantity} × ${line.unitPriceSnapshot?.toStringAsFixed(2) ?? '0.00'} ${line.currency ?? tx.currency ?? ''}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${((line.unitPriceSnapshot ?? 0.0) * line.quantity).toStringAsFixed(2)} ${line.currency ?? tx.currency ?? ''}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(
    TransactionReview? review,
    String Function(String) strings,
  ) {
    if (review == null) {
      return Card(
        elevation: 0,
        color: AppColors.statusWarningContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.statusWarning),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                Icons.hourglass_top_rounded,
                color: AppColors.statusWarning,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  strings('transactions_review'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.statusWarning,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      color: AppColors.surfaceCanvas,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderHairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  strings('review_details'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: review.isApproved
                        ? AppColors.statusSuccessContainer
                        : review.isRejected
                            ? AppColors.statusErrorContainer
                            : AppColors.statusWarningContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    review.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: review.isApproved
                          ? AppColors.statusSuccess
                          : review.isRejected
                              ? AppColors.statusError
                              : AppColors.statusWarning,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (review.reviewerReference != null) ...[
              _buildInfoRow(
                label: strings('reviewer_reference'),
                value: review.reviewerReference!,
              ),
              const SizedBox(height: 8),
            ],
            if (review.reasonCodes != null &&
                review.reasonCodes!.isNotEmpty) ...[
              Text(
                strings('reason_codes'),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: review.reasonCodes!.map((code) {
                  return Chip(
                    label: Text(code, style: const TextStyle(fontSize: 11)),
                    backgroundColor: AppColors.surfaceContainer,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    CommercialTransaction tx,
    String Function(String) strings,
    bool isBusy,
  ) {
    final state = tx.state.toLowerCase();

    if (state == 'draft') {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isBusy
                      ? null
                      : () async {
                          final updated = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  TransactionDraftFormScreen(
                                transactionProvider:
                                    widget.transactionProvider,
                                businessId: widget.businessId,
                                existingTransaction: tx,
                              ),
                            ),
                          );
                          if (updated != null) {
                            _loadDetails();
                          }
                        },
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: Text(strings('edit_draft')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isBusy ? null : () => _showSubmitReviewDialog(tx),
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: Text(strings('submit_for_review')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.statusError,
              ),
              onPressed: isBusy ? null : () => _showCancelDialog(tx),
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: Text(strings('cancel_transaction')),
            ),
          ),
        ],
      );
    }

    if (state == 'review') {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusSuccess,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isBusy ? null : () => _showApproveDialog(tx),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: Text(strings('approve_review')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusError,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isBusy ? null : () => _showRejectDialog(tx),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: Text(strings('reject_review')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.statusSuccess,
                side: const BorderSide(color: AppColors.statusSuccess),
              ),
              onPressed: isBusy ? null : () => _showConfirmDialog(tx),
              icon: const Icon(Icons.verified_rounded, size: 18),
              label: Text(strings('confirm_transaction')),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.statusError,
              ),
              onPressed: isBusy ? null : () => _showCancelDialog(tx),
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: Text(strings('cancel_transaction')),
            ),
          ),
        ],
      );
    }

    if (state == 'confirmed') {
      return SizedBox(
        width: double.infinity,
        child: TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.statusError,
          ),
          onPressed: isBusy ? null : () => _showCancelDialog(tx),
          icon: const Icon(Icons.cancel_outlined, size: 18),
          label: Text(strings('cancel_transaction')),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
