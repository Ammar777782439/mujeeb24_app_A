import 'package:flutter/foundation.dart';
import 'package:mujeeb24_app/core/crm/crm_repository.dart';
import 'package:mujeeb24_app/core/errors/api_error.dart';
import 'package:mujeeb24_app/core/models/crm_models.dart';
import 'package:mujeeb24_app/core/models/merchant_models.dart';

/// State management Provider for Phase 3 CRM (Customers and Leads)
class CrmProvider extends ChangeNotifier {
  final CrmRepository crmRepository;

  // Customers state
  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  List<Conversation> _customerConversations = [];
  List<CommercialTransaction> _customerTransactions = [];

  bool _isLoadingCustomers = false;
  bool _isLoadingCustomerDetail = false;
  bool _isLoadingCustomerConversations = false;
  bool _isLoadingCustomerTransactions = false;

  String? _customersError;
  String? _customerDetailError;
  String? _customerConversationsError;
  String? _customerTransactionsError;
  String _customerFilterStatus = 'all';
  String _customerSearchQuery = '';

  // Leads state
  List<Lead> _leads = [];
  Lead? _selectedLead;
  List<LeadScore> _leadScores = [];
  List<LeadAttribution> _leadAttributions = [];

  bool _isLoadingLeads = false;
  bool _isLoadingLeadDetail = false;
  bool _isLoadingLeadScores = false;
  bool _isLoadingLeadAttributions = false;

  String? _leadsError;
  String? _leadDetailError;
  String? _leadScoresError;
  String? _leadAttributionsError;
  String _leadFilterStatus = 'all';
  String _leadFilterScoreBand = 'all';
  String? _leadFilterCustomerId;

  // Actions & Diagnostics
  bool _isPerformingAction = false;
  String? _actionError;
  String? _lastRequestId;

  CrmProvider({required this.crmRepository});

  // Getters - Customers
  List<Customer> get customers => _customers;
  Customer? get selectedCustomer => _selectedCustomer;
  List<Conversation> get customerConversations => _customerConversations;
  List<CommercialTransaction> get customerTransactions => _customerTransactions;

  bool get isLoadingCustomers => _isLoadingCustomers;
  bool get isLoadingCustomerDetail => _isLoadingCustomerDetail;
  bool get isLoadingCustomerConversations => _isLoadingCustomerConversations;
  bool get isLoadingCustomerTransactions => _isLoadingCustomerTransactions;

  String? get customersError => _customersError;
  String? get customerDetailError => _customerDetailError;
  String? get customerConversationsError => _customerConversationsError;
  String? get customerTransactionsError => _customerTransactionsError;
  String get customerFilterStatus => _customerFilterStatus;
  String get customerSearchQuery => _customerSearchQuery;

  // Getters - Leads
  List<Lead> get leads => _leads;
  Lead? get selectedLead => _selectedLead;
  List<LeadScore> get leadScores => _leadScores;
  List<LeadAttribution> get leadAttributions => _leadAttributions;

  bool get isLoadingLeads => _isLoadingLeads;
  bool get isLoadingLeadDetail => _isLoadingLeadDetail;
  bool get isLoadingLeadScores => _isLoadingLeadScores;
  bool get isLoadingLeadAttributions => _isLoadingLeadAttributions;

  String? get leadsError => _leadsError;
  String? get leadDetailError => _leadDetailError;
  String? get leadScoresError => _leadScoresError;
  String? get leadAttributionsError => _leadAttributionsError;
  String get leadFilterStatus => _leadFilterStatus;
  String get leadFilterScoreBand => _leadFilterScoreBand;
  String? get leadFilterCustomerId => _leadFilterCustomerId;

  // Actions
  bool get isPerformingAction => _isPerformingAction;
  String? get actionError => _actionError;
  String? get lastRequestId => _lastRequestId;

  void clearErrors() {
    _customersError = null;
    _customerDetailError = null;
    _customerConversationsError = null;
    _customerTransactionsError = null;
    _leadsError = null;
    _leadDetailError = null;
    _leadScoresError = null;
    _leadAttributionsError = null;
    _actionError = null;
    notifyListeners();
  }

  void clearCustomerDetails() {
    _selectedCustomer = null;
    _customerConversations = [];
    _customerTransactions = [];
    _customerDetailError = null;
    _customerConversationsError = null;
    _customerTransactionsError = null;
    notifyListeners();
  }

  void clearLeadDetails() {
    _selectedLead = null;
    _leadScores = [];
    _leadAttributions = [];
    _leadDetailError = null;
    _leadScoresError = null;
    _leadAttributionsError = null;
    notifyListeners();
  }

