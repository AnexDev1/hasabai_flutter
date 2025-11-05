import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'models/hasab_exception.dart';

/// Core API client for Hasab AI
class HasabApiClient {
  /// The API key for authentication
  final String apiKey;

  /// Base URL for Hasab AI API
  final String baseUrl;

  /// Dio instance for HTTP requests
  late final Dio _dio;

  /// Default timeout for requests (30 seconds)
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// Create a new Hasab API client
  ///
  /// [apiKey] Your Hasab AI API key
  /// [baseUrl] Optional custom base URL (defaults to https://api.hasab.co/api)
  HasabApiClient({
    required this.apiKey,
    this.baseUrl = 'https://api.hasab.co/api',
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: defaultTimeout,
        receiveTimeout: const Duration(
          minutes: 2,
        ), // Longer for file operations
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        // Follow redirects automatically
        followRedirects: true,
        maxRedirects: 5,
        // Accept both 2xx and 3xx status codes
        validateStatus: (status) {
          return status != null && status < 400;
        },
      ),
    );

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Log request
          print('🚀 REQUEST: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log response
          print(
            '✅ RESPONSE: ${response.statusCode} ${response.requestOptions.path}',
          );
          // Log response data for debugging
          if (response.data != null) {
            final dataPreview = response.data.toString();
            print(
              '📦 DATA: ${dataPreview.length > 200 ? '${dataPreview.substring(0, 200)}...' : dataPreview}',
            );
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          // Log error with more details
          print('❌ ERROR: ${error.message}');
          if (error.response?.data != null) {
            print('📛 ERROR DATA: ${error.response?.data}');
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Make a GET request
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Make a POST request
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Make a PUT request
  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Make a DELETE request
  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload a file with multipart/form-data
  Future<Map<String, dynamic>> uploadFile(
    String path,
    File file, {
    Map<String, dynamic>? additionalFields,
    String fileFieldName = 'file',
  }) async {
    try {
      final fileName = file.path.split('/').last;

      // Log what we're sending
      print('📤 Uploading file: $fileName');
      print('📤 File path: ${file.path}');
      print('📤 Field name: $fileFieldName');
      print('📤 Additional fields: $additionalFields');

      // Build form data, converting booleans to strings
      final Map<String, dynamic> formFields = {};
      if (additionalFields != null) {
        additionalFields.forEach((key, value) {
          if (value is bool) {
            formFields[key] = value
                ? 'true'
                : 'false'; // API expects string booleans
          } else {
            formFields[key] = value.toString();
          }
        });
      }

      // Add the file
      formFields[fileFieldName] = await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      );

      print('📤 Final form fields: ${formFields.keys.toList()}');

      final formData = FormData.fromMap(formFields);

      // Debug: Log the actual FormData fields
      print('📤 FormData fields:');
      formData.fields.forEach((field) {
        print('   ${field.key}: ${field.value} (${field.value.runtimeType})');
      });
      print('📤 FormData files:');
      formData.files.forEach((file) {
        print(
          '   ${file.key}: ${file.value.filename} (${file.value.length} bytes)',
        );
      });

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Accept': 'application/json',
          },
        ),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Post multipart form data without a file (for text translation)
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, dynamic> fields,
  }) async {
    try {
      final formData = FormData.fromMap(fields);

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Accept': 'application/json',
          },
        ),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Download a file from the API
  Future<String> downloadFile(
    String path, {
    String? outputFileName,
    Map<String, dynamic>? queryParameters,
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final fileName =
          outputFileName ?? 'hasab_${DateTime.now().millisecondsSinceEpoch}';
      final savePath = '${tempDir.path}/$fileName';

      // Download file
      await _dio.download(
        path,
        savePath,
        queryParameters: queryParameters,
        onReceiveProgress: onProgress,
      );

      return savePath;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Download a file from a POST request (e.g., for TTS)
  Future<String> downloadFileFromPost(
    String path, {
    required Map<String, dynamic> data,
    String? outputFileName,
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final fileName =
          outputFileName ??
          'hasab_${DateTime.now().millisecondsSinceEpoch}.mp3';
      final savePath = '${tempDir.path}/$fileName';

      // Download file via POST
      final response = await _dio.post(
        path,
        data: data,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          maxRedirects: 5,
          validateStatus: (status) => status! < 400,
          headers: {'Accept': 'audio/mpeg, audio/*, application/octet-stream'},
        ),
        onReceiveProgress: onProgress,
      );

      // Check if we got actual audio data
      if (response.data == null || (response.data as List<int>).isEmpty) {
        throw HasabException(
          message: 'No audio data received from server',
          statusCode: response.statusCode,
        );
      }

      // Check if response is HTML (error page) instead of audio
      final bytes = response.data as List<int>;
      if (bytes.length > 15) {
        final header = String.fromCharCodes(bytes.take(15));
        if (header.toLowerCase().contains('html') ||
            header.toLowerCase().contains('<!doctype')) {
          throw HasabException(
            message:
                'Received HTML response instead of audio file. The API might be returning an error page.',
            statusCode: response.statusCode,
            details:
                'Response Content-Type: ${response.headers['content-type']}',
          );
        }
      }

      // Save the audio file
      final file = File(savePath);
      await file.writeAsBytes(bytes);

      return savePath;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle successful response
  Map<String, dynamic> _handleResponse(Response response) {
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw HasabException(
        message: 'Request failed with status ${response.statusCode}',
        statusCode: response.statusCode,
        details: response.data,
      );
    }

    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    } else if (response.data is Map) {
      // Convert Map<dynamic, dynamic> to Map<String, dynamic>
      return Map<String, dynamic>.from(response.data as Map);
    } else if (response.data is String) {
      try {
        final decoded = json.decode(response.data as String);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
        return {'data': decoded};
      } catch (_) {
        return {'data': response.data};
      }
    } else {
      return {'data': response.data};
    }
  }

  /// Handle Dio errors
  HasabException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return HasabNetworkException(
          message: 'Request timeout. Please check your internet connection.',
          details: error.message,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        // Log the full error response for debugging
        print('🔴 Bad Response Status: $statusCode');
        print('🔴 Bad Response Data: $data');

        if (statusCode == 401 || statusCode == 403) {
          return HasabAuthenticationException(
            message: 'Authentication failed. Please check your API key.',
            statusCode: statusCode,
            details: data,
          );
        }

        return HasabException(
          message: _extractErrorMessage(data) ?? 'Request failed',
          statusCode: statusCode,
          details: data,
        );

      case DioExceptionType.cancel:
        return HasabException(message: 'Request was cancelled');

      case DioExceptionType.connectionError:
        return HasabNetworkException(
          message: 'Connection error. Please check your internet connection.',
          details: error.message,
        );

      case DioExceptionType.badCertificate:
        return HasabNetworkException(
          message: 'SSL certificate error.',
          details: error.message,
        );

      case DioExceptionType.unknown:
        return HasabException(
          message: 'An unexpected error occurred: ${error.message}',
          details: error.error,
        );
    }
  }

  /// Extract error message from response data
  String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Check for validation errors (Laravel format)
      if (data.containsKey('errors') && data['errors'] is Map) {
        final errors = data['errors'] as Map;
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return '${data['message'] ?? 'Validation error'}: ${firstError.first}';
        }
      }

      return data['message'] as String? ??
          data['error'] as String? ??
          data['detail'] as String?;
    }
    return data?.toString();
  }

  /// Close the client and release resources
  void close() {
    _dio.close();
  }
}
