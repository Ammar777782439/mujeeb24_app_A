import 'package:flutter/material.dart';
import 'package:mujeeb24_app/app/localization/app_localizations.dart';
import 'package:mujeeb24_app/app/theme/app_theme.dart';
import 'package:mujeeb24_app/features/auth/providers/auth_provider.dart';

class WorkspaceScreen extends StatelessWidget {
  final AuthProvider authProvider;
  final VoidCallback onSwitchBusiness;
  final VoidCallback onLogout;

  const WorkspaceScreen({
    super.key,
    required this.authProvider,
    required this.onSwitchBusiness,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    String strings(String key) => AppStrings.get(key, context);
    final business = authProvider.selectedBusiness?.business;
    final role = authProvider.selectedBusiness?.role;
    final permissions = authProvider.selectedBusiness?.permissions ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(business?.name ?? strings('app_name')),
        actions: [
          if (authProvider.accessibleBusinesses.length > 1)
            IconButton(
              icon: const Icon(Icons.swap_horiz_rounded),
              tooltip: strings('select_business'),
              onPressed: onSwitchBusiness,
            ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: strings('logout'),
            onPressed: () async {
              await authProvider.logout();
              onLogout();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Business Identity Banner
              Card(
                color: AppColors.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.storefront_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  business?.name ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'المعرف: ${business?.slug ?? business?.id ?? ''}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'الدور في النشاط: ${role ?? 'عضو'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'العملة: ${business?.defaultCurrency ?? 'SAR'}',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'صلاحيات العضوية المعتمدة من الخادم:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: Card(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: permissions.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final perm = permissions[index];
                      return ListTile(
                        dense: true,
                        leading: const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 18,
                          color: AppColors.statusSuccess,
                        ),
                        title: Text(
                          perm,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'monospace',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
