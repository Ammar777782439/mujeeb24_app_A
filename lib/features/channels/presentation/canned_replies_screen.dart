import 'package:flutter/material.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/models/channel_automation_models.dart';
import '../../../core/models/merchant_models.dart';
import '../providers/channel_automation_provider.dart';

/// Screen for managing Reusable Canned Replies.
class CannedRepliesScreen extends StatefulWidget {
  final ChannelAutomationProvider channelProvider;
  final String businessId;

  const CannedRepliesScreen({
    super.key,
    required this.channelProvider,
    required this.businessId,
  });

  @override
  State<CannedRepliesScreen> createState() => _CannedRepliesScreenState();
}

class _CannedRepliesScreenState extends State<CannedRepliesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await widget.channelProvider.fetchCannedReplies(
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
  // Dialog: Create Canned Reply
  // ===========================================================================
  void _showCreateReplyDialog() {
    final shortcutController = TextEditingController();
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        String strings(String key) => AppStrings.get(key, context);
        return AlertDialog(
          title: Text(strings('create_canned_reply')),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: shortcutController,
                    decoration: InputDecoration(
                      labelText: '${strings('reply_shortcut')} *',
                      hintText: 'e.g. /welcome or /pricing',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return strings('required_field');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: '${strings('reply_title')} *',
                      hintText: 'e.g. Welcome Greeting',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return strings('required_field');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: bodyController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: '${strings('reply_body')} *',
                      hintText: 'Enter canned text response...',
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx);
                  final req = CreateCannedReplyRequest(
                    shortcut: shortcutController.text.trim(),
                    title: titleController.text.trim(),
                    body: bodyController.text.trim(),
                  );

                  final created = await widget.channelProvider.createReply(
                    widget.businessId,
                    req,
                  );
                  if (!mounted) return;
                  if (created != null) {
                    _showSuccessSnackBar(strings('reply_created_success'));
                  } else if (widget.channelProvider.actionError != null) {
                    _showErrorSnackBar(
                      widget.channelProvider.actionError!,
                      widget.channelProvider.lastRequestId,
                    );
                  }
                }
              },
              child: Text(strings('create_canned_reply')),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // Dialog: Edit Canned Reply
  // ===========================================================================
  void _showEditReplyDialog(CannedReply reply) {
    final shortcutController = TextEditingController(text: reply.shortcut);
    final titleController = TextEditingController(text: reply.title);
    final bodyController = TextEditingController(text: reply.body);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        String strings(String key) => AppStrings.get(key, context);
        return AlertDialog(
          title: Text(strings('edit_canned_reply')),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: shortcutController,
                    decoration: InputDecoration(
                      labelText: strings('reply_shortcut'),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return strings('required_field');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: strings('reply_title'),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return strings('required_field');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: bodyController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: strings('reply_body'),
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx);
                  final req = UpdateCannedReplyRequest(
                    shortcut: shortcutController.text.trim(),
                    title: titleController.text.trim(),
                    body: bodyController.text.trim(),
                  );

                  final updated = await widget.channelProvider.updateReply(
                    widget.businessId,
                    reply.id,
                    req,
                    ifMatch: reply.resourceVersion,
                  );
                  if (!mounted) return;
                  if (updated != null) {
                    _showSuccessSnackBar(strings('reply_updated_success'));
                  } else if (widget.channelProvider.actionError != null) {
                    _showErrorSnackBar(
                      widget.channelProvider.actionError!,
                      widget.channelProvider.lastRequestId,
                    );
                  }
                }
              },
              child: Text(strings('edit_canned_reply')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String strings(String key) => AppStrings.get(key, context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings('canned_replies_title')),
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
          if (provider.isLoadingCannedReplies &&
              provider.cannedReplies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              if (provider.cannedRepliesError != null)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Text(
                    provider.cannedRepliesError!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),

              Expanded(
                child: provider.cannedReplies.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.reply_all,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              strings('no_canned_replies'),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _showCreateReplyDialog,
                              icon: const Icon(Icons.add),
                              label: Text(strings('create_canned_reply')),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.cannedReplies.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final reply = provider.cannedReplies[index];

                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: AppColors.border),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            reply.shortcut,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            reply.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              _showEditReplyDialog(reply),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      reply.body,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateReplyDialog,
        icon: const Icon(Icons.add),
        label: Text(strings('create_canned_reply')),
      ),
    );
  }
}
