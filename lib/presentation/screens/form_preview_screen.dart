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
    // Create a comprehensive disabled config for all component types
    final disabledConfig = Map<String, dynamic>.from(component.config);

    // Universal disable flags
    disabledConfig.addAll({
      'disabled': true, // For buttons, inputs
      'readOnly': true, // For text fields, text areas
      'editable': false, // For general editing
      'interactive': false, // For custom components
      'clickable': false, // For buttons, selectors
      'selectable': false, // For dropdowns, selects
      'draggable': false, // For file uploaders
      'uploadable': false, // For file uploaders
      'checkable': false, // For checkboxes, radios
      'switchable': false, // For switches
      'slidable': false, // For sliders
      'expandable': false, // For expandable components
      'focusable': false, // Prevent focus
      'onTap': null, // Remove tap handlers
      'onChanged': null, // Remove change handlers
      'onPressed': null, // Remove press handlers
      'onSubmitted': null, // Remove submit handlers
      'onUpload': null, // Remove upload handlers
    });

    // Enhanced preview styles with visual indicators
    final previewStyle = Map<String, dynamic>.from(component.style);
    previewStyle.addAll({
      'opacity': 0.7, // Fade to indicate disabled
      'pointer_events': 'none', // Block all pointer events
      'user_select': 'none', // Prevent text selection
      'cursor': 'default', // Default cursor (not pointer)
    });

    // For input components, add visual disabled state
    if ([
      'textFieldFormType',
      'textAreaFormType',
      'selectFormType',
    ].contains(component.type.toString().split('.').last)) {
      previewStyle.addAll({
        'background_color': previewStyle['background_color'] ?? '#f5f5f5',
        'border_color': '#d1d5db', // Gray border for disabled look
        'color': '#6b7280', // Gray text for disabled look
      });
    }

    // Create preview component with same ID (for BLoC sync) but disabled
    final previewComponent = DynamicFormModel(
      id: component.id, // Keep same ID for BLoC state sync
      type: component.type,
      order: component.order,
      config: disabledConfig,
      style: previewStyle,
      inputTypes: component.inputTypes,
      variants: component.variants,
      states: component.states,
      validation: component.validation,
      children: component.children,
    );

    // Wrap in IgnorePointer to completely block interactions
    return IgnorePointer(
      ignoring: true, // Block ALL touch interactions
      child: AbsorbPointer(
        absorbing: true, // Absorb pointer events
        child: DynamicFormRenderer(component: previewComponent, page: page),
      ),
    );
  }

  Widget _buildPreviewSaveButton(DynamicFormModel saveButton) {
    return BlocBuilder<DynamicFormBloc, DynamicFormState>(
      builder: (context, state) {
        // First check if there are any validation errors in the current state
        bool hasValidationErrors = false;
        if (state.page != null) {
          hasValidationErrors = _hasValidationErrorsRecursive(
            state.page!.components,
          );
        }

        // Check conditions - only for components that actually exist
        bool conditionsPass = false;
        final conditions = saveButton.config['conditions'] as List<dynamic>?;

        if (conditions != null && conditions.isNotEmpty) {
          final buttonConditions = conditions
              .map((c) => ButtonCondition.fromJson(c as Map<String, dynamic>))
              .toList();

          debugPrint(
            '🔍 Checking conditions for Save button: ${saveButton.id}',
          );
          debugPrint('📋 Found ${buttonConditions.length} conditions to check');

          // Get list of existing component IDs
          final currentComponents = state.page?.components ?? page.components;
          final existingComponentIds = currentComponents
              .map((c) => c.id)
              .toSet();
          debugPrint('📋 Existing components: $existingComponentIds');

          // Filter conditions to only check existing components
          final validConditions = buttonConditions.where((condition) {
            final exists = existingComponentIds.contains(condition.componentId);
            if (!exists) {
              debugPrint(
                '⚠️ Skipping condition for non-existent component: ${condition.componentId}',
              );
            }
            return exists;
          }).toList();

          debugPrint(
            '📋 Valid conditions (for existing components): ${validConditions.length}',
          );

          if (validConditions.isEmpty) {
            // If no valid conditions, consider it as pass (no requirements)
            conditionsPass = true;
            debugPrint('✅ No valid conditions found - considering as pass');
          } else {
            // Use centralized validation for valid conditions only
            final validationResult = ValidationUtils.validateButtonConditions(
              validConditions,
              currentComponents,
            );

            conditionsPass = validationResult.isValid;

            if (!conditionsPass) {
              debugPrint(
                '❌ Condition failed: ${validationResult.errorMessage}',
              );
            }
          }
        } else {
          conditionsPass = true; // No conditions means always pass
        }

        // Can only save if both conditions pass AND no validation errors
        final canSave = conditionsPass && !hasValidationErrors;

        debugPrint(
          '💾 Save button state: conditionsPass=$conditionsPass, hasValidationErrors=$hasValidationErrors, canSave=$canSave',
        );

        // If conditions are not met, show message instead of Save button
        if (!canSave) {
          debugPrint('🚫 Save button hidden - conditions not met');
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.orange.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Complete all required fields',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        // Get button styles from Remote Config
        final style = Map<String, dynamic>.from(saveButton.style);
        final config = Map<String, dynamic>.from(saveButton.config);

        debugPrint('💾 Rendering Save button with canSave: $canSave');
        debugPrint('🎯 Button label: ${config['label'] ?? 'Save'}');
        debugPrint('🔧 Button icon: ${config['icon']}');

        return ElevatedButton(
          onPressed: () async {
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
          },
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
                  _mapIconNameToIconData(config['icon']) ?? Icons.save,
                  size: style['iconSize']?.toDouble() ?? 18,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                config['label'] ?? 'Save',
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

  // Thêm hàm kiểm tra lỗi validation cho toàn bộ cây component
  bool _hasValidationErrorsRecursive(List components) {
    for (final component in components) {
      // Check top-level error
      final errorText = component.config['error_text'];
      final currentState = component.config['current_state'];

      // Check nested value error (for components that store state in value)
      final value = component.config['value'];
      String? nestedErrorText;
      String? nestedCurrentState;
      if (value is Map) {
        nestedErrorText = value['error_text']?.toString();
        nestedCurrentState = value['current_state']?.toString();
      }

      if ((errorText != null && errorText.toString().isNotEmpty) ||
          currentState == 'error' ||
          (nestedErrorText != null && nestedErrorText.isNotEmpty) ||
          nestedCurrentState == 'error') {
        debugPrint(
          '❌ Validation error in ${component.id}: error_text=$errorText, current_state=$currentState, nested_error_text=$nestedErrorText, nested_current_state=$nestedCurrentState',
        );
        return true;
      }

      // Check children recursively if present
      if (component.children != null && component.children!.isNotEmpty) {
        if (_hasValidationErrorsRecursive(component.children!)) {
          return true;
        }
      }
    }
    return false;
  }
}
