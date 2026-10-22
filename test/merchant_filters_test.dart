import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mujeeb24_app/app/theme/app_theme.dart';
import 'package:mujeeb24_app/core/api/api_client.dart';
import 'package:mujeeb24_app/core/channels/channel_presentation.dart';
import 'package:mujeeb24_app/core/crm/crm_repository.dart';
import 'package:mujeeb24_app/core/merchant/merchant_repository.dart';
import 'package:mujeeb24_app/core/models/auth_models.dart';
import 'package:mujeeb24_app/core/models/crm_models.dart';
import 'package:mujeeb24_app/core/models/merchant_models.dart';
import 'package:mujeeb24_app/core/models/transaction_models.dart';
import 'package:mujeeb24_app/core/transactions/transaction_repository.dart';
import 'package:mujeeb24_app/core/widgets/filter_widgets.dart';
import 'package:mujeeb24_app/features/crm/presentation/customers_tab.dart';
import 'package:mujeeb24_app/features/crm/providers/crm_provider.dart';
import 'package:mujeeb24_app/features/merchant/presentation/inbox_tab.dart';
import 'package:mujeeb24_app/features/merchant/providers/merchant_provider.dart';
import 'package:mujeeb24_app/features/transactions/providers/transaction_provider.dart';

// =============================================================================
// Mock Repositories
// =============================================================================

class MockMerchantFilterRepository extends MerchantRepository {
  List<Conversation> storedConversations;
  String? lastCapturedChannel;
  String? lastCapturedState;
  String? lastCapturedOwnership;
  int listCallCount = 0;

  MockMerchantFilterRepository({this.storedConversations = const []})
    : super(apiClient: ApiClient());

