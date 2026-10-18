import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mujeeb24_app/core/api/api_client.dart';
import 'package:mujeeb24_app/core/merchant/merchant_repository.dart';
import 'package:mujeeb24_app/core/models/auth_models.dart';
import 'package:mujeeb24_app/core/models/merchant_models.dart';
import 'package:mujeeb24_app/core/models/transaction_models.dart';
import 'package:mujeeb24_app/core/transactions/transaction_repository.dart';
import 'package:mujeeb24_app/features/merchant/presentation/dashboard_tab.dart';
import 'package:mujeeb24_app/features/merchant/providers/merchant_provider.dart';
import 'package:mujeeb24_app/features/transactions/presentation/transaction_detail_screen.dart';
import 'package:mujeeb24_app/features/transactions/presentation/transaction_draft_form_screen.dart';
import 'package:mujeeb24_app/features/transactions/presentation/transactions_screen.dart';
import 'package:mujeeb24_app/features/transactions/providers/transaction_provider.dart';

class FakeTransactionRepository extends TransactionRepository {
  List<CommercialTransaction> mockTransactions;
  CommercialTransaction? mockSingleTransaction;
  TransactionReview? mockReview;

  bool listTransactionsCalled = false;
  bool createTransactionDraftCalled = false;
  bool updateTransactionDraftCalled = false;
  bool cancelTransactionCalled = false;
  bool confirmTransactionCalled = false;
  bool getTransactionReviewCalled = false;
  bool approveTransactionReviewCalled = false;
  bool rejectTransactionReviewCalled = false;
  bool submitTransactionReviewCalled = false;

  FakeTransactionRepository({
    this.mockTransactions = const [],
    this.mockSingleTransaction,
    this.mockReview,
  }) : super(apiClient: ApiClient(baseUrl: 'https://mock.local'));

  @override
  Future<TransactionPage> listTransactions({
    required String businessId,
    String? state,
    String? transactionType,
    String? customerId,
    String? cursor,
    int limit = 25,
  }) async {
    listTransactionsCalled = true;
    var filtered = List<CommercialTransaction>.from(mockTransactions);
    if (state != null && state.isNotEmpty && state != 'all') {
      filtered = filtered.where((t) => t.state == state).toList();
    }
    if (transactionType != null &&
        transactionType.isNotEmpty &&
        transactionType != 'all') {
      filtered = filtered.where((t) => t.transactionType == transactionType).toList();
    }
    return TransactionPage(items: filtered, hasMore: false);
  }

  @override
  Future<CommercialTransaction> getTransaction({
    required String businessId,
    required String transactionId,
  }) async {
    return mockSingleTransaction ??
        mockTransactions.firstWhere(
          (t) => t.id == transactionId,
          orElse: () => CommercialTransaction(
            id: transactionId,
            businessId: businessId,
            customerId: 'cust_01',
            transactionType: 'order',
            state: 'draft',
            schemaVersion: 1,
            resourceVersion: 'v1',
            createdAt: '2026-10-16T10:00:00Z',
            updatedAt: '2026-10-16T10:00:00Z',
          ),
        );
  }

  @override
  Future<CommercialTransaction> createTransactionDraft({
    required String businessId,
    required CreateTransactionDraftRequest request,
    String? idempotencyKey,
  }) async {
    createTransactionDraftCalled = true;
    return CommercialTransaction(
      id: 'tx_created_123',
      businessId: businessId,
      customerId: request.customerId,
      leadId: request.leadId,
      transactionType: request.transactionType,
      state: 'draft',
      totalAmount: 250.0,
      currency: request.currency ?? 'SAR',
      schemaVersion: 1,
      resourceVersion: 'v1',
      createdAt: '2026-10-16T10:00:00Z',
      updatedAt: '2026-10-16T10:00:00Z',
    );
  }

