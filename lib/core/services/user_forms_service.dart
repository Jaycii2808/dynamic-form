import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:dynamic_form_bi/data/models/form_builder/form_builder_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';

class UserFormsService {
  static final UserFormsService _instance = UserFormsService._internal();
  factory UserFormsService() => _instance;
  UserFormsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _userFormsCollection = 'user_forms';
  static const String _defaultUserId = 'user001';

  /// Save user form to Firestore
  Future<String> saveUserForm({
    required FormBuilderModel formBuilderModel,
    String? userId,
  }) async {
    try {
      debugPrint('🔄 [UserFormsService] Saving user form to Firestore');
      debugPrint('🔄 [UserFormsService] Form name: ${formBuilderModel.name}');
      debugPrint('🔄 [UserFormsService] User ID: ${userId ?? _defaultUserId}');

      final docRef = await _firestore.collection(_userFormsCollection).add({
        'userId': userId ?? _defaultUserId,
        'formId': formBuilderModel.formId,
        'name': formBuilderModel.name,
        'description': 'User created form',
        'formData': formBuilderModel.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      debugPrint('✅ [UserFormsService] User form saved with ID: ${docRef.id}');
      return docRef.id;
    } catch (e, stackTrace) {
      debugPrint('❌ [UserFormsService] Error saving user form: $e');
      debugPrint('❌ [UserFormsService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get all user forms by userId
  Future<List<Map<String, dynamic>>> getUserForms({
    String? userId,
  }) async {
    try {
      debugPrint('🔄 [UserFormsService] Loading user forms from Firestore');
      debugPrint('🔄 [UserFormsService] User ID: ${userId ?? _defaultUserId}');

      final querySnapshot = await _firestore
          .collection(_userFormsCollection)
          .where('userId', isEqualTo: userId ?? _defaultUserId)
          .where('isActive', isEqualTo: true)
          .orderBy('updatedAt', descending: true)
          .get();

      final userForms = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();

      debugPrint('✅ [UserFormsService] Loaded ${userForms.length} user forms');
      return userForms;
    } catch (e, stackTrace) {
      debugPrint('❌ [UserFormsService] Error loading user forms: $e');
      debugPrint('❌ [UserFormsService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get specific user form by ID
  Future<Map<String, dynamic>?> getUserFormById({
    required String formId,
    String? userId,
  }) async {
    try {
      debugPrint('🔄 [UserFormsService] Loading user form by ID: $formId');

      final querySnapshot = await _firestore
          .collection(_userFormsCollection)
          .where('userId', isEqualTo: userId ?? _defaultUserId)
          .where('formId', isEqualTo: formId)
          .where('isActive', isEqualTo: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('❌ [UserFormsService] User form not found: $formId');
        return null;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      final userForm = {
        'id': doc.id,
        ...data,
      };

      debugPrint('✅ [UserFormsService] User form loaded: ${userForm['name']}');
      return userForm;
    } catch (e, stackTrace) {
      debugPrint('❌ [UserFormsService] Error loading user form: $e');
      debugPrint('❌ [UserFormsService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Update user form
  Future<void> updateUserForm({
    required String formId,
    required FormBuilderModel formBuilderModel,
    String? userId,
  }) async {
    try {
      debugPrint('🔄 [UserFormsService] Updating user form: $formId');

      final querySnapshot = await _firestore
          .collection(_userFormsCollection)
          .where('userId', isEqualTo: userId ?? _defaultUserId)
          .where('formId', isEqualTo: formId)
          .where('isActive', isEqualTo: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // If not found, create (upsert behavior)
        await _firestore.collection(_userFormsCollection).add({
          'userId': userId ?? _defaultUserId,
          'formId': formId,
          'name': formBuilderModel.name,
          'description': 'User created form',
          'formData': formBuilderModel.toJson(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'isActive': true,
        });
        debugPrint(
          '✅ [UserFormsService] User form not found. Created new form: $formId',
        );
        return;
      }

      final docRef = querySnapshot.docs.first.reference;
      await docRef.update({
        'name': formBuilderModel.name,
        'formData': formBuilderModel.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ [UserFormsService] User form updated: $formId');
    } catch (e, stackTrace) {
      debugPrint('❌ [UserFormsService] Error updating user form: $e');
      debugPrint('❌ [UserFormsService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Delete user form (soft delete)
  Future<void> deleteUserForm({
    required String formId,
    String? userId,
  }) async {
    try {
      debugPrint('🔄 [UserFormsService] Deleting user form: $formId');

      final querySnapshot = await _firestore
          .collection(_userFormsCollection)
          .where('userId', isEqualTo: userId ?? _defaultUserId)
          .where('formId', isEqualTo: formId)
          .where('isActive', isEqualTo: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('User form not found: $formId');
      }

      final docRef = querySnapshot.docs.first.reference;
      await docRef.update({
        'isActive': false,
        'deletedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ [UserFormsService] User form deleted: $formId');
    } catch (e, stackTrace) {
      debugPrint('❌ [UserFormsService] Error deleting user form: $e');
      debugPrint('❌ [UserFormsService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Create user form from template
  Future<String> createUserFormFromTemplate({
    required Map<String, dynamic> templateData,
    required String templateName,
    String? userId,
  }) async {
    try {
      debugPrint(
        '🔄 [UserFormsService] Creating user form from template: $templateName',
      );

      final formBuilderModel = FormBuilderModel(
        formId: 'user_form_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Copy of $templateName',
        pages: const [], // Will be populated from template
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Convert template data to FormBuilderModel
      // This will be implemented based on template structure
      final convertedModel = _convertTemplateToFormBuilder(
        templateData,
        formBuilderModel,
      );

      return await saveUserForm(
        formBuilderModel: convertedModel,
        userId: userId,
      );
    } catch (e, stackTrace) {
      debugPrint(
        '❌ [UserFormsService] Error creating user form from template: $e',
      );
      debugPrint('❌ [UserFormsService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Convert template data to FormBuilderModel
  FormBuilderModel _convertTemplateToFormBuilder(
    Map<String, dynamic> templateData,
    FormBuilderModel baseModel,
  ) {
    try {
      debugPrint(
        '🔄 [UserFormsService] Converting template to FormBuilderModel',
      );

      // Extract pages from template data
      if (templateData['pages'] != null) {
        final pages = templateData['pages'] as List<dynamic>;
        debugPrint('🔄 [UserFormsService] Template has ${pages.length} pages');

        // Convert pages to FormBuilderPageModel
        final convertedPages = pages.map((pageData) {
          try {
            final pageId =
                pageData['pageId'] ??
                'page_${DateTime.now().millisecondsSinceEpoch}';
            final title = pageData['title'] ?? 'Untitled Page';
            final order = pageData['order'] ?? 1;
            final showPreviousButton =
                pageData['show_previous_button'] ?? false;
            final showNextButton = pageData['show_next_button'] ?? false;
            final showSubmitButton = pageData['show_submit_button'] ?? true;

            // Convert components
            List<DynamicFormModel> components = [];
            if (pageData['components'] != null) {
              final componentsData = pageData['components'] as List<dynamic>;
              components = componentsData.map((componentData) {
                try {
                  // Use DynamicFormModel.fromJson for proper conversion
                  return DynamicFormModel.fromJson(componentData);
                } catch (e) {
                  debugPrint(
                    '❌ [UserFormsService] Error converting component: $e',
                  );
                  debugPrint(
                    '❌ [UserFormsService] Component data: $componentData',
                  );

                  // Return a fallback component
                  return DynamicFormModel(
                    id:
                        componentData['id'] ??
                        'component_${DateTime.now().millisecondsSinceEpoch}',
                    type: FormTypeEnum.textFieldFormType,
                    order: componentData['order'] ?? 1,
                    config: ConfigModel(
                      label: componentData['config']?['label'] ?? 'Component',
                      placeholder:
                          componentData['config']?['placeholder'] ?? '',
                      isRequired: componentData['config']?['required'] ?? false,
                    ),
                    style: const StyleModel(), // Use default style
                  );
                }
              }).toList();
            }

            return FormBuilderPageModel(
              pageId: pageId,
              title: title,
              order: order,
              showPreviousButton: showPreviousButton,
              showNextButton: showNextButton,
              showSubmitButton: showSubmitButton,
              components: components,
            );
          } catch (e) {
            debugPrint('❌ [UserFormsService] Error converting page: $e');
            debugPrint('❌ [UserFormsService] Page data: $pageData');

            // Return a placeholder page
            return FormBuilderPageModel(
              pageId: 'page_${DateTime.now().millisecondsSinceEpoch}',
              title: 'Error Page',
              order: 1,
              components: const [],
            );
          }
        }).toList();

        debugPrint(
          '🔄 [UserFormsService] Converted ${convertedPages.length} pages',
        );
        return baseModel.copyWith(pages: convertedPages);
      }

      debugPrint('⚠️ [UserFormsService] No pages found in template data');
      return baseModel;
    } catch (e) {
      debugPrint('❌ [UserFormsService] Error converting template: $e');
      debugPrint('❌ [UserFormsService] Template data: $templateData');
      return baseModel;
    }
  }
}
