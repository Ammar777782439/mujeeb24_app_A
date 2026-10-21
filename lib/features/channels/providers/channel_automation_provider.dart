import 'package:flutter/foundation.dart';

import '../../../core/channels/channel_automation_repository.dart';
import '../../../core/errors/api_error.dart';
import '../../../core/models/channel_automation_models.dart';
import '../../../core/models/merchant_models.dart';

/// Provider for managing state across Phase 6 modules:
/// - Channel Connections
/// - Inbound Automation Rules
/// - Structured AI Decisions
/// - Reusable Canned Replies
class ChannelAutomationProvider extends ChangeNotifier {
  final ChannelAutomationRepository repository;

  ChannelAutomationProvider({required this.repository});

  // ==========================================
  // Global Action & Diagnostics State
  // ==========================================
  bool _isPerformingAction = false;
  String? _actionError;
  String? _lastRequestId;

  bool get isPerformingAction => _isPerformingAction;
  String? get actionError => _actionError;
  String? get lastRequestId => _lastRequestId;

  // ==========================================
  // Channel Connections State
  // ==========================================
  List<ChannelConnection> _connections = [];
  ChannelConnection? _selectedConnection;
  List<Capability> _connectionCapabilities = [];
  ChannelHistorySummary? _historyPurgePreview;
  bool _isLoadingConnections = false;
  bool _isLoadingConnectionDetail = false;
  String? _connectionsError;
  String _connectionStatusFilter = 'all';

  List<ChannelConnection> get connections => _connections;
  ChannelConnection? get selectedConnection => _selectedConnection;
  List<Capability> get connectionCapabilities => _connectionCapabilities;
  ChannelHistorySummary? get historyPurgePreview => _historyPurgePreview;
  bool get isLoadingConnections => _isLoadingConnections;
  bool get isLoadingConnectionDetail => _isLoadingConnectionDetail;
  String? get connectionsError => _connectionsError;
  String get connectionStatusFilter => _connectionStatusFilter;

  // ==========================================
  // Automation Rules State
  // ==========================================
  List<AutomationRule> _automationRules = [];
  bool _isLoadingRules = false;
  String? _rulesError;
  String _ruleStatusFilter = 'all'; // all | active | disabled

  List<AutomationRule> get automationRules => _automationRules;
  bool get isLoadingRules => _isLoadingRules;
  String? get rulesError => _rulesError;
  String get ruleStatusFilter => _ruleStatusFilter;

  // ==========================================
  // Structured AI Decisions State
  // ==========================================
  List<AIDecision> _aiDecisions = [];
  AIDecision? _selectedDecision;
  bool _isLoadingDecisions = false;
  String? _decisionsError;
  bool? _requiresHumanFilter;

  List<AIDecision> get aiDecisions => _aiDecisions;
  AIDecision? get selectedDecision => _selectedDecision;
  bool get isLoadingDecisions => _isLoadingDecisions;
  String? get decisionsError => _decisionsError;
  bool? get requiresHumanFilter => _requiresHumanFilter;

  // ==========================================
  // Canned Replies State
  // ==========================================
  List<CannedReply> _cannedReplies = [];
  bool _isLoadingCannedReplies = false;
  String? _cannedRepliesError;
  String _cannedStatusFilter = 'all';

  List<CannedReply> get cannedReplies => _cannedReplies;
  bool get isLoadingCannedReplies => _isLoadingCannedReplies;
  String? get cannedRepliesError => _cannedRepliesError;
  String get cannedStatusFilter => _cannedStatusFilter;

  // ==========================================
  // Connections Operations
  // ==========================================

  void setConnectionStatusFilter(String filter) {
    if (_connectionStatusFilter != filter) {
      _connectionStatusFilter = filter;
      notifyListeners();
    }
  }

  void selectConnection(ChannelConnection connection) {
    _selectedConnection = connection;
    notifyListeners();
  }

