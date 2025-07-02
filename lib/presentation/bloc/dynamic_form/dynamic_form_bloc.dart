import 'dart:async';
import 'package:dynamic_form_bi/core/utils/component_utils.dart';
import 'package:dynamic_form_bi/core/utils/validation_utils.dart';
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
      final currentPage = state.page;
      if (currentPage == null) {
        debugPrint('❌ No page found in state');
        emit(DynamicFormError(errorMessage: 'Form page not found'));
        return;
      }

      final updatedComponents = currentPage.components.map((component) {
        if (component.id == event.componentId) {
          return _updateComponentWithValue(component, event.value);
        } else {
          return component;
        }
      }).toList();

      final updatedPage = DynamicFormPageModel(
        pageId: currentPage.pageId,
        title: currentPage.title,
        order: currentPage.order,
        components: updatedComponents,
      );

      // Update button states based on conditions
      final finalPage = _updateButtonStates(updatedPage);
      debugPrint(
        '📝 Form field updated: ${event.componentId} = ${event.value}',
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

  /// Update component with new value - clean and safe
  DynamicFormModel _updateComponentWithValue(
    DynamicFormModel component,
    dynamic value,
  ) {
    try {
      final updatedConfig = Map<String, dynamic>.from(component.config);

      if (value is Map && (value as Map).containsKey('value')) {
        final mapValue = value as Map<String, dynamic>;

        // Update value with null safety
        updatedConfig['value'] = mapValue['value'];

        // Update error text
        if (mapValue.containsKey('error_text')) {
          updatedConfig['error_text'] = mapValue['error_text'];
        }

        // Update selected field if it exists
        if (mapValue.containsKey('selected')) {
          updatedConfig['selected'] = mapValue['selected'];
        }

        // Use current_state from event if provided, otherwise determine automatically
        if (mapValue.containsKey('current_state')) {
          updatedConfig['current_state'] = mapValue['current_state'];
        } else {
          // Use ValidationUtils for consistent state determination
          updatedConfig['current_state'] =
              ValidationUtils.determineComponentState(
                mapValue['value']?.toString(),
                mapValue['error_text']?.toString(),
              );
        }
      } else {
        // Simple value update
        updatedConfig['value'] = value;
        updatedConfig['current_state'] =
            ValidationUtils.determineComponentState(value?.toString(), null);
      }

      return ComponentUtils.updateComponentConfig(component, updatedConfig);
    } catch (e) {
      debugPrint('Error updating component ${component.id}: $e');
      // Return original component if update fails
      return component;
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

          debugPrint('=== Validating Save Button (${component.id}) ===');
          debugPrint('Total conditions: ${buttonConditions.length}');

          // Use centralized validation instead of duplicated if-else logic
          final validationResult = ValidationUtils.validateButtonConditions(
            buttonConditions,
            page.components,
          );

          final allConditionsValid = validationResult.isValid;
          final errorMessage = validationResult.errorMessage;

          if (validationResult.failedCondition != null) {
            debugPrint(
              '❌ FAILED: ${validationResult.failedCondition!.componentId} - $errorMessage',
            );
          } else {
            debugPrint('✅ All conditions PASSED');
          }

          // Save button logic: enabled only after preview validates successfully
          final hasPreviewedAndValid =
              component.config['hasPreviewedAndValid'] ?? false;
          final canSave = allConditionsValid && hasPreviewedAndValid;

          debugPrint(
            '=== Save Button Result: allValid=$allConditionsValid, hasPreviewedAndValid=$hasPreviewedAndValid, canSave=$canSave ===',
          );

          // Use ComponentUtils for cleaner component creation
          final updatedConfig = Map<String, dynamic>.from(component.config);
          updatedConfig.addAll({
            'canSave': canSave,
            'allConditionsValid': allConditionsValid,
            'errorMessage': errorMessage,
            'isVisible': true, // Always show Save button
            'disabled': !canSave, // Disable if can't save
          });

          return ComponentUtils.updateComponentConfig(component, updatedConfig);
        } else {
          // For non-Save buttons, ensure they're always visible and enabled
          final updatedConfig = Map<String, dynamic>.from(component.config);
          updatedConfig.addAll({'isVisible': true, 'disabled': false});

          return ComponentUtils.updateComponentConfig(component, updatedConfig);
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
