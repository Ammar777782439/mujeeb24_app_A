import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/models/platform_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/platform_provider.dart';

class PlatformHubScreen extends StatefulWidget {
  final PlatformProvider provider;
  final AuthProvider authProvider;
  final VoidCallback onBackToWorkspace;

  const PlatformHubScreen({
    super.key,
    required this.provider,
    required this.authProvider,
    required this.onBackToWorkspace,
  });

  @override
  State<PlatformHubScreen> createState() => _PlatformHubScreenState();
}

class _PlatformHubScreenState extends State<PlatformHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    if (widget.authProvider.isPlatformAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadCurrentTabData(0);
      });
      _tabController.addListener(() {
        if (!_tabController.indexIsChanging) {
          _loadCurrentTabData(_tabController.index);
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadCurrentTabData(int index) {
    switch (index) {
      case 0:
        widget.provider.fetchBusinesses(refresh: true);
        break;
      case 1:
        widget.provider.fetchChannels(refresh: true);
        break;
      case 2:
        widget.provider.fetchAIOverview();
        break;
      case 3:
        widget.provider.fetchPlans(refresh: true);
        widget.provider.fetchSubscriptions(refresh: true);
        break;
      case 4:
        widget.provider.fetchTickets(refresh: true);
        break;
      case 5:
        widget.provider.fetchAuditEvents(refresh: true);
        break;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'healthy':
      case 'enabled':
      case 'resolved':
      case 'success':
        return AppColors.statusSuccess;
      case 'suspended':
      case 'disabled':
      case 'unhealthy':
      case 'closed':
      case 'retired':
      case 'failure':
        return AppColors.statusError;
      case 'pending_setup':
      case 'draft':
      case 'open':
      case 'in_progress':
        return AppColors.statusWarning;
      case 'archived':
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Contract §10 & production plan: Guard platform screens to platform admins
    if (!widget.authProvider.isPlatformAdmin) {
      return _buildAccessDenied();
    }

    return AnimatedBuilder(
      animation: widget.provider,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.get('platform_title', context)),
            leading: IconButton(
              key: const Key('btn_platform_back'),
              icon: const Icon(Icons.arrow_back),
              onPressed: widget.onBackToWorkspace,
            ),
            actions: [
              IconButton(
                key: const Key('btn_refresh_platform'),
                icon: const Icon(Icons.refresh),
                onPressed: () => _loadCurrentTabData(_tabController.index),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: [
                Tab(
                  key: const Key('tab_plat_businesses'),
                  text: AppStrings.get('tab_platform_businesses', context),
                  icon: const Icon(Icons.storefront_outlined),
                ),
                Tab(
                  key: const Key('tab_plat_channels'),
                  text: AppStrings.get('tab_platform_channels', context),
                  icon: const Icon(Icons.hub_outlined),
                ),
                Tab(
                  key: const Key('tab_plat_ai'),
                  text: AppStrings.get('tab_platform_ai', context),
                  icon: const Icon(Icons.psychology_outlined),
                ),
                Tab(
                  key: const Key('tab_plat_plans'),
                  text: AppStrings.get('tab_platform_plans', context),
                  icon: const Icon(Icons.card_membership_outlined),
                ),
                Tab(
                  key: const Key('tab_plat_support'),
                  text: AppStrings.get('tab_platform_support', context),
                  icon: const Icon(Icons.support_agent_outlined),
                ),
                Tab(
                  key: const Key('tab_plat_audit'),
                  text: AppStrings.get('tab_platform_audit', context),
                  icon: const Icon(Icons.security_outlined),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildBusinessesTab(),
              _buildChannelsTab(),
              _buildAITab(),
              _buildPlansTab(),
              _buildSupportTab(),
              _buildAuditTab(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccessDenied() {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('access_denied_platform_title', context)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.gpp_bad_rounded,
                size: 64,
                color: AppColors.statusError,
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.get('access_denied_platform_title', context),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.get('access_denied_platform_desc', context),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                key: const Key('btn_back_to_workspace_denied'),
                icon: const Icon(Icons.arrow_back),
                label: Text(AppStrings.get('back_to_workspace', context)),
                onPressed: widget.onBackToWorkspace,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 1. Businesses Tab
  // ==========================================
  Widget _buildBusinessesTab() {
    if (widget.provider.isLoadingBusinesses &&
        widget.provider.rawBusinesses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final businesses = widget.provider.businesses;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('fab_create_business'),
        icon: const Icon(Icons.add_business),
        label: Text(AppStrings.get('create_business', context)),
        onPressed: _showCreateBusinessDialog,
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  key: const Key('chip_biz_all'),
                  label: Text(AppStrings.get('all_statuses', context)),
                  selected: widget.provider.businessStatusFilter == 'all',
                  onSelected: (_) {
                    widget.provider.setBusinessFilter('all');
                    widget.provider.fetchBusinesses(refresh: true);
                  },
                ),
                const SizedBox(width: 6),
                FilterChip(
                  key: const Key('chip_biz_active'),
                  label: const Text('Active'),
                  selected: widget.provider.businessStatusFilter == 'active',
                  onSelected: (_) {
                    widget.provider.setBusinessFilter('active');
                    widget.provider.fetchBusinesses(refresh: true);
                  },
                ),
                const SizedBox(width: 6),
                FilterChip(
                  key: const Key('chip_biz_pending'),
                  label: const Text('Pending Setup'),
                  selected:
                      widget.provider.businessStatusFilter == 'pending_setup',
                  onSelected: (_) {
                    widget.provider.setBusinessFilter('pending_setup');
                    widget.provider.fetchBusinesses(refresh: true);
                  },
                ),
                const SizedBox(width: 6),
                FilterChip(
                  key: const Key('chip_biz_suspended'),
                  label: const Text('Suspended'),
                  selected: widget.provider.businessStatusFilter == 'suspended',
                  onSelected: (_) {
                    widget.provider.setBusinessFilter('suspended');
                    widget.provider.fetchBusinesses(refresh: true);
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: businesses.isEmpty
                ? const Center(child: Text('No businesses found'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: businesses.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final b = businesses[idx];
                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppColors.borderHairline),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.primary
                                        .withValues(alpha: 0.12),
                                    child: const Icon(
                                      Icons.storefront,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          b.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          'Slug: ${b.slug}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(b.platformStatus)
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      b.platformStatus,
                                      style: TextStyle(
                                        color: _getStatusColor(
                                          b.platformStatus,
                                        ),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    key: Key('menu_biz_${b.id}'),
                                    onSelected: (action) =>
                                        _handleBusinessAction(b, action),
                                    itemBuilder: (context) => [
                                      if (b.isPendingSetup)
                                        PopupMenuItem(
                                          value: 'assign_owner',
                                          child: Text(
                                            AppStrings.get(
                                              'assign_owner',
                                              context,
                                            ),
                                          ),
                                        ),
                                      if (b.isActive)
                                        PopupMenuItem(
                                          value: 'suspend',
                                          child: Text(
                                            AppStrings.get(
                                              'suspend_business',
                                              context,
                                            ),
                                            style: const TextStyle(
                                              color: AppColors.statusError,
                                            ),
                                          ),
                                        ),
                                      if (b.isSuspended)
                                        PopupMenuItem(
                                          value: 'reactivate',
                                          child: Text(
                                            AppStrings.get(
                                              'reactivate_business',
                                              context,
                                            ),
                                          ),
                                        ),
                                      if (!b.isArchived)
                                        PopupMenuItem(
                                          value: 'archive',
                                          child: Text(
                                            AppStrings.get(
                                              'archive_business',
                                              context,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              if (b.ownerIdentitySummary != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Owner: ${b.ownerIdentitySummary}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                              if (b.subscriptionSummary != null)
                                Text(
                                  'Plan: ${b.subscriptionSummary}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showCreateBusinessDialog() {
    final nameCtrl = TextEditingController();
    final slugCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.get('create_business', ctx)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('input_biz_name'),
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: AppStrings.get('business_name_label', ctx),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('input_biz_slug'),
              controller: slugCtrl,
              decoration: InputDecoration(
                labelText: AppStrings.get('business_slug_label', ctx),
                hintText: 'e.g. al-amal-store',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppStrings.get('cancel', ctx)),
          ),
          ElevatedButton(
            key: const Key('btn_submit_create_biz'),
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final slug = slugCtrl.text.trim();
              if (name.isEmpty || slug.isEmpty) return;

              Navigator.of(ctx).pop();
              final ok = await widget.provider.createBusiness(
                PlatformCreateBusinessRequest(name: name, slug: slug),
              );

              if (ok && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(widget.provider.actionSuccessMessage ?? 'OK'),
                    backgroundColor: AppColors.statusSuccess,
                  ),
                );
              }
            },
            child: Text(AppStrings.get('save', ctx)),
          ),
        ],
      ),
    );
  }

  void _handleBusinessAction(PlatformBusinessView b, String action) async {
    if (action == 'assign_owner') {
      final emailCtrl = TextEditingController();
      final nameCtrl = TextEditingController();

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppStrings.get('assign_owner', ctx)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('input_owner_email'),
                controller: emailCtrl,
                decoration: InputDecoration(
                  labelText: AppStrings.get('owner_email_label', ctx),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('input_owner_name'),
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: AppStrings.get('owner_name_label', ctx),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(AppStrings.get('cancel', ctx)),
            ),
            ElevatedButton(
              key: const Key('btn_submit_assign_owner'),
              onPressed: () async {
                final email = emailCtrl.text.trim();
                final name = nameCtrl.text.trim();
                if (email.isEmpty || name.isEmpty) return;
                Navigator.of(ctx).pop();
                await widget.provider.assignOwner(
                  b.id,
                  PlatformAssignOwnerRequest(
                    ownerEmail: email,
                    ownerDisplayName: name,
                  ),
                );
              },
              child: Text(AppStrings.get('save', ctx)),
            ),
          ],
        ),
      );
    } else if (action == 'suspend') {
      await widget.provider.suspendBusiness(b.id);
    } else if (action == 'reactivate') {
      await widget.provider.reactivateBusiness(b.id);
    } else if (action == 'archive') {
      await widget.provider.archiveBusiness(b.id);
    }
  }

  // ==========================================
  // 2. Channels Tab
  // ==========================================
  Widget _buildChannelsTab() {
    if (widget.provider.isLoadingChannels && widget.provider.channels.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final channels = widget.provider.channels;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: channels.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, idx) {
        final ch = channels[idx];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.borderHairline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _getStatusColor(ch.health)
                          .withValues(alpha: 0.12),
                      child: Icon(Icons.hub, color: _getStatusColor(ch.health)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${ch.channel.toUpperCase()} (${ch.provider})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Business: ${ch.businessId}',
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
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(ch.health)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ch.health,
                        style: TextStyle(
                          color: _getStatusColor(ch.health),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      key: Key('btn_health_check_${ch.connectionId}'),
                      icon: const Icon(Icons.health_and_safety, size: 16),
                      label: Text(
                        AppStrings.get('run_channel_health', context),
                      ),
                      onPressed: () => widget.provider.runChannelHealthCheck(
                        ch.connectionId,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // 3. AI Operations & Emergency Kill Switch
  // ==========================================
  Widget _buildAITab() {
    final ai = widget.provider.aiOverview;
    final usage = widget.provider.aiUsage;
    final check = widget.provider.latestAIHealthCheck;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emergency Kill Switch Card
          Card(
            color: (ai?.runtime.isEnabled ?? true)
                ? Colors.amber.shade50
                : Colors.red.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: (ai?.runtime.isEnabled ?? true)
                    ? AppColors.statusWarning
                    : AppColors.statusError,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: (ai?.runtime.isEnabled ?? true)
                            ? AppColors.statusWarning
                            : AppColors.statusError,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          AppStrings.get('ai_kill_switch', context),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              ((ai?.runtime.isEnabled ?? true)
                                      ? AppColors.statusSuccess
                                      : AppColors.statusError)
                                  .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          ai?.runtime.status ?? 'enabled',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: (ai?.runtime.isEnabled ?? true)
                                ? AppColors.statusSuccess
                                : AppColors.statusError,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppStrings.get('ai_kill_switch_desc', context),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (ai?.runtime.isEnabled ?? true)
                    ElevatedButton.icon(
                      key: const Key('btn_ai_kill_switch_disable'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.statusError,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.power_settings_new),
                      label: const Text('Emergency Kill Switch (Disable AI)'),
                      onPressed: _showDisableAIConfirmation,
                    )
                  else
                    ElevatedButton.icon(
                      key: const Key('btn_ai_kill_switch_enable'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.statusSuccess,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.play_arrow),
                      label: Text(AppStrings.get('enable_ai', context)),
                      onPressed: () => widget.provider.enableAI(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Health Check & Runtime Info
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.borderHairline),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'AI Runtime & Model Health',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      ElevatedButton.icon(
                        key: const Key('btn_run_ai_health'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 36),
                        ),
                        icon: const Icon(Icons.speed, size: 16),
                        label: Text(
                          AppStrings.get('run_ai_health_check', context),
                        ),
                        onPressed: () => widget.provider.runAIHealthCheck(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (check != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: check.isSuccess
                            ? AppColors.statusSuccessContainer
                            : AppColors.statusErrorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            check.isSuccess ? Icons.check_circle : Icons.error,
                            color: check.isSuccess
                                ? AppColors.statusSuccess
                                : AppColors.statusError,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${check.model} (${check.provider}): ${check.result} in ${check.latencyMs}ms',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text('Model: ${ai?.provider.model ?? "default"}'),
                  Text('Provider: ${ai?.provider.provider ?? "google"}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Aggregate Usage
          if (usage != null)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.borderHairline),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get('ai_usage_stats', context),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            AppStrings.get('ai_total_invocations', context),
                            usage.totalInvocations.toString(),
                          ),
                        ),
                        Expanded(
                          child: _buildMetricTile(
                            AppStrings.get('ai_total_tokens', context),
                            usage.totalTokens.toString(),
                          ),
                        ),
                        Expanded(
                          child: _buildMetricTile(
                            AppStrings.get('ai_cost_yer', context),
                            '${usage.estimatedCostYer} YER',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _showDisableAIConfirmation() {
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: AppColors.statusError),
            const SizedBox(width: 8),
            Text(AppStrings.get('ai_kill_switch', ctx)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.get('disable_ai_confirm', ctx)),
            const SizedBox(height: 12),
            TextField(
              key: const Key('input_disable_ai_reason'),
              controller: reasonCtrl,
              decoration: const InputDecoration(
                labelText: 'Reason for emergency disable',
                hintText: 'e.g. Malfunctioning prompt policy',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppStrings.get('cancel', ctx)),
          ),
          ElevatedButton(
            key: const Key('btn_confirm_disable_ai'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusError,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await widget.provider.disableAI(reason: reasonCtrl.text.trim());
            },
            child: const Text('Confirm Disable'),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. Plans & Subscriptions Tab
  // ==========================================
  Widget _buildPlansTab() {
    final plans = widget.provider.plans;
    final subs = widget.provider.subscriptions;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(key: Key('subtab_plans'), text: 'Plans Catalog'),
              Tab(key: Key('subtab_subs'), text: 'Tenant Subscriptions'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Plans List
                ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: plans.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final p = plans[idx];
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AppColors.borderHairline),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${p.displayName} (${p.code})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(p.status)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    p.status,
                                    style: TextStyle(
                                      color: _getStatusColor(p.status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${p.priceYer} YER / ${p.billingInterval}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Limits: ${p.aiReplyLimit} AI replies, ${p.channelLimit} channels',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (p.isDraft)
                                  ElevatedButton(
                                    key: Key('btn_activate_plan_${p.id}'),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(0, 36),
                                    ),
                                    onPressed: () =>
                                        widget.provider.activatePlan(p.id),
                                    child: Text(
                                      AppStrings.get('activate_plan', context),
                                    ),
                                  ),
                                if (p.isActive)
                                  OutlinedButton(
                                    key: Key('btn_retire_plan_${p.id}'),
                                    onPressed: () =>
                                        widget.provider.retirePlan(p.id),
                                    child: Text(
                                      AppStrings.get('retire_plan', context),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // Subscriptions List
                ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: subs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final s = subs[idx];
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AppColors.borderHairline),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Plan: ${s.planCode} (v${s.planVersion})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(s.status)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(s.status),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Business ID: ${s.businessId}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                            Text(
                              'Period: ${s.periodStart} to ${s.periodEnd}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  key: Key('btn_override_budget_${s.id}'),
                                  child: Text(
                                    AppStrings.get('override_budget', context),
                                  ),
                                  onPressed: () => _showOverrideBudgetDialog(s),
                                ),
                                const SizedBox(width: 8),
                                if (s.isActive)
                                  ElevatedButton(
                                    key: Key('btn_cancel_sub_${s.id}'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.statusError,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(0, 36),
                                    ),
                                    child: Text(
                                      AppStrings.get(
                                        'cancel_subscription',
                                        context,
                                      ),
                                    ),
                                    onPressed: () => widget.provider
                                        .cancelSubscription(s.id),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOverrideBudgetDialog(SubscriptionView s) {
    final budgetCtrl = TextEditingController(
      text: (s.costBudgetOverrideYer ?? s.internalAiCostBudgetYer ?? 50000)
          .toString(),
    );
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.get('override_budget', ctx)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('input_budget_amount'),
              controller: budgetCtrl,
              decoration: const InputDecoration(labelText: 'New Budget (YER)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('input_budget_reason'),
              controller: reasonCtrl,
              decoration: const InputDecoration(
                labelText: 'Reason for override',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppStrings.get('cancel', ctx)),
          ),
          ElevatedButton(
            key: const Key('btn_submit_override_budget'),
            onPressed: () async {
              final budget = int.tryParse(budgetCtrl.text.trim()) ?? 0;
              final reason = reasonCtrl.text.trim();
              if (budget <= 0 || reason.isEmpty) return;

              Navigator.of(ctx).pop();
              await widget.provider.overrideAICostBudget(
                s.id,
                PlatformOverrideBudgetRequest(
                  costBudgetOverrideYer: budget,
                  reason: reason,
                ),
              );
            },
            child: Text(AppStrings.get('save', ctx)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 5. Support Tickets Tab
  // ==========================================
  Widget _buildSupportTab() {
    final tickets = widget.provider.tickets;

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              FilterChip(
                key: const Key('chip_ticket_all'),
                label: Text(AppStrings.get('all_statuses', context)),
                selected: widget.provider.ticketStatusFilter == 'all',
                onSelected: (_) => widget.provider.setTicketFilter('all'),
              ),
              const SizedBox(width: 6),
              FilterChip(
                key: const Key('chip_ticket_open'),
                label: const Text('Open'),
                selected: widget.provider.ticketStatusFilter == 'open',
                onSelected: (_) => widget.provider.setTicketFilter('open'),
              ),
              const SizedBox(width: 6),
              FilterChip(
                key: const Key('chip_ticket_in_progress'),
                label: const Text('In Progress'),
                selected: widget.provider.ticketStatusFilter == 'in_progress',
                onSelected: (_) =>
                    widget.provider.setTicketFilter('in_progress'),
              ),
              const SizedBox(width: 6),
              FilterChip(
                key: const Key('chip_ticket_resolved'),
                label: const Text('Resolved'),
                selected: widget.provider.ticketStatusFilter == 'resolved',
                onSelected: (_) => widget.provider.setTicketFilter('resolved'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: tickets.isEmpty
              ? const Center(child: Text('No support tickets found'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: tickets.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final t = tickets[idx];
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AppColors.borderHairline),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    t.subject,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(t.status)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(t.status),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Category: ${t.category} | Priority: ${t.priority}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (t.isOpen)
                                  OutlinedButton(
                                    key: Key('btn_ticket_start_${t.id}'),
                                    child: Text(
                                      AppStrings.get('ticket_start', context),
                                    ),
                                    onPressed: () =>
                                        widget.provider.startTicket(t.id),
                                  ),
                                if (t.isInProgress) ...[
                                  ElevatedButton(
                                    key: Key('btn_ticket_resolve_${t.id}'),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(0, 36),
                                    ),
                                    child: Text(
                                      AppStrings.get('ticket_resolve', context),
                                    ),
                                    onPressed: () =>
                                        widget.provider.resolveTicket(t.id),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    key: Key('btn_ticket_close_${t.id}'),
                                    child: Text(
                                      AppStrings.get('ticket_close', context),
                                    ),
                                    onPressed: () =>
                                        widget.provider.closeTicket(t.id),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ==========================================
  // 6. Platform Audit Tab
  // ==========================================
  Widget _buildAuditTab() {
    final events = widget.provider.auditEvents;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, idx) {
        final ev = events[idx];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.borderHairline),
          ),
          child: ExpansionTile(
            title: Text(
              ev.action,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              '${ev.targetType} [${ev.targetId ?? ""}] • ${ev.occurredAt}',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(ev.result).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(ev.result),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Admin ID: ${ev.actorPlatformAdminId ?? "system"}'),
                    Text('Business ID: ${ev.businessId ?? "N/A"}'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: SelectableText(
                        const JsonEncoder.withIndent('  ').convert(ev.metadata),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
