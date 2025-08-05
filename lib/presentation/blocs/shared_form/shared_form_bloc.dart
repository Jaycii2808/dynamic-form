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
    emit(SharedFormLoading.fromState(state: state));
    try {
      final sharedForm = await _firestoreService.getSharedForm(event.formId);
      if (sharedForm == null) {
        throw Exception('Form not found or has been deactivated');
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
    if (action == SharedFormButtonAction.submitForm) {
      add(const SubmitFormEvent());
    } else if (action == SharedFormButtonAction.nextPage) {
      add(const NextPageEvent());
    } else if (action == SharedFormButtonAction.previousPage) {
      add(const PreviousPageEvent());
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