  @override
  Future<CommercialTransaction> updateTransactionDraft({
    required String businessId,
    required String transactionId,
    required UpdateTransactionDraftRequest request,
    required String ifMatch,
    String? idempotencyKey,
  }) async {
    updateTransactionDraftCalled = true;
    return CommercialTransaction(
      id: transactionId,
      businessId: businessId,
      customerId: 'cust_01',
      transactionType: 'order',
      state: 'draft',
      totalAmount: 350.0,
      currency: request.currency ?? 'SAR',
      schemaVersion: 1,
      resourceVersion: 'v2',
      createdAt: '2026-10-16T10:00:00Z',
      updatedAt: '2026-10-16T10:05:00Z',
    );
  }

  @override
  Future<CommercialTransaction> cancelTransaction({
    required String businessId,
    required String transactionId,
    required TransactionReasonRequest request,
    required String ifMatch,
    String? idempotencyKey,
  }) async {
    cancelTransactionCalled = true;
    return CommercialTransaction(
      id: transactionId,
      businessId: businessId,
      customerId: 'cust_01',
      transactionType: 'order',
      state: 'cancelled',
      schemaVersion: 1,
      resourceVersion: 'v3',
      createdAt: '2026-10-16T10:00:00Z',
      updatedAt: '2026-10-16T10:10:00Z',
    );
  }

  @override
  Future<CommercialTransaction> confirmTransaction({
    required String businessId,
    required String transactionId,
    required ConfirmTransactionRequest request,
    required String ifMatch,
    String? idempotencyKey,
  }) async {
    confirmTransactionCalled = true;
    return CommercialTransaction(
      id: transactionId,
      businessId: businessId,
      customerId: 'cust_01',
      transactionType: 'order',
      state: 'confirmed',
      schemaVersion: 1,
      resourceVersion: 'v3',
      createdAt: '2026-10-16T10:00:00Z',
      updatedAt: '2026-10-16T10:15:00Z',
    );
  }

  @override
  Future<TransactionReview> getTransactionReview({
    required String businessId,
    required String transactionId,
  }) async {
    getTransactionReviewCalled = true;
    return mockReview ??
        const TransactionReview(
          required: true,
          status: 'pending',
          reasonCodes: ['high_value'],
          reviewerReference: null,
        );
  }

  @override
  Future<TransactionReview> approveTransactionReview({
    required String businessId,
    required String transactionId,
    required ReviewDecisionRequest request,
    required String ifMatch,
    String? idempotencyKey,
  }) async {
    approveTransactionReviewCalled = true;
    return TransactionReview(
      required: true,
      status: 'approved',
      reasonCodes: const ['high_value'],
      reviewerReference: request.reviewerReference,
    );
  }

  @override
  Future<TransactionReview> rejectTransactionReview({
    required String businessId,
    required String transactionId,
    required ReviewDecisionRequest request,
    required String ifMatch,
    String? idempotencyKey,
  }) async {
    rejectTransactionReviewCalled = true;
    return TransactionReview(
      required: true,
      status: 'rejected',
      reasonCodes: const ['high_value'],
      reviewerReference: request.reviewerReference,
    );
  }

  @override
  Future<TransactionReview> submitTransactionReview({
    required String businessId,
    required String transactionId,
    required SubmitReviewRequest request,
    required String ifMatch,
    String? idempotencyKey,
  }) async {
    submitTransactionReviewCalled = true;
    return TransactionReview(
      required: true,
      status: 'pending',
      reasonCodes: request.reasonCodes,
    );
  }
}

Widget buildTestWidget({required Widget child, Locale locale = const Locale('ar')}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: const [Locale('ar'), Locale('en')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: child,
  );
}

