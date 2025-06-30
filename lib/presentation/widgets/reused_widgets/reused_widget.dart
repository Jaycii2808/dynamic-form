import 'package:dynamic_form_bi/core/utils/validation_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:flutter/material.dart';

/// Use centralized validation from ValidationUtils with null safety
/// This eliminates complex if-else logic and standardizes validation
String? validateForm(DynamicFormModel component, String? value) {
  try {
    return ValidationUtils.validateForm(component, value);
  } catch (e) {
    debugPrint('Validation error for ${component.id}: $e');
    return 'Validation error occurred';
  }
}
