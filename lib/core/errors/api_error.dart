/// Error models matching OpenAPI ErrorEnvelope, ErrorBody, ErrorDetail
library;

class ApiErrorDetail {
  final String location;
  final String message;
  final dynamic value;

  const ApiErrorDetail({
    required this.location,
    required this.message,
    this.value,
  });

  factory ApiErrorDetail.fromJson(Map<String, dynamic> json) {
    return ApiErrorDetail(
      location: json['location'] as String? ?? '',
      message: json['message'] as String? ?? '',
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() => {
    'location': location,
    'message': message,
    if (value != null) 'value': value,
  };
}

class ApiErrorBody {
  final String code;
  final String message;
  final bool retryable;
  final Map<String, dynamic>? details;
  final Map<String, String>? fields;

  const ApiErrorBody({
    required this.code,
    required this.message,
    required this.retryable,
    this.details,
    this.fields,
  });

  factory ApiErrorBody.fromJson(Map<String, dynamic> json) {
    return ApiErrorBody(
      code: json['code'] as String? ?? 'UNKNOWN_ERROR',
      message: json['message'] as String? ?? 'An unexpected error occurred',
      retryable: json['retryable'] as bool? ?? false,
      details: json['details'] as Map<String, dynamic>?,
      fields: (json['fields'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    'retryable': retryable,
    if (details != null) 'details': details,
    if (fields != null) 'fields': fields,
  };
}

class ApiErrorEnvelope implements Exception {
  final ApiErrorBody error;
  final String requestId;
  final int? statusCode;

  const ApiErrorEnvelope({
    required this.error,
    required this.requestId,
    this.statusCode,
  });

  factory ApiErrorEnvelope.fromJson(
    Map<String, dynamic> json, {
    int? statusCode,
  }) {
    return ApiErrorEnvelope(
      error: json['error'] is Map<String, dynamic>
          ? ApiErrorBody.fromJson(json['error'] as Map<String, dynamic>)
          : ApiErrorBody(
              code: 'INVALID_ERROR_PAYLOAD',
              message: json['message'] as String? ?? 'Unknown error',
              retryable: false,
            ),
      requestId:
          json['request_id'] as String? ??
          (json['meta'] is Map
              ? (json['meta']['request_id'] as String? ?? '')
              : ''),
      statusCode: statusCode,
    );
  }

  factory ApiErrorEnvelope.fromRaw({
    required String code,
    required String message,
    bool retryable = false,
    String requestId = '',
    int? statusCode,
    Map<String, String>? fields,
  }) {
    return ApiErrorEnvelope(
      error: ApiErrorBody(
        code: code,
        message: message,
        retryable: retryable,
        fields: fields,
      ),
      requestId: requestId,
      statusCode: statusCode,
    );
  }

  @override
  String toString() =>
      'ApiErrorEnvelope(code: ${error.code}, message: ${error.message}, requestId: $requestId, status: $statusCode)';
}

/// Generic exception for client-side network or timeout issues
class NetworkException implements Exception {
  final String message;
  final String? originalError;
  final bool isTimeout;

  const NetworkException({
    required this.message,
    this.originalError,
    this.isTimeout = false,
  });

  @override
  String toString() => 'NetworkException: $message ($originalError)';
}
