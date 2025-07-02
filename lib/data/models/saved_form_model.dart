import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';

class SavedFormModel {
  final String id;
  final String name;
  final String description;
  final DynamicFormPageModel? formData;
  final Map<String, dynamic>? customFormData;
  final DateTime savedAt;
  final String originalConfigKey;

  SavedFormModel({
    required this.id,
    required this.name,
    required this.description,
    this.formData,
    this.customFormData,
    required this.savedAt,
    required this.originalConfigKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'formData': formData?.toJson(),
      'customFormData': customFormData,
      'savedAt': savedAt.toIso8601String(),
      'originalConfigKey': originalConfigKey,
    };
  }

  factory SavedFormModel.fromJson(Map<String, dynamic> json) {
    return SavedFormModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      formData: json['formData'] != null
          ? DynamicFormPageModel.fromJson(json['formData'])
          : null,
      customFormData: json['customFormData'],
      savedAt: DateTime.parse(json['savedAt']),
      originalConfigKey: json['originalConfigKey'] ?? '',
    );
  }
}
