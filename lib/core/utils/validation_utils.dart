// ignore_for_file: non_constant_identifier_names

import 'package:dynamic_form_bi/data/models/button_condition_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:flutter/material.dart';

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
    Map<String, dynamic>? inputTypes,
    String? value,
    String? configuredType,
  ) {
    // Null safety checks
    if (inputTypes == null || inputTypes.isEmpty) return null;
    if (configuredType != null) return configuredType;
    if (value == null || value.trim().isEmpty) return inputTypes.keys.first;

    // Check email pattern
    if (inputTypes.containsKey('email') &&
        RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
      return 'email';
    }

    // Check tel pattern
    if (inputTypes.containsKey('tel') &&
        RegExp(r'^[0-9+\-\s()]+$').hasMatch(value)) {
      return 'tel';
    }

    // Fallback order
    const fallbackOrder = ['password', 'text'];
    for (final type in fallbackOrder) {
      if (inputTypes.containsKey(type)) return type;
    }

    return inputTypes.keys.isNotEmpty ? inputTypes.keys.first : null;
  }

  /// Determine component state with null safety
  static String determineComponentState(
    String? value,
    String? errorText, {
    String? explicitState,
  }) {
    if (explicitState != null && explicitState.isNotEmpty) return explicitState;
    if (errorText != null && errorText.isNotEmpty) return 'error';
    if (value != null && value.toString().isNotEmpty) return 'success';
    return 'base';
  }

  /// Centralized form validation with comprehensive error handling
  static String? validateForm(DynamicFormModel component, String? value) {
    try {
      // Null safety for value
      final safeValue = value ?? '';

      // Required field check
      if ((component.config['isRequired'] ?? false) &&
          safeValue.trim().isEmpty) {
        return component.config['requiredMessage'] ?? 'Trường này là bắt buộc';
      }

      if (safeValue.trim().isEmpty) return null;

      final inputTypes = component.inputTypes;
      if (inputTypes == null || inputTypes.isEmpty) return null;

      final selectedType = detectInputType(
        inputTypes,
        safeValue,
        component.config['inputType'],
      );

      if (selectedType == null || !inputTypes.containsKey(selectedType)) {
        return null;
      }

      final validation =
          inputTypes[selectedType]?['validation'] as Map<String, dynamic>?;
      if (validation == null) return null;

      return _validateByRules(safeValue, validation);
    } catch (e) {
      debugPrint('Form validation error for ${component.id}: $e');
      return 'Validation error occurred';
    }
  }

  static String? _validateByRules(
    String value,
    Map<String, dynamic> validation,
  ) {
    final minLength = validation['min_length'] ?? 0;
    final maxLength = validation['max_length'] ?? 9999;
    final regexStr = validation['regex'] ?? '';
    final errorMsg = validation['error_message'] ?? 'Invalid input';

    // Length validation
    if (value.length < minLength || value.length > maxLength) {
      return errorMsg;
    }

    // Regex validation
    if (regexStr.isNotEmpty) {
      try {
        if (!RegExp(regexStr).hasMatch(value)) return errorMsg;
      } catch (e) {
        debugPrint('Invalid regex pattern: $regexStr');
        return 'Invalid format';
      }
    }

    return null;
  }
}
