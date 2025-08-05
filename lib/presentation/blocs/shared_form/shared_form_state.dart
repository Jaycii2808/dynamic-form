import 'package:dynamic_form_bi/data/models/components/component_values_model.dart';
import 'package:dynamic_form_bi/data/models/email/email_details_model.dart';
import 'package:dynamic_form_bi/data/models/form/form_data_model.dart';
import 'package:equatable/equatable.dart';

abstract class SharedFormState extends Equatable {
  final String? formId;
  final FormDataModel? formData;
  final String formName;
  final String? recipientEmail;
  final String? recipientName;
  final ComponentValuesModel componentValues;
  final int currentPageIndex;
  final bool emailServiceInitialized;
  final EmailDetailsModel? emailDetails;

  const SharedFormState({
    this.formId,
    this.formData,
    this.formName = '',
    this.recipientEmail,
    this.recipientName,
    this.componentValues = const ComponentValuesModel(values: {}),
    this.currentPageIndex = 0,
    this.emailServiceInitialized = false,
    this.emailDetails,
  });

  @override
  List<Object?> get props => [
    formId,
    formData,
    formName,
    recipientEmail,
    recipientName,
    componentValues,
    currentPageIndex,
    emailServiceInitialized,
    emailDetails,
  ];

  SharedFormState copyWith({
    String? formId,
    FormDataModel? formData,
    String? formName,
    String? recipientEmail,
    String? recipientName,
    ComponentValuesModel? componentValues,
    int? currentPageIndex,
    bool? emailServiceInitialized,
    EmailDetailsModel? emailDetails,
  });
}

class SharedFormInitial extends SharedFormState {
  const SharedFormInitial({
    super.formId,
    super.formData,
    super.formName,
    super.recipientEmail,
    super.recipientName,
    super.componentValues,
    super.currentPageIndex,
    super.emailServiceInitialized,
    super.emailDetails,
  });

  @override
  SharedFormState copyWith({
    String? formId,
    FormDataModel? formData,
    String? formName,
    String? recipientEmail,
    String? recipientName,
    ComponentValuesModel? componentValues,
    int? currentPageIndex,
    bool? emailServiceInitialized,
    EmailDetailsModel? emailDetails,
  }) {
    return SharedFormInitial(
      formId: formId ?? this.formId,
      formData: formData ?? this.formData,
      formName: formName ?? this.formName,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      recipientName: recipientName ?? this.recipientName,
      componentValues: componentValues ?? this.componentValues,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      emailServiceInitialized:
          emailServiceInitialized ?? this.emailServiceInitialized,
      emailDetails: emailDetails ?? this.emailDetails,
    );
  }
}

class SharedFormLoading extends SharedFormState {
  const SharedFormLoading({
    super.formId,
    super.formData,
    super.formName,
    super.recipientEmail,
    super.recipientName,
    super.componentValues,
    super.currentPageIndex,
    super.emailServiceInitialized,
    super.emailDetails,
  });

  SharedFormLoading.fromState({required SharedFormState state})
    : super(
        formId: state.formId,
        formData: state.formData,
        formName: state.formName,
        recipientEmail: state.recipientEmail,
        recipientName: state.recipientName,
        componentValues: state.componentValues,
        currentPageIndex: state.currentPageIndex,
        emailServiceInitialized: state.emailServiceInitialized,
        emailDetails: state.emailDetails,
      );

  @override
  SharedFormState copyWith({
    String? formId,
    FormDataModel? formData,
    String? formName,
    String? recipientEmail,
    String? recipientName,
    ComponentValuesModel? componentValues,
    int? currentPageIndex,
    bool? emailServiceInitialized,
    EmailDetailsModel? emailDetails,
  }) {
    return SharedFormLoading(
      formId: formId ?? this.formId,
      formData: formData ?? this.formData,
      formName: formName ?? this.formName,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      recipientName: recipientName ?? this.recipientName,
      componentValues: componentValues ?? this.componentValues,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      emailServiceInitialized:
          emailServiceInitialized ?? this.emailServiceInitialized,
      emailDetails: emailDetails ?? this.emailDetails,
    );
  }
}

class SharedFormSuccess extends SharedFormState {
  const SharedFormSuccess({
    super.formId,
    super.formData,
    super.formName,
    super.recipientEmail,
    super.recipientName,
    super.componentValues,
    super.currentPageIndex,
    super.emailServiceInitialized,
    super.emailDetails,
  });

  @override
  SharedFormState copyWith({
    String? formId,
    FormDataModel? formData,
    String? formName,
    String? recipientEmail,
    String? recipientName,
    ComponentValuesModel? componentValues,
    int? currentPageIndex,
    bool? emailServiceInitialized,
    EmailDetailsModel? emailDetails,
  }) {
    return SharedFormSuccess(
      formId: formId ?? this.formId,
      formData: formData ?? this.formData,
      formName: formName ?? this.formName,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      recipientName: recipientName ?? this.recipientName,
      componentValues: componentValues ?? this.componentValues,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      emailServiceInitialized:
          emailServiceInitialized ?? this.emailServiceInitialized,
      emailDetails: emailDetails ?? this.emailDetails,
    );
  }
}

class SharedFormError extends SharedFormState {
  final String errorMessage;

  const SharedFormError({
    required this.errorMessage,
    super.formId,
    super.formData,
    super.formName,
    super.recipientEmail,
    super.recipientName,
    super.componentValues,
    super.currentPageIndex,
    super.emailServiceInitialized,
    super.emailDetails,
  });

  @override
  List<Object?> get props => [
    errorMessage,
    formId,
    formData,
    formName,
    recipientEmail,
    recipientName,
    componentValues,
    currentPageIndex,
    emailServiceInitialized,
    emailDetails,
  ];

  @override
  SharedFormError copyWith({
    String? formId,
    FormDataModel? formData,
    String? formName,
    String? recipientEmail,
    String? recipientName,
    ComponentValuesModel? componentValues,
    int? currentPageIndex,
    bool? emailServiceInitialized,
    EmailDetailsModel? emailDetails,
    String? errorMessage,
  }) {
    return SharedFormError(
      errorMessage: errorMessage ?? this.errorMessage,
      formId: formId ?? this.formId,
      formData: formData ?? this.formData,
      formName: formName ?? this.formName,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      recipientName: recipientName ?? this.recipientName,
      componentValues: componentValues ?? this.componentValues,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      emailServiceInitialized:
          emailServiceInitialized ?? this.emailServiceInitialized,
      emailDetails: emailDetails ?? this.emailDetails,
    );
  }
}
