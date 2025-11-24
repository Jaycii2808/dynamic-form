import 'package:dynamic_form_bi/data/models/validation/base_validation.dart';
import 'package:dynamic_form_bi/data/models/validation/required_validation.dart';
import 'package:dynamic_form_bi/data/models/validation/max_selections_validation.dart';
import 'package:dynamic_form_bi/data/models/validation/button_condition_validation_model.dart';

class CompositeValidationModel extends BaseValidation {
  final RequiredValidation? required;
  final MaxSelectionsValidation? maxSelections;
  final ButtonConditionValidationModel? buttonCondition;

  const CompositeValidationModel({
    this.required,
    this.maxSelections,
    this.buttonCondition,
  });

  factory CompositeValidationModel.fromJson(Map<String, dynamic> json) {
    RequiredValidation? required;
    MaxSelectionsValidation? maxSelections;
    ButtonConditionValidationModel? buttonCondition;

    // Parse required validation
    if (json['required'] != null) {
      required = RequiredValidation.fromJson(json['required']);
    }

    // Parse max selections validation
    if (json['max_selections'] != null) {
      maxSelections = MaxSelectionsValidation.fromJson(json['max_selections']);
    }

    // Parse button condition validation
    if (json['condition'] != null) {
      buttonCondition = ButtonConditionValidationModel.fromJson(json);
    }

    return CompositeValidationModel(
      required: required,
      maxSelections: maxSelections,
      buttonCondition: buttonCondition,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{};

    if (required != null) result['required'] = required!.toJson();
    if (maxSelections != null) {
      result['max_selections'] = maxSelections!.toJson();
    }
    if (buttonCondition != null) result.addAll(buttonCondition!.toJson());

    return result;
  }

  @override
  List<Object?> get props => [required, maxSelections, buttonCondition];

  CompositeValidationModel copyWith({
    RequiredValidation? required,
    MaxSelectionsValidation? maxSelections,
    ButtonConditionValidationModel? buttonCondition,
  }) {
    return CompositeValidationModel(
      required: required ?? this.required,
      maxSelections: maxSelections ?? this.maxSelections,
      buttonCondition: buttonCondition ?? this.buttonCondition,
    );
  }

  bool get hasValidation =>
      required != null || maxSelections != null || buttonCondition != null;
}
