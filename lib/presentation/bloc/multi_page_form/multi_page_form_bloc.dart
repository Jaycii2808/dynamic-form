import 'dart:convert';

import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_multi_model.dart';
import 'package:dynamic_form_bi/domain/services/remote_config_service.dart';
import 'package:dynamic_form_bi/domain/services/saved_forms_service.dart';
import 'package:dynamic_form_bi/presentation/bloc/multi_page_form/multi_page_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/multi_page_form/multi_page_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MultiPageFormBloc extends Bloc<MultiPageFormEvent, MultiPageFormState> {
  final RemoteConfigService _remoteConfigService;
  String? _loadedFormJsonString;

  MultiPageFormBloc({required RemoteConfigService remoteConfigService})
    : _remoteConfigService = remoteConfigService,
      super(const MultiPageFormInitial()) {
    on<LoadMultiPageForm>(_onLoadMultiPageForm);
    on<UpdateComponentValue>(_onUpdateComponentValue);
    on<NavigateToPage>(_onNavigateToPage);
    on<NavigateToPageByIndex>(_onNavigateToPageByIndex);
    on<SubmitMultiPageForm>(_onSubmitMultiPageForm);
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
      _loadedFormJsonString = jsonString;
      final formModel = DynamicMultiPageFormModel.fromJson(
        jsonDecode(jsonString),
      );

      final initialValues = <String, dynamic>{};
      for (var page in formModel.pages) {
        for (var component in page.components) {
          if (component.config.containsKey(ValueKeyEnum.value.key)) {
            initialValues[component.id] =
                component.config[ValueKeyEnum.value.key];
          } else {
            initialValues[component.id] = null;
          }
        }
      }

      emit(
        MultiPageFormSuccess(
          formModel: formModel,
          componentValues: initialValues,
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
      final newValues = Map<String, dynamic>.from(currentState.componentValues);
      newValues[event.componentId] = event.value;
      emit(currentState.copyWith(componentValues: newValues));
    } catch (e) {
      emit(
        MultiPageFormError(
          errorMessage: "Failed to update value: ${e.toString()}",
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

      int nextPageIndex =
          currentState.currentPageIndex + (event.isNext ? 1 : -1);

      if (nextPageIndex >= 0 &&
          nextPageIndex < currentState.formModel!.pages.length) {
        emit(currentState.copyWith(currentPageIndex: nextPageIndex));
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
    if (state is! MultiPageFormSuccess) return;
    final currentState = state as MultiPageFormSuccess;
    try {
      if (currentState.formModel == null) {
        throw Exception("Form model is not loaded.");
      }

      if (event.targetIndex >= 0 &&
          event.targetIndex < currentState.formModel!.pages.length) {
        emit(currentState.copyWith(currentPageIndex: event.targetIndex));
      }
    } catch (e) {
      emit(
        MultiPageFormError(
          errorMessage:
              "Failed to navigate to page ${event.targetIndex}: ${e.toString()}",
          formModel: currentState.formModel,
          componentValues: currentState.componentValues,
          currentPageIndex: currentState.currentPageIndex,
        ),
      );
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

      final formJson = jsonDecode(_loadedFormJsonString!);
      for (var page in formJson['pages']) {
        for (var component in page['components']) {
          final id = component['id'];
          if (currentState.componentValues.containsKey(id)) {
            component['config']['value'] = currentState.componentValues[id];
          }
        }
      }
      final formWithValue = formJson;

      await SavedFormsService().saveFormWithCustomFormat(
        formId:
            formWithValue['formId'] ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: formWithValue['name'] ?? 'No name',
        description: '',
        formData: formWithValue,
        originalConfigKey: formWithValue['formId'] ?? '',
      );

      debugPrint(
        jsonEncode({
          'timestamp': DateTime.now().toIso8601String(),
          'form': formWithValue,
          'success': true,
        }),
      );

      emit(
        MultiPageFormSuccess(
          formModel: currentState.formModel,
          componentValues: currentState.componentValues,
          currentPageIndex: currentState.currentPageIndex,
        ),
      );
    } catch (e) {
      emit(
        MultiPageFormError(
          errorMessage: "Submission failed:  [${e.toString()}]",
          formModel: currentState.formModel,
          componentValues: currentState.componentValues,
          currentPageIndex: currentState.currentPageIndex,
        ),
      );
    }
  }
}
