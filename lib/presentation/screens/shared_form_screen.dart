import 'dart:async';

import 'package:dynamic_form_bi/data/models/components/component_values_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_multi/dynamic_form_multi_model.dart';
import 'package:dynamic_form_bi/domain/services/firestore_form_service.dart';
import 'package:dynamic_form_bi/domain/services/email_service.dart';
import 'package:dynamic_form_bi/core/utils/form_submission_converter.dart';
import 'package:dynamic_form_bi/presentation/widgets/dynamic_form_renderer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert'; // Added for jsonEncode and base64Encode
import 'package:http/http.dart' as http; // Added for http client

class SharedFormScreen extends StatefulWidget {
  static const String routePath = '/forms/:formId';
  static const String routeName = '/forms';
  final String formId;

  const SharedFormScreen({
    super.key,
    required this.formId,
  });

  // Example navigation:
  // context.pushNamed(
  //   SharedFormScreen.routeName,
  //   pathParameters: {'formId': 'your-form-id'},
  // );

  @override
  State<SharedFormScreen> createState() => _SharedFormScreenState();
}

class _SharedFormScreenState extends State<SharedFormScreen> {
  final FirestoreFormService _firestoreService = FirestoreFormService();
  final EmailService _emailService = EmailService();
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _formData;
  String _formName = '';
  String? _recipientEmail;
  String? _recipientName;
  ComponentValuesModel _componentValues = const ComponentValuesModel(
    values: {},
  );
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSharedForm();
    _initializeEmailService();
   // Add API test on init
  }

  /// Test Mailjet API manually (can be called from UI)
  Future<Map<String, dynamic>> _testMailjetAPIManual() async {
    try {
      debugPrint('🧪 [SharedForm] Manual Mailjet API test...');

      final url = Uri.parse('https://api.mailjet.com/v3.1/send');

      // Use exact format from curl command
      final requestBody = {
        'Messages': [
          {
            'From': {
              'Email': 'dinhthongchau@gmail.com',
              'Name': 'Mailjet Pilot',
            },
            'To': [
              {'Email': 'imprahimovic@gmail.com', 'Name': 'passenger 1'},
            ],
            'Subject': 'Test from Dynamic Form BI',
            'TextPart': 'This is a test email from Dynamic Form BI app',
            'HTMLPart':
                '<h3>Test Email</h3><br />This is a test email from Dynamic Form BI app',
          },
        ],
      };

      debugPrint('📤 [SharedForm] Sending manual test request...');
      debugPrint('  - URL: $url');
      debugPrint('  - From: dinhthongchau@gmail.com (Mailjet Pilot)');
      debugPrint('  - To: imprahimovic@gmail.com (passenger 1)');
      debugPrint('  - Subject: Test from Dynamic Form BI');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization':
                  'Basic ${base64Encode(utf8.encode('e3c5b0d1a9c15674c88e9ee7aabec0cc:bb03af67a0e72adc02d26997cf185bf3'))}',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              debugPrint(
                '❌ [SharedForm] Manual test request timeout after 30 seconds',
              );
              throw TimeoutException(
                'Manual test request timeout',
                const Duration(seconds: 30),
              );
            },
          );

      debugPrint('📥 [SharedForm] Manual test response received');
      debugPrint('  - Status code: ${response.statusCode}');
      debugPrint('  - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final messageStatus = responseData['Messages'][0]['Status'];
        final messageId = responseData['Messages'][0]['To'][0]['MessageID'];

        debugPrint('✅ [SharedForm] Manual Mailjet API test successful');
        debugPrint('  - Status: $messageStatus');
        debugPrint('  - Message ID: $messageId');

        return {
          'success': true,
          'status': messageStatus,
          'messageId': messageId,
          'response': responseData,
        };
      } else {
        debugPrint('❌ [SharedForm] Manual Mailjet API test failed');
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
      debugPrint('❌ [SharedForm] Manual test timeout error: $e');
      return {
        'success': false,
        'error': 'Request timeout: ${e.message}',
        'type': 'timeout',
      };
    } on FormatException catch (e) {
      debugPrint('❌ [SharedForm] Manual test format error: $e');
      return {
        'success': false,
        'error': 'Invalid response format: ${e.message}',
        'type': 'format',
      };
    } catch (e, stackTrace) {
      debugPrint('❌ [SharedForm] Manual test API error: $e');
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
      } else if (errorMessage.contains('401') || errorMessage.contains('403')) {
        errorMessage = 'Authentication failed. Please check API credentials.';
        errorType = 'auth';
      } else if (errorMessage.contains('429')) {
        errorMessage = 'Rate limit exceeded. Please try again later.';
        errorType = 'rate_limit';
      }

      return {
        'success': false,
        'error': errorMessage,
        'stackTrace': stackTrace.toString(),
        'type': errorType,
        'originalError': e.toString(),
      };
    }
  }

  Future<void> _initializeEmailService() async {
    await _emailService.initialize();
  }

  Future<void> _loadSharedForm() async {
    try {
      debugPrint('Loading shared form with ID: ${widget.formId}');
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final result = await _firestoreService.getSharedForm(widget.formId);

      if (result == null) {
        setState(() {
          _errorMessage = 'Form not found or has been deactivated';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _formData = result['formData'] as Map<String, dynamic>;
        _formName = result['formName'] as String;
        _recipientEmail = result['recipientEmail'] as String?;
        _recipientName = result['recipientName'] as String?;
        _isLoading = false;
      });

      debugPrint('Shared form loaded successfully: $_formName');
      debugPrint('Recipient email: $_recipientEmail');
      debugPrint('Recipient name: $_recipientName');
    } catch (e) {
      debugPrint('Error loading shared form: $e');
      setState(() {
        _errorMessage = 'Failed to load form: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<FormForMultiPageModel> _convertToDynamicPages() {
    if (_formData == null) return [];

    try {
      final pages = _formData!['pages'] as List<dynamic>;
      return pages.map((pageData) {
        return FormForMultiPageModel.fromJson(pageData as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      debugPrint('Error converting form data: $e');
      return [];
    }
  }

  void _handleFieldChanged(String componentId, dynamic value) {
    debugPrint('Field changed: $componentId = $value');
    setState(() {
      _componentValues = _componentValues.copyWith(
        values: Map<String, dynamic>.from(_componentValues.values)
          ..[componentId] = value,
      );
    });
  }

  void _handleButtonAction(String action, dynamic data) {
    debugPrint('Button action: $action, data: $data');

    if (action == 'submit_form') {
      _handleFormSubmit();
    } else if (action == 'next_page') {
      _nextPage();
    } else if (action == 'previous_page') {
      _previousPage();
    }
  }

  void _nextPage() {
    final pages = _convertToDynamicPages();
    if (_currentPageIndex < pages.length - 1) {
      setState(() {
        _currentPageIndex++;
      });
    }
  }

  void _previousPage() {
    if (_currentPageIndex > 0) {
      setState(() {
        _currentPageIndex--;
      });
    }
  }

  void _handleFormSubmit() async {
    debugPrint('Form submitted with values: ${_componentValues.values}');

    // Track email details for dialog
    Map<String, dynamic> emailDetails = {
      'recipientEmail': _recipientEmail,
      'recipientName': _recipientName,
      'emailSent': false,
      'emailError': null,
      'emailResponse': null,
    };

    try {
      // Create form submission model
      final formModel = _createFormModelFromData();
      final submissionModel = FormSubmissionConverter.convertToSubmissionModel(
        componentValues: _componentValues,
        formModel: formModel,
      );

      debugPrint('📧 [SharedForm] Form submitted successfully');
      debugPrint('  - Form: $_formName');
      debugPrint('  - Recipient: $_recipientEmail ($_recipientName)');

      // Send email only to recipient (person who shared the form)
      if (_recipientEmail != null && _recipientEmail!.isNotEmpty) {
        try {
          final emailResult = await _emailService.sendFormSubmissionEmail(
            recipientEmail: _recipientEmail!,
            recipientName: _recipientName ?? 'Form Recipient',
            submission: submissionModel,
          );

          emailDetails['emailSent'] = emailResult['success'];
          emailDetails['emailResponse'] = emailResult;

          // Log email results
          if (emailResult['success'] == true) {
            debugPrint('✅ [SharedForm] Email sent to recipient successfully');
            debugPrint('  - Status: ${emailResult['status']}');
            debugPrint('  - Message ID: ${emailResult['messageId']}');
          } else {
            debugPrint('❌ [SharedForm] Failed to send email to recipient');
            debugPrint('  - Error: ${emailResult['error']}');
            emailDetails['emailError'] = emailResult['error'];
          }
        } catch (e) {
          debugPrint('❌ [SharedForm] Email sending error: $e');
          emailDetails['emailError'] = 'Email error: $e';
        }
      } else {
        debugPrint('⚠️ [SharedForm] No recipient email found in Firestore');
        emailDetails['emailError'] =
            'No recipient email configured for this form';
      }

      // Save submission data to Firestore for tracking
      try {
        await _firestoreService.saveFormSubmission(
          formId: widget.formId,
          formData: _formData!,
          submitterEmail: 'anonymous', // No longer collecting submitter email
          submitterName: 'Anonymous User',
          submittedValues: _componentValues.values,
        );
        debugPrint('✅ [SharedForm] Submission data saved to Firestore');
      } catch (e) {
        debugPrint('❌ [SharedForm] Failed to save submission data: $e');
      }

      // Show submitted values dialog with email details
      _showSubmittedValuesDialog(_componentValues.values, emailDetails);
    } catch (e) {
      debugPrint('❌ [SharedForm] Error handling form submission: $e');
      emailDetails['emailError'] = 'Form submission error: $e';
      _showSubmittedValuesDialog(_componentValues.values, emailDetails);
    }
  }

  /// Create DynamicMultiPageFormModel from loaded form data
  DynamicMultiPageFormModel _createFormModelFromData() {
    if (_formData == null) {
      throw Exception('Form data is null');
    }

    try {
      return DynamicMultiPageFormModel.fromJson(_formData!);
    } catch (e) {
      debugPrint('Error creating form model: $e');
      // Return a basic form model as fallback
      return DynamicMultiPageFormModel(
        formId: widget.formId,
        name: _formName,
        navigationType: 'sequential',
        pages: _convertToDynamicPages(),
      );
    }
  }

  void _showSubmittedValuesDialog(
    Map<String, dynamic> values,
    Map<String, dynamic> emailDetails,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F2937),
          title: const Text(
            'Form Submitted Successfully!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 500, // Increased height for more details
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email notification section with detailed info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: emailDetails['emailSent'] == true
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: emailDetails['emailSent'] == true
                          ? Colors.green.withValues(alpha: 0.3)
                          : Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            emailDetails['emailSent'] == true
                                ? Icons.check_circle
                                : Icons.error,
                            color: emailDetails['emailSent'] == true
                                ? Colors.green
                                : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            emailDetails['emailSent'] == true
                                ? 'Email Sent Successfully'
                                : 'Email Status',
                            style: TextStyle(
                              color: emailDetails['emailSent'] == true
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Recipient information
                      if (emailDetails['recipientEmail'] != null) ...[
                        Text(
                          '📧 Recipient: ${emailDetails['recipientName'] ?? 'Unknown'} (${emailDetails['recipientEmail']})',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],

                      // Email status details
                      if (emailDetails['emailSent'] == true) ...[
                        Text(
                          '✅ Form data has been sent to the form owner.',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                          ),
                        ),
                        if (emailDetails['emailResponse'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '📤 Status: ${emailDetails['emailResponse']['status']}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                            ),
                          ),
                          if (emailDetails['emailResponse']['messageId'] !=
                              null) ...[
                            const SizedBox(height: 2),
                            Text(
                              '🆔 Message ID: ${emailDetails['emailResponse']['messageId']}',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 10,
                              ),
                            ),
                          ],
                          if (emailDetails['emailResponse']['retryCount'] !=
                                  null &&
                              emailDetails['emailResponse']['retryCount'] >
                                  0) ...[
                            const SizedBox(height: 2),
                            Text(
                              '🔄 Retry attempts: ${emailDetails['emailResponse']['retryCount']}',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ],
                      ] else if (emailDetails['emailError'] != null) ...[
                        Text(
                          '❌ ${emailDetails['emailError']}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                        if (emailDetails['emailResponse'] != null) ...[
                          if (emailDetails['emailResponse']['statusCode'] !=
                              null) ...[
                            const SizedBox(height: 2),
                            Text(
                              '🔍 HTTP ${emailDetails['emailResponse']['statusCode']}',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 10,
                              ),
                            ),
                          ],
                          if (emailDetails['emailResponse']['retryCount'] !=
                              null) ...[
                            const SizedBox(height: 2),
                            Text(
                              '🔄 Retry attempts: ${emailDetails['emailResponse']['retryCount']}',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 10,
                              ),
                            ),
                          ],
                          if (emailDetails['emailResponse']['type'] !=
                              null) ...[
                            const SizedBox(height: 2),
                            Text(
                              '🔧 Error type: ${emailDetails['emailResponse']['type']}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ],
                        // Add specific suggestions for network errors
                        if (emailDetails['emailResponse'] != null &&
                            emailDetails['emailResponse']['type'] ==
                                'network') ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.orange.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '💡 Suggestions:',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '• Check your internet connection',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 9,
                                  ),
                                ),
                                const Text(
                                  '• Try again in a few minutes',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 9,
                                  ),
                                ),
                                const Text(
                                  '• Contact support if issue persists',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ] else ...[
                        Text(
                          '⚠️ No recipient email configured for this form',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '💡 How to fix:',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '• Share the form again with recipient email',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 9,
                                ),
                              ),
                              const Text(
                                '• Contact the form owner to add email',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Debug information
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '🔍 Debug Info:',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    final debugInfo =
                                        '''
Form ID: ${widget.formId}
Submission Time: ${DateTime.now().toLocal()}
Fields Submitted: ${values.length}
Recipient: ${emailDetails['recipientEmail'] ?? 'None'}
Email Status: ${emailDetails['emailSent'] ? 'Success' : 'Failed'}
${emailDetails['emailError'] != null ? 'Error: ${emailDetails['emailError']}' : ''}
${emailDetails['emailResponse'] != null ? 'Response: ${emailDetails['emailResponse']}' : ''}
''';
                                    // Copy to clipboard
                                    // Note: In a real app, you'd use Clipboard.setData
                                    debugPrint(
                                      '📋 Debug info copied to console:',
                                    );
                                    debugPrint(debugInfo);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Copy',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 8,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '• Form ID: ${widget.formId}',
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              '• Submission Time: ${DateTime.now().toLocal()}',
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              '• Fields Submitted: ${values.length}',
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your submitted values:',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: values.entries.map((entry) {
                        final key = entry.key;
                        final value = entry.value;

                        // Format the display value
                        String displayValue = '';
                        if (value == null) {
                          displayValue = 'Not filled';
                        } else if (value is String) {
                          displayValue = value.isEmpty ? 'Not filled' : value;
                        } else if (value is List) {
                          displayValue = value.isEmpty
                              ? 'Not filled'
                              : value.join(', ');
                        } else {
                          displayValue = value.toString();
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                key,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                displayValue,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // Retry email button for network errors
            if (emailDetails['emailSent'] != true &&
                emailDetails['emailResponse'] != null &&
                emailDetails['emailResponse']['type'] == 'network') ...[
              GestureDetector(
                onTap: () async {
                  debugPrint('🔄 [Dialog] Retrying email...');
                  // Close current dialog
                  Navigator.of(context).pop();

                  // Retry form submission
                  _handleFormSubmit();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Retry Email',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            // Test email button
            if (emailDetails['emailSent'] != true) ...[
              GestureDetector(
                onTap: () async {
                  debugPrint('🧪 [Dialog] Testing Mailjet API...');
                  final testResult = await _emailService.testMailjetAPI();

                  if (mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF1F2937),
                        title: Text(
                          testResult['success'] == true
                              ? 'Test Successful'
                              : 'Test Failed',
                          style: TextStyle(
                            color: testResult['success'] == true
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              testResult['success'] == true
                                  ? '✅ Mailjet API is working correctly'
                                  : '❌ Mailjet API test failed',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            if (testResult['status'] != null) ...[
                              Text(
                                'Status: ${testResult['status']}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            if (testResult['messageId'] != null) ...[
                              Text(
                                'Message ID: ${testResult['messageId']}',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            if (testResult['error'] != null) ...[
                              Text(
                                'Error: ${testResult['error']}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            // Add suggestions for test failures
                            if (testResult['success'] != true &&
                                testResult['type'] == 'network') ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '💡 Network Issue Detected:',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '• Check internet connection',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 9,
                                      ),
                                    ),
                                    Text(
                                      '• Try again later',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        actions: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Close',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Test Email',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            // Manual API test button
            GestureDetector(
              onTap: () async {
                debugPrint('🧪 [Dialog] Manual API test...');
                final testResult = await _testMailjetAPIManual();

                if (mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF1F2937),
                      title: Text(
                        testResult['success'] == true
                            ? 'Manual Test Successful'
                            : 'Manual Test Failed',
                        style: TextStyle(
                          color: testResult['success'] == true
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            testResult['success'] == true
                                ? '✅ Direct API call successful'
                                : '❌ Direct API call failed',
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          if (testResult['status'] != null) ...[
                            Text(
                              'Status: ${testResult['status']}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (testResult['messageId'] != null) ...[
                            Text(
                              'Message ID: ${testResult['messageId']}',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (testResult['error'] != null) ...[
                            Text(
                              'Error: ${testResult['error']}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (testResult['type'] != null) ...[
                            Text(
                              'Type: ${testResult['type']}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          // Add suggestions for test failures
                          if (testResult['success'] != true &&
                              testResult['type'] == 'network') ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '💡 Network Issue Detected:',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '• Check internet connection',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 9,
                                    ),
                                  ),
                                  Text(
                                    '• Check firewall/proxy settings',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 9,
                                    ),
                                  ),
                                  Text(
                                    '• Try again later',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      actions: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Close',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Test API Direct',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Close button
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Convert FormComponentMultiPageModel to DynamicFormModel for rendering
  DynamicFormModel _convertToDynamicFormModel(
    FormComponentMultiPageModel component,
  ) {
    return DynamicFormModel(
      id: component.id,
      type: component.type,
      order: component.order,
      config: component.config,
      style: component.style,
      validation: component.validation,
      children: component.children?.map(_convertToDynamicFormModel).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_isLoading ? 'Loading...' : 'Shared Form: $_formName'),
      backgroundColor: const Color(0xFF000000),
      foregroundColor: Colors.white,
      leading: IconButton(
        onPressed: () => context.go('/'),
        icon: const Icon(Icons.home),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading shared form...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Error',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _loadSharedForm,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_formData == null) {
      return const Center(
        child: Text(
          'No form data available',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final dynamicPages = _convertToDynamicPages();

    // Shared forms only allow input mode - no preview mode
    return _buildInputMode(dynamicPages);
  }

  Widget _buildInputMode(List<FormForMultiPageModel> pages) {
    if (pages.isEmpty) {
      return const Center(
        child: Text(
          'No form pages found',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final currentPage = pages[_currentPageIndex];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Page title
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentPage.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (pages.length > 1)
                  Text(
                    'Page ${_currentPageIndex + 1} of ${pages.length}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),

          // Form components
          Expanded(
            child: ListView.builder(
              itemCount: currentPage.components.length,
              itemBuilder: (context, index) {
                final component = currentPage.components[index];
                final value = _componentValues.values[component.id];

                // Update component config with current value
                final updatedConfig = component.config.copyWith(value: value);
                final updatedComponent = component.copyWith(
                  config: updatedConfig,
                );

                // Convert to DynamicFormModel for rendering
                final dynamicComponent = _convertToDynamicFormModel(
                  updatedComponent,
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: DynamicFormRenderer(
                    component: dynamicComponent,
                    onFieldChanged: _handleFieldChanged,
                    onButtonAction: _handleButtonAction,
                    isSharedForm:
                        true, // Enable shared form mode to disable config editing
                  ),
                );
              },
            ),
          ),

          // Navigation buttons
          // if (pages.length > 1)
          //   //buildNavigationButtons(pages),
        ],
      ),
    );
  }

  Widget buildNavigationButtons(List<DynamicFormPageModel> pages) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          if (_currentPageIndex > 0)
            GestureDetector(
              onTap: _previousPage,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Previous',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            )
          else
            const SizedBox(width: 100),

          // Next/Submit button
          GestureDetector(
            onTap: _currentPageIndex < pages.length - 1
                ? _nextPage
                : _handleFormSubmit,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: _currentPageIndex < pages.length - 1
                    ? Colors.blue
                    : Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentPageIndex < pages.length - 1 ? 'Next' : 'Submit',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _currentPageIndex < pages.length - 1
                        ? Icons.arrow_forward
                        : Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