  Future<void> fetchConnections(
    String businessId, {
    bool refresh = false,
  }) async {
    _isLoadingConnections = true;
    _connectionsError = null;
    notifyListeners();

    try {
      final page = await repository.listChannelConnections(
        businessId: businessId,
        status: _connectionStatusFilter != 'all'
            ? _connectionStatusFilter
            : null,
      );
      _connections = page.items;
    } on ApiErrorEnvelope catch (e) {
      _connectionsError = e.error.message;
      _lastRequestId = e.requestId;
    } on NetworkException catch (e) {
      _connectionsError = e.message;
    } catch (e) {
      _connectionsError = e.toString();
    } finally {
      _isLoadingConnections = false;
      notifyListeners();
    }
  }

  Future<void> fetchConnectionDetail(
    String businessId,
    String connectionId,
  ) async {
    _isLoadingConnectionDetail = true;
    _connectionsError = null;
    notifyListeners();

    try {
      final connection = await repository.getChannelConnection(
        businessId: businessId,
        connectionId: connectionId,
      );
      _selectedConnection = connection;

      final capabilities = await repository.getConnectionCapabilities(
        businessId: businessId,
        connectionId: connectionId,
      );
      _connectionCapabilities = capabilities;
    } on ApiErrorEnvelope catch (e) {
      _connectionsError = e.error.message;
      _lastRequestId = e.requestId;
    } on NetworkException catch (e) {
      _connectionsError = e.message;
    } catch (e) {
      _connectionsError = e.toString();
    } finally {
      _isLoadingConnectionDetail = false;
      notifyListeners();
    }
  }

  Future<ChannelProvisioning?> beginConnection(
    String businessId,
    BeginChannelConnectionRequest request,
  ) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final provisioning = await repository.beginChannelConnection(
        businessId: businessId,
        request: request,
      );
      await fetchConnections(businessId, refresh: true);
      return provisioning;
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
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<ChannelConnection?> reconnectConnection(
    String businessId,
    String connectionId,
    String reason, {
    String? ifMatch,
  }) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final updated = await repository.reconnectChannel(
        businessId: businessId,
        connectionId: connectionId,
        reason: reason,
        ifMatch: ifMatch ?? _selectedConnection?.resourceVersion,
      );
      _selectedConnection = updated;
      final idx = _connections.indexWhere((c) => c.id == connectionId);
      if (idx != -1) {
        _connections[idx] = updated;
      }
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
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<ChannelConnection?> disconnectConnection(
    String businessId,
    String connectionId,
    String reason, {
    String? ifMatch,
  }) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final updated = await repository.disconnectChannel(
        businessId: businessId,
        connectionId: connectionId,
        reason: reason,
        ifMatch: ifMatch ?? _selectedConnection?.resourceVersion,
      );
      _selectedConnection = updated;
      final idx = _connections.indexWhere((c) => c.id == connectionId);
      if (idx != -1) {
        _connections[idx] = updated;
      }
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
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<ChannelHistorySummary?> previewPurge(
    String businessId,
    String connectionId,
  ) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final summary = await repository.previewChannelHistoryPurge(
        businessId: businessId,
        connectionId: connectionId,
      );
      _historyPurgePreview = summary;
      return summary;
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
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<ChannelHistorySummary?> executePurge(
    String businessId,
    String connectionId, {
    required String expectedVersion,
    String confirmation = PurgeChannelHistoryRequest.requiredConfirmation,
  }) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final summary = await repository.purgeChannelHistory(
        businessId: businessId,
        connectionId: connectionId,
        expectedVersion: expectedVersion,
        confirmation: confirmation,
        ifMatch: expectedVersion,
      );
      _historyPurgePreview = summary;
      return summary;
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
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  // ==========================================
  // Automation Rules Operations
  // ==========================================

  void setRuleStatusFilter(String filter) {
    if (_ruleStatusFilter != filter) {
      _ruleStatusFilter = filter;
      notifyListeners();
    }
  }

  Future<void> fetchAutomationRules(
    String businessId, {
    bool refresh = false,
  }) async {
    _isLoadingRules = true;
    _rulesError = null;
    notifyListeners();

    try {
      final page = await repository.listAutomationRules(
        businessId: businessId,
        status: _ruleStatusFilter != 'all' ? _ruleStatusFilter : null,
      );
      _automationRules = page.items;
    } on ApiErrorEnvelope catch (e) {
      _rulesError = e.error.message;
      _lastRequestId = e.requestId;
    } on NetworkException catch (e) {
      _rulesError = e.message;
    } catch (e) {
      _rulesError = e.toString();
    } finally {
      _isLoadingRules = false;
      notifyListeners();
    }
  }

