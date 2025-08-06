import 'package:dynamic_form_bi/core/enums/shared_form_button_action.dart';
import 'package:dynamic_form_bi/core/services/email_service.dart';
import 'package:dynamic_form_bi/core/services/firestore_form_service.dart';
import 'package:dynamic_form_bi/core/utils/form_submission_converter.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_multi/dynamic_form_multi_model.dart';
import 'package:dynamic_form_bi/data/models/email/email_details_model.dart';
import 'package:dynamic_form_bi/presentation/blocs/shared_form/shared_form_event.dart';
import 'package:dynamic_form_bi/presentation/blocs/shared_form/shared_form_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Validation result for required fields
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final List<String> missingFields;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.missingFields = const [],
  });
}

class SharedFormBloc extends Bloc<SharedFormEvent, SharedFormState> {
  final FirestoreFormService _firestoreService;
  final EmailService _emailService;

  SharedFormBloc({
    required FirestoreFormService firestoreService,
    required EmailService emailService,
  }) : _firestoreService = firestoreService,
       _emailService = emailService,
       super(const SharedFormInitial()) {
    on<LoadSharedFormEvent>(_onLoadSharedForm);
    on<FieldChangedEvent>(_onFieldChanged);
    on<ButtonActionEvent>(_onButtonAction);
    on<SubmitFormEvent>(_onSubmitForm);
    on<NextPageEvent>(_onNextPage);
    on<PreviousPageEvent>(_onPreviousPage);
    on<InitializeEmailServiceEvent>(_onInitializeEmailService);
    on<ValidationErrorEvent>(_onValidationError);
    on<ReturnToPreviousStateEvent>(_onReturnToPreviousState);
  }

  Future<void> _onInitializeEmailService(
    InitializeEmailServiceEvent event,
    Emitter<SharedFormState> emit,
  ) async {
    try {
      await _emailService.initialize();
      emit(state.copyWith(emailServiceInitialized: true));
    } catch (e) {
      emit(
        SharedFormError(
          errorMessage: 'Failed to initialize email service: $e',
        ),
      );
    }
  }

  Future<void> _onLoadSharedForm(
    LoadSharedFormEvent event,
    Emitter<SharedFormState> emit,
  ) async {
    debugPrint('🔄 [SharedFormBloc] Loading shared form: ${event.formId}');
    emit(SharedFormLoading.fromState(state: state));
    try {
      final sharedForm = await _firestoreService.getSharedForm(event.formId);
      if (sharedForm == null) {
        throw Exception('Form not found or has been deactivated');
      }

      debugPrint('🔄 [SharedFormBloc] Form loaded successfully');
      debugPrint('🔄 [SharedFormBloc] Form name: ${sharedForm.formName}');
      debugPrint(
        '🔄 [SharedFormBloc] Form data pages count: ${sharedForm.formData.pages.length}',
      );

      // Debug each page and component
      for (int i = 0; i < sharedForm.formData.pages.length; i++) {
        final page = sharedForm.formData.pages[i];
        debugPrint(
          '🔄 [SharedFormBloc] Page $i: ${page.title} (${page.pageId})',
        );
        debugPrint(
          '🔄 [SharedFormBloc] Page $i components count: ${page.components.length}',
        );

        for (int j = 0; j < page.components.length; j++) {
          final component = page.components[j];
          debugPrint(
            '🔄 [SharedFormBloc] Page $i Component $j: ${component.id} - ${component.type}',
          );
          debugPrint(
            '🔄 [SharedFormBloc] Page $i Component $j config: ${component.config.toJson()}',
          );
        }
      }

      emit(
        SharedFormSuccess(
          formData: sharedForm.formData,
          formName: sharedForm.formName,
          recipientEmail: sharedForm.recipientEmail,
          recipientName: sharedForm.recipientName,
          componentValues: state.componentValues,
          currentPageIndex: state.currentPageIndex,
          emailServiceInitialized: state.emailServiceInitialized,
        ),
      );
    } catch (e) {
      String errorMessage;
      if (e is Exception) {
        errorMessage = e.toString();
      } else {
        errorMessage = 'Unknown error: $e';
      }
      debugPrint('❌ [SharedFormBloc] Error loading form: $errorMessage');
      emit(SharedFormError(errorMessage: errorMessage));
    }
  }

