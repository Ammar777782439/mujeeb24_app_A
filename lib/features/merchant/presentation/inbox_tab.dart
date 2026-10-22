import 'package:flutter/material.dart';
import 'package:mujeeb24_app/app/localization/app_localizations.dart';
import 'package:mujeeb24_app/app/theme/app_theme.dart';
import 'package:mujeeb24_app/core/models/auth_models.dart';
import 'package:mujeeb24_app/core/models/merchant_models.dart';
import 'package:mujeeb24_app/core/widgets/filter_widgets.dart';
import 'package:mujeeb24_app/features/merchant/providers/merchant_provider.dart';

class InboxTab extends StatefulWidget {
  final MerchantProvider merchantProvider;
  final Business? currentBusiness;
  final Function(Conversation) onConversationSelected;

  const InboxTab({
    super.key,
    required this.merchantProvider,
    required this.currentBusiness,
    required this.onConversationSelected,
  });

  @override
  State<InboxTab> createState() => _InboxTabState();
}

class _InboxTabState extends State<InboxTab> {
  String _selectedChannel =
      'all'; // all, whatsapp, facebook, telegram, instagram
  String _selectedFilter = 'all'; // all, waiting_human, open, closed
  String _selectedOwnership = 'all'; // all, assigned, unassigned
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    widget.merchantProvider.addListener(_onStateChange);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadConversations());
    _searchController.addListener(() {
      final q = _searchController.text.trim().toLowerCase();
      if (_searchQuery != q) {
        setState(() {
          _searchQuery = q;
        });
        widget.merchantProvider.setConversationSearchQuery(q);
      }
    });
  }

  @override
  void dispose() {
    widget.merchantProvider.removeListener(_onStateChange);
    _searchController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  void _loadConversations() {
    final businessId = widget.currentBusiness?.id;
    if (businessId != null && businessId.isNotEmpty) {
      widget.merchantProvider.loadConversations(
        businessId,
        channel: _selectedChannel != 'all' ? _selectedChannel : null,
        state: _selectedFilter != 'all' ? _selectedFilter : null,
        ownership: _selectedOwnership != 'all' ? _selectedOwnership : null,
      );
    }
  }

  void _onChannelSelected(String channel) {
    setState(() {
      _selectedChannel = channel;
    });
    final businessId = widget.currentBusiness?.id ?? '';
    widget.merchantProvider.setConversationChannelFilter(businessId, channel);
  }

  void _onStateSelected(String state) {
    setState(() {
      _selectedFilter = state;
    });
    final businessId = widget.currentBusiness?.id ?? '';
    widget.merchantProvider.setConversationStateFilter(businessId, state);
  }

  void _onOwnershipSelected(String ownership) {
    setState(() {
      _selectedOwnership = ownership;
    });
    final businessId = widget.currentBusiness?.id ?? '';
    widget.merchantProvider.setConversationOwnershipFilter(
      businessId,
      ownership,
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedChannel = 'all';
      _selectedFilter = 'all';
      _selectedOwnership = 'all';
      _searchController.clear();
      _searchQuery = '';
    });
    final businessId = widget.currentBusiness?.id ?? '';
    widget.merchantProvider.clearConversationFilters(businessId);
  }

  int get _activeFiltersCount {
    int count = 0;
    if (_selectedChannel != 'all') count++;
    if (_selectedFilter != 'all') count++;
    if (_selectedOwnership != 'all') count++;
    if (_searchQuery.isNotEmpty) count++;
    return count;
  }

  String _detectChannel(Conversation conv) {
    for (final label in conv.labels) {
      final l = label.toLowerCase();
      if (l.contains('whatsapp')) return 'whatsapp';
      if (l.contains('facebook') || l.contains('meta')) return 'facebook';
      if (l.contains('telegram')) return 'telegram';
      if (l.contains('instagram')) return 'instagram';
    }
    if (conv.assignment != null && conv.assignment!['channel'] != null) {
      return conv.assignment!['channel']!;
    }
    if (_selectedChannel != 'all') {
      return _selectedChannel;
    }
    return 'whatsapp';
  }

  List<Conversation> _getFilteredConversations() {
    final list = widget.merchantProvider.conversations;
    return list.where((c) {
      // Channel Filter (client-side safety check)
      if (_selectedChannel != 'all') {
        final hasOtherExplicitChannel = c.labels.any((l) {
          final low = l.toLowerCase();
          return (low.contains('whatsapp') && _selectedChannel != 'whatsapp') ||
              (low.contains('facebook') && _selectedChannel != 'facebook') ||
              (low.contains('telegram') && _selectedChannel != 'telegram') ||
              (low.contains('instagram') && _selectedChannel != 'instagram');
        });
        if (hasOtherExplicitChannel) {
          return false;
        }
      }

      // State Filter
      if (_selectedFilter == 'waiting_human' && c.state != 'waiting_human') {
        return false;
      }
      if (_selectedFilter == 'open' && c.state != 'open') {
        return false;
      }
      if (_selectedFilter == 'closed' && c.state != 'closed') {
        return false;
      }

      // Ownership Filter
      if (_selectedOwnership == 'assigned' &&
          (c.assignment == null ||
              c.ownership == 'none' ||
              c.ownership == 'unassigned')) {
        return false;
      }
      if (_selectedOwnership == 'unassigned' &&
          (c.assignment != null &&
              c.ownership != 'none' &&
              c.ownership != 'unassigned')) {
        return false;
      }

      // Search Query
      if (_searchQuery.isNotEmpty) {
        final name = (c.customer.displayName ?? '').toLowerCase();
        final id = c.id.toLowerCase();
        final custId = c.customer.id.toLowerCase();
        final labels = c.labels.join(' ').toLowerCase();
        return name.contains(_searchQuery) ||
            id.contains(_searchQuery) ||
            custId.contains(_searchQuery) ||
            labels.contains(_searchQuery);
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    String strings(String key) => AppStrings.get(key, context);
    final provider = widget.merchantProvider;
    final filtered = _getFilteredConversations();

    return RefreshIndicator(
      onRefresh: () async => _loadConversations(),
      child: Column(
        children: [
          // Header / Search Bar & Filter Controls
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: AppColors.surfaceCanvas,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Live Indicator Strip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.presenceOnline,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${provider.conversations.length} ${strings('nav_inbox')}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    if (provider.isLoadingConversations)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        onPressed: _loadConversations,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: strings('refresh'),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Search TextField
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: strings('search_conversations'),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 1. Social Channels Filter Bar (WhatsApp, Facebook, Telegram, Instagram, etc.)
                ChannelFilterBar(
                  selectedChannel: _selectedChannel,
                  onChannelSelected: _onChannelSelected,
                ),
                const SizedBox(height: 8),

                // 2. Status & Ownership Filters Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // State Filter Chips
                      _buildFilterChip(
                        'all',
                        strings('all_conversations'),
                        _selectedFilter,
                        _onStateSelected,
                      ),
                      const SizedBox(width: 6),
                      _buildFilterChip(
                        'waiting_human',
                        strings('waiting_filter'),
                        _selectedFilter,
                        _onStateSelected,
                      ),
                      const SizedBox(width: 6),
                      _buildFilterChip(
                        'open',
                        strings('open_filter'),
                        _selectedFilter,
                        _onStateSelected,
                      ),
                      const SizedBox(width: 6),
                      _buildFilterChip(
                        'closed',
                        strings('closed_filter'),
                        _selectedFilter,
                        _onStateSelected,
                      ),

                      const SizedBox(width: 12),
                      Container(
                        height: 18,
                        width: 1,
                        color: AppColors.borderHairline,
                      ),
                      const SizedBox(width: 12),

                      // Ownership Filter Chips
                      _buildFilterChip(
                        'all',
                        strings('ownership_all'),
                        _selectedOwnership,
                        _onOwnershipSelected,
                      ),
                      const SizedBox(width: 6),
                      _buildFilterChip(
                        'assigned',
                        strings('ownership_assigned'),
                        _selectedOwnership,
                        _onOwnershipSelected,
                      ),
                      const SizedBox(width: 6),
                      _buildFilterChip(
                        'unassigned',
                        strings('ownership_unassigned'),
                        _selectedOwnership,
                        _onOwnershipSelected,
                      ),
                    ],
                  ),
                ),

                // 3. Active Filters Indicator & Clear All
                if (_activeFiltersCount > 0) ...[
                  const SizedBox(height: 6),
                  ActiveFiltersHeader(
                    activeCount: _activeFiltersCount,
                    onClear: _clearAllFilters,
                  ),
                ],
              ],
            ),
          ),

          // Error Display
          if (provider.conversationsError != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildErrorCard(
                provider.conversationsError!,
                provider.lastRequestId,
                strings,
              ),
            ),

          // Conversation List or Empty State
          Expanded(
            child: filtered.isEmpty
                ? (_activeFiltersCount > 0
                      ? FilterEmptyState(
                          title: strings('no_filtered_results'),
                          subtitle: strings('no_filtered_results_hint'),
                          onClearFilters: _clearAllFilters,
                          clearButtonText: strings('reset_all_filters'),
                        )
                      : _buildEmptyState(strings))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _buildConversationCard(item, strings);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String key,
    String label,
    String currentSelection,
    ValueChanged<String> onSelected,
  ) {
    final isSelected = currentSelection == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(key),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surfaceContainerLow,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.onSurface,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildConversationCard(
    Conversation conv,
    String Function(String) strings,
  ) {
    final customerName = conv.customer.displayName ?? conv.customer.id;
    final isWaiting = conv.state == 'waiting_human';
    final detectedChannel = _detectChannel(conv);

    return InkWell(
      onTap: () => widget.onConversationSelected(conv),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceCanvas,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isWaiting
                ? AppColors.statusWarning.withValues(alpha: 0.5)
                : AppColors.borderHairline,
          ),
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
                // Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isWaiting
                      ? AppColors.statusWarningContainer
                      : AppColors.primaryFixed,
                  child: Text(
                    customerName.isNotEmpty
                        ? customerName.characters.first.toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: isWaiting
                          ? AppColors.statusWarning
                          : AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    customerName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                ChannelBadge(
                                  channel: detectedChannel,
                                  size: 11,
                                ),
                              ],
                            ),
                          ),
                          _buildStateBadge(conv.state, strings),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            conv.id.length > 8
                                ? conv.id.substring(0, 8)
                                : conv.id,
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: AppColors.textMuted,
                            ),
                          ),
                          if (conv.priority != 'normal') ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.statusErrorContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                conv.priority,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.statusError,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Labels & Ownership footer
            if (conv.labels.isNotEmpty || conv.assignment != null) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (conv.assignment != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.person_pin_rounded,
                            size: 12,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'معيّن',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ...conv.labels.map(
                    (lbl) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#$lbl',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStateBadge(String state, String Function(String) strings) {
    Color bg;
    Color fg;
    String label;

    switch (state) {
      case 'waiting_human':
        bg = AppColors.statusWarningContainer;
        fg = AppColors.statusWarning;
        label = strings('waiting_filter');
        break;
      case 'closed':
        bg = AppColors.surfaceContainerLow;
        fg = AppColors.textMuted;
        label = strings('closed_filter');
        break;
      case 'open':
      default:
        bg = AppColors.statusSuccessContainer;
        fg = AppColors.statusSuccess;
        label = strings('open_filter');
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  Widget _buildEmptyState(String Function(String) strings) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox_rounded,
              size: 54,
              color: AppColors.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              strings('no_conversations'),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings('no_messages'),
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(
    String error,
    String? requestId,
    String Function(String) strings,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.statusErrorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.statusError.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.statusError,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  error,
                  style: const TextStyle(
                    color: AppColors.statusError,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          if (requestId != null) ...[
            const SizedBox(height: 4),
            Text(
              '${strings('request_id')}: $requestId',
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: AppColors.statusError,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
