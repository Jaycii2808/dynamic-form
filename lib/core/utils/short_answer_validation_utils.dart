import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/validation/short_answer_validation_model.dart';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:flutter/material.dart';

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
      return shortAnswerValidation.validateValue(value);
    }

    // Fallback: parse from config.validate (exported JSON path)
    final rawValidate = component.config?.validate;
    if (rawValidate is Map<String, dynamic>) {
      final parsed = ShortAnswerValidationModel.fromJson(rawValidate);
      return parsed.validateValue(value);
    }

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
  static TextInputType getKeyboardTypeForShortAnswer(DynamicFormModel component) {
    if (component.type != FormTypeEnum.shortAnswerFormType) {
      return TextInputType.text;
    }

    // Prefer typed validation
    final validation = component.validation;
    if (validation is ShortAnswerValidationModel) {
      final v = validation as ShortAnswerValidationModel;
      if (v.validationType == ShortAnswerValidationType.number) {
        return TextInputType.number;
      }
    } else {
      // Fallback to config.validate
      final raw = component.config?.validate;
      if (raw is Map<String, dynamic>) {
        final parsed = ShortAnswerValidationModel.fromJson(raw);
        if (parsed.validationType == ShortAnswerValidationType.number) {
          return TextInputType.number;
        }
      }
    }

    return TextInputType.text;
  }
}
