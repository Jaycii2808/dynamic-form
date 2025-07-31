import 'package:equatable/equatable.dart';
import 'package:dynamic_form_bi/data/models/components/button_action_data_model.dart';

class FormActionDataModel extends Equatable {
  final String action;
  final DateTime timestamp;
  final String formId;
  final String? formTitle;
  final Map<String, dynamic>? formData;
  final Map<String, dynamic>? customData;
  final String? targetPage;
  final String? configKey;
  final bool isSuccess;
  final String? errorMessage;

  const FormActionDataModel({
    required this.action,
    required this.timestamp,
    required this.formId,
    this.formTitle,
    this.formData,
    this.customData,
    this.targetPage,
    this.configKey,
    this.isSuccess = true,
    this.errorMessage,
  });

  factory FormActionDataModel.create({
    required String action,
    String? formId,
    String? formTitle,
    Map<String, dynamic>? formData,
    Map<String, dynamic>? customData,
    String? targetPage,
    String? configKey,
    bool isSuccess = true,
    String? errorMessage,
  }) {
    return FormActionDataModel(
      action: action,
      timestamp: DateTime.now(),
      formId: formId ?? 'unknown',
      formTitle: formTitle,
      formData: formData,
      customData: customData,
      targetPage: targetPage,
      configKey: configKey,
      isSuccess: isSuccess,
      errorMessage: errorMessage,
    );
  }

  factory FormActionDataModel.fromJson(Map<String, dynamic> json) {
    return FormActionDataModel(
      action: json['action'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      formId: json['formId'] as String? ?? 'unknown',
      formTitle: json['formTitle'] as String?,
      formData: json['formData'] as Map<String, dynamic>?,
      customData: json['customData'] as Map<String, dynamic>?,
      targetPage: json['targetPage'] as String?,
      configKey: json['configKey'] as String?,
      isSuccess: json['isSuccess'] as bool? ?? true,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'timestamp': timestamp.toIso8601String(),
      'formId': formId,
      if (formTitle != null) 'formTitle': formTitle,
      if (formData != null) 'formData': formData,
      if (customData != null) 'customData': customData,
      if (targetPage != null) 'targetPage': targetPage,
      if (configKey != null) 'configKey': configKey,
      'isSuccess': isSuccess,
      if (errorMessage != null) 'errorMessage': errorMessage,
    };
  }

  // Convert from ButtonActionDataModel for backward compatibility
  factory FormActionDataModel.fromButtonAction(
    ButtonActionDataModel buttonAction,
  ) {
    return FormActionDataModel(
      action: buttonAction.action,
      timestamp: buttonAction.timestamp,
      formId: buttonAction.formId,
      customData: buttonAction.customData,
      targetPage: buttonAction.targetPage,
    );
  }

  // Convert to ButtonActionDataModel for backward compatibility
  ButtonActionDataModel toButtonAction() {
    return ButtonActionDataModel(
      action: action,
      timestamp: timestamp,
      formId: formId,
      customData: customData,
      targetPage: targetPage,
    );
  }

  // Create success action
  factory FormActionDataModel.success({
    required String action,
    String? formId,
    String? formTitle,
    Map<String, dynamic>? formData,
    Map<String, dynamic>? customData,
    String? targetPage,
    String? configKey,
  }) {
    return FormActionDataModel.create(
      action: action,
      formId: formId,
      formTitle: formTitle,
      formData: formData,
      customData: customData,
      targetPage: targetPage,
      configKey: configKey,
      isSuccess: true,
    );
  }

  // Create error action
  factory FormActionDataModel.error({
    required String action,
    required String errorMessage,
    String? formId,
    String? formTitle,
    String? configKey,
  }) {
    return FormActionDataModel.create(
      action: action,
      formId: formId,
      formTitle: formTitle,
      configKey: configKey,
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }

  // Create navigation action
  factory FormActionDataModel.navigation({
    required String action,
    required String targetPage,
    String? formId,
    String? formTitle,
    String? configKey,
  }) {
    return FormActionDataModel.create(
      action: action,
      formId: formId,
      formTitle: formTitle,
      targetPage: targetPage,
      configKey: configKey,
    );
  }

  // Create form submission action
  factory FormActionDataModel.submit({
    required String formId,
    required Map<String, dynamic> formData,
    String? formTitle,
    String? configKey,
    Map<String, dynamic>? customData,
  }) {
    return FormActionDataModel.create(
      action: 'submit_form',
      formId: formId,
      formTitle: formTitle,
      formData: formData,
      customData: customData,
      configKey: configKey,
    );
  }

  @override
  List<Object?> get props => [
    action,
    timestamp,
    formId,
    formTitle,
    formData,
    customData,
    targetPage,
    configKey,
    isSuccess,
    errorMessage,
  ];

  @override
  String toString() {
    return 'FormActionDataModel(action: $action, timestamp: $timestamp, formId: $formId, formTitle: $formTitle, isSuccess: $isSuccess, errorMessage: $errorMessage)';
  }

  FormActionDataModel copyWith({
    String? action,
    DateTime? timestamp,
    String? formId,
    String? formTitle,
    Map<String, dynamic>? formData,
    Map<String, dynamic>? customData,
    String? targetPage,
    String? configKey,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return FormActionDataModel(
      action: action ?? this.action,
      timestamp: timestamp ?? this.timestamp,
      formId: formId ?? this.formId,
      formTitle: formTitle ?? this.formTitle,
      formData: formData ?? this.formData,
      customData: customData ?? this.customData,
      targetPage: targetPage ?? this.targetPage,
      configKey: configKey ?? this.configKey,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
