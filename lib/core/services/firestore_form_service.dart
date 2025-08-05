import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:dynamic_form_bi/data/models/shared_form/shared_form_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    String? recipientEmail,
    String? recipientName,
  }) async {
    try {
      debugPrint('=== Saving form to Firestore ===');
      debugPrint('Form name: $formName');
      debugPrint('Recipient email: $recipientEmail');
      debugPrint('Recipient name: $recipientName');

      final docRef = await _firestore.collection(_formsCollection).add({
        'formData': formData,
        'formName': formName,
        'recipientEmail': recipientEmail,
        'recipientName': recipientName,
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
  Future<SharedFormModel?> getSharedForm(String formId) async {
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
      return SharedFormModel.fromFirestoreResult({
        'formData': data['formData'],
        'formName': data['formName'],
        'recipientEmail': data['recipientEmail'],
        'recipientName': data['recipientName'],
        'createdAt': data['createdAt'],
      });
    } catch (e, stackTrace) {
      debugPrint('Error getting shared form: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Generate shareable link for form
  String generateFormShareLink(String formId) {
    final baseUrl = dotenv.env['BACKEND_URL'];
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

  /// Save form submission data to Firestore for tracking
  Future<String> saveFormSubmission({
    required String formId,
    required Map<String, dynamic> formData,
    required String submitterEmail,
    required String submitterName,
    required Map<String, dynamic> submittedValues,
  }) async {
    try {
      debugPrint('=== Saving form submission to Firestore ===');
      debugPrint('Form ID: $formId');
      debugPrint('Submitter: $submitterEmail ($submitterName)');

      final docRef = await _firestore.collection('form_submissions').add({
        'formId': formId,
        'formData': formData,
        'submitterEmail': submitterEmail,
        'submitterName': submitterName,
        'submittedValues': submittedValues,
        'submittedAt': FieldValue.serverTimestamp(),
        'status': 'submitted',
      });

      debugPrint('Form submission saved with ID: ${docRef.id}');
      return docRef.id;
    } catch (e, stackTrace) {
      debugPrint('Error saving form submission to Firestore: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get all submissions for a specific form
  Future<List<Map<String, dynamic>>> getFormSubmissions(String formId) async {
    try {
      debugPrint('=== Getting form submissions from Firestore ===');
      debugPrint('Form ID: $formId');

      final querySnapshot = await _firestore
          .collection('form_submissions')
          .where('formId', isEqualTo: formId)
          .orderBy('submittedAt', descending: true)
          .get();

      final submissions = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();

      debugPrint('Found ${submissions.length} submissions for form: $formId');
      return submissions;
    } catch (e, stackTrace) {
      debugPrint('Error getting form submissions: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
