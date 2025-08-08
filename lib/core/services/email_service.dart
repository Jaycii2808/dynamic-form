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
        debugPrint(
          '🔄 [EmailService] Creating email content for: ${submission.formName}',
        );
        debugPrint(
          '🔄 [EmailService] Submission has ${submission.fields.length} fields',
        );

        final emailContent = _createEmailContent(submission);
        final htmlContent = _createHtmlContent(submission);

        debugPrint(
          '📧 [EmailService] Text content length: ${emailContent.length}',
        );
        debugPrint(
          '📧 [EmailService] HTML content length: ${htmlContent.length}',
        );
        debugPrint(
          '📧 [EmailService] Text content preview: ${emailContent.length > 200 ? "${emailContent.substring(0, 200)}..." : emailContent}',
        );

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

        debugPrint('📤 [EmailService] Sending email to: $recipientEmail');
        debugPrint(
          '📤 [EmailService] Subject: Form Submission: ${submission.formName}',
        );

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
        debugPrint('❌ [EmailService] DioException occurred: ${e.message}');
        debugPrint('❌ [EmailService] Response: ${e.response?.data}');
        debugPrint('❌ [EmailService] Status code: ${e.response?.statusCode}');

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
        debugPrint('❌ [EmailService] Unexpected error: $e');
        debugPrint('❌ [EmailService] Stack trace: $stackTrace');
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
      buffer.writeln('📋 Form ID: ${submission.formId}');
      buffer.writeln('📊 Total Fields: ${submission.fields.length}');
      buffer.writeln('─' * 50);

      if (submission.fields.isEmpty) {
        buffer.writeln('⚠️ No form fields found or all fields are empty.');
        return buffer.toString();
      }

      for (int i = 0; i < submission.fields.length; i++) {
        final field = submission.fields[i];
        try {
          buffer.writeln('${i + 1}. ${field.label}');
          buffer.writeln('   Value: ${field.displayValue}');
          buffer.writeln('   Type: ${field.componentType}');
          if (field.isRequired) {
            buffer.writeln('   Required: Yes');
          }
          if (field.placeholder?.isNotEmpty == true) {
            buffer.writeln('   Placeholder: ${field.placeholder}');
          }
          if (field.description?.isNotEmpty == true) {
            debugPrint(
              '📝 [EmailService] Adding description to field ${field.label}: ${field.description}',
            );
            buffer.writeln('   Description: ${field.description}');
          }
          if (i < submission.fields.length - 1) buffer.writeln();
        } catch (e) {
          debugPrint('❌ Error processing field ${field.label}: $e');
          buffer.writeln('${i + 1}. ${field.label}');
          buffer.writeln('   Value: [Error displaying value: $e]');
          if (i < submission.fields.length - 1) buffer.writeln();
        }
      }

      buffer.writeln('─' * 50);
      buffer.writeln('✅ Form submission processed successfully');

      return buffer.toString();
    } catch (e) {
      debugPrint('❌ Error creating email content: $e');
      return 'Error creating email content: $e\n\nForm: ${submission.formName}\nTime: ${submission.submissionTime}\nFields: ${submission.fields.length}';
    }
  }

  String _createHtmlContent(FormSubmissionModel submission) {
    try {
      final buffer = StringBuffer();
      buffer.writeln(
        '<html><body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">',
      );
      buffer.writeln(
        '<h2 style="color: #2c5282;">📝 Form Submission: ${submission.formName}</h2>',
      );
      buffer.writeln(
        '<div style="background-color: #f7fafc; padding: 15px; border-radius: 8px; margin-bottom: 20px;">',
      );
      buffer.writeln(
        '<p><strong>🕒 Submitted at:</strong> ${submission.submissionTime.toLocal()}</p>',
      );
      buffer.writeln(
        '<p><strong>📋 Form ID:</strong> ${submission.formId}</p>',
      );
      buffer.writeln(
        '<p><strong>📊 Total Fields:</strong> ${submission.fields.length}</p>',
      );
      buffer.writeln('</div>');

      if (submission.fields.isEmpty) {
        buffer.writeln(
          '<div style="background-color: #fed7d7; padding: 15px; border-radius: 8px; border-left: 4px solid #e53e3e;">',
        );
        buffer.writeln(
          '<p><strong>⚠️ Warning:</strong> No form fields found or all fields are empty.</p>',
        );
        buffer.writeln('</div>');
        buffer.writeln('</body></html>');
        return buffer.toString();
      }

      buffer.writeln(
        '<div style="background-color: white; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden;">',
      );

      for (int i = 0; i < submission.fields.length; i++) {
        final field = submission.fields[i];
        try {
          final bgColor = i % 2 == 0 ? '#f7fafc' : 'white';
          buffer.writeln(
            '<div style="padding: 15px; background-color: $bgColor; border-bottom: 1px solid #e2e8f0;">',
          );
          buffer.writeln(
            '<h3 style="margin: 0 0 10px 0; color: #2d3748;">${i + 1}. ${field.label}</h3>',
          );
          buffer.writeln('<div style="margin-left: 20px;">');
          buffer.writeln(
            '<p style="margin: 5px 0;"><strong>Value:</strong> <span style="color: #2b6cb0;">${field.displayValue}</span></p>',
          );
          buffer.writeln(
            '<p style="margin: 5px 0;"><strong>Type:</strong> ${field.componentType}</p>',
          );
          if (field.isRequired) {
            buffer.writeln(
              '<p style="margin: 5px 0;"><strong>Required:</strong> <span style="color: #e53e3e;">Yes</span></p>',
            );
          }
          if (field.placeholder?.isNotEmpty == true) {
            buffer.writeln(
              '<p style="margin: 5px 0;"><strong>Placeholder:</strong> <em>${field.placeholder}</em></p>',
            );
          }
          if (field.description?.isNotEmpty == true) {
            debugPrint(
              '📝 [EmailService] Adding description to HTML field ${field.label}: ${field.description}',
            );
            buffer.writeln(
              '<p style="margin: 5px 0;"><strong>Description:</strong> <em style="color: #718096;">${field.description}</em></p>',
            );
          }
          buffer.writeln('</div>');
          buffer.writeln('</div>');
        } catch (e) {
          debugPrint('❌ Error processing field ${field.label} in HTML: $e');
          buffer.writeln(
            '<div style="padding: 15px; background-color: #fed7d7; border-bottom: 1px solid #e2e8f0;">',
          );
          buffer.writeln(
            '<h3 style="margin: 0 0 10px 0; color: #e53e3e;">${i + 1}. ${field.label}</h3>',
          );
          buffer.writeln(
            '<p style="margin: 5px 0;"><strong>Value:</strong> <span style="color: #e53e3e;">[Error displaying value: $e]</span></p>',
          );
          buffer.writeln('</div>');
        }
      }

      buffer.writeln('</div>');
      buffer.writeln(
        '<div style="margin-top: 20px; padding: 15px; background-color: #c6f6d5; border-radius: 8px; border-left: 4px solid #38a169;">',
      );
      buffer.writeln(
        '<p style="margin: 0;"><strong>✅ Status:</strong> Form submission processed successfully</p>',
      );
      buffer.writeln('</div>');
      buffer.writeln('</body></html>');

      return buffer.toString();
    } catch (e) {
      debugPrint('❌ Error creating HTML content: $e');
      return '''
        <html><body style="font-family: Arial, sans-serif;">
          <h2 style="color: #e53e3e;">❌ Error Creating Email Content</h2>
          <p><strong>Error:</strong> $e</p>
          <p><strong>Form:</strong> ${submission.formName}</p>
          <p><strong>Time:</strong> ${submission.submissionTime}</p>
          <p><strong>Fields:</strong> ${submission.fields.length}</p>
        </body></html>
      ''';
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