  String _extractErrorMessage(dynamic error) {
    if (error is ApiErrorEnvelope) {
      _lastRequestId = error.requestId;
      return error.error.message;
    } else if (error is NetworkException) {
      return error.message;
    }
    return error.toString();
  }

  // ==========================================
  // CUSTOMERS OPERATIONS
  // ==========================================

  void setCustomerFilterStatus(String status) {
    _customerFilterStatus = status;
    notifyListeners();
  }

  void setCustomerSearchQuery(String query) {
    _customerSearchQuery = query;
    notifyListeners();
  }

  Future<void> loadCustomers(
    String businessId, {
    String? search,
    String? status,
  }) async {
    _isLoadingCustomers = true;
    _customersError = null;
    notifyListeners();

    try {
      final activeSearch = search ?? _customerSearchQuery;
      final activeStatus = status ?? _customerFilterStatus;
      _customers = await crmRepository.listCustomers(
        businessId: businessId,
        search: activeSearch.isNotEmpty ? activeSearch : null,
        status: activeStatus != 'all' ? activeStatus : null,
      );
    } catch (e) {
      _customersError = _extractErrorMessage(e);
    } finally {
      _isLoadingCustomers = false;
      notifyListeners();
    }
  }

  Future<void> loadCustomerDetail(String businessId, String customerId) async {
    _isLoadingCustomerDetail = true;
    _customerDetailError = null;
    notifyListeners();

    try {
      _selectedCustomer = await crmRepository.getCustomer(
        businessId: businessId,
        customerId: customerId,
      );
    } catch (e) {
      _customerDetailError = _extractErrorMessage(e);
    } finally {
      _isLoadingCustomerDetail = false;
      notifyListeners();
    }
  }

  Future<void> loadCustomerConversations(
    String businessId,
    String customerId,
  ) async {
    _isLoadingCustomerConversations = true;
    _customerConversationsError = null;
    notifyListeners();

    try {
      _customerConversations = await crmRepository.listCustomerConversations(
        businessId: businessId,
        customerId: customerId,
      );
    } catch (e) {
      _customerConversationsError = _extractErrorMessage(e);
    } finally {
      _isLoadingCustomerConversations = false;
      notifyListeners();
    }
  }

  Future<void> loadCustomerTransactions(
    String businessId,
    String customerId,
  ) async {
    _isLoadingCustomerTransactions = true;
    _customerTransactionsError = null;
    notifyListeners();

    try {
      _customerTransactions = await crmRepository.listCustomerTransactions(
        businessId: businessId,
        customerId: customerId,
      );
    } catch (e) {
      _customerTransactionsError = _extractErrorMessage(e);
    } finally {
      _isLoadingCustomerTransactions = false;
      notifyListeners();
    }
  }

