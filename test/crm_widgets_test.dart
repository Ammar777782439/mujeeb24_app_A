import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mujeeb24_app/app/localization/app_localizations.dart';
import 'package:mujeeb24_app/core/api/api_client.dart';
import 'package:mujeeb24_app/core/auth/auth_repository.dart';
import 'package:mujeeb24_app/core/auth/workspace_repository.dart';
import 'package:mujeeb24_app/core/crm/crm_repository.dart';
import 'package:mujeeb24_app/core/merchant/merchant_repository.dart';
import 'package:mujeeb24_app/core/models/auth_models.dart';
import 'package:mujeeb24_app/core/models/crm_models.dart';
import 'package:mujeeb24_app/core/models/merchant_models.dart';
import 'package:mujeeb24_app/features/auth/providers/auth_provider.dart';
import 'package:mujeeb24_app/features/crm/presentation/customer_detail_screen.dart';
import 'package:mujeeb24_app/features/crm/presentation/customer_form_screen.dart';
import 'package:mujeeb24_app/features/crm/presentation/customers_tab.dart';
import 'package:mujeeb24_app/features/crm/presentation/lead_detail_screen.dart';
import 'package:mujeeb24_app/features/crm/presentation/lead_form_screen.dart';
import 'package:mujeeb24_app/features/crm/presentation/leads_tab.dart';
import 'package:mujeeb24_app/features/crm/providers/crm_provider.dart';
import 'package:mujeeb24_app/features/merchant/presentation/merchant_home_screen.dart';
import 'package:mujeeb24_app/features/merchant/providers/merchant_provider.dart';

class FakeCrmRepository extends CrmRepository {
  List<Customer> mockCustomers;
  Customer? mockCustomer;
  List<Conversation> mockCustomerConversations;
  List<CommercialTransaction> mockCustomerTransactions;
  List<Lead> mockLeads;
  Lead? mockLead;
  List<LeadScore> mockLeadScores;
  List<LeadAttribution> mockLeadAttributions;

  bool createCustomerCalled = false;
  bool updateCustomerCalled = false;
  bool mergeCustomerCalled = false;
  bool createLeadCalled = false;
  bool updateLeadCalled = false;
  bool qualifyLeadCalled = false;
  bool markLeadLostCalled = false;

  FakeCrmRepository({
    this.mockCustomers = const [],
    this.mockCustomer,
    this.mockCustomerConversations = const [],
    this.mockCustomerTransactions = const [],
    this.mockLeads = const [],
    this.mockLead,
    this.mockLeadScores = const [],
    this.mockLeadAttributions = const [],
  }) : super(apiClient: ApiClient());

  @override
  Future<List<Customer>> listCustomers({
    required String businessId,
    String? search,
    String? status,
    String? cursor,
    int limit = 25,
  }) async {
    return mockCustomers;
  }

  @override
  Future<Customer> getCustomer({
    required String businessId,
    required String customerId,
  }) async {
    return mockCustomer ??
        Customer(
          id: customerId,
          businessId: businessId,
          displayName: 'خالد السالم',
          status: 'active',
          resourceVersion: 'v1',
          createdAt: '2026-10-15T10:00:00Z',
          updatedAt: '2026-10-15T10:00:00Z',
          contactPoints: const [
            ContactPoint(
              kind: 'phone',
              valueNormalized: '+966501234567',
              verificationStatus: 'verified',
            ),
          ],
        );
  }

  @override
  Future<Customer> createCustomer({
    required String businessId,
    required CreateCustomerRequest request,
    String? idempotencyKey,
    String? requestId,
  }) async {
    createCustomerCalled = true;
    return Customer(
      id: 'cust_created_1',
      businessId: businessId,
      displayName: 'العميل المضاف',
      status: 'active',
      resourceVersion: 'v1',
      createdAt: '2026-10-15T10:00:00Z',
      updatedAt: '2026-10-15T10:00:00Z',
    );
  }

  @override
  Future<Customer> updateCustomer({
    required String businessId,
    required String customerId,
    required UpdateCustomerRequest request,
    String? ifMatch,
  }) async {
    updateCustomerCalled = true;
    return Customer(
      id: customerId,
      businessId: businessId,
      displayName: 'العميل المحدث',
      status: 'active',
      resourceVersion: 'v2',
      createdAt: '2026-10-15T10:00:00Z',
      updatedAt: '2026-10-15T11:00:00Z',
    );
  }

