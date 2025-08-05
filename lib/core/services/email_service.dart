import 'dart:async';
import 'package:dio/dio.dart';
import 'package:dynamic_form_bi/data/models/form_submission/form_submission_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmailService {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();

  final String _fromEmail = dotenv.env['MAILJET_FROM_EMAIL'] ?? '';
  final String _fromName = dotenv.env['MAILJET_FROM_NAME'] ?? '';
  final String _backendBaseUrl = dotenv.env['BACKEND_URL'] ?? '';

  late final Dio _dio;
  bool _isInitialized = false;

  /// Check if email service is initialized
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    // Prevent re-initialization
    if (_isInitialized) {
      debugPrint('✅ Email service already initialized, skipping...');
      return;
    }

    try {
      _dio = Dio(
        BaseOptions(
          baseUrl: _backendBaseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Content-Type': 'application/json'},
        ),
      );

      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => debugPrint('📡 [Dio] $obj'),
        ),
      );

      _isInitialized = true;
      debugPrint('✅ Email service initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing email service: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendFormSubmissionEmail({
    required String recipientEmail,
    required String recipientName,
    required FormSubmissionModel submission,
    int maxRetries = 3,
  }) async {
    // Ensure service is initialized
    if (!_isInitialized) {
      debugPrint(
        '⚠️ Email service not initialized, attempting to initialize...',
      );
      await initialize();
    }

    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final emailContent = _createEmailContent(submission);
        final htmlContent = _createHtmlContent(submission);

        final requestBody = {
          'Messages': [
            {
              'From': {'Email': _fromEmail, 'Name': _fromName},
              'To': [
                {'Email': recipientEmail, 'Name': recipientName},
              ],
              'Subject': 'Form Submission: ${submission.formName}',
              'TextPart': emailContent,
              'HTMLPart': htmlContent,
            },
          ],
        };

        final response = await _dio.post('/api/send-email', data: requestBody);

        if (response.statusCode == 200 && response.data['success'] == true) {
          final mailjetResponse = response.data['data'];
          return {
            'success': true,
            'status': mailjetResponse['Messages'][0]['Status'],
            'messageId': _safeStringConversion(
              mailjetResponse['Messages'][0]['To'][0]['MessageID'],
            ),
            'response': mailjetResponse,
            'retryCount': retryCount,
          };
        } else {
          throw DioException(
            requestOptions: response.requestOptions,
            message: response.data['error'] ?? 'Unknown backend error',
          );
        }
      } on DioException catch (e) {
        final errorInfo = _handleDioError(e);
        retryCount++;
        if (errorInfo['shouldRetry'] == true && retryCount < maxRetries) {
          await _waitBeforeRetry(retryCount);
          continue;
        }
        return {
          'success': false,
          'error': errorInfo['message'],
          'type': errorInfo['type'],
          'retryCount': retryCount,
        };
      } catch (e, stackTrace) {
        return {
          'success': false,
          'error': 'Unexpected error: $e',
          'stackTrace': stackTrace.toString(),
          'type': 'unexpected',
          'retryCount': retryCount,
        };
      }
    }

    return {
      'success': false,
      'error': 'Failed to send email after $maxRetries attempts',
      'type': 'max_retries_exceeded',
      'retryCount': retryCount,
    };
  }


  Map<String, dynamic> _handleDioError(DioException e) {
    String message = e.message ?? 'Unknown error';
    String type = 'unknown';
    bool shouldRetry = false;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        message = 'Request timeout. Please try again.';
        type = 'timeout';
        shouldRetry = true;
        break;
      case DioExceptionType.connectionError:
        message =
            'Network connection failed. Please check your internet connection.';
        type = 'network';
        shouldRetry = true;
        break;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          message =
              'Authentication failed. Please check backend configuration.';
          type = 'auth';
        } else if (statusCode == 429) {
          message = 'Rate limit exceeded. Please try again later.';
          type = 'rate_limit';
          shouldRetry = true;
        } else if (statusCode != null && statusCode >= 500) {
          message = 'Backend server error. Please try again.';
          type = 'server_error';
          shouldRetry = true;
        } else {
          message = 'Backend error $statusCode: ${e.response?.data}';
          type = 'http_error';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        type = 'cancelled';
        break;
      default:
        message = 'Unknown network error: ${e.message}';
        type = 'unknown';
    }

    return {
      'message': message,
      'type': type,
      'shouldRetry': shouldRetry,
    };
  }

  Future<void> _waitBeforeRetry(int retryCount) async {
    final waitTime = Duration(seconds: 2 * retryCount);
    debugPrint(
      '⏳ [EmailService] Waiting ${waitTime.inSeconds}s before retry...',
    );
    await Future.delayed(waitTime);
  }

  String _createEmailContent(FormSubmissionModel submission) {
    try {
      final buffer = StringBuffer();
      buffer.writeln('📝 Form Submission: ${submission.formName}');
      buffer.writeln('🕒 Submitted at: ${submission.submissionTime.toLocal()}');
      // buffer.writeln('📋 Form ID: ${submission.formId}');
      buffer.writeln('─' * 50);
      for (int i = 0; i < submission.fields.length; i++) {
        final field = submission.fields[i];
        try {
          buffer.writeln('${i + 1}. ${field.label}');
          buffer.writeln('   Value: ${field.displayValue}');
          if (i < submission.fields.length - 1) buffer.writeln();
        } catch (e) {
          debugPrint('❌ Error processing field ${field.label}: $e');
          buffer.writeln('${i + 1}. ${field.label}');
          buffer.writeln('   Value: [Error displaying value]');
          if (i < submission.fields.length - 1) buffer.writeln();
        }
      }
      return buffer.toString();
    } catch (e) {
      debugPrint('❌ Error creating email content: $e');
      return 'Error creating email content: $e';
    }
  }

  String _createHtmlContent(FormSubmissionModel submission) {
    try {
      final buffer = StringBuffer();
      buffer.writeln('<h2>📝 Form Submission: ${submission.formName}</h2>');
      buffer.writeln(
        '<p><strong>🕒 Submitted at:</strong> ${submission.submissionTime.toLocal()}</p>',
      );
      buffer.writeln(
        '<p><strong>📋 Form ID:</strong> ${submission.formId}</p>',
      );
      buffer.writeln('<hr style="border: 1px solid #ccc;">');
      for (int i = 0; i < submission.fields.length; i++) {
        final field = submission.fields[i];
        try {
          buffer.writeln('<div style="margin-bottom: 15px;">');
          buffer.writeln('<h3>${i + 1}. ${field.label}</h3>');
          buffer.writeln(
            '<p><strong>Value:</strong> ${field.displayValue}</p>',
          );
          buffer.writeln('</div>');
        } catch (e) {
          debugPrint('❌ Error processing field ${field.label} in HTML: $e');
          buffer.writeln('<div style="margin-bottom: 15px;">');
          buffer.writeln('<h3>${i + 1}. ${field.label}</h3>');
          buffer.writeln(
            '<p><strong>Value:</strong> [Error displaying value]</p>',
          );
          buffer.writeln('</div>');
        }
      }
      return buffer.toString();
    } catch (e) {
      debugPrint('❌ Error creating HTML content: $e');
      return '<p>Error creating email content: $e</p>';
    }
  }

  String _safeStringConversion(dynamic value) {
    if (value == null) return '';
    try {
      return value.toString();
    } catch (e) {
      debugPrint('❌ Error converting value to string: $e');
      return '';
    }
  }
}
