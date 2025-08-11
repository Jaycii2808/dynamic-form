import 'dart:async';

import 'package:dynamic_form_bi/core/enums/button_action_enum.dart';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/core/utils/component_utils.dart';
import 'package:dynamic_form_bi/data/models/components/button_condition_model.dart';
import 'package:dynamic_form_bi/data/models/components/component_value_update_model.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/core/services/form_template_service.dart';
import 'package:dynamic_form_bi/core/services/remote_config_service.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form/dynamic_form_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
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
    on<ValidateAllFormFieldsEvent>(_onValidateAllFormFields);
  }

  Future<void> _onLoadDynamicFormPage(
    LoadDynamicFormPageEvent event,
    Emitter<DynamicFormState> emit,
  ) async {
    emit(DynamicFormLoading.fromState(state: state));
    await Future.delayed(const Duration(milliseconds: 500));
    try {
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
      final currentPage = state.page;
      if (currentPage == null) {
        debugPrint('❌ No page found in state');
        emit(const DynamicFormError(errorMessage: 'Form page not found'));
        return;
      }

      // Find the target component (recursive search including children)
      DynamicFormModel? targetComponent;
      int targetIndex = -1;

      // First search at root level
      targetIndex = currentPage.components.indexWhere(
        (component) => component.id == event.componentId,
      );

      if (targetIndex != -1) {
        targetComponent = currentPage.components[targetIndex];
      } else {
        // Search in nested children
        targetComponent = _findComponentRecursive(
          currentPage.components,
          event.componentId,
        );
      }

      List<DynamicFormModel> updatedComponents;

      if (targetComponent != null) {
        // Component exists - update it (handle both root and nested)
        updatedComponents = _updateComponentsRecursive(
          currentPage.components,
          event.componentId,
          event.value,
        );

        debugPrint('✅ Updated existing component: ${event.componentId}');
      } else {
        // Component doesn't exist - create a minimal one and add it
        debugPrint(
          '⚠️ Component ${event.componentId} not found in current page, creating minimal component',
        );

        final newComponent = DynamicFormModel(
          id: event.componentId,
          type: FormTypeEnum.textFieldFormType,
          order: currentPage.components.length,
          config: ConfigModel(
            placeholder: 'Dynamic component',
            isRequired: false,
            value: event.value.value,
            currentState: event.value.currentState ?? StatesEnum.base,
            errorText: event.value.errorText,
          ),
          style: const StyleModel(),
        );

        // Add the new component to the list
        updatedComponents = [...currentPage.components, newComponent];
        debugPrint('✅ Added new component: ${event.componentId}');
      }

      final updatedPage = DynamicFormPageModel(
        pageId: currentPage.pageId,
        title: currentPage.title,
        order: currentPage.order,
        components: updatedComponents,
      );

      // Update button states based on conditions
      final finalPage = _updateButtonStates(updatedPage);
      debugPrint(
        '📝 Form field updated: ${event.componentId} = ${event.value.value}',
      );

      debugPrint(
        '🔄 [FormBloc] Emitting updated state with ${finalPage.components.length} components',
      );
      final targetComp = finalPage.components.firstWhere(
        (c) => c.id == event.componentId,
        orElse: () => finalPage.components.first,
      );
      debugPrint(
        '📊 [FormBloc] Target component ${event.componentId} final config: ${targetComp.config?.toJson()}',
      );

      emit(DynamicFormSuccess(page: finalPage));
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

      final updatedComponents = List<DynamicFormModel>.generate(
        state.page!.components.length,
        (index) {
          final component = state.page!.components[index];
          if (component.id == event.saveButtonId &&
              component.config?.action == ButtonAction.submitForm.value) {
            final configMap = component.config?.toJson() ?? {};
            configMap['hasPreviewedAndValid'] = true;

            return DynamicFormModel(
              id: component.id,
              type: component.type,
              order: component.order,
              config: ConfigModel.fromJson(configMap),
              style: component.style,
              inputTypes: component.inputTypes,
              variants: component.variants,
              states: component.states,
              validation: component.validation,
              children: component.children,
            );
          }
          return component;
        },
      );

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

  void _onValidateAllFormFields(
    ValidateAllFormFieldsEvent event,
    Emitter<DynamicFormState> emit,
  ) {
    if (state.page == null) {
      debugPrint('❌ No page found for validation');
      return;
    }

    debugPrint('🔍 Validating all form fields using JSON configuration...');

    final currentPage = state.page!;
    List<DynamicFormModel> updatedComponents = [];
    int validationErrors = 0;

    for (final component in currentPage.components) {
      if (!_isInputComponent(component)) {
        updatedComponents.add(component);
        continue;
      }

      final currentValue = component.config?.value?.toString() ?? '';

      // Placeholder: assume no per-field validation error computed here
      final String? validationError = null;

      if (validationError != null) {
        validationErrors++;
        debugPrint('❌ Validation failed for ${component.id}: $validationError');

        // Update component with validation error if showErrorsImmediately is true
        if (event.showErrorsImmediately) {
          final configMap = component.config?.toJson() ?? {};

          configMap['current_state'] = StatesEnum.error;

          updatedComponents.add(
            ComponentUtils.updateComponentConfig(
              component,
              ConfigModel.fromJson(configMap),
            ),
          );
        } else {
          updatedComponents.add(component);
        }
      } else {
        debugPrint('✅ Validation passed for ${component.id}');

        // Update component to success state if it has value
        if (currentValue.isNotEmpty) {
          final configMap = component.config?.toJson() ?? {};
          configMap['error_text'] = null;
          configMap['current_state'] = StatesEnum.success;

          updatedComponents.add(
            ComponentUtils.updateComponentConfig(
              component,
              ConfigModel.fromJson(configMap),
            ),
          );
        } else {
          updatedComponents.add(component);
        }
      }
    }

    debugPrint('📊 Validation summary: $validationErrors errors found');

    if (event.showErrorsImmediately && validationErrors > 0) {
      final updatedPage = DynamicFormPageModel(
        pageId: currentPage.pageId,
        title: currentPage.title,
        order: currentPage.order,
        components: updatedComponents,
      );

      final finalPage = _updateButtonStates(updatedPage);
      emit(DynamicFormSuccess(page: finalPage));
    }
  }

  /// Update component with new value - JSON-driven validation
  DynamicFormModel _updateComponentWithValue(
    DynamicFormModel component,
    ComponentValueUpdateModel value,
  ) {
    try {
      debugPrint(
        '🔧 [FormBloc] Updating component ${component.id} with value: ${value.value}',
      );

      // Use the new model directly
      final updatedComponent = ComponentUtils.updateComponentWithValue(
        component,
        value.value,
        currentState: value.currentState,
        errorText: value.errorText,
        selected: value.selected,
      );

      debugPrint(
        '✅ [FormBloc] Component ${component.id} updated successfully',
      );

      return updatedComponent;
    } catch (e) {
      debugPrint('Error updating component ${component.id}: $e');
      return component;
    }
  }

  /// Check if component is an input component that needs validation
  bool _isInputComponent(DynamicFormModel component) {
    final inputTypes = [
      'textFieldFormType',
      'textAreaFormType',
      'dateTimePickerFormType',
      'dropdownFormType',
      'selectFormType',
      'checkboxFormType',
      'radioFormType',
      'switchFormType',
      'sliderFormType',
    ];

    return inputTypes.contains(component.type.toString().split('.').last);
  }

  DynamicFormPageModel _updateButtonStates(DynamicFormPageModel page) {
    final updatedComponents = List<DynamicFormModel>.generate(
      page.components.length,
      (index) {
        final component = page.components[index];
        if (component.type.toString().contains('button')) {
          final action = component.config?.action;
          final conditions = component.config?.conditions;

          // Handle Save buttons (submit_form action)
          if (action == ButtonAction.submitForm.value &&
              conditions != null &&
              conditions.isNotEmpty) {
            final buttonConditions = List<ButtonCondition>.generate(
              conditions.length,
              (conditionIndex) => ButtonCondition.fromJson(
                conditions[conditionIndex].toJson(),
              ),
            );

            debugPrint('=== Validating Save Button (${component.id}) ===');
            debugPrint('Total conditions: ${buttonConditions.length}');

            // TODO: integrate real condition validation; mark as valid by default
            final allConditionsValid = true;
            final String? errorMessage = null;

            // Save button logic: enabled only after preview validates successfully
            final hasPreviewedAndValid =
                component.config?.toJson()['hasPreviewedAndValid'] ?? false;
            final canSave = allConditionsValid && hasPreviewedAndValid;

            debugPrint(
              '=== Save Button Result: allValid=$allConditionsValid, hasPreviewedAndValid=$hasPreviewedAndValid, canSave=$canSave ===',
            );

            final configMap = component.config?.toJson() ?? {};
            configMap.addAll({
              'canSave': canSave,
              'allConditionsValid': allConditionsValid,
              'errorMessage': errorMessage,
              'disabled': !canSave,
            });

            return ComponentUtils.updateComponentConfig(
              component,
              ConfigModel.fromJson(configMap),
            );
          } else {
            // For non-Save buttons, ensure they're always visible and enabled
            final configMap = component.config?.toJson() ?? {};
            configMap.addAll({'isVisible': true, 'disabled': false});

            return ComponentUtils.updateComponentConfig(
              component,
              ConfigModel.fromJson(configMap),
            );
          }
        }
        return component;
      },
    );

    return DynamicFormPageModel(
      pageId: page.pageId,
      title: page.title,
      order: page.order,
      components: updatedComponents,
    );
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

  /// Recursively find a component by ID in nested children
  DynamicFormModel? _findComponentRecursive(
    List<DynamicFormModel> components,
    String targetId,
  ) {
    for (final component in components) {
      if (component.id == targetId) {
        return component;
      }

      // Search in children if they exist
      if (component.children != null && component.children!.isNotEmpty) {
        final found = _findComponentRecursive(component.children!, targetId);
        if (found != null) return found;
      }
    }
    return null;
  }

  /// Recursively update components in nested structure
  List<DynamicFormModel> _updateComponentsRecursive(
    List<DynamicFormModel> components,
    String targetId,
    dynamic value,
  ) {
    return List<DynamicFormModel>.generate(
      components.length,
      (index) {
        final component = components[index];
        if (component.id == targetId) {
          // Found target - update it
          return _updateComponentWithValue(component, value);
        } else if (component.children != null &&
            component.children!.isNotEmpty) {
          // Search and update in children
          final updatedChildren = _updateComponentsRecursive(
            component.children!,
            targetId,
            value,
          );

          // Return component with updated children
          return DynamicFormModel(
            id: component.id,
            type: component.type,
            order: component.order,
            config: component.config,
            style: component.style,
            inputTypes: component.inputTypes,
            variants: component.variants,
            states: component.states,
            validation: component.validation,
            children: updatedChildren,
          );
        } else {
          // No match and no children - return as is
          return component;
        }
      },
    );
  }
}
