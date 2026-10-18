import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/api_error.dart';

/// HTTP Client wrapper handling:
/// - Base URL and path prefixes
/// - Automatic cookie header injection for platforms without automatic cookie jar
/// - Parsing Set-Cookie headers (specifically `mujeeb_refresh`)
/// - Handling Bearer auth headers
/// - Translating HTTP errors to ApiErrorEnvelope or NetworkException
class ApiClient {
  static const String defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://mujeeb24-api.onrender.com/api/v1',
  );

  final http.Client _client;
  String baseUrl;
  String? _accessToken;
  String? _refreshCookie;

  ApiClient({http.Client? client, String? baseUrl})
    : baseUrl = normalizeBaseUrl(baseUrl ?? defaultBaseUrl),
      _client = client ?? http.Client();

  /// Normalizes base URL ensuring no trailing slashes and appending `/api/v1`
  /// if only the root origin domain is provided.
  static String normalizeBaseUrl(String url) {
    var trimmed = url.trim();
    while (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    if (!trimmed.endsWith('/api/v1')) {
      trimmed = '$trimmed/api/v1';
    }
    return trimmed;
  }

  String? get accessToken => _accessToken;
  String? get refreshCookie => _refreshCookie;

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  void setRefreshCookie(String? cookie) {
    _refreshCookie = cookie;
  }

  void clearSession() {
    _accessToken = null;
    _refreshCookie = null;
  }

  Uri _resolveUri(String path, [Map<String, dynamic>? queryParameters]) {
    final cleanBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    var uri = Uri.parse('$cleanBase$cleanPath');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(
        queryParameters: queryParameters.map(
          (k, v) => MapEntry(k, v.toString()),
        ),
      );
    }
    return uri;
  }

  Map<String, String> _buildHeaders({
    Map<String, String>? extraHeaders,
    bool requiresAuth = true,
    bool sendCookie = false,
  }) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth && _accessToken != null && _accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    if (sendCookie && _refreshCookie != null && _refreshCookie!.isNotEmpty) {
      headers['Cookie'] = _refreshCookie!;
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    return headers;
  }

  void _extractCookies(http.Response response) {
    final setCookie =
        response.headers['set-cookie'] ?? response.headers['Set-Cookie'];
    if (setCookie != null && setCookie.isNotEmpty) {
      // Find mujeeb_refresh cookie
      final parts = setCookie.split(';');
      for (final part in parts) {
        final trimmed = part.trim();
        if (trimmed.startsWith('mujeeb_refresh=')) {
          _refreshCookie = trimmed;
          break;
        }
      }
      if (_refreshCookie == null && setCookie.contains('=')) {
        // Fallback: save raw cookie if formatted directly
        _refreshCookie = setCookie.split(';').first.trim();
      }
    }
  }

  dynamic _processResponse(http.Response response) {
    _extractCookies(response);

    if (response.statusCode == 204) {
      return null;
    }

    final bodyString = response.body.trim();
    dynamic jsonBody;
    if (bodyString.isNotEmpty) {
      try {
        jsonBody = jsonDecode(bodyString);
      } catch (e) {
        if (response.statusCode >= 400) {
          throw ApiErrorEnvelope.fromRaw(
            code: 'NON_JSON_ERROR',
            message:
                'Server returned error status ${response.statusCode}: $bodyString',
            statusCode: response.statusCode,
          );
        }
        throw ApiErrorEnvelope.fromRaw(
          code: 'JSON_PARSE_ERROR',
          message: 'Failed to parse JSON response: $bodyString',
          statusCode: response.statusCode,
        );
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonBody;
    }

    // Response is 4xx or 5xx
    if (jsonBody is Map<String, dynamic> && jsonBody.containsKey('error')) {
      throw ApiErrorEnvelope.fromJson(
        jsonBody,
        statusCode: response.statusCode,
      );
    } else {
      String msg = 'HTTP request failed with status ${response.statusCode}';
      if (jsonBody is Map) {
        if (jsonBody['message'] != null) {
          msg = jsonBody['message'].toString();
        } else if (jsonBody['detail'] != null) {
          final detail = jsonBody['detail'].toString();
          if (jsonBody['errors'] is List &&
              (jsonBody['errors'] as List).isNotEmpty) {
            final firstErr = (jsonBody['errors'] as List).first;
            if (firstErr is Map && firstErr['message'] != null) {
              msg = '$detail: ${firstErr['message']}';
            } else {
              msg = detail;
            }
          } else {
            msg = detail;
          }
        } else if (jsonBody['title'] != null) {
          msg = jsonBody['title'].toString();
        }
      }
      throw ApiErrorEnvelope.fromRaw(
        code: 'HTTP_${response.statusCode}',
        message: msg,
        statusCode: response.statusCode,
        requestId: jsonBody is Map && jsonBody['request_id'] != null
            ? jsonBody['request_id'].toString()
            : '',
      );
    }
  }

  Future<dynamic> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    Duration timeout = const Duration(seconds: 45),
  }) async {
    try {
      final uri = _resolveUri(path, queryParameters);
      final response = await _client
          .get(
            uri,
            headers: _buildHeaders(
              extraHeaders: headers,
              requiresAuth: requiresAuth,
            ),
          )
          .timeout(timeout);
      return _processResponse(response);
    } on ApiErrorEnvelope {
      rethrow;
    } on TimeoutException catch (e) {
      throw NetworkException(
        message:
            'Connection timed out while fetching $path. Server may be waking up.',
        originalError: e.toString(),
        isTimeout: true,
      );
    } catch (e) {
      throw NetworkException(
        message: 'Network connection failed while fetching $path',
        originalError: e.toString(),
      );
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    bool requiresAuth = false,
    bool sendCookie = false,
    Duration timeout = const Duration(seconds: 45),
  }) async {
    try {
      final uri = _resolveUri(path);
      final response = await _client
          .post(
            uri,
            headers: _buildHeaders(
              extraHeaders: headers,
              requiresAuth: requiresAuth,
              sendCookie: sendCookie,
            ),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);
      return _processResponse(response);
    } on ApiErrorEnvelope {
      rethrow;
    } on TimeoutException catch (e) {
      throw NetworkException(
        message:
            'Connection timed out while posting to $path. Server may be waking up.',
        originalError: e.toString(),
        isTimeout: true,
      );
    } catch (e) {
      throw NetworkException(
        message: 'Network connection failed while posting to $path',
        originalError: e.toString(),
      );
    }
  }

  Future<dynamic> patch(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    bool requiresAuth = true,
    Duration timeout = const Duration(seconds: 45),
  }) async {
    try {
      final uri = _resolveUri(path);
      final response = await _client
          .patch(
            uri,
            headers: _buildHeaders(
              extraHeaders: headers,
              requiresAuth: requiresAuth,
            ),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);
      return _processResponse(response);
    } on ApiErrorEnvelope {
      rethrow;
    } on TimeoutException catch (e) {
      throw NetworkException(
        message:
            'Connection timed out while updating $path. Server may be waking up.',
        originalError: e.toString(),
        isTimeout: true,
      );
    } catch (e) {
      throw NetworkException(
        message: 'Network connection failed while updating $path',
        originalError: e.toString(),
      );
    }
  }

  void close() {
    _client.close();
  }
}
