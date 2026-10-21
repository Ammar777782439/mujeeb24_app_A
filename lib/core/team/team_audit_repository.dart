import '../api/api_client.dart';
import '../models/team_audit_models.dart';

/// Repository for Phase 7:
/// - Team members listing, role updating, access updating, membership revocation
/// - Team invitations listing, creation, resending, and revocation
/// - Team invitation acceptance (authenticated)
/// - Audit events listing, filtering, and detail inspection
class TeamAuditRepository {
  final ApiClient apiClient;

  TeamAuditRepository({required this.apiClient});

  String _generateIdempotencyKey(String prefix) {
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}';
  }

  Map<String, dynamic> _extractDataMap(dynamic response) {
    if (response is Map<String, dynamic>) {
      if (response['data'] is Map) {
        return Map<String, dynamic>.from(response['data'] as Map);
      }
      return response;
    } else if (response is Map) {
      final map = Map<String, dynamic>.from(response);
      if (map['data'] is Map) {
        return Map<String, dynamic>.from(map['data'] as Map);
      }
      return map;
    }
    throw StateError('Unexpected response format: $response');
  }

  // ==========================================
  // Team Members
  // ==========================================

  /// Lists active and revoked team memberships.
  /// `GET /businesses/{business_id}/team/members`
  Future<TeamMemberPage> listTeamMembers({
    required String businessId,
    int limit = 25,
    String? cursor,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit.toString()};
    if (cursor != null && cursor.isNotEmpty) {
      queryParams['cursor'] = cursor;
    }

    final response = await apiClient.get(
      '/businesses/$businessId/team/members',
      queryParameters: queryParams,
      requiresAuth: true,
    );

    return TeamMemberPage.fromJson(
      response is Map<String, dynamic>
          ? response
          : Map<String, dynamic>.from(response as Map),
    );
  }

  /// Updates a non-owner team member role.
  /// `PATCH /businesses/{business_id}/team/members/{principal_id}/role`
  Future<TeamMember> updateTeamMemberRole({
    required String businessId,
    required String principalId,
    required UpdateTeamMemberRoleRequest request,
    String? ifMatch,
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key': idempotencyKey ?? _generateIdempotencyKey('team_role'),
    };
    if (ifMatch != null && ifMatch.isNotEmpty) {
      headers['If-Match'] = ifMatch;
    }

    final response = await apiClient.patch(
      '/businesses/$businessId/team/members/$principalId/role',
      body: request.toJson(),
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return TeamMember.fromJson(data);
  }

  /// Updates a non-owner team member role and permissions.
  /// `PATCH /businesses/{business_id}/team/members/{principal_id}/access`
  Future<TeamMember> updateTeamMemberAccess({
    required String businessId,
    required String principalId,
    required UpdateTeamMemberAccessRequest request,
    String? ifMatch,
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('team_access'),
    };
    if (ifMatch != null && ifMatch.isNotEmpty) {
      headers['If-Match'] = ifMatch;
    }

    final response = await apiClient.patch(
      '/businesses/$businessId/team/members/$principalId/access',
      body: request.toJson(),
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return TeamMember.fromJson(data);
  }

  /// Revokes a team membership while preserving at least one active owner.
  /// `POST /businesses/{business_id}/team/members/{principal_id}/revoke`
  Future<TeamMember> revokeTeamMember({
    required String businessId,
    required String principalId,
    String? ifMatch,
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('team_revoke'),
    };
    if (ifMatch != null && ifMatch.isNotEmpty) {
      headers['If-Match'] = ifMatch;
    }

    final response = await apiClient.post(
      '/businesses/$businessId/team/members/$principalId/revoke',
      body: <String, dynamic>{},
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return TeamMember.fromJson(data);
  }

  // ==========================================
  // Team Invitations
  // ==========================================

  /// Lists team invitations without exposing tokens.
  /// `GET /businesses/{business_id}/team/invitations`
  Future<TeamInvitationPage> listTeamInvitations({
    required String businessId,
    int limit = 25,
    String? cursor,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit.toString()};
    if (cursor != null && cursor.isNotEmpty) {
      queryParams['cursor'] = cursor;
    }

    final response = await apiClient.get(
      '/businesses/$businessId/team/invitations',
      queryParameters: queryParams,
      requiresAuth: true,
    );

    return TeamInvitationPage.fromJson(
      response is Map<String, dynamic>
          ? response
          : Map<String, dynamic>.from(response as Map),
    );
  }

  /// Creates a one-time team invitation.
  /// `POST /businesses/{business_id}/team/invitations`
  Future<TeamInvitationCreated> createTeamInvitation({
    required String businessId,
    required CreateTeamInvitationRequest request,
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('team_inv_create'),
    };

    final response = await apiClient.post(
      '/businesses/$businessId/team/invitations',
      body: request.toJson(),
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return TeamInvitationCreated.fromJson(data);
  }

  /// Issues a new token and invitation.
  /// `POST /businesses/{business_id}/team/invitations/{invitation_id}/resend`
  Future<TeamInvitationCreated> resendTeamInvitation({
    required String businessId,
    required String invitationId,
    int? expiresInHours,
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('team_inv_resend'),
    };
    final body = <String, dynamic>{'expires_in_hours': ?expiresInHours};

    final response = await apiClient.post(
      '/businesses/$businessId/team/invitations/$invitationId/resend',
      body: body,
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return TeamInvitationCreated.fromJson(data);
  }

  /// Revokes a pending invitation.
  /// `POST /businesses/{business_id}/team/invitations/{invitation_id}/revoke`
  Future<TeamInvitationDetails> revokeTeamInvitation({
    required String businessId,
    required String invitationId,
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('team_inv_revoke'),
    };

    final response = await apiClient.post(
      '/businesses/$businessId/team/invitations/$invitationId/revoke',
      body: <String, dynamic>{},
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return TeamInvitationDetails.fromJson(data);
  }

  /// Accepts an invitation using the authenticated principal.
  /// `POST /team/invitations/accept`
  Future<TeamInvitationDetails> acceptTeamInvitation({
    required String acceptanceToken,
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Idempotency-Key':
          idempotencyKey ?? _generateIdempotencyKey('team_inv_accept'),
    };

    final response = await apiClient.post(
      '/team/invitations/accept',
      body: {'acceptance_token': acceptanceToken},
      headers: headers,
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return TeamInvitationDetails.fromJson(data);
  }

  // ==========================================
  // Audit Events
  // ==========================================

  /// Lists security and operational audit events for a business.
  /// `GET /businesses/{business_id}/audit-events`
  Future<AuditEventPage> listAuditEvents({
    required String businessId,
    int limit = 25,
    String? cursor,
    String? actorType,
    String? action,
    String? resourceType,
    String? from,
    String? until,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit.toString()};
    if (cursor != null && cursor.isNotEmpty) queryParams['cursor'] = cursor;
    if (actorType != null && actorType.isNotEmpty && actorType != 'all') {
      queryParams['actor_type'] = actorType;
    }
    if (action != null && action.isNotEmpty && action != 'all') {
      queryParams['action'] = action;
    }
    if (resourceType != null &&
        resourceType.isNotEmpty &&
        resourceType != 'all') {
      queryParams['resource_type'] = resourceType;
    }
    if (from != null && from.isNotEmpty) queryParams['from'] = from;
    if (until != null && until.isNotEmpty) queryParams['until'] = until;

    final response = await apiClient.get(
      '/businesses/$businessId/audit-events',
      queryParameters: queryParams,
      requiresAuth: true,
    );

    return AuditEventPage.fromJson(
      response is Map<String, dynamic>
          ? response
          : Map<String, dynamic>.from(response as Map),
    );
  }

  /// Gets a single audit event projection.
  /// `GET /businesses/{business_id}/audit-events/{audit_event_id}`
  Future<AuditEvent> getAuditEvent({
    required String businessId,
    required String auditEventId,
  }) async {
    final response = await apiClient.get(
      '/businesses/$businessId/audit-events/$auditEventId',
      requiresAuth: true,
    );

    final data = _extractDataMap(response);
    return AuditEvent.fromJson(data);
  }
}