  void _onFieldChanged(
    FieldChangedEvent event,
    Emitter<SharedFormState> emit,
  ) {
    final updatedValues = Map<String, dynamic>.from(
      state.componentValues.values,
    )..[event.componentId] = event.value;
    emit(
      state.copyWith(
        componentValues: state.componentValues.copyWith(values: updatedValues),
      ),
    );
  }

  void _onButtonAction(
    ButtonActionEvent event,
    Emitter<SharedFormState> emit,
  ) {
    final action = SharedFormButtonAction.fromString(event.action);

    // Validate required fields before allowing next/submit actions
    if (action == SharedFormButtonAction.submitForm ||
        action == SharedFormButtonAction.nextPage) {
      final validationResult = _validateRequiredFields();
      if (!validationResult.isValid) {
        // Instead of emitting new state, add validation error event
        add(
          ValidationErrorEvent(
            errorMessage:
                validationResult.errorMessage ?? "Unknown validation error",
            missingFields: validationResult.missingFields,
          ),
        );
        return;
      }
    }

    if (action == SharedFormButtonAction.submitForm) {
      add(const SubmitFormEvent());
    } else if (action == SharedFormButtonAction.nextPage) {
      add(const NextPageEvent());
    } else if (action == SharedFormButtonAction.previousPage) {
      add(const PreviousPageEvent());
    }
  }

  /// Validate all required fields on current page
  ValidationResult _validateRequiredFields() {
    if (state.formData == null || state.formData!.pages.isEmpty) {
      return const ValidationResult(isValid: true);
    }

    final currentPage = state.formData!.pages[state.currentPageIndex];
    final List<String> missingFields = [];

    debugPrint(
      '🔍 [Validation] Checking required fields on page: ${currentPage.title}',
    );

    for (final component in currentPage.components) {
      final isRequired = component.config.isRequired ?? false;
      if (isRequired) {
        final value = state.componentValues.values[component.id];
        final isEmpty =
            value == null ||
            (value is bool ? value == false : value.toString().trim().isEmpty);

        debugPrint(
          '🔍 [Validation] Field ${component.id}: required=$isRequired, value=$value, isEmpty=$isEmpty',
        );

        if (isEmpty) {
          missingFields.add(component.config.label ?? component.id);
        }
      }
    }

    if (missingFields.isNotEmpty) {
      final errorMessage =
          'Please fill in all required fields:\n${missingFields.map((field) => '• $field').join('\n')}';
      debugPrint('❌ [Validation] Missing required fields: $missingFields');
      return ValidationResult(
        isValid: false,
        errorMessage: errorMessage,
        missingFields: missingFields,
      );
    }

    debugPrint('✅ [Validation] All required fields are filled');
    return const ValidationResult(isValid: true);
  }

  void _onValidationError(
    ValidationErrorEvent event,
    Emitter<SharedFormState> emit,
  ) {
    // Emit validation error state while preserving current form state
    emit(
      SharedFormValidationError(
        errorMessage: event.errorMessage,
        missingFields: event.missingFields,
        formId: state.formId,
        formData: state.formData,
        formName: state.formName,
        recipientEmail: state.recipientEmail,
        recipientName: state.recipientName,
        componentValues: state.componentValues,
        currentPageIndex: state.currentPageIndex,
        emailServiceInitialized: state.emailServiceInitialized,
        emailDetails: state.emailDetails,
      ),
    );
  }

  void _onReturnToPreviousState(
    ReturnToPreviousStateEvent event,
    Emitter<SharedFormState> emit,
  ) {
    // Return to the previous success state
    if (state.formData != null) {
      emit(
        SharedFormSuccess(
          formId: state.formId,
          formData: state.formData,
          formName: state.formName,
          recipientEmail: state.recipientEmail,
          recipientName: state.recipientName,
          componentValues: state.componentValues,
          currentPageIndex: state.currentPageIndex,
          emailServiceInitialized: state.emailServiceInitialized,
          emailDetails: state.emailDetails,
        ),
      );
    }
  }

