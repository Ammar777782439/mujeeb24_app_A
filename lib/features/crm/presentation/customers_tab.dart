import 'package:flutter/material.dart';
import 'package:mujeeb24_app/app/localization/app_localizations.dart';
import 'package:mujeeb24_app/app/theme/app_theme.dart';
import 'package:mujeeb24_app/core/channels/channel_presentation.dart';
import 'package:mujeeb24_app/core/models/crm_models.dart';
import 'package:mujeeb24_app/core/widgets/filter_widgets.dart';
import 'package:mujeeb24_app/features/crm/presentation/customer_detail_screen.dart';
import 'package:mujeeb24_app/features/crm/presentation/customer_form_screen.dart';
import 'package:mujeeb24_app/features/crm/providers/crm_provider.dart';

class CustomersTab extends StatefulWidget {
  final CrmProvider crmProvider;
  final String businessId;

  const CustomersTab({
    super.key,
    required this.crmProvider,
    required this.businessId,
  });

  @override
  State<CustomersTab> createState() => _CustomersTabState();
}

class _CustomersTabState extends State<CustomersTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.crmProvider.addListener(_onStateChange);
    _searchController.text = widget.crmProvider.customerSearchQuery;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    widget.crmProvider.removeListener(_onStateChange);
    _searchController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) {
      if (_searchController.text != widget.crmProvider.customerSearchQuery &&
          !_searchController.selection.isValid) {
        _searchController.text = widget.crmProvider.customerSearchQuery;
      }
      setState(() {});
    }
  }

  void _loadData() {
    if (widget.businessId.isNotEmpty) {
      widget.crmProvider.loadCustomers(widget.businessId);
    }
  }

  void _openCustomerDetail(Customer customer) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CustomerDetailScreen(
          crmProvider: widget.crmProvider,
          businessId: widget.businessId,
          customerId: customer.id,
          initialCustomer: customer,
        ),
      ),
    );
  }

  void _openCreateCustomer() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CustomerFormScreen(
          crmProvider: widget.crmProvider,
          businessId: widget.businessId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String strings(String key) => AppStrings.get(key, context);
    final provider = widget.crmProvider;
    final customers = provider.filteredCustomers;

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: Text(strings('create_customer')),
        onPressed: _openCreateCustomer,
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: AppColors.surfaceCanvas,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search Field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: strings('search_customers'),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.textMuted,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              provider.setCustomerSearchQuery('');
                              provider.loadCustomers(
                                widget.businessId,
                                search: '',
                              );
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surfaceCanvas,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.borderHairline,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.borderHairline,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    provider.setCustomerSearchQuery(value);
                  },
                  onSubmitted: (value) {
                    provider.setCustomerSearchQuery(value);
                    provider.loadCustomers(widget.businessId, search: value);
                  },
                ),
                const SizedBox(height: 8),

                // 1. Channel Filter Bar (WhatsApp, Facebook, Telegram, etc.)
                ChannelFilterBar(
                  selectedChannel: provider.customerChannelFilter,
                  onChannelSelected: (channel) {
                    provider.setCustomerChannelFilter(channel);
                  },
                ),
                const SizedBox(height: 8),

                // 2. Status Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: strings('all_conversations'),
                        status: 'all',
                        current: provider.customerFilterStatus,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: strings('customer_active'),
                        status: 'active',
                        current: provider.customerFilterStatus,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: strings('customer_archived'),
                        status: 'archived',
                        current: provider.customerFilterStatus,
                      ),
                    ],
                  ),
                ),

                // 3. Active Filters Header & Clear action
                if (provider.activeCustomerFiltersCount > 0) ...[
                  const SizedBox(height: 6),
                  ActiveFiltersHeader(
                    activeCount: provider.activeCustomerFiltersCount,
                    onClear: () {
                      _searchController.clear();
                      provider.clearCustomerFilters(widget.businessId);
                    },
                  ),
                ],
              ],
            ),
          ),

          // Error banner if any
          if (provider.customersError != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.statusErrorContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.statusError.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.statusError,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        provider.customersError!,
                        style: const TextStyle(
                          color: AppColors.statusError,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _loadData,
                      child: Text(strings('retry')),
                    ),
                  ],
                ),
              ),
            ),

          // Customer List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: provider.isLoadingCustomers && customers.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : customers.isEmpty
                  ? (provider.activeCustomerFiltersCount > 0
                        ? FilterEmptyState(
                            title: strings('no_filtered_results'),
                            subtitle: strings('no_filtered_results_hint'),
                            onClearFilters: () {
                              _searchController.clear();
                              provider.clearCustomerFilters(widget.businessId);
                            },
                            clearButtonText: strings('reset_all_filters'),
                          )
                        : _buildEmptyState(strings))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      itemCount: customers.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final customer = customers[index];
                        return _buildCustomerCard(
                          customer: customer,
                          strings: strings,
                          onTap: () => _openCustomerDetail(customer),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String status,
    required String current,
  }) {
    final isSelected = current == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          widget.crmProvider.setCustomerFilterStatus(status);
          widget.crmProvider.loadCustomers(widget.businessId, status: status);
        }
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.onSurface,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: AppColors.surfaceCanvas,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.borderHairline,
      ),
    );
  }

  Widget _buildCustomerCard({
    required Customer customer,
    required String Function(String) strings,
    required VoidCallback onTap,
  }) {
    final name = customer.displayName?.isNotEmpty == true
        ? customer.displayName!
        : strings('customer');
    final phone = customer.primaryPhone;
    final email = customer.primaryEmail;
    final isActive = customer.status == 'active';
    final contactPoints = customer.contactPoints ?? [];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceCanvas,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderHairline),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: isActive
                  ? AppColors.primaryFixed
                  : AppColors.surfaceCanvas,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'C',
                style: TextStyle(
                  color: isActive ? AppColors.primary : AppColors.textMuted,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.statusSuccessContainer
                              : AppColors.surfaceCanvas,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isActive
                              ? strings('customer_active')
                              : customer.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isActive
                                ? AppColors.statusSuccess
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (phone != null || email != null)
                    Row(
                      children: [
                        if (phone != null) ...[
                          const Icon(
                            Icons.phone_outlined,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            phone,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        if (email != null) ...[
                          const Icon(
                            Icons.email_outlined,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              email,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    )
                  else
                    Text(
                      'ID: ${customer.id}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                  // Display Channel badges for contact points if any
                  if (contactPoints.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: contactPoints.map((cp) {
                        final meta = ChannelPresentation.getMeta(cp.kind);
                        return ChannelBadge(channel: meta.key, size: 10);
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String Function(String) strings) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.people_outline_rounded,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            strings('no_customers_found'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings('create_customer_prompt'),
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
