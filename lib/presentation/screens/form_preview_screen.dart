import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/button_condition_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/domain/services/saved_forms_service.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/dynamic_form_renderer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/core/utils/validation_utils.dart';

class FormPreviewScreen extends StatelessWidget {
  final DynamicFormPageModel page;
  final String title;
  final bool isViewOnly;

  const FormPreviewScreen({
    super.key,
    required this.page,
    required this.title,
    this.isViewOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isViewOnly
                    ? Colors.green.shade600
                    : Colors.blue.shade600,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isViewOnly ? Icons.visibility_outlined : Icons.preview_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isViewOnly ? 'View: $title' : 'Preview: $title',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey.shade50,
        foregroundColor: const Color(0xFF1f2937),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          // Removed bookmark button - save functionality moved to Remote Config Save button
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.amber.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isViewOnly
                        ? 'View Mode - Saved form data'
                        : 'Preview Mode - Components are read-only',
                    style: TextStyle(
                      color: Colors.amber.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Form Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Render all form components in preview mode (exclude buttons)
                    ...page.components
                        .where(
                          (component) =>
                              component.config['action'] != 'submit_form' &&
                              component.config['action'] != 'preview_form',
                        )
                        .map(
                          (component) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: _buildPreviewComponent(component),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),

          // Footer with Save button
          if (!isViewOnly)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: BlocBuilder<DynamicFormBloc, DynamicFormState>(
                builder: (context, state) {
                  // Get Save button from Remote Config
                  final saveButton = page.components
                      .where((c) => c.config['action'] == 'submit_form')
                      .firstOrNull;

                  debugPrint(
                    '🔍 FormPreviewScreen: Looking for Save button in ${page.components.length} components',
                  );

                  if (saveButton == null) {
                    debugPrint('❌ No Save button found in Remote Config');
                    return const Text(
                      'No save button configured',
                      style: TextStyle(color: Colors.grey),
                    );
                  }

                  debugPrint(
                    '✅ Found Save button from Remote Config: ${saveButton.id}',
                  );
                  debugPrint('📝 Save button config: ${saveButton.config}');
                  debugPrint('🎨 Save button style: ${saveButton.style}');

                  return Row(
                    children: [
                      // Cancel button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.grey.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Save button from Remote Config
                      Expanded(child: _buildPreviewSaveButton(saveButton)),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPreviewComponent(DynamicFormModel component) {
    // Create a copy of the component with interactions disabled for preview
    final previewComponent = DynamicFormModel(
      id: '${component.id}_preview',
      type: component.type,
      order: component.order,
      config: {
        ...component.config,
        'disabled': true, // Disable all interactions
        'readOnly': true,
      },
      style: {
        ...component.style,
        'opacity': 0.8, // Slightly fade to indicate preview mode
      },
      inputTypes: component.inputTypes,
      variants: component.variants,
      states: component.states,
      validation: component.validation,
      children: component.children,
    );

    // Return the rendered component
    return DynamicFormRenderer(component: previewComponent, page: page);
  }

  Widget _buildPreviewSaveButton(DynamicFormModel saveButton) {
    return BlocBuilder<DynamicFormBloc, DynamicFormState>(
      builder: (context, state) {
        // First check if there are any validation errors in the current state
        bool hasValidationErrors = false;
        if (state.page != null) {
          for (final component in state.page!.components) {
            final errorText = component.config['errorText'];
            if (errorText != null && errorText.toString().isNotEmpty) {
              hasValidationErrors = true;
              debugPrint('❌ Validation error in ${component.id}: $errorText');
              break;
            }
          }
        }

        // Check conditions - replace duplicated if-else with centralized validation
        bool conditionsPass = false;
        final conditions = saveButton.config['conditions'] as List<dynamic>?;

        if (conditions != null && conditions.isNotEmpty) {
          final buttonConditions = conditions
              .map((c) => ButtonCondition.fromJson(c as Map<String, dynamic>))
              .toList();

          // Use centralized validation instead of duplicated switch statements
          final validationResult = ValidationUtils.validateButtonConditions(
            buttonConditions,
            state.page?.components ?? page.components,
          );

          conditionsPass = validationResult.isValid;

          if (!conditionsPass) {
            debugPrint('❌ Condition failed: ${validationResult.errorMessage}');
          }
        } else {
          conditionsPass = true; // No conditions means always pass
        }

        // Can only save if both conditions pass AND no validation errors
        final canSave = conditionsPass && !hasValidationErrors;

        debugPrint(
          '💾 Save button state: conditionsPass=$conditionsPass, hasValidationErrors=$hasValidationErrors, canSave=$canSave',
        );

        // Get button styles from Remote Config
        final style = Map<String, dynamic>.from(saveButton.style);
        final config = Map<String, dynamic>.from(saveButton.config);

        debugPrint('💾 Rendering Save button with canSave: $canSave');
        debugPrint('🎯 Button label: ${config['label'] ?? 'Save'}');
        debugPrint('🔧 Button icon: ${config['icon']}');

        // Apply disabled state if can't save
        if (!canSave) {
          final disabledStyle =
              saveButton.states?['disabled']?['style'] as Map<String, dynamic>?;
          if (disabledStyle != null) {
            style.addAll(disabledStyle);
          } else {
            // Fallback disabled style
            style['backgroundColor'] = '#F3F4F6';
            style['color'] = '#9CA3AF';
          }
        }

        return ElevatedButton(
          onPressed: canSave
              ? () async {
                  // Save form directly without dialog
                  try {
                    final savedFormsService = SavedFormsService();
                    final timestamp = DateTime.now();
                    final formId = 'form_${timestamp.millisecondsSinceEpoch}';
                    final defaultName =
                        'Form ${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';

                    // Create the save format you requested
                    final formToSave = {
                      'form_id': formId,
                      'components': page.components
                          .map((component) => component.toJson())
                          .toList(),
                      'page_id': page.pageId,
                      'title': defaultName,
                    };

                    debugPrint('💾 Starting to save form...');
                    debugPrint('📝 Form name: $defaultName');
                    debugPrint('🆔 Form ID: $formId');
                    debugPrint('📄 Page ID: ${page.pageId}');
                    debugPrint('🔢 Components: ${page.components.length}');

                    await savedFormsService.saveFormWithCustomFormat(
                      formId: formId,
                      name: defaultName,
                      description: 'Auto-saved form',
                      formData: formToSave,
                      originalConfigKey: page.pageId,
                    );

                    debugPrint('✅ Form saved successfully!');

                    if (context.mounted) {
                      // Show success dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (dialogContext) => AlertDialog(
                          title: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Form Saved'),
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Form saved successfully as:'),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  defaultName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'You can access saved forms from the main screen.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(
                                  dialogContext,
                                ).pop(); // Close dialog
                                Navigator.of(context).popUntil(
                                  (route) => route.isFirst,
                                ); // Go to main screen
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  } catch (e) {
                    debugPrint('❌ Error saving form: $e');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error saving form: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: StyleUtils.parseColor(style['backgroundColor']),
            foregroundColor: StyleUtils.parseColor(style['color']),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                style['borderRadius']?.toDouble() ?? 8,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (config['icon'] != null) ...[
                Icon(
                  _mapIconNameToIconData(config['icon']) ??
                      (canSave ? Icons.save : Icons.lock),
                  size: style['iconSize']?.toDouble() ?? 18,
                  color: canSave ? null : Colors.red.withValues(alpha: 0.4),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                canSave
                    ? (config['label'] ?? 'Save')
                    : 'Need Complete all fields',
                style: TextStyle(
                  color: canSave ? null : Colors.red.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData? _mapIconNameToIconData(String? iconName) {
    if (iconName == null) return null;
    // Add your icon mapping logic here
    switch (iconName.toLowerCase()) {
      case 'save':
        return Icons.save;
      case 'check_circle':
        return Icons.check_circle;
      case 'check':
        return Icons.check;
      default:
        return Icons.save;
    }
  }

  void _showFormSubmission(BuildContext context, DynamicFormPageModel page) {
    final formData = <String, dynamic>{};

    for (final component in page.components) {
      if (component.config['value'] != null) {
        formData[component.id] = component.config['value'];
      }
    }

    final submissionData = {
      'timestamp': DateTime.now().toIso8601String(),
      'formData': formData,
      'metadata': {
        'totalFields': page.components.length,
        'filledFields': formData.length,
        'completionPercentage': (formData.length / page.components.length * 100)
            .round(),
      },
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        elevation: 16,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450, maxHeight: 600),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10b981),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.save_alt_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Save Form Data',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1f2937),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Form data saved successfully!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Saved ${(submissionData['metadata'] as Map)['filledFields']} of ${(submissionData['metadata'] as Map)['totalFields']} fields',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          Navigator.of(context).pop(); // Go back to main form
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle),
                            SizedBox(width: 8),
                            Text(
                              'Done',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
        ),
      ),
    );
  }
}