  Future<void> _onSubmitForm(
    SubmitFormEvent event,
    Emitter<SharedFormState> emit,
  ) async {
    emit(SharedFormLoading.fromState(state: state));
    try {
      final formModel = _createFormModelFromData();
      final submissionModel = FormSubmissionConverter.convertToSubmissionModel(
        componentValues: state.componentValues,
        formModel: formModel,
      );

      EmailDetailsModel emailDetails = EmailDetailsModel(
        recipientEmail: state.recipientEmail,
        recipientName: state.recipientName,
        emailSent: false,
        emailError: null,
        emailResponse: null,
      );

      if (state.recipientEmail != null && state.recipientEmail!.isNotEmpty) {
        try {
          // Ensure email service is initialized before sending
          if (!state.emailServiceInitialized) {
            await _emailService.initialize();
          }

          final emailResult = await _emailService.sendFormSubmissionEmail(
            recipientEmail: state.recipientEmail!,
            recipientName: state.recipientName ?? 'Form Recipient',
            submission: submissionModel,
          );

          debugPrint('📧 Email result: $emailResult');

          EmailResponseModel emailResponse;
          try {
            emailResponse = EmailResponseModel.fromJson(emailResult);
          } catch (e) {
            debugPrint('❌ Error parsing email response: $e');
            debugPrint('❌ Email result data: $emailResult');
            // Create a fallback response
            emailResponse = EmailResponseModel(
              success: false,
              error: 'Failed to parse email response: $e',
            );
          }

          emailDetails = emailDetails.copyWith(
            emailSent: emailResponse.success,
            emailResponse: emailResponse,
            emailError: emailResponse.success ? null : emailResponse.error,
          );
        } catch (e) {
          debugPrint('❌ Email sending error: $e');
          emailDetails = emailDetails.copyWith(
            emailError: 'Email error: $e',
          );
        }
      } else {
        emailDetails = emailDetails.copyWith(
          emailError: 'No recipient email configured',
        );
      }

      await _firestoreService.saveFormSubmission(
        formId: state.formId ?? '',
        formData: state.formData?.toJson() ?? {},
        submitterEmail: 'anonymous',
        submitterName: 'Anonymous User',
        submittedValues: state.componentValues.values,
      );

      emit(
        SharedFormSuccess(
          formData: state.formData,
          formName: state.formName,
          recipientEmail: state.recipientEmail,
          recipientName: state.recipientName,
          componentValues: state.componentValues,
          currentPageIndex: state.currentPageIndex,
          emailServiceInitialized: state.emailServiceInitialized,
          emailDetails: emailDetails,
        ),
      );
    } catch (e) {
      final errorEmailDetails = EmailDetailsModel(
        recipientEmail: state.recipientEmail,
        recipientName: state.recipientName,
        emailSent: false,
        emailError: 'Form submission error: $e',
        emailResponse: null,
      );

      emit(
        SharedFormError(
          errorMessage: 'Form submission error: $e',
          emailDetails: errorEmailDetails,
        ),
      );
    }
  }

  void _onNextPage(
    NextPageEvent event,
    Emitter<SharedFormState> emit,
  ) {
    final pages = state.formData?.pages ?? [];
    if (state.currentPageIndex < pages.length - 1) {
      emit(state.copyWith(currentPageIndex: state.currentPageIndex + 1));
    }
  }

  void _onPreviousPage(
    PreviousPageEvent event,
    Emitter<SharedFormState> emit,
  ) {
    if (state.currentPageIndex > 0) {
      emit(state.copyWith(currentPageIndex: state.currentPageIndex - 1));
    }
  }

  DynamicMultiPageFormModel _createFormModelFromData() {
    if (state.formData == null) {
      throw Exception('Form data is null');
    }
    try {
      return DynamicMultiPageFormModel.fromJson(state.formData!.toJson());
    } catch (e) {
      return DynamicMultiPageFormModel(
        formId: state.formId ?? '',
        name: state.formName,
        pages: state.formData?.pages ?? [],
      );
    }
  }
}
