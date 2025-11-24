import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Model for readable form submission data
/// Used for email sending and data display instead of complex component IDs
class FormSubmissionModel extends Equatable {
  final String formId;
  final String formName;
  final DateTime submissionTime;
  final List<FormFieldData> fields;
  final Map<String, dynamic>? additionalData;

  const FormSubmissionModel({
    required this.formId,
    required this.formName,
    required this.submissionTime,
    required this.fields,
    this.additionalData,
  });

  factory FormSubmissionModel.fromJson(Map<String, dynamic> json) {
    return FormSubmissionModel(
      formId: json['formId'] as String? ?? '',
      formName: json['formName'] as String? ?? '',
      submissionTime: DateTime.parse(json['submissionTime'] as String),
      fields:
          (json['fields'] as List<dynamic>?)
              ?.map(
                (field) =>
                    FormFieldData.fromJson(field as Map<String, dynamic>),
              )
              .toList() ??
          [],
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'formId': formId,
      'formName': formName,
      'submissionTime': submissionTime.toIso8601String(),
      'fields': fields.map((field) => field.toJson()).toList(),
      'additionalData': additionalData,
    };
  }

  /// Convert to readable string format for email
  String toEmailFormat() {
    final buffer = StringBuffer();
    buffer.writeln('📝 Form Submission: $formName');
    buffer.writeln('🕒 Submitted at: ${submissionTime.toLocal()}');
    // hide it
    //buffer.writeln('📋 Form ID: $formId');
    buffer.writeln('─' * 50);

    for (int i = 0; i < fields.length; i++) {
      final field = fields[i];
      buffer.writeln('${i + 1}. ${field.label}');
      buffer.writeln('   Value: ${field.displayValue}');
      if (field.componentType.isNotEmpty) {
        buffer.writeln('   Type: ${field.componentType}');
      }
      if (i < fields.length - 1) {
        buffer.writeln();
      }
    }

    return buffer.toString();
  }

  /// Convert to simplified map for easy processing
  Map<String, dynamic> toSimpleMap() {
    final Map<String, dynamic> result = {
      'formName': formName,
      'submissionTime': submissionTime.toIso8601String(),
      'formId': formId,
    };

    for (final field in fields) {
      result[field.label] = field.value;
    }

    return result;
  }

  @override
  List<Object?> get props => [
    formId,
    formName,
    submissionTime,
    fields,
    additionalData,
  ];
}

/// Individual form field data with readable information
class FormFieldData extends Equatable {
  final String label;
  final dynamic value;
  final String componentType;
  final bool isRequired;
  final String? placeholder;
  final String? description; // Add description field

  const FormFieldData({
    required this.label,
    required this.value,
    required this.componentType,
    this.isRequired = false,
    this.placeholder,
    this.description, // Add description parameter
  });

  factory FormFieldData.fromJson(Map<String, dynamic> json) {
    return FormFieldData(
      label: json['label'] as String? ?? '',
      value: json['value'],
      componentType: json['componentType'] as String? ?? '',
      isRequired: json['isRequired'] as bool? ?? false,
      placeholder: json['placeholder'] as String?,
      description: json['description'] as String?, // Add description from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      'componentType': componentType,
      'isRequired': isRequired,
      'placeholder': placeholder,
      'description': description, // Add description to JSON
    };
  }

  /// Get display value for different component types
  String get displayValue {
    if (value == null) return '(No value)';

    try {
      // Handle empty strings
      if (value is String) {
        final stringValue = (value as String).trim();
        if (stringValue.isEmpty) {
          return '(Empty)';
        }
        return stringValue;
      }

      // Handle lists (tags, multi-select, etc.)
      if (value is List) {
        final list = value as List;
        if (list.isEmpty) {
          return '(No items selected)';
        }
        return list
            .map((item) => item?.toString().trim() ?? 'null')
            .where((item) => item.isNotEmpty && item != 'null')
            .join(', ');
      }

      // Handle boolean values (switches, checkboxes)
      if (value is bool) {
        return value ? 'Yes' : 'No';
      }

      // Handle numbers
      if (value is num) {
        // Handle large integers and numbers safely
        if (value is int && value > 999999999) {
          // Large integers might be timestamps or IDs, format them safely
          return 'ID: ${value.toString()}';
        }
        // Format decimal numbers nicely
        if (value is double) {
          return value % 1 == 0 ? value.toInt().toString() : value.toString();
        }
        return value.toString();
      }

      // Handle Maps (complex objects)
      if (value is Map) {
        final map = value as Map;
        if (map.isEmpty) {
          return '(No data)';
        }
        // Convert map to readable format
        final entries = map.entries
            .map((entry) => '${entry.key}: ${entry.value}')
            .join(', ');
        return entries.isNotEmpty ? entries : '(No data)';
      }

      // Handle DateTime objects
      if (value is DateTime) {
        return (value as DateTime).toLocal().toString();
      }

      // For all other types, convert to string safely
      final stringValue = value.toString().trim();
      return stringValue.isNotEmpty ? stringValue : '(No value)';
    } catch (e) {
      debugPrint('❌ Error converting value to display string: $e');
      debugPrint('❌ Value type: ${value.runtimeType}, Value: $value');
      return 'Error displaying value: ${e.toString()}';
    }
  }

  @override
  List<Object?> get props => [
    label,
    value,
    componentType,
    isRequired,
    placeholder,
    description, // Add description to props
  ];
}
