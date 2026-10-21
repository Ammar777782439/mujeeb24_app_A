import 'package:mujeeb24_app/core/models/auth_models.dart';

/// Available team roles in Mujeeb24 contract
class TeamRoles {
  static const String owner = 'owner';
  static const String admin = 'admin';
  static const String manager = 'manager';
  static const String agent = 'agent';
  static const String analyst = 'analyst';
  static const String viewer = 'viewer';

  static const List<String> assignableRoles = [
    admin,
    manager,
    agent,
    analyst,
    viewer,
  ];

  static const List<String> allRoles = [
    owner,
    admin,
    manager,
    agent,
    analyst,
    viewer,
  ];

  /// Preset permissions for each assignable role
  static List<String> defaultPermissionsForRole(String role) {
    switch (role) {
      case admin:
        return List<String>.from(TeamPermissions.all);
      case manager:
        return [
          TeamPermissions.dashboardRead,
          TeamPermissions.conversationsRead,
          TeamPermissions.conversationsReply,
          TeamPermissions.conversationsAssign,
          TeamPermissions.customersRead,
          TeamPermissions.customersWrite,
          TeamPermissions.salesRead,
          TeamPermissions.salesWrite,
          TeamPermissions.salesApprove,
          TeamPermissions.catalogRead,
          TeamPermissions.catalogWrite,
          TeamPermissions.channelsRead,
          TeamPermissions.automationRead,
          TeamPermissions.automationManage,
          TeamPermissions.teamRead,
          TeamPermissions.auditRead,
          TeamPermissions.merchantAiUse,
        ];
      case agent:
        return [
          TeamPermissions.dashboardRead,
          TeamPermissions.conversationsRead,
          TeamPermissions.conversationsReply,
          TeamPermissions.customersRead,
          TeamPermissions.catalogRead,
          TeamPermissions.salesRead,
          TeamPermissions.salesWrite,
          TeamPermissions.merchantAiUse,
        ];
      case analyst:
        return [
          TeamPermissions.dashboardRead,
          TeamPermissions.conversationsRead,
          TeamPermissions.customersRead,
          TeamPermissions.salesRead,
          TeamPermissions.catalogRead,
          TeamPermissions.channelsRead,
          TeamPermissions.automationRead,
          TeamPermissions.auditRead,
        ];
      case viewer:
        return [
          TeamPermissions.dashboardRead,
          TeamPermissions.conversationsRead,
          TeamPermissions.customersRead,
          TeamPermissions.catalogRead,
          TeamPermissions.salesRead,
        ];
      default:
        return [TeamPermissions.dashboardRead];
    }
  }
}

/// Available permissions in Mujeeb24 OpenAPI schema
class TeamPermissions {
  static const String auditRead = 'audit:read';
  static const String automationManage = 'automation:manage';
  static const String automationRead = 'automation:read';
  static const String businessRead = 'business:read';
  static const String businessSettings = 'business:settings';
  static const String catalogRead = 'catalog:read';
  static const String catalogWrite = 'catalog:write';
  static const String channelsManage = 'channels:manage';
  static const String channelsRead = 'channels:read';
  static const String conversationsAssign = 'conversations:assign';
  static const String conversationsRead = 'conversations:read';
  static const String conversationsReply = 'conversations:reply';
  static const String customersRead = 'customers:read';
  static const String customersWrite = 'customers:write';
  static const String dashboardRead = 'dashboard:read';
  static const String merchantAiUse = 'merchant_ai:use';
  static const String salesApprove = 'sales:approve';
  static const String salesRead = 'sales:read';
  static const String salesWrite = 'sales:write';
  static const String teamManage = 'team:manage';
  static const String teamRead = 'team:read';

  static const List<String> all = [
    auditRead,
    automationManage,
    automationRead,
    businessRead,
    businessSettings,
    catalogRead,
    catalogWrite,
    channelsManage,
    channelsRead,
    conversationsAssign,
    conversationsRead,
    conversationsReply,
    customersRead,
    customersWrite,
    dashboardRead,
    merchantAiUse,
    salesApprove,
    salesRead,
    salesWrite,
    teamManage,
    teamRead,
  ];
}

/// Team member model conforming to TeamMember schema
class TeamMember {
  final String principalId;
  final String email;
  final String displayName;
  final String role;
  final List<String> permissions;
  final String status;

  const TeamMember({
    required this.principalId,
    required this.email,
    required this.displayName,
    required this.role,
    required this.permissions,
    required this.status,
  });

  bool get isOwner => role.toLowerCase() == TeamRoles.owner;
  bool get isActive => status.toLowerCase() == 'active';

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      principalId: json['principal_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      role: json['role'] as String? ?? 'member',
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() => {
        'principal_id': principalId,
        'email': email,
        'display_name': displayName,
        'role': role,
        'permissions': permissions,
        'status': status,
      };

  TeamMember copyWith({
    String? principalId,
    String? email,
    String? displayName,
    String? role,
    List<String>? permissions,
    String? status,
  }) {
    return TeamMember(
      principalId: principalId ?? this.principalId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      status: status ?? this.status,
    );
  }
}

/// Team invitation model conforming to TeamInvitation schema
class TeamInvitationDetails {
  final String id;
  final String businessId;
  final String? businessName;
  final String email;
  final String displayName;
  final String role;
  final List<String> permissions;
  final String status;
  final String invitedBy;
  final String expiresAt;
  final String createdAt;
  final String updatedAt;
  final String? accountState;
  final String? acceptedAt;
  final String? acceptedBy;
  final String? revokedAt;

