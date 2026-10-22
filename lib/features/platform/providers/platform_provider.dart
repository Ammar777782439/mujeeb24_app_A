import 'package:flutter/foundation.dart';

import '../../../core/errors/api_error.dart';
import '../../../core/models/platform_models.dart';
import '../../../core/platform/platform_repository.dart';

/// Provider for managing state across Phase 8 Platform Management modules:
/// - Businesses (Platform.Businesses)
/// - Channels (Platform.Channels)
/// - AI Runtime & Kill Switch (Platform.AI)
/// - Plans & Billing (Platform.Plans)
/// - Subscriptions & Payments (Platform.Subscriptions & Platform.Payments)
/// - Support Tickets (Platform.Support)
/// - Platform Audit Trail (Platform.Audit)
class PlatformProvider extends ChangeNotifier {
  final PlatformRepository repository;

  PlatformProvider({required this.repository});

  // ==========================================
  // Global Action State & Diagnostics
  // ==========================================
  bool _isPerformingAction = false;
  String? _actionError;
  String? _actionSuccessMessage;
  String? _lastRequestId;

  bool get isPerformingAction => _isPerformingAction;
  String? get actionError => _actionError;
  String? get actionSuccessMessage => _actionSuccessMessage;
  String? get lastRequestId => _lastRequestId;

  void clearActionState() {
    _isPerformingAction = false;
    _actionError = null;
    _actionSuccessMessage = null;
    notifyListeners();
  }

  // ==========================================
  // 1. Businesses State
  // ==========================================
  List<PlatformBusinessView> _businesses = [];
  bool _isLoadingBusinesses = false;
  String? _businessesError;
  String _businessStatusFilter = 'all';

  List<PlatformBusinessView> get businesses {
    if (_businessStatusFilter == 'all') return _businesses;
    return _businesses
        .where(
          (b) =>
              b.platformStatus.toLowerCase() ==
              _businessStatusFilter.toLowerCase(),
        )
        .toList();
  }

  List<PlatformBusinessView> get rawBusinesses => _businesses;
  bool get isLoadingBusinesses => _isLoadingBusinesses;
  String? get businessesError => _businessesError;
  String get businessStatusFilter => _businessStatusFilter;

  void setBusinessFilter(String status) {
    _businessStatusFilter = status;
    notifyListeners();
  }

  Future<void> fetchBusinesses({bool refresh = false}) async {
    _isLoadingBusinesses = true;
    _businessesError = null;
    notifyListeners();

    try {
      final page = await repository.listBusinesses(
        platformStatus: _businessStatusFilter != 'all'
            ? _businessStatusFilter
            : null,
      );
      _businesses = page.items;
      _lastRequestId = page.requestId;
    } on ApiErrorEnvelope catch (e) {
      _businessesError = e.error.message;
      _lastRequestId = e.requestId;
    } on NetworkException catch (e) {
      _businessesError = e.message;
    } catch (e) {
      _businessesError = e.toString();
    } finally {
      _isLoadingBusinesses = false;
      notifyListeners();
    }
  }