  Future<Customer?> createCustomer(
    String businessId,
    CreateCustomerRequest request, {
    String? idempotencyKey,
  }) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final created = await crmRepository.createCustomer(
        businessId: businessId,
        request: request,
        idempotencyKey: idempotencyKey,
      );
      _customers.insert(0, created);
      return created;
    } catch (e) {
      _actionError = _extractErrorMessage(e);
      return null;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<Customer?> updateCustomer(
    String businessId,
    String customerId,
    UpdateCustomerRequest request, {
    String? ifMatch,
  }) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final matchHeader = ifMatch ?? _selectedCustomer?.resourceVersion;
      final updated = await crmRepository.updateCustomer(
        businessId: businessId,
        customerId: customerId,
        request: request,
        ifMatch: matchHeader,
      );
      _selectedCustomer = updated;

      final idx = _customers.indexWhere((c) => c.id == customerId);
      if (idx != -1) {
        _customers[idx] = updated;
      }
      return updated;
    } catch (e) {
      _actionError = _extractErrorMessage(e);
      return null;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<Customer?> mergeCustomer(
    String businessId,
    String customerId,
    MergeCustomerRequest request, {
    String? ifMatch,
  }) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final matchHeader = ifMatch ?? _selectedCustomer?.resourceVersion;
      final merged = await crmRepository.mergeCustomer(
        businessId: businessId,
        customerId: customerId,
        request: request,
        ifMatch: matchHeader,
      );
      _selectedCustomer = merged;
      // Refresh list to reflect merge
      await loadCustomers(businessId);
      return merged;
    } catch (e) {
      _actionError = _extractErrorMessage(e);
      return null;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  // ==========================================
  // LEADS OPERATIONS
  // ==========================================

  void setLeadFilterStatus(String status) {
    _leadFilterStatus = status;
    notifyListeners();
  }

  void setLeadFilterScoreBand(String band) {
    _leadFilterScoreBand = band;
    notifyListeners();
  }

  void setLeadFilterCustomerId(String? customerId) {
    _leadFilterCustomerId = customerId;
    notifyListeners();
  }

  Future<void> loadLeads(
    String businessId, {
    String? status,
    String? scoreBand,
    String? customerId,
  }) async {
    _isLoadingLeads = true;
    _leadsError = null;
    notifyListeners();

    try {
      final activeStatus = status ?? _leadFilterStatus;
      final activeBand = scoreBand ?? _leadFilterScoreBand;
      final activeCustId = customerId ?? _leadFilterCustomerId;

      _leads = await crmRepository.listLeads(
        businessId: businessId,
        status: activeStatus != 'all' ? activeStatus : null,
        scoreBand: activeBand != 'all' ? activeBand : null,
        customerId: activeCustId,
      );
    } catch (e) {
      _leadsError = _extractErrorMessage(e);
    } finally {
      _isLoadingLeads = false;
      notifyListeners();
    }
  }

  Future<void> loadLeadDetail(String businessId, String leadId) async {
    _isLoadingLeadDetail = true;
    _leadDetailError = null;
    notifyListeners();

    try {
      _selectedLead = await crmRepository.getLead(
        businessId: businessId,
        leadId: leadId,
      );
    } catch (e) {
      _leadDetailError = _extractErrorMessage(e);
    } finally {
      _isLoadingLeadDetail = false;
      notifyListeners();
    }
  }

  Future<void> loadLeadScores(String businessId, String leadId) async {
    _isLoadingLeadScores = true;
    _leadScoresError = null;
    notifyListeners();

    try {
      _leadScores = await crmRepository.listLeadScores(
        businessId: businessId,
        leadId: leadId,
      );
    } catch (e) {
      _leadScoresError = _extractErrorMessage(e);
    } finally {
      _isLoadingLeadScores = false;
      notifyListeners();
    }
  }

  Future<void> loadLeadAttributions(String businessId, String leadId) async {
    _isLoadingLeadAttributions = true;
    _leadAttributionsError = null;
    notifyListeners();

    try {
      _leadAttributions = await crmRepository.listLeadAttributions(
        businessId: businessId,
        leadId: leadId,
      );
    } catch (e) {
      _leadAttributionsError = _extractErrorMessage(e);
    } finally {
      _isLoadingLeadAttributions = false;
      notifyListeners();
    }
  }

  Future<Lead?> createLead(
    String businessId,
    CreateLeadRequest request, {
    String? idempotencyKey,
  }) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final created = await crmRepository.createLead(
        businessId: businessId,
        request: request,
        idempotencyKey: idempotencyKey,
      );
      _leads.insert(0, created);
      return created;
    } catch (e) {
      _actionError = _extractErrorMessage(e);
      return null;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<Lead?> updateLead(
    String businessId,
    String leadId,
    UpdateLeadRequest request, {
    String? ifMatch,
  }) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final matchHeader = ifMatch ?? _selectedLead?.resourceVersion;
      final updated = await crmRepository.updateLead(
        businessId: businessId,
        leadId: leadId,
        request: request,
        ifMatch: matchHeader,
      );
      _selectedLead = updated;

      final idx = _leads.indexWhere((l) => l.id == leadId);
      if (idx != -1) {
        _leads[idx] = updated;
      }
      return updated;
    } catch (e) {
      _actionError = _extractErrorMessage(e);
      return null;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<Lead?> qualifyLead(
    String businessId,
    String leadId, {
    String? reason,
    List<String>? evidenceReferences,
    String? ifMatch,
  }) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final matchHeader = ifMatch ?? _selectedLead?.resourceVersion;
      final qualified = await crmRepository.qualifyLead(
        businessId: businessId,
        leadId: leadId,
        reason: reason,
        evidenceReferences: evidenceReferences,
        ifMatch: matchHeader,
      );
      _selectedLead = qualified;

      final idx = _leads.indexWhere((l) => l.id == leadId);
      if (idx != -1) {
        _leads[idx] = qualified;
      }
      return qualified;
    } catch (e) {
      _actionError = _extractErrorMessage(e);
      return null;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<Lead?> markLeadLost(
    String businessId,
    String leadId,
    String lostReason, {
    String? ifMatch,
  }) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final matchHeader = ifMatch ?? _selectedLead?.resourceVersion;
      final lost = await crmRepository.markLeadLost(
        businessId: businessId,
        leadId: leadId,
        lostReason: lostReason,
        ifMatch: matchHeader,
      );
      _selectedLead = lost;

      final idx = _leads.indexWhere((l) => l.id == leadId);
      if (idx != -1) {
        _leads[idx] = lost;
      }
      return lost;
    } catch (e) {
      _actionError = _extractErrorMessage(e);
      return null;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }
}
