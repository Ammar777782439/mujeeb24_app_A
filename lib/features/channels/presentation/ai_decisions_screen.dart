import 'package:flutter/material.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/models/channel_automation_models.dart';
import '../providers/channel_automation_provider.dart';

/// Screen for viewing AI Decisions, inspecting extracted intents/entities, and requesting human review.
class AIDecisionsScreen extends StatefulWidget {
  final ChannelAutomationProvider channelProvider;
  final String businessId;

  const AIDecisionsScreen({
    super.key,
    required this.channelProvider,
    required this.businessId,
  });

  @override
  State<AIDecisionsScreen> createState() => _AIDecisionsScreenState();
}

class _AIDecisionsScreenState extends State<AIDecisionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await widget.channelProvider.fetchAIDecisions(
      widget.businessId,
      refresh: true,
    );
  }

  void _showErrorSnackBar(String message, [String? requestId]) {
    final text = requestId != null ? '$message ($requestId)' : message;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: AppColors.error),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }

  // ===========================================================================
  // Dialog: Request Human Review
  // ===========================================================================
  void _showRequestHumanDialog(AIDecision decision) {
    final reasonController = TextEditingController(
      text: 'Customer requested human supervisor',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        String strings(String key) => AppStrings.get(key, context);
        return AlertDialog(
          title: Text(strings('request_human_review')),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Decision ID: ${decision.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Intent: ${decision.intentBase}',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: strings('human_review_reason'),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return strings('required_field');
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
              ),
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx);
                  final updated = await widget.channelProvider.requestHuman(
                    widget.businessId,
                    decision.id,
                    reasonController.text.trim(),
                  );
                  if (!mounted) return;
                  if (updated != null) {
                    _showSuccessSnackBar(
                      strings('human_review_requested_success'),
                    );
                  } else if (widget.channelProvider.actionError != null) {
                    _showErrorSnackBar(
                      widget.channelProvider.actionError!,
                      widget.channelProvider.lastRequestId,
                    );
                  }
                }
              },
              child: Text(strings('request_human_review')),
            ),
          ],
        );
      },
    );
  }

  void _showDecisionDetailDialog(AIDecision decision) {
    String strings(String key) => AppStrings.get(key, context);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(strings('ai_decision_detail')),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('ID', decision.id),
                _buildDetailRow(
                  'Conversation ID',
                  decision.conversationId ?? 'N/A',
                ),
                _buildDetailRow(
                  strings('lifecycle'),
                  decision.lifecycle ?? 'suggested',
                ),
                _buildDetailRow(strings('intent'), decision.intentBase),
                if (decision.requestedAction != null)
                  _buildDetailRow('Action', decision.requestedAction!),
                if (decision.effectiveCapability != null)
                  _buildDetailRow('Capability', decision.effectiveCapability!),
                _buildDetailRow(
                  strings('requires_human'),
                  decision.requiresHuman ? 'YES' : 'NO',
                  color: decision.requiresHuman
                      ? AppColors.error
                      : AppColors.success,
                ),
                if (decision.entities.isNotEmpty) ...[
                  const Divider(),
                  Text(
                    strings('entities'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  ...decision.entities.entries.map(
                    (e) => Text(
                      '• ${e.key}: ${e.value}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
                if (decision.evidenceReferences.isNotEmpty) ...[
                  const Divider(),
                  const Text(
                    'Evidence References:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  ...decision.evidenceReferences.map(
                    (ref) =>
                        Text('• $ref', style: const TextStyle(fontSize: 13)),
                  ),
                ],
                if (decision.missingInformation.isNotEmpty) ...[
                  const Divider(),
                  const Text(
                    'Missing Information:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  ...decision.missingInformation.map(
                    (info) =>
                        Text('• $info', style: const TextStyle(fontSize: 13)),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
              ),
              icon: const Icon(Icons.person_add),
              label: Text(strings('request_human_review')),
              onPressed: () {
                Navigator.pop(ctx);
                _showRequestHumanDialog(decision);
              },
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String strings(String key) => AppStrings.get(key, context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings('ai_decisions_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: strings('refresh'),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.channelProvider,
        builder: (context, _) {
          final provider = widget.channelProvider;
          if (provider.isLoadingDecisions && provider.aiDecisions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Filter: All vs Requires Human
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    FilterChip(
                      label: Text(strings('all_conversations')),
                      selected: provider.requiresHumanFilter == null,
                      onSelected: (_) {
                        provider.setRequiresHumanFilter(null);
                        _loadData();
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      avatar: const Icon(
                        Icons.person_pin,
                        size: 16,
                        color: AppColors.warning,
                      ),
                      label: Text(strings('filter_requires_human')),
                      selected: provider.requiresHumanFilter == true,
                      onSelected: (_) {
                        provider.setRequiresHumanFilter(true);
                        _loadData();
                      },
                    ),
                  ],
                ),
              ),

              if (provider.decisionsError != null)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Text(
                    provider.decisionsError!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),

              Expanded(
                child: provider.aiDecisions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.smart_toy_outlined,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              strings('no_ai_decisions'),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.aiDecisions.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final decision = provider.aiDecisions[index];
                            final lifecycleStr =
                                decision.lifecycle ?? 'suggested';

                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: decision.requiresHuman
                                      ? AppColors.warning
                                      : AppColors.border,
                                ),
                              ),
                              child: InkWell(
                                onTap: () =>
                                    _showDecisionDetailDialog(decision),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              decision.intentBase.isNotEmpty
                                                  ? decision.intentBase
                                                  : 'Decision #${decision.id.substring(0, 8)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              lifecycleStr.toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      if (decision.entities.isNotEmpty) ...[
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: decision.entities.entries
                                              .map((ent) {
                                                return Chip(
                                                  label: Text(
                                                    '${ent.key}: ${ent.value}',
                                                  ),
                                                  backgroundColor:
                                                      Colors.blueGrey.shade50,
                                                  labelStyle: const TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                );
                                              })
                                              .toList(),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          if (decision.requiresHuman)
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.warning,
                                                  size: 16,
                                                  color: AppColors.warning,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  strings('requires_human'),
                                                  style: const TextStyle(
                                                    color: AppColors.warning,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            )
                                          else
                                            const SizedBox.shrink(),
                                          TextButton.icon(
                                            icon: const Icon(
                                              Icons.person_add,
                                              size: 16,
                                            ),
                                            label: Text(
                                              strings('request_human_review'),
                                            ),
                                            onPressed: () =>
                                                _showRequestHumanDialog(
                                                  decision,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
