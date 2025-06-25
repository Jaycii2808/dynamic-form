import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/repositories/form_repositories.dart';
import 'package:flutter/foundation.dart';

class FormTemplateService {
  static final FormTemplateService _instance = FormTemplateService._internal();
  factory FormTemplateService() => _instance;
  FormTemplateService._internal();

  /// Load form from template ID
  DynamicFormPageModel? loadFormFromTemplate(String templateId) {
    try {
      final template = FormMemoryRepository.getFormTemplateById(templateId);
      if (template != null) {
        debugPrint('FormTemplateService: Loaded template ${template.name}');
        return template.formData;
      }
      debugPrint('FormTemplateService: Template $templateId not found');
      return null;
    } catch (e) {
      debugPrint('FormTemplateService: Error loading template $templateId: $e');
      return null;
    }
  }

  /// Get form layout data in format {form_id: id, layout: [components]}
  Map<String, dynamic>? getFormLayoutData(String templateId) {
    try {
      final template = FormMemoryRepository.getFormTemplateById(templateId);
      if (template != null) {
        return template.getFormLayoutData();
      }
      return null;
    } catch (e) {
      debugPrint(
        'FormTemplateService: Error getting form layout data for $templateId: $e',
      );
      return null;
    }
  }

  /// Save form template with layout format
  bool saveFormTemplate({
    required String name,
    required String description,
    required String originalConfigKey,
    required DynamicFormPageModel formData,
    Map<String, dynamic>? metadata,
  }) {
    try {
      final templateId =
          'template_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';

      final template = FormTemplateModel.fromFormLayoutData(
        id: templateId,
        name: name,
        description: description,
        originalConfigKey: originalConfigKey,
        formLayoutData: formData.toFormLayoutJson(),
        metadata: metadata,
      );

      FormMemoryRepository.saveFormTemplate(template);
      debugPrint('FormTemplateService: Saved template ${template.name}');
      return true;
    } catch (e) {
      debugPrint('FormTemplateService: Error saving template: $e');
      return false;
    }
  }

  /// Get all templates
  List<FormTemplateModel> getAllTemplates() {
    return FormMemoryRepository.getAllFormTemplates();
  }

  /// Delete template
  bool deleteTemplate(String templateId) {
    try {
      FormMemoryRepository.deleteFormTemplate(templateId);
      debugPrint('FormTemplateService: Deleted template $templateId');
      return true;
    } catch (e) {
      debugPrint(
        'FormTemplateService: Error deleting template $templateId: $e',
      );
      return false;
    }
  }

  /// Search templates
  List<FormTemplateModel> searchTemplates(String query) {
    return FormMemoryRepository.searchFormTemplates(query);
  }
}
