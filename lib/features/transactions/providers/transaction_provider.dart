import 'package:flutter/foundation.dart';
import 'package:mujeeb24_app/core/errors/api_error.dart';
import 'package:mujeeb24_app/core/models/transaction_models.dart';
import 'package:mujeeb24_app/core/transactions/transaction_repository.dart';

/// State management Provider for Phase 4: Commercial Transactions & Reviews
class TransactionProvider extends ChangeNotifier {
  final TransactionRepository transactionRepository;

  // Transactions list state
  List<CommercialTransaction> _transactions = [];
  bool _isLoadingTransactions = false;
  bool _isLoadingMore = false;
  String? _transactionsError;
  bool _hasMore = false;
  String? _nextCursor;

  // Active filters
  String _stateFilter = 'all';
  String _transactionTypeFilter = 'all';
  String? _customerIdFilter;
  String _searchQuery = '';

  // Selected Transaction & Detail state
  CommercialTransaction? _selectedTransaction;
  bool _isLoadingTransactionDetail = false;
  String? _transactionDetailError;

  // Review state
  TransactionReview? _selectedReview;
  bool _isLoadingTransactionReview = false;
  String? _transactionReviewError;

  // Actions & Mutation State
  bool _isPerformingAction = false;
  String? _actionError;
  String? _lastRequestId;

  TransactionProvider({required this.transactionRepository});

  // Getters - List & Filters
  List<CommercialTransaction> get transactions => _transactions;
  bool get isLoadingTransactions => _isLoadingTransactions;
  bool get isLoadingMore => _isLoadingMore;
  String? get transactionsError => _transactionsError;
  bool get hasMore => _hasMore;
  String? get nextCursor => _nextCursor;

  String get stateFilter => _stateFilter;
  String get transactionTypeFilter => _transactionTypeFilter;
  String? get customerIdFilter => _customerIdFilter;
  String get searchQuery => _searchQuery;

  // Getters - Detail & Review
  CommercialTransaction? get selectedTransaction => _selectedTransaction;
  bool get isLoadingTransactionDetail => _isLoadingTransactionDetail;
  String? get transactionDetailError => _transactionDetailError;

  TransactionReview? get selectedReview => _selectedReview;
  bool get isLoadingTransactionReview => _isLoadingTransactionReview;
  String? get transactionReviewError => _transactionReviewError;

  // Getters - Action
  bool get isPerformingAction => _isPerformingAction;
  String? get actionError => _actionError;
  String? get lastRequestId => _lastRequestId;

  /// Filtered list of transactions by search query (ID, Customer ID, Lead ID, Type, State)
  List<CommercialTransaction> get filteredTransactions {
    if (_searchQuery.trim().isEmpty) {
      return _transactions;
    }
    final q = _searchQuery.trim().toLowerCase();
    return _transactions.where((tx) {
      return tx.id.toLowerCase().contains(q) ||
          tx.customerId.toLowerCase().contains(q) ||
          (tx.leadId != null && tx.leadId!.toLowerCase().contains(q)) ||
          tx.transactionType.toLowerCase().contains(q) ||
          tx.state.toLowerCase().contains(q);
    }).toList();
  }

  void setStateFilter(String state) {
    if (_stateFilter != state) {
      _stateFilter = state;
      notifyListeners();
    }
  }

  void setTransactionTypeFilter(String type) {
    if (_transactionTypeFilter != type) {
      _transactionTypeFilter = type;
      notifyListeners();
    }
  }