void _setLargeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void main() {
  const testBusinessId = 'b-100';

  final sampleDraftTx = CommercialTransaction(
    id: 'tx_draft_01',
    businessId: testBusinessId,
    customerId: 'cust_01',
    transactionType: 'order',
    state: 'draft',
    totalAmount: 180.0,
    currency: 'SAR',
    lines: const [
      {
        'id': 'line_01',
        'catalog_item_id': 'item_a',
        'item_name_snapshot': 'ساعة أنيقة',
        'quantity': 1.0,
        'unit_price_snapshot': 180.0,
        'currency': 'SAR',
      },
    ],
    schemaVersion: 1,
    resourceVersion: 'v1',
    createdAt: '2026-10-16T08:00:00Z',
    updatedAt: '2026-10-16T08:00:00Z',
  );

  final sampleReviewTx = CommercialTransaction(
    id: 'tx_review_02',
    businessId: testBusinessId,
    customerId: 'cust_02',
    transactionType: 'quote',
    state: 'review',
    totalAmount: 1200.0,
    currency: 'SAR',
    lines: const [
      {
        'id': 'line_02',
        'catalog_item_id': 'item_b',
        'item_name_snapshot': 'طقم مجوهرات فاخر',
        'quantity': 2.0,
        'unit_price_snapshot': 600.0,
        'currency': 'SAR',
      },
    ],
    schemaVersion: 1,
    resourceVersion: 'v2',
    createdAt: '2026-10-16T09:00:00Z',
    updatedAt: '2026-10-16T09:30:00Z',
  );

  group('Phase 4 Widget Tests: TransactionsScreen', () {
    testWidgets('renders transaction list, search bar, state and type filter chips', (tester) async {
      final repo = FakeTransactionRepository(
        mockTransactions: [sampleDraftTx, sampleReviewTx],
      );
      final provider = TransactionProvider(transactionRepository: repo);

      await tester.pumpWidget(
        buildTestWidget(
          child: TransactionsScreen(
            transactionProvider: provider,
            businessId: testBusinessId,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('المعاملات التجارية'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget); // Search bar
      expect(find.text('مسودة'), findsWidgets);
      expect(find.text('قيد المراجعة'), findsWidgets);
      expect(find.text('180.00 SAR'), findsOneWidget);
      expect(find.text('1200.00 SAR'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('filtering by state reloads filtered transactions', (tester) async {
      final repo = FakeTransactionRepository(
        mockTransactions: [sampleDraftTx, sampleReviewTx],
      );
      final provider = TransactionProvider(transactionRepository: repo);

      await tester.pumpWidget(
        buildTestWidget(
          child: TransactionsScreen(
            transactionProvider: provider,
            businessId: testBusinessId,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap "قيد المراجعة" filter chip
      await tester.tap(find.widgetWithText(FilterChip, 'قيد المراجعة'));
      await tester.pumpAndSettle();

      expect(provider.stateFilter, 'review');
      // Only sampleReviewTx should be in list
      expect(find.text('1200.00 SAR'), findsOneWidget);
      expect(find.text('180.00 SAR'), findsNothing);
    });
  });

  group('Phase 4 Widget Tests: TransactionDraftFormScreen', () {
    testWidgets('validates required fields, adds lines, and submits draft creation', (tester) async {
      _setLargeViewport(tester);
      final repo = FakeTransactionRepository();
      final provider = TransactionProvider(transactionRepository: repo);

      await tester.pumpWidget(
        buildTestWidget(
          child: TransactionDraftFormScreen(
            transactionProvider: provider,
            businessId: testBusinessId,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.widgetWithText(ElevatedButton, 'إنشاء مسودة معاملة'), findsOneWidget);

      // Attempt submit without filling customer_id
      await tester.tap(find.widgetWithText(ElevatedButton, 'إنشاء مسودة معاملة'));
      await tester.pumpAndSettle();

      // Validation error shown
      expect(find.text('حقل مطلوب'), findsWidgets);

      // Enter customer ID and item ID
      await tester.enterText(
        find.widgetWithText(TextFormField, 'معرف العميل (UUID) *'),
        'c_11111111-2222-3333-4444-555555555555',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'معرّف عنصر الكتالوج *'),
        'item_alpha',
      );

      // Add a second line
      await tester.tap(find.widgetWithText(TextButton, 'إضافة بند'));
      await tester.pumpAndSettle();

      expect(find.text('اسم البند #2'), findsOneWidget);

      // Fill second line
      await tester.enterText(
        find.widgetWithText(TextFormField, 'معرّف عنصر الكتالوج *').last,
        'item_beta',
      );

      // Remove second line
      await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
      await tester.pumpAndSettle();

      expect(find.text('اسم البند #2'), findsNothing);

      // Submit
      await tester.tap(find.widgetWithText(ElevatedButton, 'إنشاء مسودة معاملة'));
      await tester.pumpAndSettle();

      expect(repo.createTransactionDraftCalled, true);
    });
  });

  group('Phase 4 Widget Tests: TransactionDetailScreen & Lifecycle Actions', () {
    testWidgets('renders detail overview, lines table, and draft actions', (tester) async {
      _setLargeViewport(tester);
      final repo = FakeTransactionRepository(mockSingleTransaction: sampleDraftTx);
      final provider = TransactionProvider(transactionRepository: repo);

      await tester.pumpWidget(
        buildTestWidget(
          child: TransactionDetailScreen(
            transactionProvider: provider,
            businessId: testBusinessId,
            transactionId: sampleDraftTx.id,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('تفاصيل المعاملة'), findsOneWidget);
      expect(find.text('180.00 SAR'), findsWidgets);
      expect(find.text('ساعة أنيقة'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'تعديل المسودة'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'إرسال للمراجعة'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'إلغاء المعاملة'), findsOneWidget);
    });

    testWidgets('Submit for review dialog prompts for reason codes and submits', (tester) async {
      _setLargeViewport(tester);
      final repo = FakeTransactionRepository(mockSingleTransaction: sampleDraftTx);
      final provider = TransactionProvider(transactionRepository: repo);

      await tester.pumpWidget(
        buildTestWidget(
          child: TransactionDetailScreen(
            transactionProvider: provider,
            businessId: testBusinessId,
            transactionId: sampleDraftTx.id,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap submit for review
      await tester.tap(find.widgetWithText(ElevatedButton, 'إرسال للمراجعة'));
      await tester.pumpAndSettle();

      // Dialog appears
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('رموز أسباب المراجعة *'), findsOneWidget);

      // Tap submit in dialog
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(ElevatedButton, 'إرسال للمراجعة'),
        ),
      );
      await tester.pumpAndSettle();

      expect(repo.submitTransactionReviewCalled, true);
    });

    testWidgets('Review state renders review card and Approve/Reject dialogs', (tester) async {
      _setLargeViewport(tester);
      final repo = FakeTransactionRepository(
        mockSingleTransaction: sampleReviewTx,
        mockReview: const TransactionReview(
          required: true,
          status: 'pending',
          reasonCodes: ['high_value'],
        ),
      );
      final provider = TransactionProvider(transactionRepository: repo);

      await tester.pumpWidget(
        buildTestWidget(
          child: TransactionDetailScreen(
            transactionProvider: provider,
            businessId: testBusinessId,
            transactionId: sampleReviewTx.id,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('بيانات المراجعة'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);
      expect(find.text('high_value'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'اعتماد المعاملة'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'رفض المعاملة'), findsOneWidget);

      // Tap Approve
      await tester.tap(find.widgetWithText(ElevatedButton, 'اعتماد المعاملة'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('معرّف المراجع *'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(ElevatedButton, 'اعتماد المعاملة'),
        ),
      );
      await tester.pumpAndSettle();

      expect(repo.approveTransactionReviewCalled, true);
    });

    testWidgets('Reject review dialog prompts for reason and calls reject', (tester) async {
      _setLargeViewport(tester);
      final repo = FakeTransactionRepository(
        mockSingleTransaction: sampleReviewTx,
        mockReview: const TransactionReview(
          required: true,
          status: 'pending',
          reasonCodes: ['high_value'],
        ),
      );
      final provider = TransactionProvider(transactionRepository: repo);

      await tester.pumpWidget(
        buildTestWidget(
          child: TransactionDetailScreen(
            transactionProvider: provider,
            businessId: testBusinessId,
            transactionId: sampleReviewTx.id,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Reject
      await tester.tap(find.widgetWithText(ElevatedButton, 'رفض المعاملة'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(ElevatedButton, 'رفض المعاملة'),
        ),
      );
      await tester.pumpAndSettle();

      expect(repo.rejectTransactionReviewCalled, true);
    });

    testWidgets('Confirm transaction dialog prompts for evidence reference and confirms', (tester) async {
      _setLargeViewport(tester);
      final repo = FakeTransactionRepository(
        mockSingleTransaction: sampleReviewTx,
      );
      final provider = TransactionProvider(transactionRepository: repo);

      await tester.pumpWidget(
        buildTestWidget(
          child: TransactionDetailScreen(
            transactionProvider: provider,
            businessId: testBusinessId,
            transactionId: sampleReviewTx.id,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Confirm
      await tester.tap(find.widgetWithText(OutlinedButton, 'تأكيد المعاملة'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('مرجع الإثبات / الإيصال *'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(ElevatedButton, 'تأكيد المعاملة'),
        ),
      );
      await tester.pumpAndSettle();

      expect(repo.confirmTransactionCalled, true);
    });

    testWidgets('Cancel transaction dialog prompts for reason and cancels', (tester) async {
      _setLargeViewport(tester);
      final repo = FakeTransactionRepository(
        mockSingleTransaction: sampleDraftTx,
      );
      final provider = TransactionProvider(transactionRepository: repo);

      await tester.pumpWidget(
        buildTestWidget(
          child: TransactionDetailScreen(
            transactionProvider: provider,
            businessId: testBusinessId,
            transactionId: sampleDraftTx.id,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Cancel
      await tester.tap(find.widgetWithText(TextButton, 'إلغاء المعاملة'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('سبب الإلغاء *'), findsOneWidget);

      // Enter reason
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        'Item out of stock',
      );

      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(ElevatedButton, 'إلغاء المعاملة'),
        ),
      );
      await tester.pumpAndSettle();

      expect(repo.cancelTransactionCalled, true);
    });
  });

  group('Phase 4 Widget Tests: DashboardTab Reviews Navigation', () {
    testWidgets('tapping review banner triggers onNavigateToReviews callback', (tester) async {
      bool reviewNavCalled = false;
      final merchantProvider = MerchantProvider(
        merchantRepository: FakeMerchantRepository(),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: Scaffold(
            body: DashboardTab(
              merchantProvider: merchantProvider,
              currentBusiness: const Business(
                id: testBusinessId,
                name: 'مؤسسة الأفق للتجارة',
                slug: 'alufuq',
                defaultCurrency: 'SAR',
                locale: 'ar',
                timezone: 'Asia/Riyadh',
              ),
              onNavigateToInbox: () {},
              onNavigateToReviews: () {
                reviewNavCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('معاملات قيد المراجعة'), findsOneWidget);

      // Tap review banner
      await tester.tap(find.text('معاملات قيد المراجعة'));
      await tester.pumpAndSettle();

      expect(reviewNavCalled, true);
    });
  });
}

class FakeMerchantRepository extends MerchantRepository {
  FakeMerchantRepository()
      : super(apiClient: ApiClient(baseUrl: 'https://mock.local'));

  @override
  Future<DashboardOverview> getDashboardOverview(String businessId) async {
    return const DashboardOverview(
      openConversations: 5,
      waitingHuman: 2,
      newCustomers: 12,
      newLeads: 4,
      transactionsNeedingReview: 3,
      connections: {'whatsapp': 1},
    );
  }
}
