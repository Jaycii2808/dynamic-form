import 'package:equatable/equatable.dart';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:flutter/foundation.dart';

class ShortAnswerValidationModel extends Equatable {
  final ShortAnswerValidationType validationType;
  final NumberValidationAction? numberAction;
  final TextValidationAction? textAction;
  final LengthValidationType? lengthType;
  final RegexValidationAction? regexAction;
  final String? validationValue;
  final String? errorMessage;

  const ShortAnswerValidationModel({
    this.validationType = ShortAnswerValidationType.number,
    this.numberAction,
    this.textAction,
    this.lengthType,
    this.regexAction,
    this.validationValue,
    this.errorMessage,
  });

  factory ShortAnswerValidationModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ShortAnswerValidationModel();
    }

    ShortAnswerValidationType parseValidationType(String? type) {
      if (type == null) return ShortAnswerValidationType.number;
      try {
        return ShortAnswerValidationType.values.firstWhere(
          (e) => e.name == type,
        );
      } catch (e) {
        return ShortAnswerValidationType.number;
      }
    }

    NumberValidationAction? parseNumberAction(String? action) {
      if (action == null) return null;
      try {
        return NumberValidationAction.values.firstWhere(
          (e) => e.name == action,
        );
      } catch (e) {
        return null;
      }
    }

    TextValidationAction? parseTextAction(String? action) {
      if (action == null) return null;
      try {
        return TextValidationAction.values.firstWhere(
          (e) => e.name == action,
        );
      } catch (e) {
        return null;
      }
    }

    LengthValidationType? parseLengthType(String? type) {
      if (type == null) return null;
      try {
        return LengthValidationType.values.firstWhere(
          (e) => e.name == type,
        );
      } catch (e) {
        return null;
      }
    }

    RegexValidationAction? parseRegexAction(String? action) {
      if (action == null) return null;
      try {
        return RegexValidationAction.values.firstWhere(
          (e) => e.name == action,
        );
      } catch (e) {
        return null;
      }
    }

    return ShortAnswerValidationModel(
      validationType: parseValidationType(json['validation_type'] as String?),
      numberAction: parseNumberAction(json['number_action'] as String?),
      textAction: parseTextAction(json['text_action'] as String?),
      lengthType: parseLengthType(json['length_type'] as String?),
      regexAction: parseRegexAction(json['regex_action'] as String?),
      validationValue: json['validation_value'] as String?,
      errorMessage: json['error_message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'validation_type': validationType.name,
      if (numberAction != null) 'number_action': numberAction!.name,
      if (textAction != null) 'text_action': textAction!.name,
      if (lengthType != null) 'length_type': lengthType!.name,
      if (regexAction != null) 'regex_action': regexAction!.name,
      if (validationValue != null) 'validation_value': validationValue,
      if (errorMessage != null) 'error_message': errorMessage,
    };
  }

  @override
  List<Object?> get props => [
    validationType,
    numberAction,
    textAction,
    lengthType,
    regexAction,
    validationValue,
    errorMessage,
  ];

  ShortAnswerValidationModel copyWith({
    ShortAnswerValidationType? validationType,
    NumberValidationAction? numberAction,
    TextValidationAction? textAction,
    LengthValidationType? lengthType,
    RegexValidationAction? regexAction,
    String? validationValue,
    String? errorMessage,
  }) {
    return ShortAnswerValidationModel(
      validationType: validationType ?? this.validationType,
      numberAction: numberAction ?? this.numberAction,
      textAction: textAction ?? this.textAction,
      lengthType: lengthType ?? this.lengthType,
      regexAction: regexAction ?? this.regexAction,
      validationValue: validationValue ?? this.validationValue,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Validate input value based on current validation configuration
  String? validateValue(String value) {
    debugPrint('🔍 Validating value: "$value" with type: $validationType');

    if (value.trim().isEmpty) {
      return null; // Let required validation handle empty values
    }

    switch (validationType) {
      case ShortAnswerValidationType.number:
        return _validateNumber(value);
      case ShortAnswerValidationType.text:
        return _validateText(value);
      case ShortAnswerValidationType.length:
        return _validateLength(value);
      case ShortAnswerValidationType.regularExpression:
        return _validateRegex(value);
    }
  }

  String? _validateNumber(String value) {
    debugPrint('🔍 Validating number: "$value"');
    final numberValue = double.tryParse(value);
    if (numberValue == null) {
      debugPrint('❌ Invalid number format: $value');
      return errorMessage ?? 'Please enter a valid number';
    }

    if (numberAction == null || validationValue == null) {
      debugPrint('⚠️ Missing validation configuration');
      return null;
    }

    final targetValue = double.tryParse(validationValue!);
    if (targetValue == null) {
      debugPrint('❌ Invalid target value: $validationValue');
      return errorMessage ?? 'Invalid validation configuration';
    }

    debugPrint('🔍 Comparing $numberValue ${numberAction!.name} $targetValue');

    bool isValid = false;
    switch (numberAction!) {
      case NumberValidationAction.greaterThan:
        isValid = numberValue > targetValue;
        break;
      case NumberValidationAction.lessThan:
        isValid = numberValue < targetValue;
        break;
      case NumberValidationAction.equalTo:
        isValid = numberValue == targetValue;
        break;
    }

    debugPrint('🔍 Number validation result: $isValid');
    return isValid ? null : (errorMessage ?? 'Number validation failed');
  }

  String? _validateText(String value) {
    if (textAction == null || validationValue == null) {
      return null;
    }

    bool isValid = false;
    switch (textAction!) {
      case TextValidationAction.contains:
        isValid = value.contains(validationValue!);
        break;
      case TextValidationAction.doesNotContain:
        isValid = !value.contains(validationValue!);
        break;
      case TextValidationAction.emailAddress:
        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
        isValid = emailRegex.hasMatch(value);
        break;
      case TextValidationAction.url:
        final urlRegex = RegExp(
          r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
        );
        isValid = urlRegex.hasMatch(value);
        break;
    }

    return isValid ? null : (errorMessage ?? 'Text validation failed');
  }

  String? _validateLength(String value) {
    if (lengthType == null || validationValue == null) {
      return null;
    }

    final targetLength = int.tryParse(validationValue!);
    if (targetLength == null) {
      return errorMessage ?? 'Invalid length configuration';
    }

    bool isValid = false;
    switch (lengthType!) {
      case LengthValidationType.minimumCharacterCount:
        isValid = value.length >= targetLength;
        break;
      case LengthValidationType.maximumCharacterCount:
        isValid = value.length <= targetLength;
        break;
    }

    return isValid ? null : (errorMessage ?? 'Length validation failed');
  }

  String? _validateRegex(String value) {
    if (regexAction == null || validationValue == null) {
      return null;
    }

    try {
      final regex = RegExp(validationValue!);
      bool isValid = false;

      switch (regexAction!) {
        case RegexValidationAction.contains:
          isValid = regex.hasMatch(value);
          break;
        case RegexValidationAction.doesNotContain:
          isValid = !regex.hasMatch(value);
          break;
        case RegexValidationAction.matches:
          isValid = regex.hasMatch(value);
          break;
        case RegexValidationAction.doesNotMatch:
          isValid = !regex.hasMatch(value);
          break;
      }

      return isValid ? null : (errorMessage ?? 'Regex validation failed');
    } catch (e) {
      return errorMessage ?? 'Invalid regex pattern';
    }
  }
}
