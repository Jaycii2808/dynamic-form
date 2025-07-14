class InputTypeValidationModel {
  final String? regex;
  final String? errorMessage;
  final int? minLength;
  final int? maxLength;

  InputTypeValidationModel({
    this.regex,
    this.errorMessage,
    this.minLength,
    this.maxLength,
  });

  factory InputTypeValidationModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return InputTypeValidationModel();
    return InputTypeValidationModel(
      regex: json['regex'] as String?,
      errorMessage: json['error_message'] as String?,
      minLength: json['min_length'] is int
          ? json['min_length']
          : (json['min_length'] is String
          ? int.tryParse(json['min_length'])
          : null),
      maxLength: json['max_length'] is int
          ? json['max_length']
          : (json['max_length'] is String
          ? int.tryParse(json['max_length'])
          : null),
    );
  }

  Map<String, dynamic> toJson() => {
    if (regex != null) 'regex': regex,
    if (errorMessage != null) 'error_message': errorMessage,
    if (minLength != null) 'min_length': minLength,
    if (maxLength != null) 'max_length': maxLength,
  };
}
