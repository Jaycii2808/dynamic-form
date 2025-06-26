import 'dart:async';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/domain/services/form_template_service.dart';
import 'package:dynamic_form_bi/domain/services/remote_config_service.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicFormBloc extends Bloc<DynamicFormEvent, DynamicFormState> {
  final RemoteConfigService _remoteConfigService;
  final FormTemplateService _formTemplateService;

  DynamicFormBloc({
    required RemoteConfigService remoteConfigService,
    required FormTemplateService formTemplateService,
  }) : _remoteConfigService = remoteConfigService,
       _formTemplateService = formTemplateService,

       super(const DynamicFormInitial()) {
    on<LoadDynamicFormPageEvent>(_onLoadDynamicFormPage);
    on<UpdateFormFieldEvent>(_onUpdateFormField);
    on<RefreshDynamicFormEvent>(_onRefreshDynamicForm);
  }

  Future<void> _onLoadDynamicFormPage(
    LoadDynamicFormPageEvent event,
    Emitter<DynamicFormState> emit,
  ) async {
    emit(DynamicFormLoading.fromState(state: state));
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      //final page = _remoteConfigService.getConfigKey(event.configKey);
      DynamicFormPageModel? page;

      // First, check if this is a template ID (starts with 'template_')
      if (event.configKey.startsWith('template_')) {
        page = _formTemplateService.loadFormFromTemplate(event.configKey);
        if (page != null) {
          debugPrint('Loaded form from template: ${event.configKey}');
        }
      }

      // If not a template or template not found, try Remote Config
      if (page == null) {
        page = _remoteConfigService.getConfigKey(event.configKey);
        if (page != null) {
          debugPrint('Loaded form from Remote Config: ${event.configKey}');
        }
      }

      if (page != null) {
        emit(DynamicFormSuccess.fromState(state: state, page: page));
      } else {
        throw Exception('Form not found');
      }
    } catch (e, stackTrace) {
      final errorMessage = 'Failed to load form: $e';
      debugPrint('Error: $e, StackTrace: $stackTrace');
      emit(DynamicFormError(errorMessage: errorMessage));
    }
  }

  void _onUpdateFormField(UpdateFormFieldEvent event, Emitter<DynamicFormState> emit) {
    debugPrint('UpdateFormFieldEvent: Component ${event.componentId}, Value: ${event.value}');
    try {
      if (state.page != null) {
        final updatedComponents = state.page!.components.map((component) {
          if (component.id == event.componentId) {
            final updatedConfig = Map<String, dynamic>.from(component.config);

            if (event.value is Map && (event.value as Map).containsKey('value')) {
              final mapValue = event.value as Map;
              updatedConfig['value'] = mapValue['value'];
              updatedConfig['errorText'] = mapValue['errorText'];
              if (mapValue['errorText'] != null && mapValue['errorText'].toString().isNotEmpty) {
                updatedConfig['currentState'] = 'error';
              } else if (mapValue['value'] != null && mapValue['value'].toString().isNotEmpty) {
                updatedConfig['currentState'] = 'success';
              } else {
                updatedConfig['currentState'] = 'base';
              }
            } else {
              updatedConfig['value'] = event.value;
              updatedConfig['currentState'] =
                  (event.value != null && event.value.toString().isNotEmpty) ? 'success' : 'base';
            }

            return DynamicFormModel(
              id: component.id,
              type: component.type,
              order: component.order,
              config: updatedConfig,
              style: component.style,
              inputTypes: component.inputTypes,
              variants: component.variants,
              states: component.states,
              validation: component.validation,
              children: component.children,
            );
          }
          return component;
        }).toList();

        final updatedPage = DynamicFormPageModel(
          pageId: state.page!.pageId,
          title: state.page!.title,
          order: state.page!.order,
          components: updatedComponents,
        );

        emit(DynamicFormSuccess(page: updatedPage));
      }
    } catch (e, stackTrace) {
      final errorMessage = 'Failed to update form field: $e';
      debugPrint('Error in _onUpdateFormField: $e, StackTrace: $stackTrace');
      emit(DynamicFormError(errorMessage: errorMessage));
    }
  }

  Future<void> _onRefreshDynamicForm(
    RefreshDynamicFormEvent event,
    Emitter<DynamicFormState> emit,
  ) async {
    emit(DynamicFormLoading.fromState(state: state));
    try {
      await _remoteConfigService.initialize();
      await Future.delayed(const Duration(milliseconds: 500));

      final page = _remoteConfigService.getConfigKey(event.configKey);
      if (page != null) {
        emit(DynamicFormSuccess.fromState(state: state, page: page));
      } else {
        throw Exception('Form not found');
      }
    } catch (e, stackTrace) {
      final errorMessage = 'Failed to refresh form: $e';
      debugPrint('Error: $e, StackTrace: $stackTrace');
      emit(DynamicFormError(errorMessage: errorMessage));
    }
  }
}