  Future<AutomationRule?> createRule(
    String businessId,
    CreateAutomationRuleRequest request,
  ) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final created = await repository.createAutomationRule(
        businessId: businessId,
        request: request,
      );
      _automationRules.insert(0, created);
      return created;
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
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<AutomationRule?> updateRule(
    String businessId,
    String ruleId,
    UpdateAutomationRuleRequest request, {
    String? ifMatch,
  }) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final updated = await repository.updateAutomationRule(
        businessId: businessId,
        automationRuleId: ruleId,
        request: request,
        ifMatch: ifMatch,
      );
      final idx = _automationRules.indexWhere((r) => r.id == ruleId);
      if (idx != -1) {
        _automationRules[idx] = updated;
      }
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
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  // ==========================================
  // AI Decisions Operations
  // ==========================================

  void setRequiresHumanFilter(bool? filter) {
    if (_requiresHumanFilter != filter) {
      _requiresHumanFilter = filter;
      notifyListeners();
    }
  }

  void selectDecision(AIDecision decision) {
    _selectedDecision = decision;
    notifyListeners();
  }

  Future<void> fetchAIDecisions(
    String businessId, {
    bool refresh = false,
  }) async {
    _isLoadingDecisions = true;
    _decisionsError = null;
    notifyListeners();

    try {
      final page = await repository.listAIDecisions(
        businessId: businessId,
        requiresHuman: _requiresHumanFilter,
      );
      _aiDecisions = page.items;
    } on ApiErrorEnvelope catch (e) {
      _decisionsError = e.error.message;
      _lastRequestId = e.requestId;
    } on NetworkException catch (e) {
      _decisionsError = e.message;
    } catch (e) {
      _decisionsError = e.toString();
    } finally {
      _isLoadingDecisions = false;
      notifyListeners();
    }
  }

  Future<AIDecision?> requestHuman(
    String businessId,
    String decisionId,
    String reason,
  ) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final updated = await repository.requestHumanReview(
        businessId: businessId,
        decisionId: decisionId,
        reason: reason,
      );
      _selectedDecision = updated;
      final idx = _aiDecisions.indexWhere((d) => d.id == decisionId);
      if (idx != -1) {
        _aiDecisions[idx] = updated;
      }
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
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  // ==========================================
  // Canned Replies Operations
  // ==========================================

  void setCannedStatusFilter(String filter) {
    if (_cannedStatusFilter != filter) {
      _cannedStatusFilter = filter;
      notifyListeners();
    }
  }

  Future<void> fetchCannedReplies(
    String businessId, {
    bool refresh = false,
  }) async {
    _isLoadingCannedReplies = true;
    _cannedRepliesError = null;
    notifyListeners();

    try {
      final list = await repository.listCannedReplies(
        businessId: businessId,
        status: _cannedStatusFilter != 'all' ? _cannedStatusFilter : null,
      );
      _cannedReplies = list;
    } on ApiErrorEnvelope catch (e) {
      _cannedRepliesError = e.error.message;
      _lastRequestId = e.requestId;
    } on NetworkException catch (e) {
      _cannedRepliesError = e.message;
    } catch (e) {
      _cannedRepliesError = e.toString();
    } finally {
      _isLoadingCannedReplies = false;
      notifyListeners();
    }
  }

  Future<CannedReply?> createReply(
    String businessId,
    CreateCannedReplyRequest request,
  ) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final created = await repository.createCannedReply(
        businessId: businessId,
        request: request,
      );
      _cannedReplies.insert(0, created);
      return created;
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
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  Future<CannedReply?> updateReply(
    String businessId,
    String replyId,
    UpdateCannedReplyRequest request, {
    String? ifMatch,
  }) async {
    _isPerformingAction = true;
    _actionError = null;
    notifyListeners();

    try {
      final updated = await repository.updateCannedReply(
        businessId: businessId,
        cannedReplyId: replyId,
        request: request,
        ifMatch: ifMatch,
      );
      final idx = _cannedReplies.indexWhere((r) => r.id == replyId);
      if (idx != -1) {
        _cannedReplies[idx] = updated;
      }
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
      _isPerformingAction = false;
      notifyListeners();
    }
  }
}
