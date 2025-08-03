import 'dart:convert';

import 'package:dynamic_form_bi/data/models/components/component_values_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_multi/dynamic_form_multi_model.dart';
import 'package:dynamic_form_bi/data/models/validation/validation_errors_model.dart';
import 'package:dynamic_form_bi/domain/services/remote_config_service.dart';
import 'package:dynamic_form_bi/domain/services/saved_forms_service.dart';
import 'package:dynamic_form_bi/presentation/blocs/multi_page_form/multi_page_form_event.dart';
import 'package:dynamic_form_bi/presentation/blocs/multi_page_form/multi_page_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MultiPageFormBloc extends Bloc<MultiPageFormEvent, MultiPageFormState> {
  final RemoteConfigService _remoteConfigService;

  MultiPageFormBloc({required RemoteConfigService remoteConfigService})
    : _remoteConfigService = remoteConfigService,
      super(const MultiPageFormInitial()) {
    on<LoadMultiPageForm>(_onLoadMultiPageForm);
    on<UpdateComponentValue>(_onUpdateComponentValue);
    on<NavigateToPage>(_onNavigateToPage);
    on<NavigateToPageByIndex>(_onNavigateToPageByIndex);
    on<SubmitMultiPageForm>(_onSubmitMultiPageForm);
  }

  // Helper method to add validation error

  // Helper method to remove validation error

  // Helper method to clear all validation errors
  void _clearValidationErrors(Emitter<MultiPageFormState> emit) {
    if (state is MultiPageFormSuccess) {
      final currentState = state as MultiPageFormSuccess;
      final clearedValidationErrors = currentState.validationErrors.clear();

      emit(currentState.copyWith(validationErrors: clearedValidationErrors));
    }
  }

  // Helper method to validate current page
  bool _validateCurrentPage(Emitter<MultiPageFormState> emit) {
    if (state is! MultiPageFormSuccess) return false;

    final currentState = state as MultiPageFormSuccess;
    if (currentState.formModel == null) return false;

    final currentPage = currentState.currentPage;
    if (currentPage == null) return false;

    bool isValid = true;
    final newErrors = <ValidationErrorModel>[];

    for (final component in currentPage.components) {
      final value = currentState.componentValues.getValue(component.id);

      // Check required validation
      if (component.config.isRequired == true) {
        if (value == null ||
            (value is bool
                ? value == false
                : value.toString().trim().isEmpty)) {
          final error = ValidationErrorModel.create(
            componentId: component.id,
            errorMessage:
                component.config.errorText ?? 'This field is required',
            fieldName: component.config.label,
            validationType: 'required',
          );
          newErrors.add(error);
          isValid = false;
        }
      }

      // Add more validation types here as needed
      // For example: regex validation, length validation, etc.
    }

    if (newErrors.isNotEmpty) {
      final updatedValidationErrors = currentState.validationErrors.addErrors(
        newErrors,
      );
      emit(currentState.copyWith(validationErrors: updatedValidationErrors));
    } else {
      // Clear errors if validation passes
      _clearValidationErrors(emit);
    }

    return isValid;
  }

  Future<void> _onLoadMultiPageForm(
    LoadMultiPageForm event,
    Emitter<MultiPageFormState> emit,
  ) async {
    emit(MultiPageFormLoading.fromState(state));
    try {
      final jsonString = _remoteConfigService.getString(event.configKey);
      if (jsonString.isEmpty) {
        throw Exception('Remote config key is empty or not found.');
      }
      final formModel = DynamicMultiPageFormModel.fromJson(
        jsonDecode(jsonString),
      );

      final initialValues = <String, dynamic>{};
      for (var page in formModel.pages) {
        for (var component in page.components) {
          // Read value from config model
          final value = component.config.value;
          if (value != null) {
            initialValues[component.id] = value;
            debugPrint(
              '📝 [MultiPageForm] Initialized ${component.id} = $value',
            );
          } else {
            initialValues[component.id] = null;
            debugPrint('📝 [MultiPageForm] Initialized ${component.id} = null');
          }
        }
      }

      emit(
        MultiPageFormSuccess(
          formModel: formModel,
          componentValues: ComponentValuesModel.fromJson(initialValues),
          currentPageIndex: 0,
        ),
      );
    } catch (e) {
      emit(
        MultiPageFormError(
          errorMessage: e.toString(),
          formModel: state.formModel,
          componentValues: state.componentValues,
          currentPageIndex: state.currentPageIndex,
        ),
      );
    }
  }

  void _onUpdateComponentValue(
    UpdateComponentValue event,
    Emitter<MultiPageFormState> emit,
  ) {
    if (state is! MultiPageFormSuccess) return;
    final currentState = state as MultiPageFormSuccess;
    try {
      final oldValue = currentState.componentValues.getValue(event.componentId);
      final newComponentValues = currentState.componentValues.setValue(
        event.componentId,
        event.value.value,
      );

      debugPrint(
        '📝 [MultiPageForm] Updated ${event.componentId}: $oldValue -> ${event.value.value}',
      );
      debugPrint(
        '📝 [MultiPageForm] All component values: ${newComponentValues.values}',
      );

      // Clear validation error for this component when value is updated
      final updatedValidationErrors = currentState.validationErrors.removeError(
        event.componentId,
      );

      emit(
        currentState.copyWith(
          componentValues: newComponentValues,
          validationErrors: updatedValidationErrors,
        ),
      );
    } catch (e) {
      emit(
        MultiPageFormError(
          errorMessage: e.toString(),
          formModel: currentState.formModel,
          componentValues: currentState.componentValues,
          currentPageIndex: currentState.currentPageIndex,
        ),
      );
    }
  }

  void _onNavigateToPage(
    NavigateToPage event,
    Emitter<MultiPageFormState> emit,
  ) {
    if (state is! MultiPageFormSuccess) return;
    final currentState = state as MultiPageFormSuccess;
    try {
      if (currentState.formModel == null) {
        throw Exception("Form model is not loaded.");
      }

      // Validate current page before navigating to next page
      if (event.isNext) {
        final isValid = _validateCurrentPage(emit);
        if (!isValid) {
          debugPrint('[Bloc] Navigation blocked: validation failed');
          return;
        }
      }

      int nextPageIndex =
          currentState.currentPageIndex + (event.isNext ? 1 : -1);

      debugPrint(
        '[Bloc] Attempting to navigate from page  [33m${currentState.currentPageIndex} [0m to  [33m$nextPageIndex [0m',
      );
      debugPrint(
        '[Bloc] Total pages:  [33m${currentState.formModel!.pages.length} [0m',
      );

      if (nextPageIndex >= 0 &&
          nextPageIndex < currentState.formModel!.pages.length) {
        debugPrint('[Bloc] Navigating to page  [33m$nextPageIndex [0m');
        // Clear validation errors when navigating to a new page
        final clearedValidationErrors = currentState.validationErrors.clear();
        emit(
          currentState.copyWith(
            currentPageIndex: nextPageIndex,
            validationErrors: clearedValidationErrors,
          ),
        );
      } else {
        debugPrint('[Bloc] Navigation blocked: out of range');
      }
    } catch (e) {
      emit(
        MultiPageFormError(
          errorMessage: "Failed to navigate: ${e.toString()}",
          formModel: currentState.formModel,
          componentValues: currentState.componentValues,
          currentPageIndex: currentState.currentPageIndex,
        ),
      );
    }
  }

  void _onNavigateToPageByIndex(
    NavigateToPageByIndex event,
    Emitter<MultiPageFormState> emit,
  ) {
    if (state is MultiPageFormSuccess) {
      final currentState = state as MultiPageFormSuccess;
      if (event.targetIndex >= 0 &&
          event.targetIndex < (currentState.formModel?.pages.length ?? 0)) {
        debugPrint(
          '[Bloc] Navigating to page index:  [33m${event.targetIndex} [0m',
        );
        emit(
          MultiPageFormSuccess(
            formModel: currentState.formModel,
            currentPageIndex: event.targetIndex,
            componentValues: currentState.componentValues,
          ),
        );
      } else {
        debugPrint('[Bloc] Invalid page index: ${event.targetIndex}');
        emit(
          MultiPageFormError(
            errorMessage: 'Invalid page index',
            formModel: currentState.formModel,
            componentValues: currentState.componentValues,
            currentPageIndex: currentState.currentPageIndex,
          ),
        );
      }
    } else {
      debugPrint('[Bloc] Cannot navigate: Not in Success state');
    }
  }

  Future<void> _onSubmitMultiPageForm(
    SubmitMultiPageForm event,
    Emitter<MultiPageFormState> emit,
  ) async {
    if (state is! MultiPageFormSuccess) return;
    final currentState = state as MultiPageFormSuccess;

    emit(MultiPageFormLoading.fromState(currentState));
    try {
      if (currentState.formModel == null) {
        throw Exception("Form is not initialized for submission.");
      }

      await Future.delayed(const Duration(seconds: 1));

      // Use model instead of raw JSON
      final formModel = currentState.formModel!;

      // Create a copy of the form model with updated values
      final updatedPages = List<FormForMultiPageModel>.generate(
        formModel.pages.length,
        (pageIndex) {
          final page = formModel.pages[pageIndex];
          final updatedComponents = List<FormComponentMultiPageModel>.generate(
            page.components.length,
            (componentIndex) {
              final component = page.components[componentIndex];
              if (currentState.componentValues.hasValue(component.id)) {
                final updatedConfig = component.config.copyWith(
                  value: currentState.componentValues.getValue(component.id),
                );
                return component.copyWith(config: updatedConfig);
              }
              return component;
            },
          );

          return page.copyWith(components: updatedComponents);
        },
      );

      final formWithValues = formModel.copyWith(pages: updatedPages);
      final formJson = formWithValues.toJson();

      await SavedFormsService().saveFormWithCustomFormat(
        formId: formWithValues.formId.isNotEmpty
            ? formWithValues.formId
            : DateTime.now().millisecondsSinceEpoch.toString(),
        name: formWithValues.name.isNotEmpty ? formWithValues.name : 'No name',
        description: '',
        formData: formJson,
        originalConfigKey: formWithValues.formId.isNotEmpty
            ? formWithValues.formId
            : '',
      );

      // debugPrint(
      //   jsonEncode({
      //     'timestamp': DateTime.now().toIso8601String(),
      //     'form': formJson,
      //     StatesEnum.success: true,
      //   }),
      // );

      emit(
        MultiPageFormSuccess(
          formModel: formWithValues,
          componentValues: currentState.componentValues,
          currentPageIndex: currentState.currentPageIndex,
        ),
      );
    } catch (e) {
      emit(
        MultiPageFormError(
          errorMessage: "Submission failed: [${e.toString()}]",
          formModel: currentState.formModel,
          componentValues: currentState.componentValues,
          currentPageIndex: currentState.currentPageIndex,
        ),
      );
    }
  }
}
