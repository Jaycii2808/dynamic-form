import 'package:dynamic_form_bi/data/models/components/component_values_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_multi/dynamic_form_multi_model.dart';
import 'package:dynamic_form_bi/data/models/form_submission/form_submission_model.dart';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:flutter/material.dart';

class FormSubmissionConverter {
  /// Convert ComponentValuesModel and DynamicMultiPageFormModel to readable FormSubmissionModel
  static FormSubmissionModel convertToSubmissionModel({
    required ComponentValuesModel componentValues,
    required DynamicMultiPageFormModel formModel,
  }) {
    final List<FormFieldData> fields = [];

    // Iterate through all pages and components to extract readable data
    for (final page in formModel.pages) {
      for (final component in page.components) {
        // Skip buttons and non-input components
        if (_isInputComponent(component.type)) {
          final value = componentValues.getValue(component.id);

          // Only include components that have values (skip empty fields)
          if (value != null && _hasValidValue(value)) {
            final fieldData = FormFieldData(
              label:
                  component.config.label ??
                  _generateLabelFromType(component.type),
              value: value,
              componentType: _getReadableComponentType(component.type),
              isRequired: component.config.isRequired ?? false,
              placeholder: component.config.placeholder,
            );
            fields.add(fieldData);
          }
        }
      }
    }

    return FormSubmissionModel(
      formId: formModel.formId,
      formName: formModel.name,
      submissionTime: DateTime.now(),
      fields: fields,
    );
  }

  /// Check if component type is an input component (not button, container, etc.)
  static bool _isInputComponent(FormTypeEnum type) {
    const nonInputTypes = {
      FormTypeEnum.buttonFormType,
      FormTypeEnum.container,
      FormTypeEnum.unknown,
    };

    return !nonInputTypes.contains(type);
  }

  /// Check if value is valid for form submission
  static bool _hasValidValue(dynamic value) {
    if (value == null) return false;

    try {
      if (value is String) {
        return value.trim().isNotEmpty;
      }
      if (value is List) {
        return value.isNotEmpty;
      }
      if (value is bool) {
        return true; // Include both true and false values
      }
      if (value is num) {
        return true; // Include all numbers
      }
      // For other types, check if toString() produces a non-empty string
      return value.toString().trim().isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error checking value validity: $e');
      return false;
    }
  }

  /// Generate readable label from component type if no label is provided
  static String _generateLabelFromType(FormTypeEnum type) {
    switch (type) {
      case FormTypeEnum.textFieldFormType:
        return 'Text Field';
      case FormTypeEnum.textAreaFormType:
        return 'Text Area';
      case FormTypeEnum.dateTimePickerFormType:
        return 'Date & Time';
      case FormTypeEnum.dateTimeRangePickerFormType:
        return 'Date Range';
      case FormTypeEnum.selectorButtonFormType:
        return 'Selector';
      case FormTypeEnum.switchFormType:
        return 'Switch';
      case FormTypeEnum.textFieldTagsFormType:
        return 'Tags';
      case FormTypeEnum.buttonFormType:
        return 'Button';
      case FormTypeEnum.container:
        return 'Container';
      case FormTypeEnum.unknown:
        return 'Field';
    }
  }

  /// Get readable component type name
  static String _getReadableComponentType(FormTypeEnum type) {
    return type.toString().split('.').last.replaceAll('FormType', '');
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