  @override
  Future<Customer> mergeCustomer({
    required String businessId,
    required String customerId,
    required MergeCustomerRequest request,
    String? ifMatch,
  }) async {
    mergeCustomerCalled = true;
    return Customer(
      id: request.targetCustomerId,
      businessId: businessId,
      displayName: 'العميل المدمج',
      status: 'active',
      resourceVersion: 'v3',
      createdAt: '2026-10-15T10:00:00Z',
      updatedAt: '2026-10-15T12:00:00Z',
    );
  }

  @override
  Future<List<Conversation>> listCustomerConversations({
    required String businessId,
    required String customerId,
    String? cursor,
    int limit = 25,
  }) async {
    return mockCustomerConversations;
  }

  @override
  Future<List<CommercialTransaction>> listCustomerTransactions({
    required String businessId,
    required String customerId,
    String? cursor,
    int limit = 25,
  }) async {
    return mockCustomerTransactions;
  }

  @override
  Future<List<Lead>> listLeads({
    required String businessId,
    String? status,
    String? customerId,
    String? scoreBand,
    String? cursor,
    int limit = 25,
  }) async {
    return mockLeads;
  }

  @override
  Future<Lead> getLead({
    required String businessId,
    required String leadId,
  }) async {
    return mockLead ??
        Lead(
          id: leadId,
          businessId: businessId,
          customerId: 'cust_01',
          status: 'new',
          createdBy: 'agent_01',
          resourceVersion: 'v1',
          scoreBand: 'high',
          currentScore: 90.0,
        );
  }

  @override
  Future<Lead> createLead({
    required String businessId,
    required CreateLeadRequest request,
    String? idempotencyKey,
  }) async {
    createLeadCalled = true;
    return Lead(
      id: 'lead_created_1',
      businessId: businessId,
      customerId: request.customerId,
      status: 'new',
      createdBy: 'system',
      resourceVersion: 'v1',
    );
  }

  @override
  Future<Lead> updateLead({
    required String businessId,
    required String leadId,
    required UpdateLeadRequest request,
    String? ifMatch,
  }) async {
    updateLeadCalled = true;
    return Lead(
      id: leadId,
      businessId: businessId,
      customerId: 'cust_01',
      status: 'contacted',
      createdBy: 'system',
      resourceVersion: 'v2',
    );
  }

  @override
  Future<Lead> qualifyLead({
    required String businessId,
    required String leadId,
    String? reason,
    List<String>? evidenceReferences,
    String? ifMatch,
  }) async {
    qualifyLeadCalled = true;
    return Lead(
      id: leadId,
      businessId: businessId,
      customerId: 'cust_01',
      status: 'qualified',
      createdBy: 'system',
      resourceVersion: 'v3',
    );
  }

  @override
  Future<Lead> markLeadLost({
    required String businessId,
    required String leadId,
    required String lostReason,
    String? ifMatch,
  }) async {
    markLeadLostCalled = true;
    return Lead(
      id: leadId,
      businessId: businessId,
      customerId: 'cust_01',
      status: 'lost',
      createdBy: 'system',
      resourceVersion: 'v4',
    );
  }

  @override
  Future<List<LeadScore>> listLeadScores({
    required String businessId,
    required String leadId,
    String? cursor,
    int limit = 25,
  }) async {
    return mockLeadScores;
  }

  @override
  Future<List<LeadAttribution>> listLeadAttributions({
    required String businessId,
    required String leadId,
    String? cursor,
    int limit = 25,
  }) async {
    return mockLeadAttributions;
  }
}

class FakeMerchantRepository extends MerchantRepository {
  FakeMerchantRepository() : super(apiClient: ApiClient());

  @override
  Future<DashboardOverview> getDashboardOverview(String businessId) async {
    return const DashboardOverview(
      openConversations: 10,
      waitingHuman: 3,
      newCustomers: 25,
      newLeads: 8,
      transactionsNeedingReview: 0,
      connections: {'واتساب': 10},
    );
  }

  @override
  Future<Business> getBusinessProfile(String businessId) async {
    return const Business(
      id: 'biz_01',
      name: 'مؤسسة الأفق للتجارة',
      slug: 'alufuq-corp',
      defaultCurrency: 'SAR',
      locale: 'ar',
      timezone: 'Asia/Riyadh',
    );
  }

  @override
  Future<BusinessPolicy> getBusinessPolicy(String businessId) async {
    return const BusinessPolicy(
      businessId: 'biz_01',
      aiMode: 'copilot',
      defaultHumanReview: true,
      allowAutoReply: true,
      allowAutoLeadCreation: true,
      allowAutoTransactionDraft: false,
      allowAutoConfirmation: false,
      resourceVersion: 'v1',
    );
  }

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
    return [];
  }
}

