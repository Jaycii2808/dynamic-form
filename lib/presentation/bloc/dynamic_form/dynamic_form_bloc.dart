import 'dart:async';
import 'package:dynamic_form_bi/data/models/button_condition_model.dart';
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
    on<ValidateButtonConditionsEvent>(_onValidateButtonConditions);
    on<MarkPreviewValidatedEvent>(_onMarkPreviewValidated);
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
    try {
      if (state.page != null) {
        final updatedComponents = state.page!.components.map((component) {
          if (component.id == event.componentId) {
            final updatedConfig = Map<String, dynamic>.from(component.config);

            if (event.value is Map &&
                (event.value as Map).containsKey('value')) {
              final mapValue = event.value as Map;
              updatedConfig['value'] = mapValue['value'];
              updatedConfig['error_text'] = mapValue['error_text'];

              // Use current_state from event if provided, otherwise determine automatically
              if (mapValue.containsKey('current_state')) {
                updatedConfig['current_state'] = mapValue['current_state'];
              } else {
                if (mapValue['error_text'] != null &&
                    mapValue['error_text'].toString().isNotEmpty) {
                  updatedConfig['current_state'] = 'error';
                } else if (mapValue['value'] != null &&
                    mapValue['value'].toString().isNotEmpty) {
                  updatedConfig['current_state'] = 'success';
                } else {
                  updatedConfig['current_state'] = 'base';
                }
              }
            } else {
              updatedConfig['value'] = event.value;
              updatedConfig['current_state'] =
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

        // Update button states based on conditions
        final finalPage = _updateButtonStates(updatedPage);
        debugPrint(
          '📝 Form field updated: ${event.componentId} = ${event.value}',
        );

        emit(DynamicFormSuccess(page: finalPage));
      }
    } catch (e, stackTrace) {
      final errorMessage = 'Failed to update form field: $e';
      debugPrint('Error in _onUpdateFormField: $e, StackTrace: $stackTrace');
      emit(DynamicFormError(errorMessage: errorMessage));
    }
  }

  void _onValidateButtonConditions(
    ValidateButtonConditionsEvent event,
    Emitter<DynamicFormState> emit,
  ) {
    if (state.page != null) {
      final updatedPage = _updateButtonStates(state.page!);
      emit(DynamicFormSuccess(page: updatedPage));
    }
  }

  void _onMarkPreviewValidated(
    MarkPreviewValidatedEvent event,
    Emitter<DynamicFormState> emit,
  ) {
    if (state.page != null) {
      debugPrint(
        '🔍 Marking Save button as preview-validated: ${event.saveButtonId}',
      );

      final updatedComponents = state.page!.components.map((component) {
        if (component.id == event.saveButtonId &&
            component.config['action'] == 'submit_form') {
          final updatedConfig = Map<String, dynamic>.from(component.config);
          updatedConfig['hasPreviewedAndValid'] = true;

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

      // Re-validate button states with the new preview status
      final finalPage = _updateButtonStates(updatedPage);
      emit(DynamicFormSuccess(page: finalPage));
    }
  }

  DynamicFormPageModel _updateButtonStates(DynamicFormPageModel page) {
    final updatedComponents = page.components.map((component) {
      if (component.type.toString().contains('button')) {
        final action = component.config['action']?.toString();
        final conditions = component.config['conditions'] as List<dynamic>?;

        // Handle Save buttons (submit_form action)
        if (action == 'submit_form' &&
            conditions != null &&
            conditions.isNotEmpty) {
          final buttonConditions = conditions
              .map((c) => ButtonCondition.fromJson(c as Map<String, dynamic>))
              .toList();

          bool allConditionsValid = true;
          String? errorMessage;

          debugPrint('=== Validating Save Button (${component.id}) ===');
          debugPrint('Total conditions: ${buttonConditions.length}');

          for (final condition in buttonConditions) {
            try {
              final targetComponent = page.components.firstWhere(
                (c) => c.id == condition.componentId,
              );

              final value = targetComponent.config['value'];
              debugPrint(
                'Checking ${condition.componentId}: rule=${condition.rule}, value=$value, expected=${condition.expectedValue}',
              );

              if (!_validateCondition(condition, value)) {
                allConditionsValid = false;
                errorMessage = condition.errorMessage;
                debugPrint(
                  '❌ FAILED: ${condition.componentId} - ${condition.errorMessage}',
                );
                break;
              } else {
                debugPrint('✅ PASSED: ${condition.componentId}');
              }
            } catch (e) {
              debugPrint('❌ COMPONENT NOT FOUND: ${condition.componentId}');
              allConditionsValid = false;
              errorMessage = condition.errorMessage;
              break;
            }
          }

          // Save button logic:
          // - Always visible
          // - Disabled by default (until preview is clicked and validation passes)
          // - Only enabled after preview validates successfully
          final hasPreviewedAndValid =
              component.config['hasPreviewedAndValid'] ?? false;
          final canSave = allConditionsValid && hasPreviewedAndValid;

          debugPrint(
            '=== Save Button Result: allValid=$allConditionsValid, hasPreviewedAndValid=$hasPreviewedAndValid, canSave=$canSave ===',
          );

          final updatedConfig = Map<String, dynamic>.from(component.config);
          updatedConfig['canSave'] = canSave;
          updatedConfig['allConditionsValid'] = allConditionsValid;
          updatedConfig['errorMessage'] = errorMessage;
          updatedConfig['isVisible'] = true; // Always show Save button
          updatedConfig['disabled'] = !canSave; // Disable if can't save

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
        } else {
          // For non-Save buttons, ensure they're always visible and enabled
          final updatedConfig = Map<String, dynamic>.from(component.config);
          updatedConfig['isVisible'] = true;
          updatedConfig['disabled'] = false;

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
      }
      return component;
    }).toList();

    return DynamicFormPageModel(
      pageId: page.pageId,
      title: page.title,
      order: page.order,
      components: updatedComponents,
    );
  }

  bool _validateCondition(ButtonCondition condition, dynamic value) {
    debugPrint(
      '_validateCondition: componentId=${condition.componentId}, rule=${condition.rule}, value=$value, expected=${condition.expectedValue}',
    );

    switch (condition.rule) {
      case 'not_null':
        // For string values, check if not null and not empty
        if (value is String) {
          final result = value.trim().isNotEmpty;
          debugPrint(
            'String validation for ${condition.componentId}: "$value" -> $result',
          );
          return result;
        }
        // For other types, just check not null and not empty
        if (value == null) {
          debugPrint('null value for ${condition.componentId} -> false');
          return false;
        }
        if (value.toString().isEmpty) {
          debugPrint('empty value for ${condition.componentId} -> false');
          return false;
        }
        debugPrint(
          'not_null validation for ${condition.componentId}: $value -> true',
        );
        return true;

      case 'equals':
        final result = value == condition.expectedValue;
        debugPrint(
          'equals validation for ${condition.componentId}: $value == ${condition.expectedValue} -> $result',
        );
        return result;

      case 'not_empty':
        if (value is List) {
          final result = value.isNotEmpty;
          debugPrint(
            'List validation for ${condition.componentId}: ${value.length} items -> $result',
          );
          return result;
        }
        if (value is String) {
          final result = value.trim().isNotEmpty;
          debugPrint(
            'String validation for ${condition.componentId}: "$value" -> $result',
          );
          return result;
        }
        if (value is bool) {
          final result = value == true;
          debugPrint(
            'Bool validation for ${condition.componentId}: $value -> $result',
          );
          return result;
        }
        final result = value != null;
        debugPrint(
          'General validation for ${condition.componentId}: $value -> $result',
        );
        return result;

      default:
        debugPrint(
          'Unknown rule ${condition.rule} for ${condition.componentId} -> true',
        );
        return true;
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
