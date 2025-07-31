import 'dart:convert';

import 'package:dynamic_form_bi/data/models/components/component_values_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_multi/dynamic_form_multi_model.dart';
import 'package:dynamic_form_bi/domain/services/remote_config_service.dart';
import 'package:dynamic_form_bi/domain/services/saved_forms_service.dart';
import 'package:dynamic_form_bi/presentation/bloc/multi_page_form/multi_page_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/multi_page_form/multi_page_form_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
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
          componentValues: ComponentValuesModel.fromMap(initialValues),
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

      emit(currentState.copyWith(componentValues: newComponentValues));
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

      debugPrint(
        '[Bloc] Attempting to navigate from page  [33m${currentState.currentPageIndex} [0m to  [33m$nextPageIndex [0m',
      );
      debugPrint(
        '[Bloc] Total pages:  [33m${currentState.formModel!.pages.length} [0m',
      );

      if (nextPageIndex >= 0 &&
          nextPageIndex < currentState.formModel!.pages.length) {
        debugPrint('[Bloc] Navigating to page  [33m$nextPageIndex [0m');
        emit(currentState.copyWith(currentPageIndex: nextPageIndex));
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
      final updatedPages = formModel.pages.map((page) {
        final updatedComponents = page.components.map((component) {
          if (currentState.componentValues.hasValue(component.id)) {
            final updatedConfig = component.config.copyWith(
              value: currentState.componentValues.getValue(component.id),
            );
            return component.copyWith(config: updatedConfig);
          }
          return component;
        }).toList();

        return page.copyWith(components: updatedComponents);
      }).toList();

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
          formModel: currentState.formModel,
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
