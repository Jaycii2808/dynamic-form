import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:dynamic_form_bi/data/models/form_submission/form_submission_model.dart';

class EmailService {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();

  // Use working API credentials
  static const String _apiKey = 'e3c5b0d1a9c15674c88e9ee7aabec0cc';
  static const String _apiSecret = 'bb03af67a0e72adc02d26997cf185bf3';
  static const String _fromEmail = 'dinhthongchau@gmail.com';
  static const String _fromName = 'Dynamic Form BI';

  /// Initialize email service with environment variables
  Future<void> initialize() async {
    try {
      debugPrint('✅ Email service initialized successfully');
      debugPrint('  - From: $_fromEmail ($_fromName)');
    } catch (e) {
      debugPrint('❌ Error initializing email service: $e');
    }
  }

  /// Check network connectivity
  Future<bool> checkNetworkConnectivity() async {
    try {
      debugPrint('🌐 [EmailService] Checking network connectivity...');

      // Try to connect to a reliable service
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 10));

      final isConnected = response.statusCode == 200;
      debugPrint(
        '🌐 [EmailService] Network connectivity: ${isConnected ? "✅ Connected" : "❌ Disconnected"}',
      );

      return isConnected;
    } catch (e) {
      debugPrint('❌ [EmailService] Network connectivity check failed: $e');
      return false;
    }
  }

  /// Send form submission email to recipient with retry mechanism
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

        final url = Uri.parse('https://api.mailjet.com/v3.1/send');

        // Create email content
        final emailContent = _createEmailContent(submission);

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
              'HTMLPart': _createHtmlContent(submission),
            },
          ],
        };

        debugPrint('📤 [EmailService] Sending request to Mailjet...');
        debugPrint('  - URL: $url');
        debugPrint('  - From: $_fromEmail ($_fromName)');
        debugPrint('  - Subject: Form Submission: ${submission.formName}');

        // Add timeout and better error handling
        final response = await http
            .post(
              url,
              headers: {
                'Content-Type': 'application/json',
                'Authorization':
                    'Basic ${base64Encode(utf8.encode('$_apiKey:$_apiSecret'))}',
              },
              body: jsonEncode(requestBody),
            )
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                debugPrint('❌ [EmailService] Request timeout after 30 seconds');
                throw TimeoutException(
                  'Request timeout',
                  const Duration(seconds: 30),
                );
              },
            );

        debugPrint('📥 [EmailService] Response received');
        debugPrint('  - Status code: ${response.statusCode}');
        debugPrint('  - Response body: ${response.body}');

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final messageStatus = responseData['Messages'][0]['Status'];
          final messageId = responseData['Messages'][0]['To'][0]['MessageID'];

          debugPrint('✅ [EmailService] Email sent successfully');
          debugPrint('  - Status: $messageStatus');
          debugPrint('  - Message ID: $messageId');

          return {
            'success': true,
            'status': messageStatus,
            'messageId': messageId,
            'response': responseData,
            'retryCount': retryCount,
          };
        } else {
          debugPrint('❌ [EmailService] Failed to send email');
          debugPrint('  - Status code: ${response.statusCode}');
          debugPrint('  - Response: ${response.body}');

          // Don't retry on client errors (4xx)
          if (response.statusCode >= 400 && response.statusCode < 500) {
            return {
              'success': false,
              'statusCode': response.statusCode,
              'error': 'HTTP ${response.statusCode}: ${response.body}',
              'response': response.body,
              'retryCount': retryCount,
            };
          }

          // Retry on server errors (5xx) or network issues
          throw Exception('HTTP ${response.statusCode}: ${response.body}');
        }
      } on TimeoutException catch (e) {
        debugPrint('❌ [EmailService] Timeout error: $e');
        retryCount++;

        if (retryCount >= maxRetries) {
          return {
            'success': false,
            'error': 'Request timeout after $maxRetries attempts: ${e.message}',
            'type': 'timeout',
            'retryCount': retryCount,
          };
        }

        // Wait before retry with exponential backoff
        final waitTime = Duration(seconds: 2 * retryCount);
        debugPrint(
          '⏳ [EmailService] Waiting ${waitTime.inSeconds}s before retry...',
        );
        await Future.delayed(waitTime);
      } on FormatException catch (e) {
        debugPrint('❌ [EmailService] Format error: $e');
        return {
          'success': false,
          'error': 'Invalid response format: ${e.message}',
          'type': 'format',
          'retryCount': retryCount,
        };
      } catch (e, stackTrace) {
        debugPrint('❌ [EmailService] Error sending email: $e');
        debugPrint('  - Stack trace: $stackTrace');

        // Check for specific network errors
        String errorMessage = e.toString();
        String errorType = 'unknown';

        if (errorMessage.contains('Failed to fetch') ||
            errorMessage.contains('NetworkException') ||
            errorMessage.contains('SocketException') ||
            errorMessage.contains('HandshakeException') ||
            errorMessage.contains('Connection refused') ||
            errorMessage.contains('No address associated with hostname')) {
          errorMessage =
              'Network connection failed. Please check your internet connection.';
          errorType = 'network';
        } else if (errorMessage.contains('TimeoutException')) {
          errorMessage = 'Request timeout. Please try again.';
          errorType = 'timeout';
        } else if (errorMessage.contains('FormatException')) {
          errorMessage = 'Invalid response format from email service.';
          errorType = 'format';
        } else if (errorMessage.contains('401') ||
            errorMessage.contains('403')) {
          errorMessage = 'Authentication failed. Please check API credentials.';
          errorType = 'auth';
        } else if (errorMessage.contains('429')) {
          errorMessage = 'Rate limit exceeded. Please try again later.';
          errorType = 'rate_limit';
        }

        // Retry on network errors
        if (errorType == 'network' || errorType == 'timeout') {
          retryCount++;

          if (retryCount >= maxRetries) {
            return {
              'success': false,
              'error': errorMessage,
              'stackTrace': stackTrace.toString(),
              'type': errorType,
              'originalError': e.toString(),
              'retryCount': retryCount,
            };
          }

          // Wait before retry with exponential backoff
          final waitTime = Duration(seconds: 2 * retryCount);
          debugPrint(
            '⏳ [EmailService] Waiting ${waitTime.inSeconds}s before retry...',
          );
          await Future.delayed(waitTime);
        } else {
          // Don't retry on other errors
          return {
            'success': false,
            'error': errorMessage,
            'stackTrace': stackTrace.toString(),
            'type': errorType,
            'originalError': e.toString(),
            'retryCount': retryCount,
          };
        }
      }
    }

    return {
      'success': false,
      'error': 'Failed to send email after $maxRetries attempts',
      'type': 'max_retries_exceeded',
      'retryCount': retryCount,
    };
  }

  /// Test Mailjet API with simple message (for debugging)
  Future<Map<String, dynamic>> testMailjetAPI() async {
    try {
      debugPrint('🧪 [EmailService] Testing Mailjet API...');

      final url = Uri.parse('https://api.mailjet.com/v3.1/send');

      final requestBody = {
        'Messages': [
          {
            'From': {
              'Email': _fromEmail,
              'Name': _fromName,
            },
            'To': [
              {
                'Email': 'imprahimovic@gmail.com',
                'Name': 'Test Recipient',
              },
            ],
            'Subject': 'Test Email from Dynamic Form BI',
            'TextPart':
                'This is a test email to verify Mailjet API is working correctly.',
            'HTMLPart':
                '<h3>Test Email</h3><br />This is a test email to verify Mailjet API is working correctly.',
          },
        ],
      };

      debugPrint('📤 [EmailService] Sending test request...');
      debugPrint('  - URL: $url');
      debugPrint('  - From: $_fromEmail ($_fromName)');
      debugPrint('  - To: imprahimovic@gmail.com');
      debugPrint('  - Subject: Test Email from Dynamic Form BI');

      // Add timeout for test request
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization':
                  'Basic ${base64Encode(utf8.encode('$_apiKey:$_apiSecret'))}',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              debugPrint(
                '❌ [EmailService] Test request timeout after 30 seconds',
              );
              throw TimeoutException(
                'Test request timeout',
                const Duration(seconds: 30),
              );
            },
          );

      debugPrint('📥 [EmailService] Test response received');
      debugPrint('  - Status code: ${response.statusCode}');
      debugPrint('  - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final messageStatus = responseData['Messages'][0]['Status'];
        final messageId = responseData['Messages'][0]['To'][0]['MessageID'];

        debugPrint('✅ [EmailService] Test email sent successfully');
        debugPrint('  - Status: $messageStatus');
        debugPrint('  - Message ID: $messageId');

        return {
          'success': true,
          'status': messageStatus,
          'messageId': messageId,
          'response': responseData,
        };
      } else {
        debugPrint('❌ [EmailService] Test email failed');
        debugPrint('  - Status code: ${response.statusCode}');
        debugPrint('  - Response: ${response.body}');

        return {
          'success': false,
          'statusCode': response.statusCode,
          'error': 'HTTP ${response.statusCode}: ${response.body}',
          'response': response.body,
        };
      }
    } on TimeoutException catch (e) {
      debugPrint('❌ [EmailService] Test timeout error: $e');
      return {
        'success': false,
        'error': 'Test request timeout: ${e.message}',
        'type': 'timeout',
      };
    } on FormatException catch (e) {
      debugPrint('❌ [EmailService] Test format error: $e');
      return {
        'success': false,
        'error': 'Invalid test response format: ${e.message}',
        'type': 'format',
      };
    } catch (e, stackTrace) {
      debugPrint('❌ [EmailService] Test email error: $e');
      debugPrint('  - Stack trace: $stackTrace');

      // Check for specific network errors
      String errorMessage = e.toString();
      if (errorMessage.contains('Failed to fetch')) {
        errorMessage =
            'Network connection failed. Please check your internet connection.';
      } else if (errorMessage.contains('SocketException')) {
        errorMessage =
            'Unable to connect to email service. Please try again later.';
      }

      return {
        'success': false,
        'error': errorMessage,
        'stackTrace': stackTrace.toString(),
        'type': 'network',
      };
    }
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
