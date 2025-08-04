import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreFormService {
  static final FirestoreFormService _instance =
      FirestoreFormService._internal();
  factory FirestoreFormService() => _instance;
  FirestoreFormService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _formsCollection = 'shared_forms';

  /// Save form data to Firestore and return unique form ID
  Future<String> saveSharedForm({
    required Map<String, dynamic> formData,
    required String formName,
  }) async {
    try {
      debugPrint('=== Saving form to Firestore ===');
      debugPrint('Form name: $formName');

      final docRef = await _firestore.collection(_formsCollection).add({
        'formData': formData,
        'formName': formName,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      debugPrint('Form saved with ID: ${docRef.id}');
      return docRef.id;
    } catch (e, stackTrace) {
      debugPrint('Error saving form to Firestore: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get shared form data by ID
  Future<Map<String, dynamic>?> getSharedForm(String formId) async {
    try {
      debugPrint('=== Getting shared form from Firestore ===');
      debugPrint('Form ID: $formId');

      final docSnapshot = await _firestore
          .collection(_formsCollection)
          .doc(formId)
          .get();

      if (!docSnapshot.exists) {
        debugPrint('Form not found with ID: $formId');
        return null;
      }

      final data = docSnapshot.data();
      if (data == null || data['isActive'] != true) {
        debugPrint('Form is inactive or data is null');
        return null;
      }

      debugPrint('Form data retrieved successfully');
      return {
        'formData': data['formData'],
        'formName': data['formName'],
        'createdAt': data['createdAt'],
      };
    } catch (e, stackTrace) {
      debugPrint('Error getting shared form: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Generate shareable link for form
  String generateFormShareLink(String formId) {
    const baseUrl = 'https://dynamicformbiwo.web.app';
    final shareUrl = '$baseUrl/forms/$formId';
    debugPrint('Generated share link: $shareUrl');
    return shareUrl;
  }

  /// Deactivate shared form
  Future<void> deactivateSharedForm(String formId) async {
    try {
      await _firestore.collection(_formsCollection).doc(formId).update({
        'isActive': false,
      });
      debugPrint('Form deactivated: $formId');
    } catch (e) {
      debugPrint('Error deactivating form: $e');
      rethrow;
    }
  }
}
