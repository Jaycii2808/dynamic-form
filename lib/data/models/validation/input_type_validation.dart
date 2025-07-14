import 'base_validation.dart';

class InputTypeValidation extends BaseValidation {
  final String? regex;
  final String? errorMessage;
  final int? minLength;
  final int? maxLength;

  const InputTypeValidation({
    this.regex,
    this.errorMessage,
    this.minLength,
    this.maxLength,
  });

  factory InputTypeValidation.fromJson(Map<String, dynamic> json) {
    return InputTypeValidation(
      regex: json['regex']?.toString(),
      errorMessage: json['error_message']?.toString(),
      minLength: json['min_length'] is int ? json['min_length'] : null,
      maxLength: json['max_length'] is int ? json['max_length'] : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{};

    if (regex != null) result['regex'] = regex;
    if (errorMessage != null) result['error_message'] = errorMessage;
    if (minLength != null) result['min_length'] = minLength;
    if (maxLength != null) result['max_length'] = maxLength;

    return result;
  }

  @override
  List<Object?> get props => [regex, errorMessage, minLength, maxLength];

  InputTypeValidation copyWith({
    String? regex,
    String? errorMessage,
    int? minLength,
    int? maxLength,
  }) {
    return InputTypeValidation(
      regex: regex ?? this.regex,
      errorMessage: errorMessage ?? this.errorMessage,
      minLength: minLength ?? this.minLength,
      maxLength: maxLength ?? this.maxLength,
    );
  }
}
