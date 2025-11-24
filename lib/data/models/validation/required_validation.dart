import 'package:dynamic_form_bi/data/models/validation/base_validation.dart';

class RequiredValidation extends BaseValidation {
  final bool isRequired;
  final String? errorMessage;

  const RequiredValidation({
    this.isRequired = false,
    this.errorMessage,
  });

  factory RequiredValidation.fromJson(Map<String, dynamic> json) {
    return RequiredValidation(
      isRequired: json['isRequired'] is bool ? json['isRequired'] : false,
      errorMessage: json['error_message']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{};

    if (isRequired) result['isRequired'] = isRequired;
    if (errorMessage != null) result['error_message'] = errorMessage;

    return result;
  }

  @override
  List<Object?> get props => [isRequired, errorMessage];

  RequiredValidation copyWith({
    bool? isRequired,
    String? errorMessage,
  }) {
    return RequiredValidation(
      isRequired: isRequired ?? this.isRequired,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
