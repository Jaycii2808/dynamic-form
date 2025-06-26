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

  void _onUpdateFormField(
    UpdateFormFieldEvent event,
    Emitter<DynamicFormState> emit,
  ) {
    debugPrint(
      'UpdateFormFieldEvent: Component ${event.componentId}, Value: ${event.value}',
    );

    if (state.page != null) {
      final updatedComponents = state.page!.components.map((component) {
        if (component.id == event.componentId) {
          final updatedConfig = Map<String, dynamic>.from(component.config);

          if (event.value is Map && (event.value as Map).containsKey('value')) {
            final mapValue = event.value as Map;
            updatedConfig['value'] = mapValue['value'];
            updatedConfig['errorText'] = mapValue['errorText'];
            if (mapValue['errorText'] != null &&
                mapValue['errorText'].toString().isNotEmpty) {
              updatedConfig['currentState'] = 'error';
            } else if (mapValue['value'] != null &&
                mapValue['value'].toString().isNotEmpty) {
              updatedConfig['currentState'] = 'success';
            } else {
              updatedConfig['currentState'] = 'base';
            }
          } else {
            updatedConfig['value'] = event.value;
            updatedConfig['currentState'] =
                (event.value != null && event.value.toString().isNotEmpty)
                ? 'success'
                : 'base';
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
  }

  // void _onUpdateFormField(UpdateFormFieldEvent event, Emitter<DynamicFormState> emit) {
  //   final page = state.page;
  //   if (page == null) return;
  //
  //   final updatedComponents = page.components.map((c) {
  //     if (c.id == event.componentId && c.type == FormTypeEnum.radioFormType) {
  //       final newConfig = Map<String, dynamic>.from(c.config);
  //       final bool newValue = !(c.config['value'] == true);
  //       newConfig['value'] = newValue;
  //       newConfig['currentState'] = newValue ? 'selected' : 'base';
  //       newConfig['errorText'] = null;
  //       debugPrint('[BLoC][Radio] id=${c.id} value=$newValue');
  //       return DynamicFormModel(
  //         id: c.id,
  //         type: c.type,
  //         order: c.order,
  //         config: newConfig,
  //         style: c.style,
  //         inputTypes: c.inputTypes,
  //         variants: c.variants,
  //         states: c.states,
  //         validation: c.validation,
  //         children: c.children,
  //       );
  //     }
  //
  //     if (c.id == event.componentId) {
  //       final newConfig = Map<String, dynamic>.from(c.config);
  //
  //       if (c.type == FormTypeEnum.checkboxFormType) {
  //         final bool boolValue = event.value == true || event.value == 'true';
  //         newConfig['value'] = boolValue;
  //         newConfig['currentState'] = boolValue ? 'selected' : 'base';
  //         newConfig['errorText'] = null;
  //         return DynamicFormModel(
  //           id: c.id,
  //           type: c.type,
  //           order: c.order,
  //           config: newConfig,
  //           style: c.style,
  //           inputTypes: c.inputTypes,
  //           variants: c.variants,
  //           states: c.states,
  //           validation: c.validation,
  //           children: c.children,
  //         );
  //       } else if (c.type == FormTypeEnum.selectFormType && c.config['multiple'] == true) {
  //         List<String> values = [];
  //         if (event.value is List) {
  //           values = (event.value as List).map((e) => e.toString()).toList();
  //         } else if (event.value is String && event.value.isNotEmpty) {
  //           values = [event.value as String];
  //         }
  //
  //         String? errorText;
  //         if (c.validation != null && c.validation!['maxSelections'] != null) {
  //           final maxSelections = c.validation!['maxSelections']['max'] as int?;
  //           if (maxSelections != null && values.length > maxSelections) {
  //             errorText =
  //                 c.validation!['maxSelections']['error_message'] as String? ??
  //                 'Vượt quá số lượng cho phép';
  //           }
  //         }
  //         String newState = 'base';
  //         if (errorText != null && errorText.isNotEmpty) {
  //           newState = 'error';
  //         } else if (values.isNotEmpty) {
  //           newState = 'success';
  //         }
  //         newConfig['value'] = values;
  //         newConfig['errorText'] = errorText;
  //         newConfig['currentState'] = newState;
  //         debugPrint(
  //           '[BLoC][SelectMultiple] id=${c.id} value=$values state=$newState error=$errorText',
  //         );
  //         return DynamicFormModel(
  //           id: c.id,
  //           type: c.type,
  //           order: c.order,
  //           config: newConfig,
  //           style: c.style,
  //           inputTypes: c.inputTypes,
  //           variants: c.variants,
  //           states: c.states,
  //           validation: c.validation,
  //           children: c.children,
  //         );
  //       } else if (c.type == FormTypeEnum.fileUploaderFormType) {
  //         newConfig['value'] = event.value;
  //         return DynamicFormModel(
  //           id: c.id,
  //           type: c.type,
  //           order: c.order,
  //           config: newConfig,
  //           style: c.style,
  //           inputTypes: c.inputTypes,
  //           variants: c.variants,
  //           states: c.states,
  //           validation: c.validation,
  //           children: c.children,
  //         );
  //       } else {
  //         String value = '';
  //         if (c.type == FormTypeEnum.selectFormType && c.config['multiple'] != true) {
  //           if (event.value is List) {
  //             final list = event.value as List;
  //             value = list.isNotEmpty ? list.first.toString() : '';
  //           } else {
  //             value = event.value?.toString() ?? '';
  //           }
  //         } else {
  //           value = event.value?.toString() ?? '';
  //         }
  //
  //         String? errorText;
  //         if (c.type == FormTypeEnum.selectFormType &&
  //             c.config['multiple'] != true &&
  //             c.validation != null &&
  //             c.validation!['required'] != null) {
  //           final requiredCfg = c.validation!['required'];
  //           if ((requiredCfg['isRequired'] ?? false) && value.trim().isEmpty) {
  //             errorText = requiredCfg['error_message'] ?? 'Trường này là bắt buộc';
  //           }
  //         }
  //         errorText ??= validateForm(c, value);
  //         String newState = 'base';
  //         if (errorText != null && errorText.isNotEmpty) {
  //           newState = 'error';
  //         } else if (value.isNotEmpty) {
  //           newState = 'success';
  //         }
  //         newConfig['value'] = value;
  //         newConfig['errorText'] = errorText;
  //         newConfig['currentState'] = newState;
  //         return DynamicFormModel(
  //           id: c.id,
  //           type: c.type,
  //           order: c.order,
  //           config: newConfig,
  //           style: c.style,
  //           inputTypes: c.inputTypes,
  //           variants: c.variants,
  //           states: c.states,
  //           validation: c.validation,
  //           children: c.children,
  //         );
  //       }
  //     }
  //     return c;
  //   }).toList();
  //
  //   emit(
  //     DynamicFormSuccess(
  //       page: DynamicFormPageModel(
  //         pageId: page.pageId,
  //         title: page.title,
  //         order: page.order,
  //         components: updatedComponents,
  //       ),
  //     ),
  //   );
  // }

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
