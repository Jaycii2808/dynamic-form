import 'base_validation.dart';
import 'composite_validation.dart';
import 'required_validation.dart';
import 'max_selections_validation.dart';
import 'button_condition_validation.dart';

class ValidationFactory {
  static BaseValidation? fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return null;

    // Check if it's a composite validation (has multiple validation types)
    final hasMultipleValidations = _hasMultipleValidations(json);

    if (hasMultipleValidations) {
      return CompositeValidation.fromJson(json);
    }

    // Check for specific validation types
    if (json['required'] != null) {
      return RequiredValidation.fromJson(json['required']);
    }

    if (json['max_selections'] != null) {
      return MaxSelectionsValidation.fromJson(json['max_selections']);
    }

    if (json['condition'] != null) {
      return ButtonConditionValidation.fromJson(json);
    }

    // Check if it's a direct validation object
    if (json['isRequired'] != null || json['error_message'] != null) {
      return RequiredValidation.fromJson(json);
    }

    // Check if it's a max selections validation
    if (json['max'] != null) {
      return MaxSelectionsValidation.fromJson(json);
    }

    // Check if it's a button condition validation
    if (json['id_component'] != null) {
      return ButtonConditionValidation.fromJson({
        'condition': [json],
      });
    }

    // If no specific validation type is found, return null
    return null;
  }

  static BaseValidation empty() {
    return const CompositeValidation();
  }

  static bool _hasMultipleValidations(Map<String, dynamic> json) {
    int validationCount = 0;

    if (json['required'] != null) validationCount++;
    if (json['max_selections'] != null) validationCount++;
    if (json['condition'] != null) validationCount++;

    return validationCount > 1;
  }
}
