import 'dart:convert';
import 'dart:developer';

import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/saved_form/saved_form_data_model.dart';
import 'package:dynamic_form_bi/data/models/saved_form/saved_form_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

      // Convert to JSON without using map
      final List<Map<String, dynamic>> jsonList = [];
      for (final form in savedForms) {
        jsonList.add(form.toJson());
      }

      await prefs.setString(_savedFormsKey, jsonEncode(jsonList));

      debugPrint('✅ Form saved successfully: $name');
    } catch (e) {
      debugPrint('❌ Error saving form: $e');
      rethrow;
    }
  }

  /// Save form with custom format
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

      // Convert formData to CustomFormDataModel
      final customFormData = CustomFormDataModel.fromJson(formData);

      final newForm = SavedFormModel(
        id: formId,
        name: name,
        description: description,
        customFormData: customFormData,
        savedAt: DateTime.now(),
        originalConfigKey: originalConfigKey,
      );

      savedForms.add(newForm);

      // Convert to JSON without using map
      final List<Map<String, dynamic>> jsonList = [];
      for (final form in savedForms) {
        jsonList.add(form.toJson());
      }

      await prefs.setString(_savedFormsKey, jsonEncode(jsonList));

      debugPrint('✅ Form saved successfully with custom format: $name');
      debugPrint('📋 Custom form data: ${customFormData.toJson()}');
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

      // Convert JSON to SavedFormModel without using map
      final List<SavedFormModel> savedForms = [];
      for (final json in jsonList) {
        final formModel = SavedFormModel.fromJson(json as Map<String, dynamic>);
        savedForms.add(formModel);
      }

      // Sort by savedAt (latest first)
      savedForms.sort((a, b) => b.savedAt.compareTo(a.savedAt));

      return savedForms;
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

      // Convert to JSON without using map
      final List<Map<String, dynamic>> jsonList = [];
      for (final form in savedForms) {
        jsonList.add(form.toJson());
      }

      await prefs.setString(_savedFormsKey, jsonEncode(jsonList));

      debugPrint('✅ Form deleted successfully: $formId');
    } catch (e) {
      debugPrint('❌ Error deleting form: $e');
      rethrow;
    }
  }

  /// Clear all saved forms
  Future<void> clearAllSavedForms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_savedFormsKey);
      debugPrint('✅ All saved forms cleared successfully');
    } catch (e) {
      debugPrint('❌ Error clearing all saved forms: $e');
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

        // Convert to JSON without using map
        final List<Map<String, dynamic>> jsonList = [];
        for (final form in savedForms) {
          jsonList.add(form.toJson());
        }

        await prefs.setString(_savedFormsKey, jsonEncode(jsonList));

        debugPrint('✅ Form updated successfully: ${updatedForm.name}');
      } else {
        throw Exception('Form not found: ${updatedForm.id}');
      }
    } catch (e) {
      debugPrint('❌ Error updating form: $e');
      rethrow;
    }
  }

  /// Get a specific saved form by ID
  Future<SavedFormModel?> getSavedFormById(String formId) async {
    try {
      final savedForms = await getSavedForms();

      // Find form by ID without using firstWhere
      for (final form in savedForms) {
        if (form.id == formId) {
          return form;
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error getting saved form by ID: $e');
      return null;
    }
  }
}
