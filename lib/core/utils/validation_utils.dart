// ignore_for_file: non_constant_identifier_names

import 'package:dynamic_form_bi/data/models/components/button_condition_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_types/input_type_validation_model.dart';
import 'package:dynamic_form_bi/data/models/input_types/input_types_model.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:flutter/material.dart';

/// Result class for button validation operations
class ButtonValidationResult {
  final bool isValid;
  final String? errorMessage;
  final ButtonCondition? failedCondition;

  const ButtonValidationResult({
    required this.isValid,
    this.errorMessage,
    this.failedCondition,
  });
}

class ValidationUtils {
  /// Centralized validation for button conditions with null safety
  static bool validateCondition(ButtonCondition condition, dynamic value) {
    try {
      final result = _getValidationResult(
        condition.rule,
        value,
        condition.expectedValue,
      );

      debugPrint(
        'Validation: ${condition.componentId} - ${condition.rule}($value) = $result',
      );
      return result;
    } catch (e) {
      debugPrint('Validation error for ${condition.componentId}: $e');
      return false; // Default to invalid on error
    }
  }

  static bool _getValidationResult(
    String rule,
    dynamic value,
    dynamic expectedValue,
  ) {
    switch (rule) {
      case 'not_null':
        return _validateNotNull(value, expectedValue);
      case 'equals':
        return _validateEquals(value, expectedValue);
      case 'not_empty':
        return _validateNotEmpty(value, expectedValue);
      default:
        debugPrint('Unknown validation rule: $rule');
        return true; // Default to valid for unknown rules
    }
  }

