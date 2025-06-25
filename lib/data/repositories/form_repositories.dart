import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FormMemoryRepository {
  static final Map<String, Map<String, dynamic>> _forms = {};
  static final Map<String, FormTemplateModel> _formTemplates = {};
  static const String _templatesKey = 'form_templates';

  // Legacy methods for backward compatibility
  static void saveForm(String id, Map<String, dynamic> formJson) {
    _forms[id] = formJson;
  }

  static Map<String, dynamic>? getFormById(String id) {
    return _forms[id];
  }

  static List<Map<String, dynamic>> getAllForms() {
    return _forms.values.toList();
  }

  // New methods for FormTemplateModel
  static void saveFormTemplate(FormTemplateModel template) {
    _formTemplates[template.id] = template;
    persistTemplates();
  }

  static FormTemplateModel? getFormTemplateById(String id) {
    return _formTemplates[id];
  }

  static List<FormTemplateModel> getAllFormTemplates() {
    return _formTemplates.values.toList();
  }

  static void deleteFormTemplate(String id) {
    _formTemplates.remove(id);
    persistTemplates();
  }

  static void updateFormTemplate(FormTemplateModel template) {
    _formTemplates[template.id] = template;
    persistTemplates();
  }

  static List<FormTemplateModel> searchFormTemplates(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _formTemplates.values.where((template) {
      return template.name.toLowerCase().contains(lowercaseQuery) ||
          template.description.toLowerCase().contains(lowercaseQuery) ||
          template.originalConfigKey.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  static void clearAllFormTemplates() {
    _formTemplates.clear();
    persistTemplates();
  }

  static int getFormTemplatesCount() {
    return _formTemplates.length;
  }

  static Future<void> persistTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final templatesList = _formTemplates.values.map((t) => t.toJson()).toList();
    await prefs.setString(_templatesKey, jsonEncode(templatesList));
  }

  static Future<void> loadTemplatesFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_templatesKey);
    if (jsonString != null) {
      final List<dynamic> list = jsonDecode(jsonString);
      _formTemplates.clear();
      for (var item in list) {
        final template = FormTemplateModel.fromJson(item);
        _formTemplates[template.id] = template;
      }
    }
  }
}
