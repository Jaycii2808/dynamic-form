import 'base_validation.dart';
import 'required_validation.dart';
import 'max_selections_validation.dart';
import 'button_condition_validation.dart';

class CompositeValidation extends BaseValidation {
  final RequiredValidation? required;
  final MaxSelectionsValidation? maxSelections;
  final ButtonConditionValidation? buttonCondition;

  const CompositeValidation({
    this.required,
    this.maxSelections,
    this.buttonCondition,
  });

  factory CompositeValidation.fromJson(Map<String, dynamic> json) {
    RequiredValidation? required;
    MaxSelectionsValidation? maxSelections;
    ButtonConditionValidation? buttonCondition;

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
      buttonCondition = ButtonConditionValidation.fromJson(json);
    }

    return CompositeValidation(
      required: required,
      maxSelections: maxSelections,
      buttonCondition: buttonCondition,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{};

    if (required != null) result['required'] = required!.toJson();
    if (maxSelections != null)
      result['max_selections'] = maxSelections!.toJson();
    if (buttonCondition != null) result.addAll(buttonCondition!.toJson());

    return result;
  }

  @override
  List<Object?> get props => [required, maxSelections, buttonCondition];

  CompositeValidation copyWith({
    RequiredValidation? required,
    MaxSelectionsValidation? maxSelections,
    ButtonConditionValidation? buttonCondition,
  }) {
    return CompositeValidation(
      required: required ?? this.required,
      maxSelections: maxSelections ?? this.maxSelections,
      buttonCondition: buttonCondition ?? this.buttonCondition,
    );
  }

  bool get hasValidation =>
      required != null || maxSelections != null || buttonCondition != null;
}
