import 'dart:async';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
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
    on<ValidateAllFormFieldsEvent>(_onValidateAllFormFields);
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
          type: FormTypeEnum
              .textFieldFormType, // Default type for missing components
          order: currentPage.components.length,
          config: {
            'placeholder': 'Dynamic component',
            'isRequired': false,
            'value': event.value is Map
                ? (event.value as Map)['value']
                : event.value,
            'current_state': event.value is Map
                ? (event.value as Map)['current_state'] ?? 'base'
                : 'base',
            'error_text': event.value is Map
                ? (event.value as Map)['error_text']
                : null,
          },
          style: {
            'padding': '10px 12px',
            'border_color': '#888888',
            'border_radius': 6,
            'font_size': 15,
            'color': '#e0e0e0',
            'background_color': '#000000',
          },
          inputTypes: {
            'text': {
              'validation': {'min_length': 1, 'max_length': 100},
            },
          },
          variants: {},
          states: {
            'base': {
              'style': {'border_color': '#888888'},
            },
            'error': {
              'style': {'border_color': '#ff4d4f'},
            },
            'success': {
              'style': {'border_color': '#00b96b'},
            },
          },
          validation: null,
          children: null,
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

      final currentValue = component.config['value']?.toString() ?? '';
      final validationError = ValidationUtils.validateForm(
        component,
        currentValue,
      );

      if (validationError != null) {
        validationErrors++;
        debugPrint('❌ Validation failed for ${component.id}: $validationError');

        // Update component with validation error if showErrorsImmediately is true
        if (event.showErrorsImmediately) {
          final updatedConfig = Map<String, dynamic>.from(component.config);
          updatedConfig['error_text'] = validationError;
          updatedConfig['current_state'] = 'error';

          updatedComponents.add(
            ComponentUtils.updateComponentConfig(component, updatedConfig),
          );
        } else {
          updatedComponents.add(component);
        }
      } else {
        debugPrint('✅ Validation passed for ${component.id}');

        // Update component to success state if it has value
        if (currentValue.isNotEmpty) {
          final updatedConfig = Map<String, dynamic>.from(component.config);
          updatedConfig['error_text'] = null;
          updatedConfig['current_state'] = 'success';

          updatedComponents.add(
            ComponentUtils.updateComponentConfig(component, updatedConfig),
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
    dynamic value,
  ) {
    try {
      final updatedConfig = Map<String, dynamic>.from(component.config);

      if (value is Map && (value as Map).containsKey('value')) {
        final mapValue = value as Map<String, dynamic>;

        // Direct map-based update (for complex components)
        updatedConfig['value'] = mapValue['value'];

        if (mapValue.containsKey('error_text')) {
          updatedConfig['error_text'] = mapValue['error_text'];
        }

        if (mapValue.containsKey('selected')) {
          updatedConfig['selected'] = mapValue['selected'];
        }

        if (mapValue.containsKey('current_state')) {
          updatedConfig['current_state'] = mapValue['current_state'];
        } else {
          updatedConfig['current_state'] =
              ValidationUtils.determineComponentState(
                mapValue['value']?.toString(),
                mapValue['error_text']?.toString(),
              );
        }
      } else {
        // ✅ Special handling for range slider (array values)
        final isRangeSlider = component.config['range'] == true;

        if (isRangeSlider && value is List && value.length == 2) {
          // Range slider: store in 'values' field (plural)
          updatedConfig['values'] = value;
          debugPrint(
            '📝 Range Slider Update: ${component.id} = $value (stored in values field)',
          );
        } else {
          // Regular components: store in 'value' field (singular)
          updatedConfig['value'] = value;
        }

        // Simple value update with JSON-driven validation
        final stringValue = value?.toString() ?? '';

        // Use JSON-configured validation
        final validationError = ValidationUtils.validateForm(
          component,
          stringValue,
        );

        // Update component config
        updatedConfig['error_text'] = validationError;

        // Determine state based on validation result and JSON config
        updatedConfig['current_state'] =
            ValidationUtils.determineComponentState(
              stringValue,
              validationError,
            );

        debugPrint(
          '📝 JSON Validation: ${component.id} = "$stringValue" -> ${validationError ?? "valid"} (state: ${updatedConfig['current_state']})',
        );
      }

      return ComponentUtils.updateComponentConfig(component, updatedConfig);
    } catch (e) {
      debugPrint('Error updating component ${component.id}: $e');
      return component;
    }
  }

  /// Validate all form components using JSON configuration
  void _validateAllComponents(DynamicFormPageModel page) {
    for (final component in page.components) {
      final currentValue = component.config['value']?.toString() ?? '';

      // Skip validation for non-input components
      if (!_isInputComponent(component)) continue;

      // Use JSON-driven validation
      final validationError = ValidationUtils.validateForm(
        component,
        currentValue,
      );

      if (validationError != null) {
        debugPrint(
          '⚠️ Validation failed for ${component.id}: $validationError',
        );

        // Update component with validation error
        final updateData = ValidationUtils.createFieldUpdateData(
          value: currentValue,
          errorText: validationError,
          explicitState: 'error',
        );

        add(
          UpdateFormFieldEvent(
            componentId: component.id,
            value: updateData,
          ),
        );
      }
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

  /// Apply JSON-configured styles and states based on validation result
  Map<String, dynamic> _buildComponentStyleWithState(
    DynamicFormModel component,
    String currentState,
  ) {
    final baseStyle = Map<String, dynamic>.from(component.style);

    // Apply variant styles if configured
    if (component.variants != null) {
      for (final variant in component.variants!.values) {
        final variantStyle = variant['style'] as Map<String, dynamic>?;
        if (variantStyle != null) {
          baseStyle.addAll(variantStyle);
        }
      }
    }

    // Apply state-specific styles from JSON
    if (component.states != null &&
        component.states!.containsKey(currentState)) {
      final stateStyle =
          component.states![currentState]['style'] as Map<String, dynamic>?;
      if (stateStyle != null) {
        baseStyle.addAll(stateStyle);
        debugPrint(
          '📋 Applied JSON state style for ${component.id}: $currentState',
        );
      }
    }

    return baseStyle;
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
            // 'isVisible': false, // Always show Save button
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
    return components.map((component) {
      if (component.id == targetId) {
        // Found target - update it
        return _updateComponentWithValue(component, value);
      } else if (component.children != null && component.children!.isNotEmpty) {
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
    }).toList();
  }
}