  const TeamInvitationDetails({
    required this.id,
    required this.businessId,
    this.businessName,
    required this.email,
    required this.displayName,
    required this.role,
    required this.permissions,
    required this.status,
    required this.invitedBy,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.accountState,
    this.acceptedAt,
    this.acceptedBy,
    this.revokedAt,
  });

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isAccepted => status.toLowerCase() == 'accepted';
  bool get isRevoked => status.toLowerCase() == 'revoked';

  factory TeamInvitationDetails.fromJson(Map<String, dynamic> json) {
    return TeamInvitationDetails(
      id: json['id'] as String? ?? '',
      businessId: json['business_id'] as String? ?? '',
      businessName: json['business_name'] as String?,
      email: json['email'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      role: json['role'] as String? ?? 'agent',
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      status: json['status'] as String? ?? 'pending',
      invitedBy: json['invited_by'] as String? ?? '',
      expiresAt: json['expires_at'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      accountState: json['account_state'] as String?,
      acceptedAt: json['accepted_at'] as String?,
      acceptedBy: json['accepted_by'] as String?,
      revokedAt: json['revoked_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'business_id': businessId,
        if (businessName != null) 'business_name': businessName,
        'email': email,
        'display_name': displayName,
        'role': role,
        'permissions': permissions,
        'status': status,
        'invited_by': invitedBy,
        'expires_at': expiresAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
        if (accountState != null) 'account_state': accountState,
        if (acceptedAt != null) 'accepted_at': acceptedAt,
        if (acceptedBy != null) 'accepted_by': acceptedBy,
        if (revokedAt != null) 'revoked_at': revokedAt,
      };
}

/// Created invitation response with acceptance token
class TeamInvitationCreated {
  final TeamInvitationDetails invitation;
  final String acceptanceToken;

  const TeamInvitationCreated({
    required this.invitation,
    required this.acceptanceToken,
  });

  factory TeamInvitationCreated.fromJson(Map<String, dynamic> json) {
    return TeamInvitationCreated(
      invitation: TeamInvitationDetails.fromJson(
        json['invitation'] as Map<String, dynamic>? ?? {},
      ),
      acceptanceToken: json['acceptance_token'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'invitation': invitation.toJson(),
        'acceptance_token': acceptanceToken,
      };
}

/// Request for creating a new team invitation
class CreateTeamInvitationRequest {
  final String email;
  final String displayName;
  final String role;
  final List<String> permissions;
  final int? expiresInHours;

  const CreateTeamInvitationRequest({
    required this.email,
    required this.displayName,
    required this.role,
    required this.permissions,
    this.expiresInHours,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'display_name': displayName,
        'role': role,
        'permissions': permissions,
        if (expiresInHours != null) 'expires_in_hours': expiresInHours,
      };
}

/// Request for updating member access (role + permissions)
class UpdateTeamMemberAccessRequest {
  final String role;
  final List<String> permissions;

  const UpdateTeamMemberAccessRequest({
    required this.role,
    required this.permissions,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'permissions': permissions,
      };
}

/// Request for updating member role
class UpdateTeamMemberRoleRequest {
  final String role;

  const UpdateTeamMemberRoleRequest({required this.role});

  Map<String, dynamic> toJson() => {
        'role': role,
      };
}

/// Audit event item conforming to AuditEvent schema
class AuditEvent {
  final String id;
  final String businessId;
  final String actorType;
  final String? actorReference;
  final String action;
  final String resourceType;
  final String? resourceId;
  final Map<String, dynamic> metadata;
  final String occurredAt;

  const AuditEvent({
    required this.id,
    required this.businessId,
    required this.actorType,
    this.actorReference,
    required this.action,
    required this.resourceType,
    this.resourceId,
    required this.metadata,
    required this.occurredAt,
  });

  factory AuditEvent.fromJson(Map<String, dynamic> json) {
    return AuditEvent(
      id: json['id'] as String? ?? '',
      businessId: json['business_id'] as String? ?? '',
      actorType: json['actor_type'] as String? ?? '',
      actorReference: json['actor_reference'] as String?,
      action: json['action'] as String? ?? '',
      resourceType: json['resource_type'] as String? ?? '',
      resourceId: json['resource_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      occurredAt: json['occurred_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'business_id': businessId,
        'actor_type': actorType,
        if (actorReference != null) 'actor_reference': actorReference,
        'action': action,
        'resource_type': resourceType,
        if (resourceId != null) 'resource_id': resourceId,
        'metadata': metadata,
        'occurred_at': occurredAt,
      };
}

/// Paginated page of team members
class TeamMemberPage {
  final List<TeamMember> items;
  final PaginationPage pagination;
  final String requestId;

  const TeamMemberPage({
    required this.items,
    required this.pagination,
    required this.requestId,
  });

  factory TeamMemberPage.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    return TeamMemberPage(
      items: list
          .map((e) => TeamMember.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: PaginationPage.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
      requestId: json['request_id'] as String? ?? '',
    );
  }
}

/// Paginated page of team invitations
class TeamInvitationPage {
  final List<TeamInvitationDetails> items;
  final PaginationPage pagination;
  final String requestId;

  const TeamInvitationPage({
    required this.items,
    required this.pagination,
    required this.requestId,
  });

  factory TeamInvitationPage.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    return TeamInvitationPage(
      items: list
          .map((e) => TeamInvitationDetails.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: PaginationPage.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
      requestId: json['request_id'] as String? ?? '',
    );
  }
}

/// Paginated page of audit events
class AuditEventPage {
  final List<AuditEvent> items;
  final PaginationPage pagination;
  final String requestId;

  const AuditEventPage({
    required this.items,
    required this.pagination,
    required this.requestId,
  });

  factory AuditEventPage.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    return AuditEventPage(
      items: list
          .map((e) => AuditEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: PaginationPage.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
      requestId: json['request_id'] as String? ?? '',
    );
  }
}
