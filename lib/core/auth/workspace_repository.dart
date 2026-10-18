import '../api/api_client.dart';
import '../models/auth_models.dart';

/// Workspace / Business Repository implementing:
/// - GET /me/businesses
class WorkspaceRepository {
  final ApiClient apiClient;

  WorkspaceRepository({required this.apiClient});

  /// GET /me/businesses
  Future<List<BusinessMembership>> getAccessibleBusinesses({
    int limit = 25,
    String? cursor,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit};
    if (cursor != null && cursor.isNotEmpty) {
      queryParams['cursor'] = cursor;
    }

    final response = await apiClient.get(
      '/me/businesses',
      queryParameters: queryParams,
      requiresAuth: true,
    );

    final dataList = response['data'] as List<dynamic>? ?? [];
    return dataList
        .map(
          (item) => BusinessMembership.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
