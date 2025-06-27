import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:flutter/material.dart';

String? validateForm(DynamicFormModel component, String value) {
  if ((component.config['isRequired'] ?? false) && value.trim().isEmpty) {
    return 'Trường này là bắt buộc';
  }

  if (value.trim().isEmpty) {
    return null;
  }

  final inputTypes = component.inputTypes;
  if (inputTypes != null && inputTypes.isNotEmpty) {
    String? selectedType;

    if (component.config['inputType'] != null) {
      selectedType = component.config['inputType'];
    }

    if (selectedType == null) {
      if (inputTypes.containsKey('email') && value.contains('@')) {
        selectedType = 'email';
      } else if (inputTypes.containsKey('tel') &&
          RegExp(r'^[0-9+\-\s()]+$').hasMatch(value)) {
        selectedType = 'tel';
      } else if (inputTypes.containsKey('password')) {
        selectedType = 'password';
      } else if (inputTypes.containsKey('text')) {
        selectedType = 'text';
      }
    }

    selectedType ??= inputTypes.keys.first;

    if (inputTypes.containsKey(selectedType)) {
      final typeConfig = inputTypes[selectedType];
      final validation = typeConfig['validation'] as Map<String, dynamic>?;

      if (validation != null) {
        final minLength = validation['min_length'] ?? 0;
        final maxLength = validation['max_length'] ?? 9999;
        final regexStr = validation['regex'] ?? '';
        final errorMsg = validation['error_message'] ?? 'Invalid input';

        if (value.length < minLength || value.length > maxLength) {
          return errorMsg;
        }

        if (regexStr.isNotEmpty) {
          try {
            final regex = RegExp(regexStr);
            if (!regex.hasMatch(value)) {
              return errorMsg;
            }
          } catch (e) {
            debugPrint('Invalid regex pattern: $regexStr');
          }
        }
      }
    }
  }

  return null;
}
