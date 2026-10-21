import 'package:flutter/material.dart';
import 'package:mujeeb24_app/app/localization/app_localizations.dart';
import 'package:mujeeb24_app/app/theme/app_theme.dart';
import 'package:mujeeb24_app/core/models/crm_models.dart';
import 'package:mujeeb24_app/core/widgets/filter_widgets.dart';
import 'package:mujeeb24_app/features/crm/presentation/lead_detail_screen.dart';
import 'package:mujeeb24_app/features/crm/presentation/lead_form_screen.dart';
import 'package:mujeeb24_app/features/crm/providers/crm_provider.dart';

class LeadsTab extends StatefulWidget {
  final CrmProvider crmProvider;
  final String businessId;

  const LeadsTab({
    super.key,
    required this.crmProvider,
    required this.businessId,
  });

  @override
  State<LeadsTab> createState() => _LeadsTabState();
}

class _LeadsTabState extends State<LeadsTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.crmProvider.addListener(_onStateChange);
    _searchController.text = widget.crmProvider.leadSearchQuery;
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
      if (_searchController.text != widget.crmProvider.leadSearchQuery &&
          !_searchController.selection.isValid) {
        _searchController.text = widget.crmProvider.leadSearchQuery;
      }
      setState(() {});
    }
  }

  void _loadData() {
    if (widget.businessId.isNotEmpty) {
      widget.crmProvider.loadLeads(widget.businessId);
    }
  }

  void _openLeadDetail(Lead lead) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LeadDetailScreen(
          crmProvider: widget.crmProvider,
          businessId: widget.businessId,
          leadId: lead.id,
          initialLead: lead,
        ),
      ),
    );
  }

  void _openCreateLead() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LeadFormScreen(
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
    final leads = provider.filteredLeads;

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_chart_rounded),
        label: Text(strings('create_lead')),
        onPressed: _openCreateLead,
      ),
      body: Column(
        children: [
          // Filter Chips Container
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: AppColors.surfaceCanvas,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Social Channels Filter Bar
                ChannelFilterBar(
                  selectedChannel: provider.leadChannelFilter,
                  onChannelSelected: (val) {
                    provider.setLeadChannelFilter(val);
                  },
                ),
                const SizedBox(height: 8),

                // 2. Status Filter Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: strings('all_conversations'),
                        value: 'all',
                        current: provider.leadFilterStatus,
                        onSelected: (val) {
                          provider.setLeadFilterStatus(val);
                          provider.loadLeads(widget.businessId, status: val);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: strings('lead_status_new'),
                        value: 'new',
                        current: provider.leadFilterStatus,
                        onSelected: (val) {
                          provider.setLeadFilterStatus(val);
                          provider.loadLeads(widget.businessId, status: val);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: strings('lead_status_contacted'),
                        value: 'contacted',
                        current: provider.leadFilterStatus,
                        onSelected: (val) {
                          provider.setLeadFilterStatus(val);
                          provider.loadLeads(widget.businessId, status: val);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: strings('lead_status_qualified'),
                        value: 'qualified',
                        current: provider.leadFilterStatus,
                        onSelected: (val) {
                          provider.setLeadFilterStatus(val);
                          provider.loadLeads(widget.businessId, status: val);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: strings('lead_status_lost'),
                        value: 'lost',
                        current: provider.leadFilterStatus,
                        onSelected: (val) {
                          provider.setLeadFilterStatus(val);
                          provider.loadLeads(widget.businessId, status: val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 3. Score Band Filter Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: strings('lead_score_band'),
                        value: 'all',
                        current: provider.leadFilterScoreBand,
                        onSelected: (val) {
                          provider.setLeadFilterScoreBand(val);
                          provider.loadLeads(widget.businessId, scoreBand: val);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'HIGH',
                        value: 'high',
                        current: provider.leadFilterScoreBand,
                        color: AppColors.statusSuccess,
                        onSelected: (val) {
                          provider.setLeadFilterScoreBand(val);
                          provider.loadLeads(widget.businessId, scoreBand: val);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'MEDIUM',
                        value: 'medium',
                        current: provider.leadFilterScoreBand,
                        color: AppColors.statusWarning,
                        onSelected: (val) {
                          provider.setLeadFilterScoreBand(val);
                          provider.loadLeads(widget.businessId, scoreBand: val);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'LOW',
                        value: 'low',
                        current: provider.leadFilterScoreBand,
                        color: AppColors.textMuted,
                        onSelected: (val) {
                          provider.setLeadFilterScoreBand(val);
                          provider.loadLeads(widget.businessId, scoreBand: val);
                        },
                      ),
                    ],
                  ),
                ),

                // 4. Active Filters Header & Clear action
                if (provider.activeLeadFiltersCount > 0) ...[
                  const SizedBox(height: 6),
                  ActiveFiltersHeader(
                    activeCount: provider.activeLeadFiltersCount,
                    onClear: () {
                      _searchController.clear();
                      provider.clearLeadFilters(widget.businessId);
                    },
                  ),
                ],
              ],
            ),
          ),

          // Error banner if any
          if (provider.leadsError != null)
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
                        provider.leadsError!,
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

          // Leads List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: provider.isLoadingLeads && leads.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : leads.isEmpty
                  ? (provider.activeLeadFiltersCount > 0
                      ? FilterEmptyState(
                          title: strings('no_filtered_results'),
                          subtitle: strings('no_filtered_results_hint'),
                          onClearFilters: () {
                            _searchController.clear();
                            provider.clearLeadFilters(widget.businessId);
                          },
                          clearButtonText: strings('reset_all_filters'),
                        )
                      : _buildEmptyState(strings))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      itemCount: leads.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final lead = leads[index];
                        return _buildLeadCard(
                          lead: lead,
                          strings: strings,
                          onTap: () => _openLeadDetail(lead),
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
    required String value,
    required String current,
    required ValueChanged<String> onSelected,
    Color? color,
  }) {
    final isSelected = current == value;
    final primaryColor = color ?? AppColors.primary;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onSelected(value);
        }
      },
      selectedColor: primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.onSurface,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: AppColors.surfaceCanvas,
      side: BorderSide(
        color: isSelected ? primaryColor : AppColors.borderHairline,
      ),
    );
  }

  Widget _buildLeadCard({
    required Lead lead,
    required String Function(String) strings,
    required VoidCallback onTap,
  }) {
    final statusColor = _getStatusColor(lead.status);
    final statusIcon = _getStatusIcon(lead.status);
    final score = lead.currentScore != null
        ? lead.currentScore!.toStringAsFixed(1)
        : '-';
    final band = lead.scoreBand?.toUpperCase() ?? 'NONE';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: statusColor.withValues(alpha: 0.15),
                  child: Icon(statusIcon, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lead: ${lead.id}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Cust: ${lead.customerId}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    lead.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20, color: AppColors.borderHairline),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.speed_rounded,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Score: $score',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'BAND: $band',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'qualified':
        return AppColors.statusSuccess;
      case 'lost':
        return AppColors.statusError;
      case 'contacted':
        return AppColors.statusWarning;
      case 'new':
      default:
        return AppColors.primary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'qualified':
        return Icons.verified_rounded;
      case 'lost':
        return Icons.cancel_outlined;
      case 'contacted':
        return Icons.phone_in_talk_rounded;
      case 'new':
      default:
        return Icons.fiber_new_rounded;
    }
  }

  Widget _buildEmptyState(String Function(String) strings) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.trending_up_rounded,
                size: 64,
                color: AppColors.textMuted.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                strings('no_leads_found'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
