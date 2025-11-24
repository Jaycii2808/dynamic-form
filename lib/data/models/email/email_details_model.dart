import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class EmailDetailsModel extends Equatable {
  final String? recipientEmail;
  final String? recipientName;
  final bool emailSent;
  final String? emailError;
  final EmailResponseModel? emailResponse;

  const EmailDetailsModel({
    this.recipientEmail,
    this.recipientName,
    this.emailSent = false,
    this.emailError,
    this.emailResponse,
  });

  factory EmailDetailsModel.fromJson(Map<String, dynamic> json) {
    return EmailDetailsModel(
      recipientEmail: json['recipientEmail'] as String?,
      recipientName: json['recipientName'] as String?,
      emailSent: json['emailSent'] as bool? ?? false,
      emailError: json['emailError'] as String?,
      emailResponse: json['emailResponse'] != null
          ? EmailResponseModel.fromJson(
              json['emailResponse'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipientEmail': recipientEmail,
      'recipientName': recipientName,
      'emailSent': emailSent,
      'emailError': emailError,
      'emailResponse': emailResponse?.toJson(),
    };
  }

  EmailDetailsModel copyWith({
    String? recipientEmail,
    String? recipientName,
    bool? emailSent,
    String? emailError,
    EmailResponseModel? emailResponse,
  }) {
    return EmailDetailsModel(
      recipientEmail: recipientEmail ?? this.recipientEmail,
      recipientName: recipientName ?? this.recipientName,
      emailSent: emailSent ?? this.emailSent,
      emailError: emailError ?? this.emailError,
      emailResponse: emailResponse ?? this.emailResponse,
    );
  }

  @override
  List<Object?> get props => [
    recipientEmail,
    recipientName,
    emailSent,
    emailError,
    emailResponse,
  ];
}

class EmailResponseModel extends Equatable {
  final bool success;
  final String? status;
  final String? messageId;
  final String? error;
  final String? type;
  final int? statusCode;
  final int? retryCount;
  final Map<String, dynamic>? response;
  final String? stackTrace;

  const EmailResponseModel({
    this.success = false,
    this.status,
    this.messageId,
    this.error,
    this.type,
    this.statusCode,
    this.retryCount,
    this.response,
    this.stackTrace,
  });

  factory EmailResponseModel.fromJson(Map<String, dynamic> json) {
    return EmailResponseModel(
      success: json['success'] as bool? ?? false,
      status: json['status'] as String?,
      messageId: _safeStringConversion(json['messageId']),
      error: json['error'] as String?,
      type: json['type'] as String?,
      statusCode: json['statusCode'] as int?,
      retryCount: json['retryCount'] as int?,
      response: json['response'] as Map<String, dynamic>?,
      stackTrace: json['stackTrace'] as String?,
    );
  }

  /// Safely convert any value to string for messageId
  static String? _safeStringConversion(dynamic value) {
    if (value == null) return null;
    try {
      return value.toString();
    } catch (e) {
      debugPrint('❌ Error converting messageId to string: $e');
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'status': status,
      'messageId': messageId,
      'error': error,
      'type': type,
      'statusCode': statusCode,
      'retryCount': retryCount,
      'response': response,
      'stackTrace': stackTrace,
    };
  }

  EmailResponseModel copyWith({
    bool? success,
    String? status,
    String? messageId,
    String? error,
    String? type,
    int? statusCode,
    int? retryCount,
    Map<String, dynamic>? response,
    String? stackTrace,
  }) {
    return EmailResponseModel(
      success: success ?? this.success,
      status: status ?? this.status,
      messageId: messageId ?? this.messageId,
      error: error ?? this.error,
      type: type ?? this.type,
      statusCode: statusCode ?? this.statusCode,
      retryCount: retryCount ?? this.retryCount,
      response: response ?? this.response,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }

  @override
  List<Object?> get props => [
    success,
    status,
    messageId,
    error,
    type,
    statusCode,
    retryCount,
    response,
    stackTrace,
  ];
}
