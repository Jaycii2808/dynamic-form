import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dynamic_form_bi/data/models/form_submission/form_submission_model.dart';
import 'package:flutter/foundation.dart';

class EmailService {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();

  // Email configuration
  static const String _fromEmail = 'dinhthongchau@gmail.com';
  static const String _fromName = 'Dynamic Form BI';
  static const String _backendBaseUrl = 'https://be-mail-dynamic-form.vercel.app/';

  // Dio instance for HTTP requests
  late final Dio _dio;

  /// Initialize email service
  Future<void> initialize() async {
    try {
      // Initialize Dio với cấu hình cho backend
      _dio = Dio(
        BaseOptions(
          baseUrl: _backendBaseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      // Add interceptors for logging
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => debugPrint('📡 [Dio] $obj'),
        ),
      );

      debugPrint('✅ Email service initialized successfully');
      debugPrint('  - From: $_fromEmail ($_fromName)');
      debugPrint('  - Backend: $_backendBaseUrl');

    } catch (e) {
      debugPrint('❌ Error initializing email service: $e');
    }
  }

  /// Send form submission email via backend
  Future<Map<String, dynamic>> sendFormSubmissionEmail({
    required String recipientEmail,
    required String recipientName,
    required FormSubmissionModel submission,
    int maxRetries = 3,
  }) async {
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        debugPrint(
          '📧 [EmailService] Sending form submission email... (Attempt ${retryCount + 1}/$maxRetries)',
        );
        debugPrint('  - To: $recipientEmail ($recipientName)');
        debugPrint('  - Form: ${submission.formName}');

        // Create email content
        final emailContent = _createEmailContent(submission);
        final htmlContent = _createHtmlContent(submission);

        final requestBody = {
          'Messages': [
            {
              'From': {
                'Email': _fromEmail,
                'Name': _fromName,
              },
              'To': [
                {
                  'Email': recipientEmail,
                  'Name': recipientName,
                },
              ],
              'Subject': 'Form Submission: ${submission.formName}',
              'TextPart': emailContent,
              'HTMLPart': htmlContent,
            },
          ],
        };

        debugPrint('📤 [EmailService] Sending request to backend...');
        debugPrint('  - Subject: Form Submission: ${submission.formName}');

        final response = await _dio.post(
          '/api/send-email',
          data: requestBody,
        );

        debugPrint('📥 [EmailService] Response received from backend');
        debugPrint('  - Status code: ${response.statusCode}');

        if (response.statusCode == 200) {
          final responseData = response.data;

          if (responseData['success'] == true) {
            final mailjetResponse = responseData['data'];
            final messageStatus = mailjetResponse['Messages'][0]['Status'];
            final messageId = mailjetResponse['Messages'][0]['To'][0]['MessageID'];

            debugPrint('✅ [EmailService] Email sent successfully via backend');
            debugPrint('  - Status: $messageStatus');
            debugPrint('  - Message ID: $messageId');

            return {
              'success': true,
              'status': messageStatus,
              'messageId': messageId,
              'response': mailjetResponse,
              'retryCount': retryCount,
            };
          } else {
            throw DioException(
              requestOptions: response.requestOptions,
              message: responseData['error'] ?? 'Unknown backend error',
            );
          }
        } else {
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            message: 'Backend returned ${response.statusCode}',
          );
        }

      } on DioException catch (e) {
        debugPrint('❌ [EmailService] Dio error: ${e.message}');

        final errorInfo = _handleDioError(e);

        // Retry on network errors or timeouts
        if (errorInfo['shouldRetry'] == true) {
          retryCount++;

          if (retryCount >= maxRetries) {
            return {
              'success': false,
              'error': errorInfo['message'],
              'type': errorInfo['type'],
              'retryCount': retryCount,
            };
          }

          await _waitBeforeRetry(retryCount);
        } else {
          // Don't retry on other errors
          return {
            'success': false,
            'error': errorInfo['message'],
            'type': errorInfo['type'],
            'retryCount': retryCount,
          };
        }
      } catch (e, stackTrace) {
        debugPrint('❌ [EmailService] Unexpected error: $e');
        debugPrint('  - Stack trace: $stackTrace');

        return {
          'success': false,
          'error': 'Unexpected error: ${e.toString()}',
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

  /// Test backend email sending
  Future<Map<String, dynamic>> testBackendEmail() async {
    try {
      debugPrint('🧪 [EmailService] Testing backend email...');

      final response = await _dio.post('/api/test-email');

      debugPrint('📥 [EmailService] Test response received from backend');
      debugPrint('  - Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true) {
          final mailjetResponse = responseData['data'];
          final messageStatus = mailjetResponse['Messages'][0]['Status'];
          final messageId = mailjetResponse['Messages'][0]['To'][0]['MessageID'];

          debugPrint('✅ [EmailService] Test email sent successfully via backend');
          debugPrint('  - Status: $messageStatus');
          debugPrint('  - Message ID: $messageId');

          return {
            'success': true,
            'status': messageStatus,
            'messageId': messageId,
            'response': mailjetResponse,
          };
        } else {
          return {
            'success': false,
            'error': responseData['error'] ?? 'Unknown backend error',
            'response': responseData,
          };
        }
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'error': 'Backend error ${response.statusCode}: ${response.data}',
          'response': response.data,
        };
      }
    } on DioException catch (e) {
      debugPrint('❌ [EmailService] Test Dio error: ${e.message}');

      final errorInfo = _handleDioError(e);

      return {
        'success': false,
        'error': errorInfo['message'],
        'type': errorInfo['type'],
      };
    } catch (e, stackTrace) {
      debugPrint('❌ [EmailService] Test unexpected error: $e');

      return {
        'success': false,
        'error': 'Unexpected test error: ${e.toString()}',
        'stackTrace': stackTrace.toString(),
        'type': 'unexpected',
      };
    }
  }

  /// Handle Dio errors and categorize them
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
        message = 'Network connection failed. Please check your internet connection.';
        type = 'network';
        shouldRetry = true;
        break;

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          message = 'Authentication failed. Please check backend configuration.';
          type = 'auth';
          shouldRetry = false;
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
          shouldRetry = false;
        }
        break;

      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        type = 'cancelled';
        shouldRetry = false;
        break;

      default:
        message = 'Unknown network error: ${e.message}';
        type = 'unknown';
        shouldRetry = false;
    }

    return {
      'message': message,
      'type': type,
      'shouldRetry': shouldRetry,
    };
  }

  /// Wait before retry with exponential backoff
  Future<void> _waitBeforeRetry(int retryCount) async {
    final waitTime = Duration(seconds: 2 * retryCount);
    debugPrint(
      '⏳ [EmailService] Waiting ${waitTime.inSeconds}s before retry...',
    );
    await Future.delayed(waitTime);
  }

  /// Create plain text email content
  String _createEmailContent(FormSubmissionModel submission) {
    final buffer = StringBuffer();
    buffer.writeln('📝 Form Submission: ${submission.formName}');
    buffer.writeln('🕒 Submitted at: ${submission.submissionTime.toLocal()}');
    buffer.writeln('📋 Form ID: ${submission.formId}');
    buffer.writeln('─' * 50);

    for (int i = 0; i < submission.fields.length; i++) {
      final field = submission.fields[i];
      buffer.writeln('${i + 1}. ${field.label}');
      buffer.writeln('   Value: ${field.displayValue}');
      if (i < submission.fields.length - 1) {
        buffer.writeln();
      }
    }

    return buffer.toString();
  }

  /// Create HTML email content
  String _createHtmlContent(FormSubmissionModel submission) {
    final buffer = StringBuffer();
    buffer.writeln('<h2>📝 Form Submission: ${submission.formName}</h2>');
    buffer.writeln(
      '<p><strong>🕒 Submitted at:</strong> ${submission.submissionTime.toLocal()}</p>',
    );
    buffer.writeln('<p><strong>📋 Form ID:</strong> ${submission.formId}</p>');
    buffer.writeln('<hr style="border: 1px solid #ccc;">');

    for (int i = 0; i < submission.fields.length; i++) {
      final field = submission.fields[i];
      buffer.writeln('<div style="margin-bottom: 15px;">');
      buffer.writeln('<h3>${i + 1}. ${field.label}</h3>');
      buffer.writeln('<p><strong>Value:</strong> ${field.displayValue}</p>');
      buffer.writeln('</div>');
    }

    return buffer.toString();
  }
}