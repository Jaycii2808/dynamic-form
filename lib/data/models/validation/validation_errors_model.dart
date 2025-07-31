import 'package:equatable/equatable.dart';

class ValidationErrorModel extends Equatable {
  final String componentId;
  final String errorMessage;
  final DateTime timestamp;
  final String? fieldName;
  final String? validationType;

  const ValidationErrorModel({
    required this.componentId,
    required this.errorMessage,
    required this.timestamp,
    this.fieldName,
    this.validationType,
  });

  factory ValidationErrorModel.create({
    required String componentId,
    required String errorMessage,
    String? fieldName,
    String? validationType,
  }) {
    return ValidationErrorModel(
      componentId: componentId,
      errorMessage: errorMessage,
      timestamp: DateTime.now(),
      fieldName: fieldName,
      validationType: validationType,
    );
  }

  factory ValidationErrorModel.fromJson(Map<String, dynamic> json) {
    return ValidationErrorModel(
      componentId: json['componentId'] as String,
      errorMessage: json['errorMessage'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      fieldName: json['fieldName'] as String?,
      validationType: json['validationType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'componentId': componentId,
      'errorMessage': errorMessage,
      'timestamp': timestamp.toIso8601String(),
      if (fieldName != null) 'fieldName': fieldName,
      if (validationType != null) 'validationType': validationType,
    };
  }

  @override
  List<Object?> get props => [
    componentId,
    errorMessage,
    timestamp,
    fieldName,
    validationType,
  ];

  ValidationErrorModel copyWith({
    String? componentId,
    String? errorMessage,
    DateTime? timestamp,
    String? fieldName,
    String? validationType,
  }) {
    return ValidationErrorModel(
      componentId: componentId ?? this.componentId,
      errorMessage: errorMessage ?? this.errorMessage,
      timestamp: timestamp ?? this.timestamp,
      fieldName: fieldName ?? this.fieldName,
      validationType: validationType ?? this.validationType,
    );
  }
}

class ValidationErrorsModel extends Equatable {
  final Map<String, ValidationErrorModel> errors;

  const ValidationErrorsModel({
    this.errors = const {},
  });

  factory ValidationErrorsModel.empty() {
    return const ValidationErrorsModel();
  }

  // Add a validation error
  ValidationErrorsModel addError(ValidationErrorModel error) {
    final newErrors = Map<String, ValidationErrorModel>.from(errors);
    newErrors[error.componentId] = error;
    return ValidationErrorsModel(errors: newErrors);
  }

  // Add multiple validation errors
  ValidationErrorsModel addErrors(List<ValidationErrorModel> newErrors) {
    final updatedErrors = Map<String, ValidationErrorModel>.from(errors);
    for (final error in newErrors) {
      updatedErrors[error.componentId] = error;
    }
    return ValidationErrorsModel(errors: updatedErrors);
  }

  // Remove a validation error
  ValidationErrorsModel removeError(String componentId) {
    final newErrors = Map<String, ValidationErrorModel>.from(errors);
    newErrors.remove(componentId);
    return ValidationErrorsModel(errors: newErrors);
  }

  // Clear all errors
  ValidationErrorsModel clear() {
    return const ValidationErrorsModel();
  }

  // Get error for specific component
  ValidationErrorModel? getError(String componentId) {
    return errors[componentId];
  }

  // Get error message for specific component (for backward compatibility)
  String? getErrorMessage(String componentId) {
    return errors[componentId]?.errorMessage;
  }

  // Check if component has error
  bool hasError(String componentId) {
    return errors.containsKey(componentId);
  }

  // Get all error messages (for backward compatibility)
  Map<String, String?> get errorMessages {
    return errors.map((key, value) => MapEntry(key, value.errorMessage));
  }

  // Get count of errors
  int get errorCount => errors.length;

  // Check if there are any errors
  bool get hasErrors => errors.isNotEmpty;

  // Get all component IDs with errors
  List<String> get componentIdsWithErrors => errors.keys.toList();

  // Get errors by validation type
  List<ValidationErrorModel> getErrorsByType(String validationType) {
    return errors.values
        .where((error) => error.validationType == validationType)
        .toList();
  }

  // Get recent errors (within specified duration)
  List<ValidationErrorModel> getRecentErrors(Duration duration) {
    final cutoffTime = DateTime.now().subtract(duration);
    return errors.values
        .where((error) => error.timestamp.isAfter(cutoffTime))
        .toList();
  }

  factory ValidationErrorsModel.fromJson(Map<String, dynamic> json) {
    final errorsMap = <String, ValidationErrorModel>{};
    if (json['errors'] is Map) {
      final errorsJson = json['errors'] as Map<String, dynamic>;
      for (final entry in errorsJson.entries) {
        errorsMap[entry.key] = ValidationErrorModel.fromJson(entry.value);
      }
    }
    return ValidationErrorsModel(errors: errorsMap);
  }

  Map<String, dynamic> toJson() {
    return {
      'errors': errors.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  // Convert from old Map<String, String?> format (for backward compatibility)
  factory ValidationErrorsModel.fromMap(Map<String, String?> oldFormat) {
    final errorsMap = <String, ValidationErrorModel>{};
    for (final entry in oldFormat.entries) {
      if (entry.value != null) {
        errorsMap[entry.key] = ValidationErrorModel.create(
          componentId: entry.key,
          errorMessage: entry.value!,
        );
      }
    }
    return ValidationErrorsModel(errors: errorsMap);
  }

  @override
  List<Object?> get props => [errors];
}
