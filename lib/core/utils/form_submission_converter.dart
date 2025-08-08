import 'package:dynamic_form_bi/data/models/components/component_values_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_multi/dynamic_form_multi_model.dart';
import 'package:dynamic_form_bi/data/models/form_submission/form_submission_model.dart';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:flutter/material.dart';

class FormSubmissionConverter {
  /// Convert ComponentValuesModel and DynamicMultiPageFormModel to readable FormSubmissionModel
  static FormSubmissionModel convertToSubmissionModel({
    required ComponentValuesModel componentValues,
    required DynamicMultiPageFormModel formModel,
  }) {
    final List<FormFieldData> fields = [];

    debugPrint('🔄 [FormSubmissionConverter] Starting conversion...');
    debugPrint(
      '🔄 [FormSubmissionConverter] Total component values: ${componentValues.length}',
    );
    debugPrint(
      '🔄 [FormSubmissionConverter] Component values: ${componentValues.values}',
    );

    // Iterate through all pages and components to extract readable data
    for (int pageIndex = 0; pageIndex < formModel.pages.length; pageIndex++) {
      final page = formModel.pages[pageIndex];
      debugPrint(
        '🔄 [FormSubmissionConverter] Processing page ${pageIndex + 1}: ${page.components.length} components',
      );

      for (int compIndex = 0; compIndex < page.components.length; compIndex++) {
        final component = page.components[compIndex];
        debugPrint(
          '🔄 [FormSubmissionConverter] Processing component: ${component.id} (${component.type})',
        );

        // Skip buttons and non-input components
        if (_isInputComponent(component.type)) {
          final value = componentValues.getValue(component.id);
          debugPrint(
            '🔄 [FormSubmissionConverter] Component ${component.id} value: $value',
          );

          final emailFieldType = EmailFieldTypeEnum.fromFormType(
            component.type,
          );

          // Convert dropdown values to labels if needed
          final processedValue = _processComponentValue(
            value: value,
            componentType: component.type,
            componentConfig: component.config,
          );

          // Include ALL input components, even empty ones for complete email data
          final fieldData = FormFieldData(
            label: component.config.label?.isNotEmpty == true
                ? component.config.label!
                : emailFieldType.displayName,
            value: processedValue ?? _getDefaultValueForType(component.type),
            componentType: emailFieldType.displayName,
            isRequired: component.config.isRequired ?? false,
            placeholder: component.config.placeholder,
            description: component.config.description, // Add description field
          );
          fields.add(fieldData);
          debugPrint(
            '✅ [FormSubmissionConverter] Added field: ${fieldData.label} = ${fieldData.displayValue}',
          );
          if (component.config.description?.isNotEmpty == true) {
            debugPrint(
              '📝 [FormSubmissionConverter] Field has description: ${component.config.description}',
            );
          }
        } else {
          debugPrint(
            '⏭️ [FormSubmissionConverter] Skipped non-input component: ${component.type}',
          );
        }
      }
    }

    debugPrint(
      '✅ [FormSubmissionConverter] Conversion complete. Total fields: ${fields.length}',
    );

    return FormSubmissionModel(
      formId: formModel.formId,
      formName: formModel.name,
      submissionTime: DateTime.now(),
      fields: fields,
    );
  }

  /// Process component value based on component type
  /// For dropdowns, convert value to label
  static dynamic _processComponentValue({
    required dynamic value,
    required FormTypeEnum componentType,
    required ConfigModel? componentConfig,
  }) {
    if (value == null) return null;

    try {
      // Handle dropdown values - convert to label
      if (componentType == FormTypeEnum.dropdownFormType && value is String) {
        final options = componentConfig?.options ?? [];
        debugPrint(
          '🔄 [FormSubmissionConverter] Processing dropdown value: $value',
        );
        debugPrint(
          '🔄 [FormSubmissionConverter] Available options: ${options.map((opt) => '${opt.value}->${opt.label}').join(', ')}',
        );

        final selectedOption = options.firstWhere(
          (option) => option.value == value,
          orElse: () {
            debugPrint(
              '⚠️ [FormSubmissionConverter] No matching option found for value: $value, using fallback',
            );
            return Option(
              value: value,
              label: value,
            ); // Fallback to value as label
          },
        );

        debugPrint(
          '🔄 [FormSubmissionConverter] Dropdown value: $value -> label: ${selectedOption.label}',
        );
        return selectedOption.label; // Return the label instead of value
      }

      // For other component types, return value as is
      return value;
    } catch (e) {
      debugPrint(
        '❌ [FormSubmissionConverter] Error processing component value: $e',
      );
      return value; // Return original value on error
    }
  }

  /// Check if component type is an input component (not button, container, etc.)
  static bool _isInputComponent(FormTypeEnum type) {
    switch (type) {
      case FormTypeEnum.buttonFormType:
      case FormTypeEnum.container:
      case FormTypeEnum.unknown:
        return false;
      case FormTypeEnum.textFieldFormType:
      case FormTypeEnum.textAreaFormType:
      case FormTypeEnum.dateTimePickerFormType:
      case FormTypeEnum.dateTimeRangePickerFormType:
      case FormTypeEnum.selectorButtonFormType:
      case FormTypeEnum.switchFormType:
      case FormTypeEnum.textFieldTagsFormType:
      case FormTypeEnum.dropdownFormType:
        return true;
    }
  }

  /// Get default value for component type when no value is provided
  static dynamic _getDefaultValueForType(FormTypeEnum type) {
    switch (type) {
      case FormTypeEnum.textFieldFormType:
      case FormTypeEnum.textAreaFormType:
        return '(No value entered)';
      case FormTypeEnum.dateTimePickerFormType:
      case FormTypeEnum.dateTimeRangePickerFormType:
        return '(No date selected)';
      case FormTypeEnum.selectorButtonFormType:
      case FormTypeEnum.switchFormType:
        return false;
      case FormTypeEnum.textFieldTagsFormType:
        return <String>[];
      case FormTypeEnum.dropdownFormType:
        return '(No option selected)';
      case FormTypeEnum.buttonFormType:
      case FormTypeEnum.container:
      case FormTypeEnum.unknown:
        return '(No value)';
    }
  }

  /// Print form submission in readable format for debugging
  static void debugPrintSubmission(FormSubmissionModel submission) {
    debugPrint('📝 Form Submission Debug:');
    debugPrint('Form: ${submission.formName} (${submission.formId})');
    debugPrint('Time: ${submission.submissionTime}');
    debugPrint('Fields (${submission.fields.length}):');

    for (int i = 0; i < submission.fields.length; i++) {
      final field = submission.fields[i];
      debugPrint('  ${i + 1}. ${field.label}: ${field.displayValue}');
    }
    debugPrint('─' * 50);
  }
}
