import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mujeeb24_app/core/api/api_client.dart';
import 'package:mujeeb24_app/core/auth/auth_repository.dart';
import 'package:mujeeb24_app/core/auth/workspace_repository.dart';
import 'package:mujeeb24_app/core/errors/api_error.dart';
import 'package:mujeeb24_app/core/models/auth_models.dart';
import 'package:mujeeb24_app/features/auth/presentation/login_screen.dart';
import 'package:mujeeb24_app/features/auth/providers/auth_provider.dart';

class FakeAuthRepository extends AuthRepository {
  final bool shouldSucceed;
  final String? errorMessage;
  final String? requestId;

  FakeAuthRepository({
    this.shouldSucceed = true,
    this.errorMessage,
    this.requestId,
  }) : super(apiClient: ApiClient());

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    if (!shouldSucceed) {
      throw ApiErrorEnvelope.fromRaw(
        code: 'INVALID_CREDENTIALS',
        message: errorMessage ?? 'بيانات الاعتماد غير صحيحة',
        requestId: requestId ?? 'req_test_123',
        statusCode: 401,
      );
    }
    return AuthResponse(
      accessToken: 'test_token',
      tokenType: 'Bearer',
      expiresAt: '2026-10-15T00:00:00Z',
      isPlatformAdmin: false,
      principal: const Principal(
        principalId: 'p_1',
        displayName: 'Test User',
        email: 'test@example.com',
      ),
    );
  }
}

class FakeWorkspaceRepository extends WorkspaceRepository {
  final List<BusinessMembership> businesses;

  FakeWorkspaceRepository({this.businesses = const []})
    : super(apiClient: ApiClient());

  @override
  Future<List<BusinessMembership>> getAccessibleBusinesses({
    int limit = 25,
    String? cursor,
  }) async {
    return businesses;
  }
}

Widget buildTestableWidget({
  required AuthProvider authProvider,
  VoidCallback? onLoginSuccess,
  VoidCallback? onNavigateToInvitation,
}) {
  return MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: const [Locale('ar'), Locale('en')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: LoginScreen(
      authProvider: authProvider,
      onLoginSuccess: onLoginSuccess ?? () {},
      onNavigateToInvitation: onNavigateToInvitation ?? () {},
    ),
  );
}

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('renders login screen fields and buttons', (tester) async {
      final fakeAuthRepo = FakeAuthRepository();
      final fakeWsRepo = FakeWorkspaceRepository();
      final authProvider = AuthProvider(
        authRepository: fakeAuthRepo,
        workspaceRepository: fakeWsRepo,
      );

      await tester.pumpWidget(buildTestableWidget(authProvider: authProvider));

      expect(find.text('مجيب 24'), findsOneWidget);
      expect(find.text('تسجيل الدخول'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('validates required fields on submit without input', (
      tester,
    ) async {
      final fakeAuthRepo = FakeAuthRepository();
      final fakeWsRepo = FakeWorkspaceRepository();
      final authProvider = AuthProvider(
        authRepository: fakeAuthRepo,
        workspaceRepository: fakeWsRepo,
      );

      await tester.pumpWidget(buildTestableWidget(authProvider: authProvider));

      // Tap login without typing anything
      await tester.tap(find.text('تسجيل الدخول'));
      await tester.pumpAndSettle();

      expect(find.text('حقل مطلوب'), findsWidgets);
    });

    testWidgets('quick fill button populates email and password', (
      tester,
    ) async {
      final fakeAuthRepo = FakeAuthRepository();
      final fakeWsRepo = FakeWorkspaceRepository();
      final authProvider = AuthProvider(
        authRepository: fakeAuthRepo,
        workspaceRepository: fakeWsRepo,
      );

      await tester.pumpWidget(buildTestableWidget(authProvider: authProvider));

      await tester.tap(find.text('تعبئة سريعة'));
      await tester.pumpAndSettle();

      expect(find.text('admin@alufuq.com'), findsOneWidget);
    });

    testWidgets('displays server error banner and request_id on failure', (
      tester,
    ) async {
      final fakeAuthRepo = FakeAuthRepository(
        shouldSucceed: false,
        errorMessage: 'بيانات الاعتماد غير متطابقة',
        requestId: 'req_fail_999',
      );
      final fakeWsRepo = FakeWorkspaceRepository();
      final authProvider = AuthProvider(
        authRepository: fakeAuthRepo,
        workspaceRepository: fakeWsRepo,
      );

      await tester.pumpWidget(buildTestableWidget(authProvider: authProvider));

      await tester.tap(find.text('تعبئة سريعة'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('تسجيل الدخول'));
      await tester.pumpAndSettle();

      expect(find.text('بيانات الاعتماد غير متطابقة'), findsOneWidget);
      expect(find.textContaining('req_fail_999'), findsOneWidget);
    });

    testWidgets('calls onLoginSuccess on valid login', (tester) async {
      bool successCalled = false;
      final fakeAuthRepo = FakeAuthRepository(shouldSucceed: true);
      final fakeWsRepo = FakeWorkspaceRepository();
      final authProvider = AuthProvider(
        authRepository: fakeAuthRepo,
        workspaceRepository: fakeWsRepo,
      );

      await tester.pumpWidget(
        buildTestableWidget(
          authProvider: authProvider,
          onLoginSuccess: () {
            successCalled = true;
          },
        ),
      );

      await tester.tap(find.text('تعبئة سريعة'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('تسجيل الدخول'));
      await tester.pumpAndSettle();

      expect(successCalled, true);
    });
  });
}
