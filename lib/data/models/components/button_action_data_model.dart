import 'package:equatable/equatable.dart';

class ButtonActionDataModel extends Equatable {
  final String action;
  final DateTime timestamp;
  final String formId;
  final Map<String, dynamic>? customData;
  final String? targetPage;

  const ButtonActionDataModel({
    required this.action,
    required this.timestamp,
    required this.formId,
    this.customData,
    this.targetPage,
  });

  factory ButtonActionDataModel.create({
    required String action,
    String? formId,
    Map<String, dynamic>? customData,
    String? targetPage,
  }) {
    return ButtonActionDataModel(
      action: action,
      timestamp: DateTime.now(),
      formId: formId ?? 'unknown',
      customData: customData,
      targetPage: targetPage,
    );
  }

  factory ButtonActionDataModel.fromJson(Map<String, dynamic> json) {
    return ButtonActionDataModel(
      action: json['action'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      formId: json['formId'] as String? ?? 'unknown',
      customData: json['customData'] as Map<String, dynamic>?,
      targetPage: json['targetPage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'timestamp': timestamp.toIso8601String(),
      'formId': formId,
      'customData': customData,
      'targetPage': targetPage,
    };
  }

  @override
  List<Object?> get props => [
    action,
    timestamp,
    formId,
    customData,
    targetPage,
  ];

  @override
  String toString() {
    return 'ButtonActionDataModel(action: $action, timestamp: $timestamp, formId: $formId, customData: $customData, targetPage: $targetPage)';
  }
}
