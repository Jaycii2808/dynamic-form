import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/components/component_values_model.dart';
import 'package:dynamic_form_bi/domain/services/firestore_form_service.dart';
import 'package:dynamic_form_bi/presentation/screens/multi_screen/preview_multipage_screen.dart';
import 'package:dynamic_form_bi/presentation/widgets/dynamic_form_renderer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SharedFormScreen extends StatefulWidget {
  static const String routeName = '/forms';
  final String formId;

  const SharedFormScreen({
    super.key,
    required this.formId,
  });

  @override
  State<SharedFormScreen> createState() => _SharedFormScreenState();
}

class _SharedFormScreenState extends State<SharedFormScreen> {
  final FirestoreFormService _firestoreService = FirestoreFormService();
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _formData;
  String _formName = '';
  bool _isPreviewMode = false; // Toggle between preview and input mode
  ComponentValuesModel _componentValues = ComponentValuesModel(values: {});
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSharedForm();
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
        _isLoading = false;
      });

      debugPrint('Shared form loaded successfully: $_formName');
    } catch (e) {
      debugPrint('Error loading shared form: $e');
      setState(() {
        _errorMessage = 'Failed to load form: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<DynamicFormPageModel> _convertToDynamicPages() {
    if (_formData == null) return [];

    try {
      final pages = _formData!['pages'] as List<dynamic>;
      return pages.map((pageData) {
        return DynamicFormPageModel.fromJson(pageData as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      debugPrint('Error converting form data: $e');
      return [];
    }
  }

  void _toggleMode() {
    setState(() {
      _isPreviewMode = !_isPreviewMode;
    });
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

  void _handleFormSubmit() {
    debugPrint('Form submitted with values: ${_componentValues.values}');
    _showSubmittedValuesDialog(_componentValues.values);
  }

  void _showSubmittedValuesDialog(Map<String, dynamic> values) {
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
          content: Container(
            width: double.maxFinite,
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
      actions: [
        if (!_isLoading && _formData != null)
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _toggleMode,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _isPreviewMode ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isPreviewMode ? Icons.visibility : Icons.edit,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isPreviewMode ? 'Preview Mode' : 'Input Mode',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
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

    if (_isPreviewMode) {
      // Preview mode - read-only
      final emptyComponentValues = ComponentValuesModel(values: {});
      return PreviewPageScreen(
        pages: dynamicPages,
        allComponentValues: emptyComponentValues,
      );
    } else {
      // Input mode - user can fill the form
      return _buildInputMode(dynamicPages);
    }
  }

  Widget _buildInputMode(List<DynamicFormPageModel> pages) {
    if (pages.isEmpty) {
      return const Center(
        child: Text(
          'No form pages available',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final currentPage = pages[_currentPageIndex];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Page header
          if (pages.length > 1)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.description,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Page ${_currentPageIndex + 1}/${pages.length}: ${currentPage.title}',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
                final updatedConfig = component.config?.copyWith(value: value);
                final updatedComponent = component.copyWith(
                  config: updatedConfig,
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: DynamicFormRenderer(
                    component: updatedComponent,
                    onFieldChanged: _handleFieldChanged,
                    onButtonAction: _handleButtonAction,
                  ),
                );
              },
            ),
          ),

          // Navigation buttons
          if (pages.length > 1)
            Container(
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
                            _currentPageIndex < pages.length - 1
                                ? 'Next'
                                : 'Submit',
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
            ),
        ],
      ),
    );
  }
}
