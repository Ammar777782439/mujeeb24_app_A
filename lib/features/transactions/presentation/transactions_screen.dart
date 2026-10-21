import 'package:flutter/material.dart';
import 'package:mujeeb24_app/app/localization/app_localizations.dart';
import 'package:mujeeb24_app/app/theme/app_theme.dart';
import 'package:mujeeb24_app/core/models/crm_models.dart';
import 'package:mujeeb24_app/core/widgets/filter_widgets.dart';
import 'package:mujeeb24_app/features/transactions/presentation/transaction_detail_screen.dart';
import 'package:mujeeb24_app/features/transactions/presentation/transaction_draft_form_screen.dart';
import 'package:mujeeb24_app/features/transactions/providers/transaction_provider.dart';

class TransactionsScreen extends StatefulWidget {
  final TransactionProvider transactionProvider;
  final String businessId;
  final String? initialStateFilter;

  const TransactionsScreen({
    super.key,
    required this.transactionProvider,
    required this.businessId,
    this.initialStateFilter,
  });

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialStateFilter != null &&
        widget.initialStateFilter!.isNotEmpty) {
      widget.transactionProvider.setStateFilter(widget.initialStateFilter!);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await widget.transactionProvider.loadTransactions(
      widget.businessId,
      refresh: true,
    );
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
        return strings('tx_state_all');
    }
  }

  void _openDetail(CommercialTransaction tx) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TransactionDetailScreen(
          transactionProvider: widget.transactionProvider,
          businessId: widget.businessId,
          transactionId: tx.id,
        ),
      ),
    );
  }

  void _openCreateDraft() async {
    final created = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TransactionDraftFormScreen(
          transactionProvider: widget.transactionProvider,
          businessId: widget.businessId,
        ),
      ),
    );
    if (created != null) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    String strings(String key) => AppStrings.get(key, context);
    final provider = widget.transactionProvider;

    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        final txList = provider.filteredTransactions;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              strings('transactions_title'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: strings('refresh'),
                onPressed: provider.isLoadingTransactions ? null : _loadData,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openCreateDraft,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: Text(strings('create_draft_transaction')),
          ),
          body: RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: strings('search_transactions'),
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              provider.setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surfaceSubtle,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.borderHairline,
                      ),
                    ),
                  ),
                  onChanged: (val) => provider.setSearchQuery(val),
                ),
                const SizedBox(height: 12),

                // State Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStateFilterChip(
                        'all',
                        strings('tx_state_all'),
                        provider,
                      ),
                      const SizedBox(width: 8),
                      _buildStateFilterChip(
                        'review',
                        strings('tx_state_review'),
                        provider,
                      ),
                      const SizedBox(width: 8),
                      _buildStateFilterChip(
                        'draft',
                        strings('tx_state_draft'),
                        provider,
                      ),
                      const SizedBox(width: 8),
                      _buildStateFilterChip(
                        'confirmed',
                        strings('tx_state_confirmed'),
                        provider,
                      ),
                      const SizedBox(width: 8),
                      _buildStateFilterChip(
                        'cancelled',
                        strings('tx_state_cancelled'),
                        provider,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Type Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTypeFilterChip(
                        'all',
                        strings('tx_type_all'),
                        provider,
                      ),
                      const SizedBox(width: 8),
                      _buildTypeFilterChip(
                        'order',
                        strings('tx_type_order'),
                        provider,
                      ),
                      const SizedBox(width: 8),
                      _buildTypeFilterChip(
                        'quote',
                        strings('tx_type_quote'),
                        provider,
                      ),
                      const SizedBox(width: 8),
                      _buildTypeFilterChip(
                        'invoice',
                        strings('tx_type_invoice'),
                        provider,
                      ),
                      const SizedBox(width: 8),
                      _buildTypeFilterChip(
                        'sale',
                        strings('tx_type_sale'),
                        provider,
                      ),
                    ],
                  ),
                ),
                if (provider.activeFiltersCount > 0) ...[
                  const SizedBox(height: 10),
                  ActiveFiltersHeader(
                    activeCount: provider.activeFiltersCount,
                    onClear: () {
                      _searchController.clear();
                      provider.clearFilters(widget.businessId);
                    },
                  ),
                ],
                const SizedBox(height: 16),

                // Error Banner
                if (provider.transactionsError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.statusErrorContainer,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.statusError),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.statusError,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.transactionsError!,
                            style: const TextStyle(
                              color: AppColors.statusError,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Transactions List
                if (provider.isLoadingTransactions && txList.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (txList.isEmpty)
                  provider.activeFiltersCount > 0
                      ? FilterEmptyState(
                          title: strings('no_filtered_results'),
                          subtitle: strings('no_filtered_results_hint'),
                          onClearFilters: () {
                            _searchController.clear();
                            provider.clearFilters(widget.businessId);
                          },
                          clearButtonText: strings('reset_all_filters'),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  provider.stateFilter == 'review'
                                      ? Icons.task_alt_rounded
                                      : Icons.receipt_long_rounded,
                                  size: 48,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  provider.stateFilter == 'review'
                                      ? strings(
                                          'no_transactions_needing_review',
                                        )
                                      : strings('no_transactions'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                else
                  ...txList.map((tx) {
                    final stateColor = _getStateColor(tx.state);
                    final stateBg = _getStateBgColor(tx.state);

                    return Card(
                      elevation: 0,
                      color: AppColors.surfaceCanvas,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppColors.borderHairline),
                      ),
                      child: InkWell(
                        onTap: () => _openDetail(tx),
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: stateBg,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: stateColor.withValues(
                                              alpha: 0.4,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          _formatStateLabel(tx.state, strings),
                                          style: TextStyle(
                                            color: stateColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceSubtle,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          tx.transactionType.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${tx.totalAmount?.toStringAsFixed(2) ?? '0.00'} ${tx.currency ?? ''}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'ID: ${tx.id.length > 18 ? '${tx.id.substring(0, 18)}...' : tx.id}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  Text(
                                    tx.createdAt.length >= 10
                                        ? tx.createdAt.substring(0, 10)
                                        : tx.createdAt,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                // Pagination Load More
                if (provider.hasMore) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: provider.isLoadingMore
                          ? null
                          : () => provider.loadMoreTransactions(
                              widget.businessId,
                            ),
                      child: provider.isLoadingMore
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(strings('load_more')),
                    ),
                  ),
                ],
                const SizedBox(height: 60),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStateFilterChip(
    String state,
    String label,
    TransactionProvider provider,
  ) {
    final isSelected = provider.stateFilter == state;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        provider.setStateFilter(state);
        provider.loadTransactions(widget.businessId);
      },
      selectedColor: AppColors.primaryContainer.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
      ),
    );
  }

  Widget _buildTypeFilterChip(
    String type,
    String label,
    TransactionProvider provider,
  ) {
    final isSelected = provider.transactionTypeFilter == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        provider.setTransactionTypeFilter(type);
        provider.loadTransactions(widget.businessId);
      },
      selectedColor: AppColors.primaryFixed,
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
      ),
    );
  }
}
