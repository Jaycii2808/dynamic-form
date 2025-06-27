import 'dart:convert';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class SavedFormsService {
  static const String _savedFormsKey = 'saved_forms';

  /// Save a form with filled data
  Future<void> saveForm({
    required String name,
    required String description,
    required DynamicFormPageModel formData,
    required String originalConfigKey,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedForms = await getSavedForms();

      final newForm = SavedFormModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        formData: formData,
        savedAt: DateTime.now(),
        originalConfigKey: originalConfigKey,
      );

      savedForms.add(newForm);

      final jsonList = savedForms.map((form) => form.toJson()).toList();
      await prefs.setString(_savedFormsKey, jsonEncode(jsonList));

      debugPrint('✅ Form saved successfully: $name');
    } catch (e) {
      debugPrint('❌ Error saving form: $e');
      rethrow;
    }
  }

  /// Save a form with custom format (form_id and components)
  Future<void> saveFormWithCustomFormat({
    required String formId,
    required String name,
    required String description,
    required Map<String, dynamic> formData,
    required String originalConfigKey,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedForms = await getSavedForms();

      final newForm = SavedFormModel(
        id: formId,
        name: name,
        description: description,
        customFormData: formData,
        savedAt: DateTime.now(),
        originalConfigKey: originalConfigKey,
      );

      savedForms.add(newForm);

      final jsonList = savedForms.map((form) => form.toJson()).toList();
      await prefs.setString(_savedFormsKey, jsonEncode(jsonList));

      debugPrint('✅ Form saved successfully with custom format: $name');
      debugPrint('📋 Custom form data: $formData');
    } catch (e) {
      debugPrint('❌ Error saving form with custom format: $e');
      rethrow;
    }
  }

  /// Get all saved forms
  Future<List<SavedFormModel>> getSavedForms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_savedFormsKey);

      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((json) => SavedFormModel.fromJson(json)).toList()
        ..sort((a, b) => b.savedAt.compareTo(a.savedAt)); // Latest first
    } catch (e) {
      debugPrint('❌ Error loading saved forms: $e');
      return [];
    }
  }

  /// Delete a saved form
  Future<void> deleteSavedForm(String formId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedForms = await getSavedForms();

      savedForms.removeWhere((form) => form.id == formId);

      final jsonList = savedForms.map((form) => form.toJson()).toList();
      await prefs.setString(_savedFormsKey, jsonEncode(jsonList));

      debugPrint('✅ Form deleted successfully: $formId');
    } catch (e) {
      debugPrint('❌ Error deleting form: $e');
      rethrow;
    }
  }

  /// Update a saved form
  Future<void> updateSavedForm(SavedFormModel updatedForm) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedForms = await getSavedForms();

      final index = savedForms.indexWhere((form) => form.id == updatedForm.id);
      if (index != -1) {
        savedForms[index] = updatedForm;

        final jsonList = savedForms.map((form) => form.toJson()).toList();
        await prefs.setString(_savedFormsKey, jsonEncode(jsonList));

        debugPrint('✅ Form updated successfully: ${updatedForm.name}');
      }
    } catch (e) {
      debugPrint('❌ Error updating form: $e');
      rethrow;
    }
  }

  /// Clear all saved forms
  Future<void> clearAllSavedForms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_savedFormsKey);
      debugPrint('✅ All saved forms cleared');
    } catch (e) {
      debugPrint('❌ Error clearing saved forms: $e');
      rethrow;
    }
  }
}
