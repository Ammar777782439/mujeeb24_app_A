import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mujeeb24_app/app/theme/app_theme.dart';
import 'package:mujeeb24_app/core/api/api_client.dart';
import 'package:mujeeb24_app/core/merchant/merchant_repository.dart';
import 'package:mujeeb24_app/core/models/auth_models.dart';
import 'package:mujeeb24_app/core/team/team_audit_repository.dart';
import 'package:mujeeb24_app/features/merchant/presentation/business_settings_tab.dart';
import 'package:mujeeb24_app/features/merchant/providers/merchant_provider.dart';
import 'package:mujeeb24_app/features/team/presentation/audit_logs_screen.dart';
import 'package:mujeeb24_app/features/team/presentation/team_screen.dart';
import 'package:mujeeb24_app/features/team/providers/team_audit_provider.dart';

Widget _createTestApp(Widget child) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    locale: const Locale('ar'),
    supportedLocales: const [Locale('ar'), Locale('en')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: child,
  );
}

void main() {
  group('Phase 7 Widget Tests: TeamScreen', () {
    testWidgets('renders team members list, badges, and tabs', (tester) async {
      final mock = MockClient((request) async {
        if (request.url.path.contains('/team/members')) {
          return http.Response(
            jsonEncode({
              'data': [
                {
                  'principal_id': 'owner-1',
                  'email': 'owner@alufuq.com',
                  'display_name': 'Al-Ufuq Owner',
                  'role': 'owner',
                  'permissions': ['*'],
                  'status': 'active',
                },
                {
                  'principal_id': 'agent-1',
                  'email': 'agent@alufuq.com',
                  'display_name': 'Ahmed Agent',
                  'role': 'agent',
                  'permissions': ['conversations:reply', 'sales:read'],
                  'status': 'active',
                },
              ],
              'pagination': {'has_more': false},
              'request_id': 'req-members-test',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.url.path.contains('/team/invitations')) {
          return http.Response(
            jsonEncode({
              'data': [
                {
                  'id': 'inv-1',
                  'business_id': 'biz-1',
                  'email': 'pending@alufuq.com',
                  'display_name': 'Pending Invitee',
                  'role': 'manager',
                  'permissions': ['team:read'],
                  'status': 'pending',
                  'invited_by': 'owner-1',
                  'expires_at': '2026-10-30T10:00:00Z',
                  'created_at': '2026-10-22T10:00:00Z',
                  'updated_at': '2026-10-22T10:00:00Z',
                },
              ],
              'pagination': {'has_more': false},
              'request_id': 'req-inv-test',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final repo = TeamAuditRepository(apiClient: ApiClient(client: mock));
      final provider = TeamAuditProvider(repository: repo);

      await tester.pumpWidget(
        _createTestApp(TeamScreen(provider: provider, businessId: 'biz-1')),
      );

      await tester.pumpAndSettle();

      // Check Tabs
      expect(find.byKey(const Key('tab_team_members')), findsOneWidget);
      expect(find.byKey(const Key('tab_team_invitations')), findsOneWidget);

      // Check Members
      expect(find.text('Al-Ufuq Owner'), findsOneWidget);
      expect(find.text('Ahmed Agent'), findsOneWidget);
      expect(find.text('owner@alufuq.com'), findsOneWidget);

      // Owner popup menu should NOT exist, agent popup menu should exist
      expect(find.byKey(const Key('menu_member_owner-1')), findsNothing);
      expect(find.byKey(const Key('menu_member_agent-1')), findsOneWidget);

      // Switch to Invitations tab
      await tester.tap(find.byKey(const Key('tab_team_invitations')));
      await tester.pumpAndSettle();

      expect(find.text('Pending Invitee'), findsOneWidget);
      expect(find.text('pending@alufuq.com'), findsOneWidget);
      expect(find.byKey(const Key('btn_resend_inv_inv-1')), findsOneWidget);
      expect(find.byKey(const Key('btn_revoke_inv_inv-1')), findsOneWidget);
    });

    testWidgets(
      'opens invite member dialog, submits, and displays token modal',
      (tester) async {
        final mock = MockClient((request) async {
          if (request.url.path.contains('/team/invitations') &&
              request.method == 'POST') {
            return http.Response(
              jsonEncode({
                'data': {
                  'invitation': {
                    'id': 'inv-99',
                    'business_id': 'biz-1',
                    'email': 'newcomer@alufuq.com',
                    'display_name': 'New Colleague',
                    'role': 'agent',
                    'permissions': ['conversations:reply'],
                    'status': 'pending',
                    'invited_by': 'owner-1',
                    'expires_at': '2026-10-25T10:00:00Z',
                    'created_at': '2026-10-22T10:00:00Z',
                    'updated_at': '2026-10-22T10:00:00Z',
                  },
                  'acceptance_token': 'magic-token-abc-777',
                },
                'request_id': 'req-create-inv-test',
              }),
              201,
              headers: {'content-type': 'application/json'},
            );
          }
          return http.Response(
            jsonEncode({
              'data': [],
              'pagination': {'has_more': false},
              'request_id': 'req-empty',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final repo = TeamAuditRepository(apiClient: ApiClient(client: mock));
        final provider = TeamAuditProvider(repository: repo);

        await tester.pumpWidget(
          _createTestApp(TeamScreen(provider: provider, businessId: 'biz-1')),
        );
        await tester.pumpAndSettle();

        // Tap FAB Invite Member
        await tester.tap(find.byKey(const Key('fab_invite_member')));
        await tester.pumpAndSettle();

        // Enter fields
        await tester.enterText(
          find.byKey(const Key('input_invite_email')),
          'newcomer@alufuq.com',
        );
        await tester.enterText(
          find.byKey(const Key('input_invite_name')),
          'New Colleague',
        );

        // Submit invitation
        await tester.tap(find.byKey(const Key('btn_submit_invite')));
        await tester.pumpAndSettle();

        // Token modal should appear
        expect(find.text('magic-token-abc-777'), findsOneWidget);
        expect(find.byKey(const Key('btn_copy_token')), findsOneWidget);

        // Close modal
        await tester.tap(find.byKey(const Key('btn_close_token_modal')));
        await tester.pumpAndSettle();

        expect(find.text('magic-token-abc-777'), findsNothing);
      },
    );
  });

  group('Phase 7 Widget Tests: AuditLogsScreen', () {
    testWidgets('renders audit logs and opens detail sheet', (tester) async {
      final mock = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 'audit-test-1',
                'business_id': 'biz-1',
                'actor_type': 'principal',
                'actor_reference': 'admin@alufuq.com',
                'action': 'team.member.role_updated',
                'resource_type': 'team_member',
                'resource_id': 'user-88',
                'metadata': {'old_role': 'agent', 'new_role': 'manager'},
                'occurred_at': '2026-10-22T16:00:00Z',
              },
            ],
            'pagination': {'has_more': false},
            'request_id': 'req-audit-view',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = TeamAuditRepository(apiClient: ApiClient(client: mock));
      final provider = TeamAuditProvider(repository: repo);

      await tester.pumpWidget(
        _createTestApp(
          AuditLogsScreen(provider: provider, businessId: 'biz-1'),
        ),
      );
      await tester.pumpAndSettle();

      // Event card should render action
      expect(find.text('team.member.role_updated'), findsOneWidget);
      expect(find.text('2026-10-22T16:00:00Z'), findsOneWidget);

      // Tap on event card to open detail bottom sheet
      await tester.tap(find.text('team.member.role_updated'));
      await tester.pumpAndSettle();

      // Should show event details and event ID
      expect(find.text('Event ID'), findsOneWidget);
      expect(find.text('audit-test-1'), findsOneWidget);
      expect(find.text('Business ID'), findsOneWidget);
      expect(find.text('biz-1'), findsOneWidget);
    });
  });

  group('Phase 7 Widget Tests: Settings & Home Navigation Integration', () {
    testWidgets(
      'BusinessSettingsTab renders Team and Audit tiles and calls navigation',
      (tester) async {
        bool navigatedToTeam = false;
        bool navigatedToAudit = false;

        final mock = MockClient((req) async => http.Response('{}', 200));
        final merchantProvider = MerchantProvider(
          merchantRepository: MerchantRepository(
            apiClient: ApiClient(client: mock),
          ),
        );

        const business = Business(
          id: 'biz-1',
          name: 'Al-Ufuq Electronics',
          slug: 'alufuq',
        );

        await tester.pumpWidget(
          _createTestApp(
            Scaffold(
              body: BusinessSettingsTab(
                merchantProvider: merchantProvider,
                currentBusiness: business,
                onSwitchBusiness: () {},
                onLogout: () {},
                onToggleLanguage: () {},
                onNavigateToTeam: () => navigatedToTeam = true,
                onNavigateToAuditLogs: () => navigatedToAudit = true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find Team tile and tap
        expect(find.byKey(const Key('tile_team_management')), findsOneWidget);
        await tester.ensureVisible(
          find.byKey(const Key('tile_team_management')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('tile_team_management')));
        expect(navigatedToTeam, isTrue);

        // Find Audit tile and tap
        expect(find.byKey(const Key('tile_audit_logs')), findsOneWidget);
        await tester.ensureVisible(find.byKey(const Key('tile_audit_logs')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('tile_audit_logs')));
        expect(navigatedToAudit, isTrue);
      },
    );
  });
}
