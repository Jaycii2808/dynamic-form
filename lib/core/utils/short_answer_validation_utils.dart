import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/validation/short_answer_validation_model.dart';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:flutter/foundation.dart';

/// Utility class for shortAnswer validation that can be reused across the application
class ShortAnswerValidationUtils {
  /// Validate a shortAnswer component with its current value
  /// Returns null if validation passes, error message if validation fails
  static String? validateShortAnswerComponent(
    DynamicFormModel component,
    String? value,
  ) {
    if (component.type != FormTypeEnum.shortAnswerFormType) {
      return null; // Not a shortAnswer component
    }

    // If no value provided, let required validation handle it
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    // Prefer typed validation on the component
    final validation = component.validation;
    if (validation is ShortAnswerValidationModel) {
      final shortAnswerValidation = validation as ShortAnswerValidationModel;
      debugPrint(
        '🔍 [ShortAnswerValidationUtils] Validating shortAnswer (typed): ${component.id}, value: "$value"',
      );
      return shortAnswerValidation.validateValue(value);
    }

    // Fallback: parse from config.validate (exported JSON path)
    final rawValidate = component.config?.validate;
    if (rawValidate is Map<String, dynamic>) {
      final parsed = ShortAnswerValidationModel.fromJson(rawValidate);
      debugPrint(
        '🔍 [ShortAnswerValidationUtils] Validating shortAnswer (config.validate): ${component.id}, value: "$value"',
      );
      return parsed.validateValue(value);
    }

    debugPrint(
      '⚠️ [ShortAnswerValidationUtils] No validation config found for shortAnswer component: ${component.id}',
    );
    return null;
  }

  /// Validate multiple shortAnswer components in a list
  /// Returns list of validation errors
  static List<String> validateShortAnswerComponents(
    List<DynamicFormModel> components,
    Map<String, dynamic> componentValues,
  ) {
    final List<String> validationErrors = [];

    for (final component in components) {
      if (component.type == FormTypeEnum.shortAnswerFormType) {
        final value = componentValues[component.id];
        final validationError = validateShortAnswerComponent(
          component,
          value?.toString(),
        );

        if (validationError != null) {
          final fieldName = component.config?.label ?? component.id;
          validationErrors.add('$fieldName: $validationError');
        }
      }
    }

    return validationErrors;
  }

  /// Get keyboard type for shortAnswer component based on validation type
  static String getKeyboardTypeForShortAnswer(DynamicFormModel component) {
    if (component.type != FormTypeEnum.shortAnswerFormType) {
      return 'text';
    }

    final validation = component.validation;
    if (validation != null && validation is ShortAnswerValidationModel) {
      final shortAnswerValidation = validation as ShortAnswerValidationModel;
      if (shortAnswerValidation.validationType ==
          ShortAnswerValidationType.number) {
        return 'number';
      }
    }

    return 'text';
  }
}