  @override
  Future<List<Conversation>> listConversations({
    required String businessId,
    int limit = 25,
    String? cursor,
    String? state,
    String? ownership,
    String? channel,
    String? customerId,
  }) async {
    listCallCount++;
    lastCapturedChannel = channel;
    lastCapturedState = state;
    lastCapturedOwnership = ownership;

    return storedConversations.where((c) {
      if (state != null && state.isNotEmpty && c.state != state) return false;
      if (ownership != null && ownership.isNotEmpty) {
        if (ownership == 'assigned') {
          if (c.assignment == null ||
              c.ownership == 'none' ||
              c.ownership == 'unassigned') {
            return false;
          }
        } else if (ownership == 'unassigned') {
          if (c.assignment != null &&
              c.ownership != 'none' &&
              c.ownership != 'unassigned') {
            return false;
          }
        } else if (c.ownership != ownership) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}

class MockCrmFilterRepository extends CrmRepository {
  List<Customer> storedCustomers;
  List<Lead> storedLeads;
  String? lastSearch;
  String? lastStatus;
  String? lastScoreBand;

  MockCrmFilterRepository({
    this.storedCustomers = const [],
    this.storedLeads = const [],
  }) : super(apiClient: ApiClient());

  @override
  Future<List<Customer>> listCustomers({
    required String businessId,
    String? search,
    String? status,
    int limit = 25,
    String? cursor,
  }) async {
    lastSearch = search;
    lastStatus = status;
    return storedCustomers;
  }

  @override
  Future<List<Lead>> listLeads({
    required String businessId,
    String? status,
    String? scoreBand,
    String? customerId,
    int limit = 25,
    String? cursor,
  }) async {
    lastStatus = status;
    lastScoreBand = scoreBand;
    return storedLeads;
  }
}

class MockTransactionFilterRepository extends TransactionRepository {
  List<CommercialTransaction> storedTransactions;
  String? lastState;
  String? lastType;

  MockTransactionFilterRepository({this.storedTransactions = const []})
    : super(apiClient: ApiClient());

  @override
  Future<TransactionPage> listTransactions({
    required String businessId,
    String? state,
    String? transactionType,
    String? customerId,
    String? cursor,
    int limit = 25,
  }) async {
    lastState = state;
    lastType = transactionType;
    return TransactionPage(
      items: storedTransactions,
      nextCursor: null,
      hasMore: false,
    );
  }
}

// =============================================================================
// Helper to build test app
// =============================================================================
Widget buildTestApp({required Widget child}) {
  return MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: const [Locale('ar'), Locale('en')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: AppTheme.lightTheme,
    home: Scaffold(body: child),
  );
}

void main() {
  const testBusiness = Business(
    id: 'biz_123',
    name: 'متجر الأنوار الحديثة',
    slug: 'alanwar-store',
    defaultCurrency: 'SAR',
    locale: 'ar',
    timezone: 'Asia/Riyadh',
  );

  final sampleConversations = [
    const Conversation(
      id: 'conv_wa_01',
      businessId: 'biz_123',
      customer: CustomerSummary(id: 'c1', displayName: 'محمد علي'),
      state: 'open',
      ownership: 'unassigned',
      aiMode: 'assist',
      priority: 'high',
      lastActivityAt: '2026-10-21T01:00:00Z',
      resourceVersion: '1',
      labels: ['whatsapp', 'استفسار طلب'],
    ),
    const Conversation(
      id: 'conv_tg_02',
      businessId: 'biz_123',
      customer: CustomerSummary(id: 'c2', displayName: 'فاطمة الزهراء'),
      state: 'waiting_human',
      ownership: 'human',
      aiMode: 'off',
      priority: 'normal',
      lastActivityAt: '2026-10-21T00:30:00Z',
      resourceVersion: '1',
      labels: ['telegram', 'شكوى'],
      assignment: {'channel': 'telegram'},
    ),
    const Conversation(
      id: 'conv_fb_03',
      businessId: 'biz_123',
      customer: CustomerSummary(id: 'c3', displayName: 'أحمد سعيد'),
      state: 'closed',
      ownership: 'none',
      aiMode: 'suggest',
      priority: 'low',
      lastActivityAt: '2026-10-20T22:00:00Z',
      resourceVersion: '1',
      labels: ['facebook'],
    ),
  ];

  final sampleCustomers = [
    const Customer(
      id: 'cust_01',
      businessId: 'biz_123',
      displayName: 'سامي الخالد',
      status: 'active',
      resourceVersion: '1',
      createdAt: '2026-10-20T10:00:00Z',
      updatedAt: '2026-10-20T10:00:00Z',
      contactPoints: [
        ContactPoint(
          kind: 'whatsapp',
          valueNormalized: '+966500000001',
          verificationStatus: 'verified',
        ),
      ],
    ),
    const Customer(
      id: 'cust_02',
      businessId: 'biz_123',
      displayName: 'منى الحربي',
      status: 'active',
      resourceVersion: '1',
      createdAt: '2026-10-20T10:00:00Z',
      updatedAt: '2026-10-20T10:00:00Z',
      contactPoints: [
        ContactPoint(
          kind: 'telegram',
          valueNormalized: '@mona_h',
          verificationStatus: 'verified',
        ),
      ],
    ),
  ];

  group('1. ChannelPresentation & ChannelMeta Unit Tests', () {
    test(
      'Resolves brand names, colors, and icons accurately in Arabic & English',
      () {
        final wa = ChannelPresentation.getMeta('whatsapp');
        expect(wa.nameAr, 'واتساب');
        expect(wa.nameEn, 'WhatsApp');
        expect(wa.brandColor, AppColors.channelWhatsapp);
        expect(wa.icon, Icons.chat_bubble_rounded);

        final fb = ChannelPresentation.getMeta('facebook');
        expect(fb.nameAr, 'فيسبوك');
        expect(fb.nameEn, 'Facebook');
        expect(fb.brandColor, AppColors.channelFacebook);

        final tg = ChannelPresentation.getMeta('telegram');
        expect(tg.nameAr, 'تليجرام');
        expect(tg.nameEn, 'Telegram');
        expect(tg.brandColor, AppColors.channelTelegram);

        final ig = ChannelPresentation.getMeta('instagram');
        expect(ig.nameAr, 'إنستغرام');
        expect(ig.nameEn, 'Instagram');

        final all = ChannelPresentation.getMeta('all');
        expect(all.nameAr, 'كافة القنوات');
        expect(all.nameEn, 'All Channels');
      },
    );

    test('Primary filter channels prioritize WhatsApp, Facebook, Telegram, Instagram', () {
      final keys = ChannelPresentation.primaryFilterChannels
          .map((c) => c.key)
          .toList();
      expect(
        keys,
        containsAll(['all', 'whatsapp', 'facebook', 'telegram', 'instagram']),
      );
    });

    test('Unknown and technical provider aliases map gracefully', () {
      expect(ChannelPresentation.getMeta('meta').key, 'facebook');
      expect(ChannelPresentation.getMeta('twilio').key, 'sms');
      expect(ChannelPresentation.getMeta('custom').key, 'webhook');
      expect(
        ChannelPresentation.getMeta('unknown_custom_channel').key,
        'other',
      );
    });
  });

  group('2. MerchantProvider Conversation Filter Logic', () {
    test('Initial filter state is all and counts zero active filters', () {
      final repo = MockMerchantFilterRepository(
        storedConversations: sampleConversations,
      );
      final provider = MerchantProvider(merchantRepository: repo);

      expect(provider.conversationChannelFilter, 'all');
      expect(provider.conversationStateFilter, 'all');
      expect(provider.conversationOwnershipFilter, 'all');
      expect(provider.activeConversationFiltersCount, 0);
    });

    test('Setting channel filter passes channel parameter to repository and increases count', () async {
      final repo = MockMerchantFilterRepository(
        storedConversations: sampleConversations,
      );
      final provider = MerchantProvider(merchantRepository: repo);

      provider.setConversationChannelFilter('biz_123', 'whatsapp');
      expect(provider.conversationChannelFilter, 'whatsapp');
      expect(provider.activeConversationFiltersCount, 1);
      expect(repo.lastCapturedChannel, 'whatsapp');
    });

    test('Multiple filters operate together harmoniously (channel, state, ownership, search)', () async {
      final repo = MockMerchantFilterRepository(
        storedConversations: sampleConversations,
      );
      final provider = MerchantProvider(merchantRepository: repo);

      provider.setConversationChannelFilter('biz_123', 'telegram');
      provider.setConversationStateFilter('biz_123', 'waiting_human');
      provider.setConversationOwnershipFilter('biz_123', 'assigned');
      await provider.loadConversations('biz_123');
      provider.setConversationSearchQuery('فاطمة');

      expect(provider.activeConversationFiltersCount, 4);
      expect(repo.lastCapturedChannel, 'telegram');
      expect(repo.lastCapturedState, 'waiting_human');
      expect(repo.lastCapturedOwnership, 'assigned');

      // Check local filteredConversations
      final filtered = provider.filteredConversations;
      expect(filtered.length, 1);
      expect(filtered.first.id, 'conv_tg_02');
    });

    test(
      'clearConversationFilters resets all filters to all and reloads',
      () async {
        final repo = MockMerchantFilterRepository(
          storedConversations: sampleConversations,
        );
        final provider = MerchantProvider(merchantRepository: repo);

        provider.setConversationChannelFilter('biz_123', 'facebook');
        provider.setConversationStateFilter('biz_123', 'closed');
        provider.setConversationSearchQuery('أحمد');
        expect(provider.activeConversationFiltersCount, 3);

        provider.clearConversationFilters('biz_123');
        expect(provider.conversationChannelFilter, 'all');
        expect(provider.conversationStateFilter, 'all');
        expect(provider.conversationOwnershipFilter, 'all');
        expect(provider.conversationSearchQuery, '');
        expect(provider.activeConversationFiltersCount, 0);
        expect(repo.lastCapturedChannel, null);
        expect(repo.lastCapturedState, null);
      },
    );
  });

  group('3. CrmProvider Customer & Lead Filters', () {
    test(
      'Customer channel filter matches contact points and calculates count',
      () async {
        final repo = MockCrmFilterRepository(storedCustomers: sampleCustomers);
        final provider = CrmProvider(crmRepository: repo);

        // Load customers
        await provider.loadCustomers('biz_123');

        // Filter by whatsapp
        provider.setCustomerChannelFilter('whatsapp');
        expect(provider.customerChannelFilter, 'whatsapp');
        expect(provider.activeCustomerFiltersCount, 1);

        final waCustomers = provider.filteredCustomers;
        expect(waCustomers.length, 1);
        expect(waCustomers.first.displayName, 'سامي الخالد');

        // Filter by telegram
        provider.setCustomerChannelFilter('telegram');
        final tgCustomers = provider.filteredCustomers;
        expect(tgCustomers.length, 1);
        expect(tgCustomers.first.displayName, 'منى الحربي');

        // Clear filters
        provider.clearCustomerFilters('biz_123');
        expect(provider.activeCustomerFiltersCount, 0);
        expect(provider.customerChannelFilter, 'all');
      },
    );

    test(
      'Lead filters track status, score band, channel, and reset cleanly',
      () async {
        final sampleLeads = [
          const Lead(
            id: 'lead_01',
            businessId: 'biz_123',
            customerId: 'cust_01',
            status: 'qualified',
            createdBy: 'user_1',
            resourceVersion: '1',
            scoreBand: 'high',
            currentScore: 92.0,
          ),
          const Lead(
            id: 'lead_02',
            businessId: 'biz_123',
            customerId: 'cust_02',
            status: 'new',
            createdBy: 'user_2',
            resourceVersion: '1',
            scoreBand: 'low',
            currentScore: 35.0,
          ),
        ];

        final repo = MockCrmFilterRepository(storedLeads: sampleLeads);
        final provider = CrmProvider(crmRepository: repo);
        await provider.loadLeads('biz_123');

        provider.setLeadFilterStatus('qualified');
        provider.setLeadFilterScoreBand('high');
        expect(provider.activeLeadFiltersCount, 2);

        final filtered = provider.filteredLeads;
        expect(filtered.length, 1);
        expect(filtered.first.id, 'lead_01');

        provider.clearLeadFilters('biz_123');
        expect(provider.activeLeadFiltersCount, 0);
        expect(provider.leadFilterStatus, 'all');
        expect(provider.leadFilterScoreBand, 'all');
      },
    );
  });

  group('4. TransactionProvider Commercial Transaction Filters', () {
    test(
      'Tracks active filter counts and clears all filters back to default',
      () {
        final repo = MockTransactionFilterRepository(
          storedTransactions: const [
            CommercialTransaction(
              id: 'tx_01',
              businessId: 'biz_123',
              customerId: 'cust_01',
              transactionType: 'order',
              state: 'confirmed',
              totalAmount: 450.0,
              currency: 'SAR',
              schemaVersion: 1,
              resourceVersion: '1',
              createdAt: '2026-10-21T00:00:00Z',
              updatedAt: '2026-10-21T00:00:00Z',
            ),
          ],
        );
        final provider = TransactionProvider(transactionRepository: repo);

        expect(provider.activeFiltersCount, 0);

        provider.setStateFilter('confirmed');
        provider.setTransactionTypeFilter('order');
        provider.setSearchQuery('tx_01');
        expect(provider.activeFiltersCount, 3);

        provider.clearFilters('biz_123');
        expect(provider.activeFiltersCount, 0);
        expect(provider.stateFilter, 'all');
        expect(provider.transactionTypeFilter, 'all');
        expect(provider.searchQuery, '');
      },
    );
  });

  group('5. Filter Widgets & UI Components Tests', () {
    testWidgets(
      'ChannelFilterBar displays channels with brand icons and triggers selection',
      (tester) async {
        String selected = 'all';

        await tester.pumpWidget(
          buildTestApp(
            child: StatefulBuilder(
              builder: (context, setState) {
                return ChannelFilterBar(
                  selectedChannel: selected,
                  onChannelSelected: (ch) => setState(() => selected = ch),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Check for prominent brand options
        expect(find.text('كافة القنوات'), findsOneWidget);
        expect(find.text('واتساب'), findsOneWidget);
        expect(find.text('فيسبوك'), findsOneWidget);
        expect(find.text('تليجرام'), findsOneWidget);
        expect(find.text('إنستغرام'), findsOneWidget);

        // Tap on WhatsApp
        await tester.tap(find.text('واتساب'));
        await tester.pumpAndSettle();
        expect(selected, 'whatsapp');

        // Tap on Telegram
        await tester.tap(find.text('تليجرام'));
        await tester.pumpAndSettle();
        expect(selected, 'telegram');
      },
    );

    testWidgets(
      'ActiveFiltersHeader renders active count and triggers clear callback',
      (tester) async {
        bool cleared = false;

        await tester.pumpWidget(
          buildTestApp(
            child: ActiveFiltersHeader(
              activeCount: 3,
              onClear: () => cleared = true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('3'), findsOneWidget);
        expect(find.text('الفلاتر النشطة'), findsOneWidget);
        expect(find.text('مسح الفلاتر'), findsOneWidget);

        await tester.tap(find.text('مسح الفلاتر'));
        expect(cleared, isTrue);
      },
    );

    testWidgets('FilterEmptyState renders title, subtitle, and clear button', (
      tester,
    ) async {
      bool resetClicked = false;

      await tester.pumpWidget(
        buildTestApp(
          child: FilterEmptyState(
            title: 'لا توجد نتائج مطابقة للفلاتر المحددة',
            subtitle: 'جرّب تعديل معايير البحث',
            onClearFilters: () => resetClicked = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('لا توجد نتائج مطابقة للفلاتر المحددة'), findsOneWidget);
      expect(find.text('جرّب تعديل معايير البحث'), findsOneWidget);
      expect(find.text('مسح الفلاتر'), findsOneWidget);

      await tester.tap(find.text('مسح الفلاتر'));
      expect(resetClicked, isTrue);
    });

    testWidgets('ChannelBadge renders channel icon and localized brand name', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const Row(
            children: [
              ChannelBadge(channel: 'whatsapp'),
              ChannelBadge(channel: 'telegram'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('واتساب'), findsOneWidget);
      expect(find.text('تليجرام'), findsOneWidget);
    });
  });

  group(
    '6. InboxTab Merchant UI Integration with Channel & Status Filters',
    () {
      testWidgets(
        'Renders channel filter bar, filters conversations, and resets cleanly',
        (tester) async {
          final repo = MockMerchantFilterRepository(
            storedConversations: sampleConversations,
          );
          final provider = MerchantProvider(merchantRepository: repo);

          await tester.pumpWidget(
            buildTestApp(
              child: InboxTab(
                merchantProvider: provider,
                currentBusiness: testBusiness,
                onConversationSelected: (_) {},
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Check initial conversations
          expect(find.text('محمد علي'), findsOneWidget);
          expect(find.text('فاطمة الزهراء'), findsOneWidget);
          expect(find.text('أحمد سعيد'), findsOneWidget);

          // Verify Social Channels bar is present
          expect(
            find.widgetWithText(ChoiceChip, 'كافة القنوات'),
            findsOneWidget,
          );
          expect(find.widgetWithText(ChoiceChip, 'واتساب'), findsOneWidget);
          expect(find.widgetWithText(ChoiceChip, 'تليجرام'), findsOneWidget);
          expect(find.widgetWithText(ChoiceChip, 'فيسبوك'), findsOneWidget);

          // Tap on Telegram channel chip
          await tester.tap(find.widgetWithText(ChoiceChip, 'تليجرام'));
          await tester.pumpAndSettle();

          // Only Telegram conversation visible
          expect(find.text('فاطمة الزهراء'), findsOneWidget);
          expect(find.text('محمد علي'), findsNothing);
          expect(find.text('أحمد سعيد'), findsNothing);

          // Active filters header appears
          expect(find.text('مسح الفلاتر'), findsOneWidget);

          // Tap clear filters to reset
          await tester.tap(find.text('مسح الفلاتر'));
          await tester.pumpAndSettle();

          // All conversations are visible again
          expect(find.text('محمد علي'), findsOneWidget);
          expect(find.text('فاطمة الزهراء'), findsOneWidget);
          expect(find.text('أحمد سعيد'), findsOneWidget);
        },
      );
    },
  );

  group('7. CustomersTab UI with Channel Filter and Contact Point Badges', () {
    testWidgets(
      'Filters customers by communication channel and renders channel badge',
      (tester) async {
        final repo = MockCrmFilterRepository(storedCustomers: sampleCustomers);
        final provider = CrmProvider(crmRepository: repo);

        await tester.pumpWidget(
          buildTestApp(
            child: CustomersTab(crmProvider: provider, businessId: 'biz_123'),
          ),
        );
        await tester.pumpAndSettle();

        // Both customers visible initially
        expect(find.text('سامي الخالد'), findsOneWidget);
        expect(find.text('منى الحربي'), findsOneWidget);

        // Tap on Telegram channel filter
        await tester.tap(find.widgetWithText(ChoiceChip, 'تليجرام'));
        await tester.pumpAndSettle();

        // Only Mona (who has Telegram contact point) remains
        expect(find.text('منى الحربي'), findsOneWidget);
        expect(find.text('سامي الخالد'), findsNothing);

        // Clear filters
        await tester.tap(find.text('مسح الفلاتر'));
        await tester.pumpAndSettle();

        expect(find.text('سامي الخالد'), findsOneWidget);
        expect(find.text('منى الحربي'), findsOneWidget);
      },
    );
  });
}