  Future<bool> createBusiness(PlatformCreateBusinessRequest request) async {
    _isPerformingAction = true;
    _actionError = null;
    _actionSuccessMessage = null;
    notifyListeners();

    try {
      final biz = await repository.createBusiness(request);
      _businesses.insert(0, biz);
      _actionSuccessMessage = 'تم إنشاء النشاط التجاري بنجاح';
      return true;
    } on ApiErrorEnvelope catch (e) {
      _actionError = e.error.message;
      _lastRequestId = e.requestId;
      return false;
    } on NetworkException catch (e) {
      _actionError = e.message;
      return false;
    } catch (e) {
      _actionError = e.toString();
      return false;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<bool> assignOwner(
    String businessId,
    PlatformAssignOwnerRequest request,
  ) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final updated = await repository.assignOwner(businessId, request);
      final idx = _businesses.indexWhere((b) => b.id == businessId);
      if (idx != -1) _businesses[idx] = updated;
      _actionSuccessMessage = 'تم تعيين المالك وتفعيل النشاط التجاري';
      return true;
    } on ApiErrorEnvelope catch (e) {
      _actionError = e.error.message;
      _lastRequestId = e.requestId;
      return false;
    } on NetworkException catch (e) {
      _actionError = e.message;
      return false;
    } catch (e) {
      _actionError = e.toString();
      return false;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<bool> suspendBusiness(String businessId) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final updated = await repository.suspendBusiness(businessId);
      final idx = _businesses.indexWhere((b) => b.id == businessId);
      if (idx != -1) _businesses[idx] = updated;
      _actionSuccessMessage = 'تم تعليق النشاط التجاري بنجاح';
      return true;
    } on ApiErrorEnvelope catch (e) {
      _actionError = e.error.message;
      _lastRequestId = e.requestId;
      return false;
    } on NetworkException catch (e) {
      _actionError = e.message;
      return false;
    } catch (e) {
      _actionError = e.toString();
      return false;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<bool> reactivateBusiness(String businessId) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final updated = await repository.reactivateBusiness(businessId);
      final idx = _businesses.indexWhere((b) => b.id == businessId);
      if (idx != -1) _businesses[idx] = updated;
      _actionSuccessMessage = 'تمت إعادة تفعيل النشاط التجاري';
      return true;
    } on ApiErrorEnvelope catch (e) {
      _actionError = e.error.message;
      _lastRequestId = e.requestId;
      return false;
    } on NetworkException catch (e) {
      _actionError = e.message;
      return false;
    } catch (e) {
      _actionError = e.toString();
      return false;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<bool> archiveBusiness(String businessId) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final updated = await repository.archiveBusiness(businessId);
      final idx = _businesses.indexWhere((b) => b.id == businessId);
      if (idx != -1) _businesses[idx] = updated;
      _actionSuccessMessage = 'تمت أرشفة النشاط التجاري';
      return true;
    } on ApiErrorEnvelope catch (e) {
      _actionError = e.error.message;
      _lastRequestId = e.requestId;
      return false;
    } on NetworkException catch (e) {
      _actionError = e.message;
      return false;
    } catch (e) {
      _actionError = e.toString();
      return false;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  // ==========================================
  // 2. Channels State
  // ==========================================
  List<PlatformChannelView> _channels = [];
  bool _isLoadingChannels = false;
  String? _channelsError;
  bool _isCheckingChannelHealth = false;

  List<PlatformChannelView> get channels => _channels;
  bool get isLoadingChannels => _isLoadingChannels;
  String? get channelsError => _channelsError;
  bool get isCheckingChannelHealth => _isCheckingChannelHealth;

  Future<void> fetchChannels({bool refresh = false}) async {
    _isLoadingChannels = true;
    _channelsError = null;
    notifyListeners();

    try {
      final page = await repository.listChannels();
      _channels = page.items;
      _lastRequestId = page.requestId;
    } on ApiErrorEnvelope catch (e) {
      _channelsError = e.error.message;
      _lastRequestId = e.requestId;
    } on NetworkException catch (e) {
      _channelsError = e.message;
    } catch (e) {
      _channelsError = e.toString();
    } finally {
      _isLoadingChannels = false;
      notifyListeners();
    }
  }

  Future<PlatformChannelView?> runChannelHealthCheck(
    String connectionId,
  ) async {
    _isCheckingChannelHealth = true;
    _actionError = null;
    notifyListeners();

    try {
      final updated = await repository.runChannelHealthCheck(connectionId);
      final idx = _channels.indexWhere((c) => c.connectionId == connectionId);
      if (idx != -1) _channels[idx] = updated;
      _actionSuccessMessage = 'اكتمل فحص سلامة القناة';
      return updated;
    } on ApiErrorEnvelope catch (e) {
      _actionError = e.error.message;
      _lastRequestId = e.requestId;
      return null;
    } on NetworkException catch (e) {
      _actionError = e.message;
      return null;
    } catch (e) {
      _actionError = e.toString();
      return null;
    } finally {
      _isCheckingChannelHealth = false;
      notifyListeners();
    }
  }

  // ==========================================
  // 3. AI Operations & Kill Switch
  // ==========================================
  PlatformAIOverviewView? _aiOverview;
  PlatformAIUsageOverviewView? _aiUsage;
  PlatformAIHealthCheckResult? _latestAIHealthCheck;
  bool _isLoadingAI = false;
  bool _isTogglingAI = false;
  bool _isCheckingAIHealth = false;
  String? _aiError;

  PlatformAIOverviewView? get aiOverview => _aiOverview;
  PlatformAIUsageOverviewView? get aiUsage => _aiUsage;
  PlatformAIHealthCheckResult? get latestAIHealthCheck => _latestAIHealthCheck;
  bool get isLoadingAI => _isLoadingAI;
  bool get isTogglingAI => _isTogglingAI;
  bool get isCheckingAIHealth => _isCheckingAIHealth;
  String? get aiError => _aiError;

  Future<void> fetchAIOverview() async {
    _isLoadingAI = true;
    _aiError = null;
    notifyListeners();

    try {
      _aiOverview = await repository.getAIOverview();
      _aiUsage = await repository.getAIUsage();
    } on ApiErrorEnvelope catch (e) {
      _aiError = e.error.message;
      _lastRequestId = e.requestId;
    } on NetworkException catch (e) {
      _aiError = e.message;
    } catch (e) {
      _aiError = e.toString();
    } finally {
      _isLoadingAI = false;
      notifyListeners();
    }
  }

  Future<bool> disableAI({String? reason}) async {
    _isTogglingAI = true;
    _actionError = null;
    notifyListeners();

    try {
      final updated = await repository.disableAI(reason: reason);
      _aiOverview = updated;
      _actionSuccessMessage = 'تم تفعيل قاطع الطوارئ وإيقاف الذكاء الاصطناعي';
      return true;
    } on ApiErrorEnvelope catch (e) {
      _actionError = e.error.message;
      _lastRequestId = e.requestId;
      return false;
    } on NetworkException catch (e) {
      _actionError = e.message;
      return false;
    } catch (e) {
      _actionError = e.toString();
      return false;
    } finally {
      _isTogglingAI = false;
      notifyListeners();
    }
  }

  Future<bool> enableAI() async {
    _isTogglingAI = true;
    _actionError = null;
    notifyListeners();

    try {
      final updated = await repository.enableAI();
      _aiOverview = updated;
      _actionSuccessMessage = 'تمت إعادة تشغيل خدمة الذكاء الاصطناعي بنجاح';
      return true;
    } on ApiErrorEnvelope catch (e) {
      _actionError = e.error.message;
      _lastRequestId = e.requestId;
      return false;
    } on NetworkException catch (e) {
      _actionError = e.message;
      return false;
    } catch (e) {
      _actionError = e.toString();
      return false;
    } finally {
      _isTogglingAI = false;
      notifyListeners();
    }
  }

  Future<PlatformAIHealthCheckResult?> runAIHealthCheck() async {
    _isCheckingAIHealth = true;
    _actionError = null;
    notifyListeners();

    try {
      final res = await repository.runAIHealthCheck();
      _latestAIHealthCheck = res;
      _actionSuccessMessage =
          'فحص الذكاء الاصطناعي: ${res.result} (${res.latencyMs}ms)';
      return res;
    } on ApiErrorEnvelope catch (e) {
      _actionError = e.error.message;
      _lastRequestId = e.requestId;
      return null;
    } on NetworkException catch (e) {
      _actionError = e.message;
      return null;
    } catch (e) {
      _actionError = e.toString();
      return null;
    } finally {
      _isCheckingAIHealth = false;
      notifyListeners();
    }
  }

  // ==========================================
  // 4. Plans State
  // ==========================================
  List<PlanView> _plans = [];
  bool _isLoadingPlans = false;
  String? _plansError;
  String _planStatusFilter = 'all';

  List<PlanView> get plans {
    if (_planStatusFilter == 'all') return _plans;
    return _plans
        .where((p) => p.status.toLowerCase() == _planStatusFilter.toLowerCase())
        .toList();
  }

  List<PlanView> get rawPlans => _plans;
  bool get isLoadingPlans => _isLoadingPlans;
  String? get plansError => _plansError;
  String get planStatusFilter => _planStatusFilter;

  void setPlanFilter(String status) {
    _planStatusFilter = status;
    notifyListeners();
  }

  Future<void> fetchPlans({bool refresh = false}) async {
    _isLoadingPlans = true;
    _plansError = null;
    notifyListeners();

    try {
      final page = await repository.listPlans(
        status: _planStatusFilter != 'all' ? _planStatusFilter : null,
      );
      _plans = page.items;
      _lastRequestId = page.requestId;
    } on ApiErrorEnvelope catch (e) {
      _plansError = e.error.message;
      _lastRequestId = e.requestId;
    } on NetworkException catch (e) {
      _plansError = e.message;
    } catch (e) {
      _plansError = e.toString();
    } finally {
      _isLoadingPlans = false;
      notifyListeners();
    }
  }

  Future<bool> createPlan(PlatformCreatePlanRequest request) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final plan = await repository.createPlan(request);
      _plans.insert(0, plan);
      _actionSuccessMessage = 'تم إنشاء الخطة كمسودة';
      return true;
    } on ApiErrorEnvelope catch (e) {
      _actionError = e.error.message;
      _lastRequestId = e.requestId;
      return false;
    } on NetworkException catch (e) {
      _actionError = e.message;
      return false;
    } catch (e) {
      _actionError = e.toString();
      return false;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<bool> activatePlan(String planId) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final updated = await repository.activatePlan(planId);
      final idx = _plans.indexWhere((p) => p.id == planId);
      if (idx != -1) _plans[idx] = updated;
      _actionSuccessMessage = 'تم تفعيل الخطة بنجاح';
      return true;
    } on ApiErrorEnvelope catch (e) {
      _actionError = e.error.message;
      _lastRequestId = e.requestId;
      return false;
    } on NetworkException catch (e) {
      _actionError = e.message;
      return false;
    } catch (e) {
      _actionError = e.toString();
      return false;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<bool> retirePlan(String planId) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final updated = await repository.retirePlan(planId);
      final idx = _plans.indexWhere((p) => p.id == planId);
      if (idx != -1) _plans[idx] = updated;
      _actionSuccessMessage = 'تمت إحالة الخطة للتقاعد';
      return true;
    } on ApiErrorEnvelope catch (e) {
      _actionError = e.error.message;
      _lastRequestId = e.requestId;
      return false;
    } on NetworkException catch (e) {
      _actionError = e.message;
      return false;
    } catch (e) {
      _actionError = e.toString();
      return false;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  // ==========================================
  // 5. Subscriptions & Payments State
  // ==========================================
  List<SubscriptionView> _subscriptions = [];
  bool _isLoadingSubscriptions = false;
  String? _subscriptionsError;

  List<PaymentView> _payments = [];
  bool _isLoadingPayments = false;
  String? _paymentsError;

  List<SubscriptionView> get subscriptions => _subscriptions;
  bool get isLoadingSubscriptions => _isLoadingSubscriptions;
  String? get subscriptionsError => _subscriptionsError;

  List<PaymentView> get payments => _payments;
  bool get isLoadingPayments => _isLoadingPayments;
  String? get paymentsError => _paymentsError;

  Future<void> fetchSubscriptions({bool refresh = false}) async {
    _isLoadingSubscriptions = true;
    _subscriptionsError = null;
    notifyListeners();

    try {
      final page = await repository.listSubscriptions();
      _subscriptions = page.items;
      _lastRequestId = page.requestId;
    } on ApiErrorEnvelope catch (e) {
      _subscriptionsError = e.error.message;
      _lastRequestId = e.requestId;
    } on NetworkException catch (e) {
      _subscriptionsError = e.message;
    } catch (e) {
      _subscriptionsError = e.toString();
    } finally {
      _isLoadingSubscriptions = false;
      notifyListeners();
    }
  }

  Future<bool> cancelSubscription(String subId, {String? reason}) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final updated = await repository.cancelSubscription(
        subId,
        reason: reason,
      );
      final idx = _subscriptions.indexWhere((s) => s.id == subId);
      if (idx != -1) _subscriptions[idx] = updated;
      _actionSuccessMessage = 'تم إلغاء الاشتراك';
      return true;
    } on ApiErrorEnvelope catch (e) {
      _actionError = e.error.message;
      _lastRequestId = e.requestId;
      return false;
    } on NetworkException catch (e) {
      _actionError = e.message;
      return false;
    } catch (e) {
      _actionError = e.toString();
      return false;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<bool> overrideAICostBudget(
    String subId,
    PlatformOverrideBudgetRequest request,
  ) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final updated = await repository.overrideAICostBudget(subId, request);
      final idx = _subscriptions.indexWhere((s) => s.id == subId);
      if (idx != -1) _subscriptions[idx] = updated;
      _actionSuccessMessage = 'تم تحديث ميزانية الذكاء الاصطناعي للاشتراك';
      return true;
    } on ApiErrorEnvelope catch (e) {
      _actionError = e.error.message;
      _lastRequestId = e.requestId;
      return false;
    } on NetworkException catch (e) {
      _actionError = e.message;
      return false;
    } catch (e) {
      _actionError = e.toString();
      return false;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<void> fetchPayments(String subId) async {
    _isLoadingPayments = true;
    _paymentsError = null;
    notifyListeners();

    try {
      final page = await repository.listPayments(subId);
      _payments = page.items;
      _lastRequestId = page.requestId;
    } on ApiErrorEnvelope catch (e) {
      _paymentsError = e.error.message;
      _lastRequestId = e.requestId;
    } on NetworkException catch (e) {
      _paymentsError = e.message;
    } catch (e) {
      _paymentsError = e.toString();
    } finally {
      _isLoadingPayments = false;
      notifyListeners();
    }
  }

  Future<bool> recordPayment(
    String subId,
    PlatformRecordPaymentRequest request,
  ) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final p = await repository.recordPayment(subId, request);
      _payments.insert(0, p);
      _actionSuccessMessage = 'تم تسجيل الدفعة اليدوية بنجاح';
      return true;
    } on ApiErrorEnvelope catch (e) {
      _actionError = e.error.message;
      _lastRequestId = e.requestId;
      return false;
    } on NetworkException catch (e) {
      _actionError = e.message;
      return false;
    } catch (e) {
      _actionError = e.toString();
      return false;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  // ==========================================
  // 6. Support Tickets State
  // ==========================================
  List<SupportTicketView> _tickets = [];
  bool _isLoadingTickets = false;
  String? _ticketsError;
  String _ticketStatusFilter = 'all';

  List<SupportTicketView> get tickets {
    if (_ticketStatusFilter == 'all') return _tickets;
    return _tickets
        .where(
          (t) => t.status.toLowerCase() == _ticketStatusFilter.toLowerCase(),
        )
        .toList();
  }

  List<SupportTicketView> get rawTickets => _tickets;
  bool get isLoadingTickets => _isLoadingTickets;
  String? get ticketsError => _ticketsError;
  String get ticketStatusFilter => _ticketStatusFilter;

  void setTicketFilter(String status) {
    _ticketStatusFilter = status;
    notifyListeners();
  }

  Future<void> fetchTickets({bool refresh = false}) async {
    _isLoadingTickets = true;
    _ticketsError = null;
    notifyListeners();

    try {
      final page = await repository.listTickets(
        status: _ticketStatusFilter != 'all' ? _ticketStatusFilter : null,
      );
      _tickets = page.items;
      _lastRequestId = page.requestId;
    } on ApiErrorEnvelope catch (e) {
      _ticketsError = e.error.message;
      _lastRequestId = e.requestId;
    } on NetworkException catch (e) {
      _ticketsError = e.message;
    } catch (e) {
      _ticketsError = e.toString();
    } finally {
      _isLoadingTickets = false;
      notifyListeners();
    }
  }

  Future<bool> startTicket(String ticketId) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final updated = await repository.startTicket(ticketId);
      final idx = _tickets.indexWhere((t) => t.id == ticketId);
      if (idx != -1) _tickets[idx] = updated;
      _actionSuccessMessage = 'بدأ العمل على التذكرة';
      return true;
    } on ApiErrorEnvelope catch (e) {
      _actionError = e.error.message;
      _lastRequestId = e.requestId;
      return false;
    } on NetworkException catch (e) {
      _actionError = e.message;
      return false;
    } catch (e) {
      _actionError = e.toString();
      return false;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<bool> resolveTicket(String ticketId) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final updated = await repository.resolveTicket(ticketId);
      final idx = _tickets.indexWhere((t) => t.id == ticketId);
      if (idx != -1) _tickets[idx] = updated;
      _actionSuccessMessage = 'تم تحديد التذكرة كمحلولة';
      return true;
    } on ApiErrorEnvelope catch (e) {
      _actionError = e.error.message;
      _lastRequestId = e.requestId;
      return false;
    } on NetworkException catch (e) {
      _actionError = e.message;
      return false;
    } catch (e) {
      _actionError = e.toString();
      return false;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<bool> closeTicket(String ticketId) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final updated = await repository.closeTicket(ticketId);
      final idx = _tickets.indexWhere((t) => t.id == ticketId);
      if (idx != -1) _tickets[idx] = updated;
      _actionSuccessMessage = 'تم إغلاق التذكرة نهائيًا';
      return true;
    } on ApiErrorEnvelope catch (e) {
      _actionError = e.error.message;
      _lastRequestId = e.requestId;
      return false;
    } on NetworkException catch (e) {
      _actionError = e.message;
      return false;
    } catch (e) {
      _actionError = e.toString();
      return false;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<bool> appendTicketMessage(String ticketId, String text) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final updated = await repository.appendTicketMessage(
        ticketId,
        PlatformTicketMessageRequest(body: text),
      );
      final idx = _tickets.indexWhere((t) => t.id == ticketId);
      if (idx != -1) _tickets[idx] = updated;
      _actionSuccessMessage = 'تم إرسال الرد على التذكرة';
      return true;
    } on ApiErrorEnvelope catch (e) {
      _actionError = e.error.message;
      _lastRequestId = e.requestId;
      return false;
    } on NetworkException catch (e) {
      _actionError = e.message;
      return false;
    } catch (e) {
      _actionError = e.toString();
      return false;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  // ==========================================
  // 7. Platform Audit Trail State
  // ==========================================
  List<PlatformAuditEventView> _auditEvents = [];
  bool _isLoadingAudit = false;
  String? _auditError;

  List<PlatformAuditEventView> get auditEvents => _auditEvents;
  bool get isLoadingAudit => _isLoadingAudit;
  String? get auditError => _auditError;

  Future<void> fetchAuditEvents({bool refresh = false}) async {
    _isLoadingAudit = true;
    _auditError = null;
    notifyListeners();

    try {
      final page = await repository.listAuditEvents();
      _auditEvents = page.items;
      _lastRequestId = page.requestId;
    } on ApiErrorEnvelope catch (e) {
      _auditError = e.error.message;
      _lastRequestId = e.requestId;
    } on NetworkException catch (e) {
      _auditError = e.message;
    } catch (e) {
      _auditError = e.toString();
    } finally {
      _isLoadingAudit = false;
      notifyListeners();
    }
  }
}
