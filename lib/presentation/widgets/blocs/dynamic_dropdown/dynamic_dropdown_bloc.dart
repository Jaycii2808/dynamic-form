import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_types/input_validation_model.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_dropdown/dynamic_dropdown_event.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_dropdown/dynamic_dropdown_state.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/component_widgets/dropdown_form/dropdown_navigation_service.dart';

class DynamicDropdownBloc
    extends Bloc<DynamicDropdownEvent, DynamicDropdownState> {
  final DropdownNavigationService _navigationService =
      DropdownNavigationService();
  final String? _currentPageId; // Add page ID for navigation tracking

  DynamicDropdownBloc({
    required DynamicFormModel initialComponent,
    String? currentPageId,
  }) : _currentPageId = currentPageId,
       super(
         DynamicDropdownInitial(
           component: initialComponent,
           inputConfig: InputValidationModel.fromJson(
             initialComponent.config?.toJson() ?? {},
           ),
           currentValue: initialComponent.config?.value?.toString(),
         ),
       ) {
    on<DropdownValueChangedEvent>(_onValueChanged);
    on<DropdownFocusLostEvent>(_onFocusLost);
    on<DropdownValidationEvent>(_onValidation);
    on<DropdownOptionSelectedEvent>(_onOptionSelected);
  }

  Future<void> _onValueChanged(
    DropdownValueChangedEvent event,
    Emitter<DynamicDropdownState> emit,
  ) async {
    debugPrint('🔄 [DynamicDropdownBloc] Value changed: ${event.value}');

    emit(DynamicDropdownLoading.fromState(state: state));

    try {
      // Update component with new value
      final updatedComponent = state.component.copyWith(
        config: state.component.config?.copyWith(value: event.value),
      );

      emit(
        DynamicDropdownSuccess.fromState(state: state).copyWith(
          component: updatedComponent,
          currentValue: event.value,
        ),
      );
    } catch (e) {
      debugPrint('❌ [DynamicDropdownBloc] Error in value change: $e');
      emit(
        DynamicDropdownError(
          component: state.component,
          inputConfig: state.inputConfig,
          currentValue: state.currentValue,
          errorMessage: 'Error updating value: $e',
        ),
      );
    }
  }

  Future<void> _onFocusLost(
    DropdownFocusLostEvent event,
    Emitter<DynamicDropdownState> emit,
  ) async {
    debugPrint(
      '🔍 [DynamicDropdownBloc] Focus lost with value: ${event.value}',
    );

    emit(DynamicDropdownLoading.fromState(state: state));

    try {
      // Validate the value when focus is lost
      final validationResult = _validateValue(event.value);

      if (validationResult.isValid) {
        emit(
          DynamicDropdownSuccess.fromState(state: state).copyWith(
            currentValue: event.value,
            errorText: null,
          ),
        );
      } else {
        emit(
          DynamicDropdownError(
            component: state.component,
            inputConfig: state.inputConfig,
            currentValue: event.value,
            errorText: validationResult.errorMessage,
            errorMessage: validationResult.errorMessage,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ [DynamicDropdownBloc] Error in focus lost: $e');
      emit(
        DynamicDropdownError(
          component: state.component,
          inputConfig: state.inputConfig,
          currentValue: state.currentValue,
          errorMessage: 'Error in validation: $e',
        ),
      );
    }
  }

  Future<void> _onValidation(
    DropdownValidationEvent event,
    Emitter<DynamicDropdownState> emit,
  ) async {
    debugPrint('✅ [DynamicDropdownBloc] Validating value: ${event.value}');

    emit(DynamicDropdownLoading.fromState(state: state));

    try {
      final validationResult = _validateValue(event.value);

      if (validationResult.isValid) {
        emit(
          DynamicDropdownSuccess.fromState(state: state).copyWith(
            currentValue: event.value,
            errorText: null,
          ),
        );
      } else {
        emit(
          DynamicDropdownError(
            component: state.component,
            inputConfig: state.inputConfig,
            currentValue: event.value,
            errorText: validationResult.errorMessage,
            errorMessage: validationResult.errorMessage,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ [DynamicDropdownBloc] Error in validation: $e');
      emit(
        DynamicDropdownError(
          component: state.component,
          inputConfig: state.inputConfig,
          currentValue: state.currentValue,
          errorMessage: 'Error in validation: $e',
        ),
      );
    }
  }

  Future<void> _onOptionSelected(
    DropdownOptionSelectedEvent event,
    Emitter<DynamicDropdownState> emit,
  ) async {
    debugPrint('🎯 [DynamicDropdownBloc] Option selected: ${event.value}');
    debugPrint('🎯 [DynamicDropdownBloc] Action: ${event.action}');
    debugPrint(
      '🎯 [DynamicDropdownBloc] Target section: ${event.targetSection}',
    );

    emit(DynamicDropdownLoading.fromState(state: state));

    try {
      // Update component with selected value
      final updatedComponent = state.component.copyWith(
        config: state.component.config?.copyWith(value: event.value),
      );

      // Find the selected option to store in navigation service
      final options = state.component.config?.options ?? [];
      final selectedOption = options.firstWhere(
        (opt) => opt.value == event.value,
        orElse: () => options.first,
      );

      // Store selection in navigation service if we have a page ID
      if (_currentPageId != null) {
        _navigationService.storeDropdownSelection(
          _currentPageId,
          state.component.id,
          selectedOption,
        );
        debugPrint(
          '🗂️ [DynamicDropdownBloc] Stored selection for page $_currentPageId, component ${state.component.id}',
        );
      }

      emit(
        DynamicDropdownSuccess.fromState(state: state).copyWith(
          component: updatedComponent,
          currentValue: event.value,
          errorText: null,
        ),
      );
    } catch (e) {
      debugPrint('❌ [DynamicDropdownBloc] Error in option selection: $e');
      emit(
        DynamicDropdownError(
          component: state.component,
          inputConfig: state.inputConfig,
          currentValue: state.currentValue,
          errorMessage: 'Error selecting option: $e',
        ),
      );
    }
  }

  ValidationResult _validateValue(String? value) {
    final config = state.component.config;
    final inputConfig = state.inputConfig;

    // Check if required
    if (config?.isRequired == true && (value == null || value.isEmpty)) {
      return ValidationResult(
        isValid: false,
        errorMessage: inputConfig.errorText ?? 'This field is required',
      );
    }

    // Check if value is in options list
    final options = config?.options ?? [];
    if (options.isNotEmpty && value != null && value.isNotEmpty) {
      final validOptions = options.map((opt) => opt.value).toList();
      if (!validOptions.contains(value)) {
        return ValidationResult(
          isValid: false,
          errorMessage: 'Please select a valid option',
        );
      }
    }

    return ValidationResult(isValid: true);
  }

  List<Option> getShuffledOptions() {
    final options = state.component.config?.options ?? [];
    if (state.component.config?.shuffleOptions == true) {
      final shuffled = List<Option>.from(options);
      shuffled.shuffle(Random());
      return shuffled;
    }
    return options;
  }

  /// Get navigation service instance
  DropdownNavigationService get navigationService => _navigationService;
}

class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult({
    required this.isValid,
    this.errorMessage,
  });
}