class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository() : super(apiClient: ApiClient());
}

class FakeWorkspaceRepository extends WorkspaceRepository {
  FakeWorkspaceRepository() : super(apiClient: ApiClient());
}

Widget buildTestApp({required Widget child}) {
  return MaterialApp(
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
  const testBusinessId = 'biz_01';
  const testCustomerId = 'cust_01';
  const testLeadId = 'lead_01';

  final sampleCustomer = Customer(
    id: testCustomerId,
    businessId: testBusinessId,
    displayName: 'سارة أحمد',
    status: 'active',
    resourceVersion: 'v1',
    createdAt: '2026-10-15T10:00:00Z',
    updatedAt: '2026-10-15T10:00:00Z',
    contactPoints: const [
      ContactPoint(
        kind: 'phone',
        valueNormalized: '+966555112233',
        verificationStatus: 'verified',
      ),
      ContactPoint(
        kind: 'email',
        valueNormalized: 'sara@example.com',
        verificationStatus: 'verified',
      ),
    ],
  );

  final sampleLead = Lead(
    id: testLeadId,
    businessId: testBusinessId,
    customerId: testCustomerId,
    status: 'new',
    createdBy: 'agent_01',
    resourceVersion: 'v1',
    scoreBand: 'high',
    currentScore: 88.5,
  );

  group('Phase 3 Widget Tests: CustomersTab', () {
    testWidgets('renders customer list, search bar, and filter chips', (
      tester,
    ) async {
      final repo = FakeCrmRepository(mockCustomers: [sampleCustomer]);
      final provider = CrmProvider(crmRepository: repo);

      await tester.pumpWidget(
        buildTestApp(
          child: CustomersTab(
            crmProvider: provider,
            businessId: testBusinessId,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check customer display name and contact points
      expect(find.text('سارة أحمد'), findsOneWidget);
      expect(find.text('+966555112233'), findsOneWidget);
      expect(find.text('sara@example.com'), findsOneWidget);

      // Check filter chips
      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('نشط'), findsWidgets);
      expect(find.text('مؤرشف'), findsOneWidget);

      // Tap on Archived filter chip
      await tester.tap(find.text('مؤرشف'));
      await tester.pumpAndSettle();

      expect(provider.customerFilterStatus, 'archived');
    });

    testWidgets('renders empty state when no customers exist', (tester) async {
      final repo = FakeCrmRepository(mockCustomers: []);
      final provider = CrmProvider(crmRepository: repo);

      await tester.pumpWidget(
        buildTestApp(
          child: CustomersTab(
            crmProvider: provider,
            businessId: testBusinessId,
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('لم يتم العثور على أي عملاء'), findsOneWidget);
    });
  });

  group('Phase 3 Widget Tests: CustomerDetailScreen', () {
    testWidgets('renders tabs, overview, contact points, and merge dialog', (
      tester,
    ) async {
      final repo = FakeCrmRepository(
        mockCustomer: sampleCustomer,
        mockCustomerConversations: [
          Conversation(
            id: 'conv_sara_01',
            businessId: testBusinessId,
            customer: const CustomerSummary(
              id: testCustomerId,
              displayName: 'سارة',
            ),
            state: 'open',
            ownership: 'ai',
            aiMode: 'copilot',
            priority: 'urgent',
            lastActivityAt: '2026-10-15T12:00:00Z',
            resourceVersion: 'v1',
          ),
        ],
        mockCustomerTransactions: [
          const CommercialTransaction(
            id: 'tx_sara_01',
            businessId: testBusinessId,
            customerId: testCustomerId,
            transactionType: 'sale',
            state: 'completed',
            totalAmount: 750.0,
            currency: 'SAR',
            schemaVersion: 1,
            resourceVersion: 'v1',
            createdAt: '2026-10-15T12:00:00Z',
            updatedAt: '2026-10-15T12:00:00Z',
          ),
        ],
      );
      final provider = CrmProvider(crmRepository: repo);

      await tester.pumpWidget(
        buildTestApp(
          child: CustomerDetailScreen(
            crmProvider: provider,
            businessId: testBusinessId,
            customerId: testCustomerId,
            initialCustomer: sampleCustomer,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check header and contact points
      expect(find.text('سارة أحمد'), findsWidgets);
      expect(find.text('+966555112233'), findsOneWidget);
      expect(find.text('sara@example.com'), findsOneWidget);

      // Switch to Conversations tab
      await tester.tap(find.text('المحادثات (1)'));
      await tester.pumpAndSettle();
      expect(find.text('Conv: conv_sara_01'), findsOneWidget);

      // Switch to Transactions tab
      await tester.tap(find.text('المعاملات (1)'));
      await tester.pumpAndSettle();
      expect(find.text('SALE'), findsOneWidget);
      expect(find.text('750.00 SAR'), findsOneWidget);

      // Tap Merge icon in AppBar
      await tester.tap(find.byIcon(Icons.merge_type_rounded));
      await tester.pumpAndSettle();

      expect(find.text('دمج حساب العميل'), findsOneWidget);

      // Enter target customer id and reason
      await tester.enterText(
        find.widgetWithText(TextFormField, 'معرّف العميل المستهدف (UUID)'),
        'cust_target_888',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'سبب الدمج'),
        'حساب مكرر لنفس العميل',
      );

      // Confirm merge
      await tester.tap(find.text('تأكيد الدمج'));
      await tester.pumpAndSettle();

      expect(repo.mergeCustomerCalled, true);
    });
  });

  group('Phase 3 Widget Tests: CustomerFormScreen', () {
    testWidgets(
      'allows entering customer details and dynamically managing contact points',
      (tester) async {
        final repo = FakeCrmRepository();
        final provider = CrmProvider(crmRepository: repo);

        await tester.pumpWidget(
          buildTestApp(
            child: CustomerFormScreen(
              crmProvider: provider,
              businessId: testBusinessId,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Check title
        expect(find.text('إضافة عميل جديد'), findsWidgets);

        // Enter display name
        await tester.enterText(
          find.widgetWithText(TextFormField, 'الاسم الظاهر'),
          'عبدالله فهد',
        );

        // Add another contact point row
        await tester.tap(find.text('إضافة وسيلة اتصال'));
        await tester.pumpAndSettle();

        // Submit form
        await tester.ensureVisible(find.byType(ElevatedButton));
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        expect(repo.createCustomerCalled, true);
      },
    );
  });

  group('Phase 3 Widget Tests: LeadsTab', () {
    testWidgets('renders leads list, score band chips, and status filters', (
      tester,
    ) async {
      final repo = FakeCrmRepository(mockLeads: [sampleLead]);
      final provider = CrmProvider(crmRepository: repo);

      await tester.pumpWidget(
        buildTestApp(
          child: LeadsTab(crmProvider: provider, businessId: testBusinessId),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Lead card
      expect(find.text('Lead: lead_01'), findsOneWidget);
      expect(find.text('Cust: cust_01'), findsOneWidget);
      expect(find.text('BAND: HIGH'), findsOneWidget);
      expect(find.text('Score: 88.5'), findsOneWidget);

      // Tap on status filter chip
      await tester.tap(find.text('جديدة'));
      await tester.pumpAndSettle();
      expect(provider.leadFilterStatus, 'new');

      // Tap on score band chip
      await tester.tap(find.text('HIGH'));
      await tester.pumpAndSettle();
      expect(provider.leadFilterScoreBand, 'high');
    });
  });

  group('Phase 3 Widget Tests: LeadDetailScreen', () {
    testWidgets(
      'renders lead overview, triggers qualify and mark-lost dialogs',
      (tester) async {
        final repo = FakeCrmRepository(
          mockLead: sampleLead,
          mockLeadScores: [
            const LeadScore(
              id: 'sc_01',
              leadId: testLeadId,
              value: 94.0,
              band: 'high',
              factors: {'interest': 'high'},
              calculatedAt: '2026-10-15T14:00:00Z',
            ),
          ],
          mockLeadAttributions: [
            const LeadAttribution(
              id: 'at_01',
              leadId: testLeadId,
              sourceChannel: 'whatsapp',
              capturedAt: '2026-10-15T14:05:00Z',
            ),
          ],
        );
        final provider = CrmProvider(crmRepository: repo);

        await tester.pumpWidget(
          buildTestApp(
            child: LeadDetailScreen(
              crmProvider: provider,
              businessId: testBusinessId,
              leadId: testLeadId,
              initialLead: sampleLead,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Check overview
        expect(find.text('Lead: lead_01'), findsWidgets);
        expect(find.text('Score: 88.5'), findsOneWidget);

        // Open Qualify Dialog
        await tester.tap(find.text('تأهيل الفرصة'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.enterText(
          find.widgetWithText(TextField, 'سبب التأهيل'),
          'تم تأكيد الرغبة بالشراء',
        );
        await tester.tap(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(ElevatedButton),
          ),
        );
        await tester.pumpAndSettle();

        expect(repo.qualifyLeadCalled, true);

        // Open Mark Lost Dialog
        await tester.tap(find.text('تحديد كفرصة مفقودة'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.enterText(
          find.widgetWithText(TextFormField, 'سبب الفقد'),
          'لا توجد ميزانية حالياً',
        );
        await tester.tap(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(ElevatedButton),
          ),
        );
        await tester.pumpAndSettle();

        expect(repo.markLeadLostCalled, true);
      },
    );
  });

  group('Phase 3 Widget Tests: LeadFormScreen', () {
    testWidgets(
      'allows entering customer ID and qualification context to create lead',
      (tester) async {
        final repo = FakeCrmRepository();
        final provider = CrmProvider(crmRepository: repo);

        await tester.pumpWidget(
          buildTestApp(
            child: LeadFormScreen(
              crmProvider: provider,
              businessId: testBusinessId,
              prefilledCustomerId: testCustomerId,
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('إنشاء فرصة جديدة'), findsWidgets);
        expect(find.text(testCustomerId), findsOneWidget);

        await tester.enterText(
          find.widgetWithText(TextFormField, 'سياق التأهيل (ملاحظات/بيانات)'),
          'العميل طلب عرض سعر لباقة الشركات',
        );

        await tester.ensureVisible(find.byType(ElevatedButton));
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        expect(repo.createLeadCalled, true);
      },
    );
  });

  group('Phase 3 Widget Tests: MerchantHomeScreen 5 Tabs Navigation', () {
    testWidgets(
      'navigates seamlessly across Home, Inbox, Customers, Leads, and Settings tabs',
      (tester) async {
        final merchantRepo = FakeMerchantRepository();
        final merchantProvider = MerchantProvider(
          merchantRepository: merchantRepo,
        );

        final crmRepo = FakeCrmRepository(
          mockCustomers: [sampleCustomer],
          mockLeads: [sampleLead],
        );
        final crmProvider = CrmProvider(crmRepository: crmRepo);

        final authProvider = AuthProvider(
          authRepository: FakeAuthRepository(),
          workspaceRepository: FakeWorkspaceRepository(),
        );
        authProvider.selectBusiness(
          const BusinessMembership(
            business: Business(
              id: testBusinessId,
              name: 'مؤسسة الأفق للتجارة',
              slug: 'alufuq-corp',
              defaultCurrency: 'SAR',
              locale: 'ar',
              timezone: 'Asia/Riyadh',
            ),
            permissions: ['*'],
          ),
        );

        final localeProvider = AppLocaleProvider();

        await tester.pumpWidget(
          buildTestApp(
            child: MerchantHomeScreen(
              authProvider: authProvider,
              merchantProvider: merchantProvider,
              crmProvider: crmProvider,
              localeProvider: localeProvider,
              onSwitchBusiness: () {},
              onLogout: () {},
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Home (Dashboard) tab active initially
        expect(find.text('مؤشرات الأداء المباشرة'), findsOneWidget);
        expect(find.text('عملاء جدد'), findsOneWidget);
        expect(find.text('فرص جديدة'), findsOneWidget);

        // Tap "عملاء جدد" card on Dashboard to navigate directly to Customers tab!
        await tester.tap(find.text('عملاء جدد'));
        await tester.pumpAndSettle();

        // Now on Customers tab
        expect(find.text('سارة أحمد'), findsOneWidget);
        expect(find.text('بحث بالاسم، الهاتف، أو المعرف...'), findsOneWidget);

        // Tap Home tab
        await tester.tap(
          find.descendant(
            of: find.byType(BottomNavigationBar),
            matching: find.byIcon(Icons.dashboard_rounded),
          ),
        );
        await tester.pumpAndSettle();

        // Tap "فرص جديدة" card on Dashboard to navigate directly to Leads tab!
        await tester.tap(find.text('فرص جديدة'));
        await tester.pumpAndSettle();

        // Now on Leads tab
        expect(find.text('Lead: lead_01'), findsOneWidget);

        // Tap Inbox tab in BottomNavigationBar
        await tester.tap(
          find.descendant(
            of: find.byType(BottomNavigationBar),
            matching: find.byIcon(Icons.forum_rounded),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('بحث بالعميل أو المعرف...'), findsOneWidget);

        // Tap Settings tab in BottomNavigationBar
        await tester.tap(
          find.descendant(
            of: find.byType(BottomNavigationBar),
            matching: find.byIcon(Icons.settings_rounded),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('الملف التعريفي للنشاط'), findsOneWidget);
      },
    );
  });
}
