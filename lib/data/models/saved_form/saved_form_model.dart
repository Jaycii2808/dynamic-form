import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/saved_form/saved_form_data_model.dart';

class SavedFormModel {
  final String id;
  final String name;
  final String description;
  final DynamicFormPageModel? formData;
  final CustomFormDataModel? customFormData;
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
      'customFormData': customFormData?.toJson(),
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
      customFormData: json['customFormData'] != null
          ? CustomFormDataModel.fromJson(json['customFormData'])
          : null,
      savedAt: DateTime.parse(json['savedAt']),
      originalConfigKey: json['originalConfigKey'] ?? '',
    );
  }

  /// Get total component count
  int get totalComponentsCount {
    if (customFormData != null) {
      return customFormData!.totalComponentsCount;
    } else if (formData != null) {
      return formData!.components.length;
    } else {
      return 0;
    }
  }

  /// Check if form has custom data
  bool get hasCustomData {
    return customFormData != null && customFormData!.hasData;
  }

  /// Check if form is multi-page
  bool get isMultiPage {
    return customFormData != null && customFormData!.isMultiPage;
  }
}
