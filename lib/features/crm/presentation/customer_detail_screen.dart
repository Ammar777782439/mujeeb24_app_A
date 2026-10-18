import 'package:flutter/material.dart';
import 'package:mujeeb24_app/app/localization/app_localizations.dart';
import 'package:mujeeb24_app/app/theme/app_theme.dart';
import 'package:mujeeb24_app/core/models/crm_models.dart';
import 'package:mujeeb24_app/core/models/merchant_models.dart';
import 'package:mujeeb24_app/features/crm/presentation/customer_form_screen.dart';
import 'package:mujeeb24_app/features/crm/providers/crm_provider.dart';

class CustomerDetailScreen extends StatefulWidget {
  final CrmProvider crmProvider;
  final String businessId;
  final String customerId;
  final Customer? initialCustomer;

  const CustomerDetailScreen({
    super.key,
    required this.crmProvider,
    required this.businessId,
    required this.customerId,
    this.initialCustomer,
  });

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    widget.crmProvider.addListener(_onStateChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    widget.crmProvider.removeListener(_onStateChange);
    _tabController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _loadData() {
    widget.crmProvider.loadCustomerDetail(widget.businessId, widget.customerId);
    widget.crmProvider.loadCustomerConversations(
      widget.businessId,
      widget.customerId,
    );
    widget.crmProvider.loadCustomerTransactions(
      widget.businessId,
      widget.customerId,
    );
  }

  void _openEditCustomer(Customer customer) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CustomerFormScreen(
          crmProvider: widget.crmProvider,
          businessId: widget.businessId,
          customerToEdit: customer,
        ),
      ),
    );
  }

  void _showMergeDialog(Customer customer) {
    showDialog(
      context: context,
      builder: (dialogCtx) => _MergeCustomerDialog(
        crmProvider: widget.crmProvider,
        businessId: widget.businessId,
        sourceCustomer: customer,
        onSuccess: () {
          Navigator.of(context).pop(); // Back to customers list
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String strings(String key) => AppStrings.get(key, context);
    final provider = widget.crmProvider;
    final customer = provider.selectedCustomer ?? widget.initialCustomer;

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(
        title: Text(
          customer?.displayName?.isNotEmpty == true
              ? customer!.displayName!
              : strings('customer_details'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          if (customer != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: strings('edit_customer'),
              onPressed: () => _openEditCustomer(customer),
            ),
            IconButton(
              icon: const Icon(Icons.merge_type_rounded),
              tooltip: strings('merge_customer'),
              onPressed: () => _showMergeDialog(customer),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: strings('refresh'),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: strings('tab_overview')),
            Tab(
              text:
                  '${strings('tab_conversations')} (${provider.customerConversations.length})',
            ),
            Tab(
              text:
                  '${strings('tab_transactions')} (${provider.customerTransactions.length})',
            ),
          ],
        ),
      ),
      body: customer == null && provider.isLoadingCustomerDetail
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(customer, strings),
                _buildConversationsTab(provider, strings),
                _buildTransactionsTab(provider, strings),
              ],
            ),
    );
  }

  Widget _buildOverviewTab(
    Customer? customer,
    String Function(String) strings,
  ) {
    if (customer == null) {
      return Center(
        child: Text(
          strings('no_customers_found'),
          style: const TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    final isActive = customer.status == 'active';
    final points = customer.contactPoints ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCanvas,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderHairline),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primaryFixed,
                  child: Text(
                    customer.displayName?.isNotEmpty == true
                        ? customer.displayName![0].toUpperCase()
                        : 'C',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.displayName?.isNotEmpty == true
                            ? customer.displayName!
                            : strings('customer'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${customer.id}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.statusSuccessContainer
                              : AppColors.surfaceCanvas,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isActive
                              ? strings('customer_active')
                              : customer.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? AppColors.statusSuccess
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Contact Points Section
          Text(
            strings('contact_points'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          if (points.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCanvas,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderHairline),
              ),
              child: Text(
                strings('no_messages'),
                style: const TextStyle(color: AppColors.textMuted),
              ),
            )
          else
            ...points.map(
              (p) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCanvas,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderHairline),
                ),
                child: Row(
                  children: [
                    Icon(
                      p.kind.toLowerCase() == 'email'
                          ? Icons.email_outlined
                          : Icons.phone_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.valueNormalized,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            p.kind.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: p.verificationStatus == 'verified'
                            ? AppColors.statusSuccessContainer
                            : AppColors.surfaceCanvas,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        p.verificationStatus,
                        style: TextStyle(
                          fontSize: 11,
                          color: p.verificationStatus == 'verified'
                              ? AppColors.statusSuccess
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Metadata Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCanvas,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderHairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMetaRow('Version', customer.resourceVersion),
                const Divider(height: 16),
                _buildMetaRow('Created At', customer.createdAt),
                const Divider(height: 16),
                _buildMetaRow('Updated At', customer.updatedAt),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildConversationsTab(
    CrmProvider provider,
    String Function(String) strings,
  ) {
    if (provider.isLoadingCustomerConversations) {
      return const Center(child: CircularProgressIndicator());
    }

    final conversations = provider.customerConversations;
    if (conversations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 48,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 12),
              Text(
                strings('no_customer_conversations'),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: conversations.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final conv = conversations[index];
        return _buildConversationCard(conv, strings);
      },
    );
  }

  Widget _buildConversationCard(
    Conversation conv,
    String Function(String) strings,
  ) {
    final isOpen = conv.state == 'open';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCanvas,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Conv: ${conv.id}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isOpen
                      ? AppColors.primaryFixed
                      : AppColors.surfaceCanvas,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  conv.state.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isOpen ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.smart_toy_outlined,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                'AI: ${conv.aiMode}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.flag_outlined,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                conv.priority,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab(
    CrmProvider provider,
    String Function(String) strings,
  ) {
    if (provider.isLoadingCustomerTransactions) {
      return const Center(child: CircularProgressIndicator());
    }

    final txs = provider.customerTransactions;
    if (txs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 12),
              Text(
                strings('no_customer_transactions'),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: txs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final tx = txs[index];
        return _buildTransactionCard(tx, strings);
      },
    );
  }

  Widget _buildTransactionCard(
    CommercialTransaction tx,
    String Function(String) strings,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCanvas,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tx.transactionType.toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                tx.totalAmount != null
                    ? '${tx.totalAmount!.toStringAsFixed(2)} ${tx.currency ?? strings('currency_sar')}'
                    : '-',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ID: ${tx.id}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCanvas,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tx.state.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            tx.createdAt,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _MergeCustomerDialog extends StatefulWidget {
  final CrmProvider crmProvider;
  final String businessId;
  final Customer sourceCustomer;
  final VoidCallback onSuccess;

  const _MergeCustomerDialog({
    required this.crmProvider,
    required this.businessId,
    required this.sourceCustomer,
    required this.onSuccess,
  });

  @override
  State<_MergeCustomerDialog> createState() => _MergeCustomerDialogState();
}

class _MergeCustomerDialogState extends State<_MergeCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _targetIdController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _targetIdController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    final req = MergeCustomerRequest(
      targetCustomerId: _targetIdController.text.trim(),
      reason: _reasonController.text.trim(),
    );

    final result = await widget.crmProvider.mergeCustomer(
      widget.businessId,
      widget.sourceCustomer.id,
      req,
      ifMatch: widget.sourceCustomer.resourceVersion,
    );

    setState(() => _isSubmitting = false);

    if (result != null && mounted) {
      Navigator.of(context).pop();
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    String strings(String key) => AppStrings.get(key, context);

    return AlertDialog(
      title: Text(strings('merge_customer_dialog_title')),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                strings('merge_customer_desc'),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _targetIdController,
                decoration: InputDecoration(
                  labelText: strings('target_customer_id'),
                  hintText: 'e.g. 123e4567-e89b-12d3-a456-426614174000',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? strings('required_field')
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reasonController,
                decoration: InputDecoration(
                  labelText: strings('merge_reason'),
                  hintText: 'e.g. Duplicate account detected',
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (v) => v == null || v.trim().isEmpty
                    ? strings('required_field')
                    : null,
              ),
              if (widget.crmProvider.actionError != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.crmProvider.actionError!,
                  style: const TextStyle(
                    color: AppColors.statusError,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.statusWarning,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(strings('confirm_merge')),
        ),
      ],
    );
  }
}
