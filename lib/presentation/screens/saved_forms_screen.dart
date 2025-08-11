import 'dart:convert';

import 'package:dynamic_form_bi/core/enums/date_picker_enum.dart';
import 'package:dynamic_form_bi/data/models/components/component_values_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/saved_form/saved_form_data_model.dart';
import 'package:dynamic_form_bi/data/models/saved_form/saved_form_model.dart';
import 'package:dynamic_form_bi/core/services/saved_forms_service.dart';
import 'package:dynamic_form_bi/presentation/screens/preview_page_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:dynamic_form_bi/core/enums/menu_action_enum.dart';
import 'package:go_router/go_router.dart';

class SavedFormsScreen extends StatefulWidget {
  static const String routeName = '/saved-forms';
  const SavedFormsScreen({super.key});

  @override
  State<SavedFormsScreen> createState() => _SavedFormsScreenState();
}

class _SavedFormsScreenState extends State<SavedFormsScreen> {
  final SavedFormsService _savedFormsService = SavedFormsService();
  List<SavedFormModel> _savedForms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedForms();
  }

  Future<void> _loadSavedForms() async {
    debugPrint('🔄 Loading saved forms...');
    setState(() => _isLoading = true);
    try {
      final forms = await _savedFormsService.getSavedForms();
      debugPrint('📋 Loaded ${forms.length} saved forms');
      for (final form in forms) {
        debugPrint('  - ${form.name} (${form.id}) - ${form.savedAt}');
      }
      setState(() {
        _savedForms = forms;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading saved forms: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading saved forms: $e')),
        );
      }
    }
  }

  Future<void> _deleteSavedForm(SavedFormModel form) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Form'),
        content: Text('Are you sure you want to delete "${form.name}"?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _savedFormsService.deleteSavedForm(form.id);
        await _loadSavedForms();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${form.name} deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting form: $e')));
        }
      }
    }
  }

  void _loadSavedForm(SavedFormModel savedForm) {
    try {
      if (savedForm.hasCustomData && savedForm.isMultiPage) {
        // Load multi-page form with custom format
        _loadMultiPageForm(savedForm);
      } else if (savedForm.formData != null) {
        // Load legacy single-page form
        _loadLegacyForm(savedForm);
      } else {
        throw Exception('No form data available');
      }
    } catch (e) {
      debugPrint('❌ Error loading saved form: $e');
      _showErrorSnackBar('Failed to load form: $e');
    }
  }

  /// Load multi-page form with custom format
  void _loadMultiPageForm(SavedFormModel savedForm) {
    final customFormData = savedForm.customFormData!;

    // Step 1: Convert saved form pages to dynamic form pages for preview screen
    final dynamicPages = _convertToDynamicFormPages(customFormData.pages);

    // Step 2: Log form information for debugging
    debugPrint('🔄 Loading saved form with custom format');
    debugPrint('📋 Form ID: ${customFormData.formId}');
    debugPrint('🔢 Pages loaded: ${dynamicPages.length}');

    // Step 3: Close current screen and navigate to preview
    context.pop(); // Close saved forms screen

    // Step 4: Navigate to preview screen with converted data
    context.push(
      PreviewPageScreen.routeName,
      extra: {
        'pages': dynamicPages,
        'values': _getComponentValuesForPreview(customFormData.componentValues),
      },
    );
  }

  /// Load legacy single-page form (backward compatibility)
  void _loadLegacyForm(SavedFormModel savedForm) {
    // For legacy forms, we can use the formData directly
    context.pop();
    context.push(
      PreviewPageScreen.routeName,
      extra: {
        'pages': [savedForm.formData!],
        'values': ComponentValuesModel.empty(),
      },
    );
  }

  /// Convert saved form pages to dynamic form pages for preview screen
  ///
  /// This method transforms SavedFormPageDataModel (from storage)
  /// to DynamicFormPageModel (for preview screen)
  List<DynamicFormPageModel> _convertToDynamicFormPages(
    List<SavedFormPageDataModel> savedPages,
  ) {
    return List<DynamicFormPageModel>.generate(
      savedPages.length,
      (index) {
        final savedPage = savedPages[index];
        // Convert each saved page to dynamic form page
        return DynamicFormPageModel(
          pageId: savedPage.pageId, // Keep the same page ID
          title: savedPage.title, // Keep the same title
          order: savedPage.order, // Keep the same order
          components: _convertPageComponents(
            savedPage.components,
          ), // Convert components
        );
      },
    );
  }

  /// Convert saved form components to dynamic form components
  ///
  /// This method transforms SavedFormComponentDataModel (from storage)
  /// to DynamicFormModel (for preview screen)
  List<DynamicFormModel> _convertPageComponents(
    List<SavedFormComponentDataModel> savedComponents,
  ) {
    return List<DynamicFormModel>.generate(
      savedComponents.length,
      (index) {
        final savedComponent = savedComponents[index];
        // Use the built-in conversion method to transform each component
        return savedComponent.toDynamicFormModel();
      },
    );
  }

  /// Get component values for preview screen
  ///
  /// This method converts ComponentValuesDataModel to ComponentValuesModel
  /// that the preview screen expects
  ComponentValuesModel _getComponentValuesForPreview(
    ComponentValuesDataModel componentValues,
  ) {
    if (componentValues.hasValues) {
      // Convert to ComponentValuesModel if there are values
      return componentValues.toComponentValuesModel();
    } else {
      // Return empty model if no values
      return ComponentValuesModel.empty();
    }
  }

  /// Show error snackbar with consistent styling
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.archive_outlined, size: 24),
            SizedBox(width: 8),
            Text('Saved Forms'),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade800,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadSavedForms,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          if (_savedForms.isNotEmpty)
            PopupMenuButton<MenuAction>(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem<MenuAction>(
                  value: MenuAction.clearAll,
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Clear All'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == MenuAction.clearAll) {
                  // Capture ScaffoldMessenger before any async operations
                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear All Forms'),
                      content: const Text(
                        'Are you sure you want to delete all saved forms? This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => context.pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => context.pop(true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Clear All'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    try {
                      await _savedFormsService.clearAllSavedForms();
                      await _loadSavedForms();
                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(content: Text('All forms cleared')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(content: Text('Error clearing forms: $e')),
                        );
                      }
                    }
                  }
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedForms.isEmpty
          ? _buildEmptyState()
          : _buildFormsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.archive_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No Saved Forms',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Save forms from the preview page to access them here',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _savedForms.length,
      itemBuilder: (context, index) {
        final form = _savedForms[index];
        return _buildFormCard(form);
      },
    );
  }

  Widget _buildFormCard(SavedFormModel form) {
    final dateFormat = DateFormat(
      DateFormatCustomPattern.mmmDdYyyyHhMm.pattern,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _loadSavedForm(form),
        borderRadius: BorderRadius.circular(12),
        hoverColor: Colors.yellow.withValues(alpha: 0.1),
        highlightColor: Colors.red.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          form.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (form.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            form.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.grey),
                    tooltip: 'Copy Config',
                    onPressed: () async {
                      String configJson;
                      try {
                        if (form.hasCustomData) {
                          // Use CustomFormDataModel for proper conversion
                          configJson = const JsonEncoder().convert(
                            form.customFormData!.toJson(),
                          );
                        } else if (form.formData != null) {
                          configJson = const JsonEncoder().convert(
                            form.formData!.toJson(),
                          );
                        } else {
                          throw Exception('No config data available');
                        }
                        await Clipboard.setData(
                          ClipboardData(text: configJson),
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Config copied to clipboard'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to copy config: $e'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  PopupMenuButton<MenuAction>(
                    icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                    itemBuilder: (context) => [
                      const PopupMenuItem<MenuAction>(
                        value: MenuAction.load,
                        child: Row(
                          children: [
                            Icon(Icons.open_in_new, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Load Form'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<MenuAction>(
                        value: MenuAction.delete,
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == MenuAction.load) {
                        _loadSavedForm(form);
                      } else if (value == MenuAction.delete) {
                        _deleteSavedForm(form);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Saved ${dateFormat.format(form.savedAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.source, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'From: ${form.originalConfigKey}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${form.totalComponentsCount} components',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