  static bool _validateNotNull(dynamic value, dynamic expectedValue) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    return value.toString().isNotEmpty;
  }

  static bool _validateEquals(dynamic value, dynamic expectedValue) {
    return value == expectedValue;
  }

  static bool _validateNotEmpty(dynamic value, dynamic expectedValue) {
    if (value == null) return false;
    if (value is List) return value.isNotEmpty;
    if (value is String) return value.trim().isNotEmpty;
    if (value is bool) return value == true;
    return value.toString().isNotEmpty;
  }

  /// Auto-detect input type with null safety
  static String? detectInputType(
    InputTypesModel? inputTypes,
    String? value,
  ) {
    if (inputTypes == null || inputTypes.isEmpty) return null;
    if (value == null || value.trim().isEmpty) {
      if (inputTypes.email != null) return 'email';
      if (inputTypes.tel != null) return 'tel';
      if (inputTypes.password != null) return 'password';
      if (inputTypes.multiline != null) return 'multiline';
      return null;
    }
    if (inputTypes.email != null &&
        RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
      return 'email';
    }
    if (inputTypes.tel != null && RegExp(r'^[0-9+\-\s()]+$').hasMatch(value)) {
      return 'tel';
    }
    if (inputTypes.password != null) return 'password';
    if (inputTypes.multiline != null) return 'multiline';
    return null;
  }

  /// Determine component state with null safety
  static Object determineComponentState(
    String? value,
    String? errorText, {
    String? explicitState,
  }) {
    if (explicitState != null && explicitState.isNotEmpty) return explicitState;
    if (errorText != null && errorText.isNotEmpty) return StatesEnum.error;
    if (value != null && value.toString().isNotEmpty) return StatesEnum.success;
    return StatesEnum.base;
  }

  /// Centralized form validation with comprehensive error handling
  static String? validateForm(DynamicFormModel component, String? value) {
    try {
      final safeValue = value ?? '';
      final config = component.config;
      if (config == null) return null;
      if ((config.isRequired ?? false) && safeValue.trim().isEmpty) {
        return config.errorText ?? 'This field is required';
      }
      if (safeValue.trim().isEmpty) return null;
      final inputTypes = component.inputTypes;
      if (inputTypes == null || inputTypes.isEmpty) return null;
      String? selectedType = detectInputType(
        inputTypes,
        safeValue, // No inputType property in ConfigModel, rely on auto-detection
      );
      // Fallback for textAreaFormType: if multiline is missing, use text
      if (component.type.toString().contains('textAreaFormType')) {
        if (selectedType == null && inputTypes.text != null) {
          selectedType = 'text';
        }
      }
      debugPrint(
        'validateForm: id=${component.id}, selectedType=$selectedType, value="$safeValue"',
      );
      InputTypeValidationModel? validation;
      if (selectedType == 'text') {
        validation = inputTypes.text;
      } else if (selectedType == 'multiline') {
        validation = inputTypes.multiline ?? inputTypes.text;
      } else if (selectedType == 'email') {
        validation = inputTypes.email;
      } else if (selectedType == 'tel') {
        validation = inputTypes.tel;
      } else if (selectedType == 'password') {
        validation = inputTypes.password;
      }
      if (validation != null) {
        debugPrint('validateForm: using validation=${validation.toJson()}');
        if (validation.minLength != null &&
            safeValue.length < validation.minLength!) {
          return validation.errorMessage ?? 'Too short';
        }
        if (validation.maxLength != null &&
            safeValue.length > validation.maxLength!) {
          return validation.errorMessage ?? 'Too long';
        }
        if (validation.regex != null) {
          final regex = RegExp(validation.regex!);
          final matches = regex.hasMatch(safeValue);
          debugPrint(
            'validateForm: regex=${validation.regex}, value="$safeValue", matches=$matches',
          );
          if (!matches) {
            return validation.errorMessage ?? 'Incorrect format';
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Form validation error for ${component.id}: $e');
      return 'Validation error occurred';
    }
  }

  /// Centralized button conditions validation - eliminates duplicated if-else logic
  static ButtonValidationResult validateButtonConditions(
    List<ButtonCondition> conditions,
    List<DynamicFormModel> components,
  ) {
    for (final condition in conditions) {
      final targetComponent = components.cast<DynamicFormModel?>().firstWhere(
        (comp) => comp?.id == condition.componentId,
        orElse: () => null,
      );

      if (targetComponent == null) {
        return ButtonValidationResult(
          isValid: false,
          errorMessage: 'Component ${condition.componentId} not found',
          failedCondition: condition,
        );
      }

      final value = targetComponent.config?.value;
      if (!validateCondition(condition, value)) {
        return ButtonValidationResult(
          isValid: false,
          errorMessage: condition.errorMessage,
          failedCondition: condition,
        );
      }
    }

    return const ButtonValidationResult(isValid: true);
  }

  /// Centralized state determination - replaces multiple if-else chains
  static Object determineFieldState(
    String? value,
    String? errorText, {
    bool? boolValue,
    List<dynamic>? listValue,
  }) {
    if (errorText != null && errorText.isNotEmpty) return StatesEnum.error;

    // For boolean fields (checkbox, switch, radio)
    if (boolValue != null) {
      return boolValue ? StatesEnum.success : StatesEnum.base;
    }

    // For list fields (multi-select, tags)
    if (listValue != null) {
      return listValue.isNotEmpty ? StatesEnum.success : StatesEnum.base;
    }

    // For text fields
    if (value != null && value.toString().trim().isNotEmpty) {
      return StatesEnum.success;
    }

    return StatesEnum.base;
  }

  /// Smart field update data creation - reduces boilerplate
  static Map<String, dynamic> createFieldUpdateData({
    required dynamic value,
    String? errorText,
    String? explicitState,
    bool? selected,
    Map<String, dynamic>? additionalData,
  }) {
    final state =
        explicitState ??
        determineFieldState(
          value?.toString(),
          errorText,
          boolValue: selected,
          listValue: value is List ? value : null,
        );

    final data = <String, dynamic>{'value': value, 'current_state': state};

    // Always set error_text, even when null to clear previous errors
    data['error_text'] = errorText;
    if (selected != null) data['selected'] = selected;
    if (additionalData != null) data.addAll(additionalData);

    return data;
  }
}