  void setCustomerIdFilter(String? customerId) {
    if (_customerIdFilter != customerId) {
      _customerIdFilter = customerId;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  int get activeFiltersCount {
    int count = 0;
    if (_stateFilter != 'all') count++;
    if (_transactionTypeFilter != 'all') count++;
    if (_customerIdFilter != null && _customerIdFilter!.isNotEmpty) count++;
    if (_searchQuery.trim().isNotEmpty) count++;
    return count;
  }

  void clearFilters(String businessId) {
    _stateFilter = 'all';
    _transactionTypeFilter = 'all';
    _customerIdFilter = null;
    _searchQuery = '';
    notifyListeners();
    if (businessId.isNotEmpty) {
      loadTransactions(businessId, refresh: true);
    }
  }

  void clearTransactionDetail() {
    _selectedTransaction = null;
    _selectedReview = null;
    _transactionDetailError = null;
    _transactionReviewError = null;
    _actionError = null;
    notifyListeners();
  }

  void clearErrors() {
    _transactionsError = null;
    _transactionDetailError = null;
    _transactionReviewError = null;
    _actionError = null;
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
  // FETCH TRANSACTIONS & DETAILS
  // ==========================================

  /// Load transactions list with active filters
  Future<void> loadTransactions(
    String businessId, {
    bool refresh = false,
  }) async {
    if (businessId.isEmpty) {
      return;
    }

    _isLoadingTransactions = true;
    _transactionsError = null;
    notifyListeners();

    try {
      final page = await transactionRepository.listTransactions(
        businessId: businessId,
        state: _stateFilter,
        transactionType: _transactionTypeFilter,
        customerId: _customerIdFilter,
        limit: 25,
      );

      _transactions = page.items;
      _hasMore = page.hasMore;
      _nextCursor = page.nextCursor;
      if (page.requestId != null && page.requestId!.isNotEmpty) {
        _lastRequestId = page.requestId;
      }
    } catch (e) {
      _transactionsError = _extractErrorMessage(e);
    } finally {
      _isLoadingTransactions = false;
      notifyListeners();
    }
  }

  /// Load more transactions for pagination
  Future<void> loadMoreTransactions(String businessId) async {
    if (businessId.isEmpty ||
        !_hasMore ||
        _isLoadingMore ||
        _isLoadingTransactions ||
        _nextCursor == null) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final page = await transactionRepository.listTransactions(
        businessId: businessId,
        state: _stateFilter,
        transactionType: _transactionTypeFilter,
        customerId: _customerIdFilter,
        cursor: _nextCursor,
        limit: 25,
      );

      _transactions.addAll(page.items);
      _hasMore = page.hasMore;
      _nextCursor = page.nextCursor;
      if (page.requestId != null && page.requestId!.isNotEmpty) {
        _lastRequestId = page.requestId;
      }
    } catch (e) {
      _transactionsError = _extractErrorMessage(e);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Load single transaction details
  Future<void> loadTransactionDetail(
    String businessId,
    String transactionId,
  ) async {
    _isLoadingTransactionDetail = true;
    _transactionDetailError = null;
    notifyListeners();

    try {
      final tx = await transactionRepository.getTransaction(
        businessId: businessId,
        transactionId: transactionId,
      );
      _selectedTransaction = tx;

      // Update in cached list if present
      final idx = _transactions.indexWhere((t) => t.id == transactionId);
      if (idx != -1) {
        _transactions[idx] = tx;
      }
    } catch (e) {
      _transactionDetailError = _extractErrorMessage(e);
    } finally {
      _isLoadingTransactionDetail = false;
      notifyListeners();
    }
  }

  /// Load review information for transaction
  Future<void> loadTransactionReview(
    String businessId,
    String transactionId,
  ) async {
    _isLoadingTransactionReview = true;
    _transactionReviewError = null;
    notifyListeners();

    try {
      final review = await transactionRepository.getTransactionReview(
        businessId: businessId,
        transactionId: transactionId,
      );
      _selectedReview = review;
    } catch (e) {
      _transactionReviewError = _extractErrorMessage(e);
    } finally {
      _isLoadingTransactionReview = false;
      notifyListeners();
    }
  }

  // ==========================================
  // MUTATIONS (Idempotency & Concurrency)
  // ==========================================

  /// Create a new transaction draft
  Future<CommercialTransaction?> createDraft(
    String businessId,
    CreateTransactionDraftRequest request, {
    String? idempotencyKey,
  }) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final created = await transactionRepository.createTransactionDraft(
        businessId: businessId,
        request: request,
        idempotencyKey: idempotencyKey,
      );

      _transactions.insert(0, created);
      _selectedTransaction = created;
      return created;
    } catch (e) {
      _actionError = _extractErrorMessage(e);
      return null;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  /// Update an existing transaction draft (requires If-Match)
  Future<CommercialTransaction?> updateDraft(
    String businessId,
    String transactionId,
    UpdateTransactionDraftRequest request, {
    String? ifMatch,
    String? idempotencyKey,
  }) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final matchHeader = ifMatch ?? _selectedTransaction?.resourceVersion;
      if (matchHeader == null || matchHeader.isEmpty) {
        throw StateError('If-Match resource version is required for draft update');
      }

      final updated = await transactionRepository.updateTransactionDraft(
        businessId: businessId,
        transactionId: transactionId,
        request: request,
        ifMatch: matchHeader,
        idempotencyKey: idempotencyKey,
      );

      _selectedTransaction = updated;
      final idx = _transactions.indexWhere((t) => t.id == transactionId);
      if (idx != -1) {
        _transactions[idx] = updated;
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

  /// Submit a draft transaction for review (requires If-Match)
  Future<TransactionReview?> submitForReview(
    String businessId,
    String transactionId,
    List<String> reasonCodes, {
    String? ifMatch,
    String? idempotencyKey,
  }) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final matchHeader = ifMatch ?? _selectedTransaction?.resourceVersion;
      if (matchHeader == null || matchHeader.isEmpty) {
        throw StateError('If-Match resource version is required to submit review');
      }

      final review = await transactionRepository.submitTransactionReview(
        businessId: businessId,
        transactionId: transactionId,
        request: SubmitReviewRequest(reasonCodes: reasonCodes),
        ifMatch: matchHeader,
        idempotencyKey: idempotencyKey,
      );

      _selectedReview = review;
      // Refresh transaction details to reflect transition to 'review' state
      await loadTransactionDetail(businessId, transactionId);
      return review;
    } catch (e) {
      _actionError = _extractErrorMessage(e);
      return null;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  /// Approve a pending review (requires If-Match)
  Future<TransactionReview?> approveReview(
    String businessId,
    String transactionId,
    String reviewerReference, {
    String? reason,
    String? ifMatch,
    String? idempotencyKey,
  }) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final matchHeader = ifMatch ?? _selectedTransaction?.resourceVersion;
      if (matchHeader == null || matchHeader.isEmpty) {
        throw StateError('If-Match resource version is required to approve review');
      }

      final review = await transactionRepository.approveTransactionReview(
        businessId: businessId,
        transactionId: transactionId,
        request: ReviewDecisionRequest(
          reviewerReference: reviewerReference,
          reason: reason,
        ),
        ifMatch: matchHeader,
        idempotencyKey: idempotencyKey,
      );

      _selectedReview = review;
      await loadTransactionDetail(businessId, transactionId);
      return review;
    } catch (e) {
      _actionError = _extractErrorMessage(e);
      return null;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  /// Reject a pending review (requires If-Match)
  Future<TransactionReview?> rejectReview(
    String businessId,
    String transactionId,
    String reviewerReference, {
    String? reason,
    String? ifMatch,
    String? idempotencyKey,
  }) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final matchHeader = ifMatch ?? _selectedTransaction?.resourceVersion;
      if (matchHeader == null || matchHeader.isEmpty) {
        throw StateError('If-Match resource version is required to reject review');
      }

      final review = await transactionRepository.rejectTransactionReview(
        businessId: businessId,
        transactionId: transactionId,
        request: ReviewDecisionRequest(
          reviewerReference: reviewerReference,
          reason: reason,
        ),
        ifMatch: matchHeader,
        idempotencyKey: idempotencyKey,
      );

      _selectedReview = review;
      await loadTransactionDetail(businessId, transactionId);
      return review;
    } catch (e) {
      _actionError = _extractErrorMessage(e);
      return null;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  /// Confirm transaction (requires If-Match)
  Future<CommercialTransaction?> confirmTransaction(
    String businessId,
    String transactionId,
    String evidenceReference, {
    String? policyVersion,
    String? ifMatch,
    String? idempotencyKey,
  }) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final matchHeader = ifMatch ?? _selectedTransaction?.resourceVersion;
      if (matchHeader == null || matchHeader.isEmpty) {
        throw StateError('If-Match resource version is required to confirm transaction');
      }

      final confirmed = await transactionRepository.confirmTransaction(
        businessId: businessId,
        transactionId: transactionId,
        request: ConfirmTransactionRequest(
          evidenceReference: evidenceReference,
          policyVersion: policyVersion,
        ),
        ifMatch: matchHeader,
        idempotencyKey: idempotencyKey,
      );

      _selectedTransaction = confirmed;
      final idx = _transactions.indexWhere((t) => t.id == transactionId);
      if (idx != -1) {
        _transactions[idx] = confirmed;
      }
      return confirmed;
    } catch (e) {
      _actionError = _extractErrorMessage(e);
      return null;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  /// Cancel transaction (requires If-Match)
  Future<CommercialTransaction?> cancelTransaction(
    String businessId,
    String transactionId,
    String reason, {
    String? ifMatch,
    String? idempotencyKey,
  }) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final matchHeader = ifMatch ?? _selectedTransaction?.resourceVersion;
      if (matchHeader == null || matchHeader.isEmpty) {
        throw StateError('If-Match resource version is required to cancel transaction');
      }

      final cancelled = await transactionRepository.cancelTransaction(
        businessId: businessId,
        transactionId: transactionId,
        request: TransactionReasonRequest(reason: reason),
        ifMatch: matchHeader,
        idempotencyKey: idempotencyKey,
      );

      _selectedTransaction = cancelled;
      final idx = _transactions.indexWhere((t) => t.id == transactionId);
      if (idx != -1) {
        _transactions[idx] = cancelled;
      }
      return cancelled;
    } catch (e) {
      _actionError = _extractErrorMessage(e);
      return null;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }
}
