import 'package:bloc/bloc.dart';
import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/core/utils/validation_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_select/dynamic_select_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_select/dynamic_select_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicSelectBloc extends Bloc<DynamicSelectEvent, DynamicSelectState> {
  final DynamicFormModel initialComponent;
  late GlobalKey selectKey;
  late FocusNode focusNode;

  DynamicSelectBloc({required this.initialComponent})
    : super(const DynamicSelectInitial()) {
    selectKey = GlobalKey();
    focusNode = FocusNode();

    on<InitializeSelectEvent>(_onInitialize);
    on<SelectValueChangedEvent>(_onValueChanged);
    on<MultipleOptionToggleEvent>(_onMultipleOptionToggle);
    on<ToggleDropdownEvent>(_onToggleDropdown);
    on<OpenDropdownEvent>(_onOpenDropdown);
    on<CloseDropdownEvent>(_onCloseDropdown);
    on<UpdateSelectFromExternalEvent>(_onUpdateFromExternal);
  }

  @override
  Future<void> close() {
    try {
      // Safely remove overlay if it exists
      if (state is DynamicSelectSuccess) {
        final currentState = state as DynamicSelectSuccess;
        if (currentState.overlayEntry != null) {
          currentState.overlayEntry!.remove();
        }
      }
    } catch (e) {
      debugPrint('❌ [SelectBloc] Error removing overlay on close: $e');
    }

    focusNode.dispose();
    return super.close();
  }

  Future<void> _onInitialize(
    InitializeSelectEvent event,
    Emitter<DynamicSelectState> emit,
  ) async {
    try {
      emit(
        DynamicSelectLoading(
          component: initialComponent,
        ),
      );

      final styleConfig = StyleConfig.fromJson(initialComponent.style);
      final inputConfig = InputConfig.fromJson(initialComponent.config);

      // Extract options and configuration
      final options =
          initialComponent.config['options'] as List<dynamic>? ?? [];
      final isMultiple = initialComponent.config['multiple'] ?? false;
      final isSearchable = initialComponent.config['searchable'] ?? false;
      final isDisabled = initialComponent.config['disabled'] == true;

      // Get initial value
      final value = initialComponent.config[ValueKeyEnum.value.key];
      dynamic selectedValue;
      if (isMultiple) {
        selectedValue = value is List ? value : [];
      } else {
        selectedValue = value;
      }

      // Compute initial form state
      final formState = _computeFormState(initialComponent, selectedValue);

      // Compute validation error
      final errorText = _validateSelect(initialComponent, selectedValue);

      debugPrint(
        '📋 [SelectBloc] Initial options: ${options.length} items',
      );
      for (int i = 0; i < options.length && i < 3; i++) {
        debugPrint('  Option $i: ${options[i]}');
      }

      debugPrint(
        '🟢 [SelectBloc] Initialized: ${initialComponent.id}, state: $formState',
      );

      emit(
        DynamicSelectSuccess(
          component: initialComponent,
          styleConfig: styleConfig,
          inputConfig: inputConfig,
          formState: formState,
          errorText: errorText,
          isDropdownOpen: false,
          options: options,
          selectedValue: selectedValue,
          isMultiple: isMultiple,
          isSearchable: isSearchable,
          isDisabled: isDisabled,
          selectKey: selectKey,
          focusNode: focusNode,
        ),
      );
    } catch (e) {
      debugPrint('❌ [SelectBloc] Initialization error: $e');
      emit(
        DynamicSelectError(
          errorMessage: 'Failed to initialize select: ${e.toString()}',
          component: initialComponent,
        ),
      );
    }
  }

  Future<void> _onValueChanged(
    SelectValueChangedEvent event,
    Emitter<DynamicSelectState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicSelectSuccess) return;

    try {
      debugPrint(
        '📥 [SelectBloc] Received value: ${event.value} (type: ${event.value.runtimeType})',
      );
      debugPrint(
        '📋 [SelectBloc] Current selected: ${currentState.selectedValue} (type: ${currentState.selectedValue.runtimeType})',
      );

      final updatedComponent = _updateComponentValue(
        currentState.component!,
        event.value,
      );

      final formState = _computeFormState(updatedComponent, event.value);
      final errorText = _validateSelect(updatedComponent, event.value);

      debugPrint(
        '🔄 [SelectBloc] Value changed: ${updatedComponent.id} = ${event.value}',
      );

      emit(
        currentState.copyWith(
          component: updatedComponent,
          selectedValue: event.value,
          formState: formState,
          errorText: errorText,
          selectionTimestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } catch (e) {
      debugPrint('❌ [SelectBloc] Value change error: $e');
      emit(
        DynamicSelectError(
          errorMessage: 'Failed to update value: ${e.toString()}',
          component: currentState.component,
          formState: currentState.formState,
          errorText: currentState.errorText,
        ),
      );
    }
  }

  Future<void> _onMultipleOptionToggle(
    MultipleOptionToggleEvent event,
    Emitter<DynamicSelectState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicSelectSuccess) return;

    try {
      // Get current selected values
      List<String> currentValues = currentState.selectedValue is List
          ? (currentState.selectedValue as List).cast<String>()
          : [];

      // Create new values list
      List<String> newValues = List.from(currentValues);
      if (event.isSelected) {
        if (!newValues.contains(event.optionValue)) {
          newValues.add(event.optionValue);
        }
      } else {
        newValues.remove(event.optionValue);
      }

      // Update component and state
      final updatedComponent = _updateComponentValue(
        currentState.component!,
        newValues,
      );

      final formState = _computeFormState(updatedComponent, newValues);
      final errorText = _validateSelect(updatedComponent, newValues);

      debugPrint(
        '🔄 [MultipleBloc] Multiple selection changed: ${updatedComponent.id} = $newValues',
      );

      emit(
        currentState.copyWith(
          component: updatedComponent,
          selectedValue: newValues,
          formState: formState,
          errorText: errorText,
          selectionTimestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } catch (e) {
      debugPrint('❌ [MultipleBloc] Multiple toggle error: $e');
      emit(
        DynamicSelectError(
          errorMessage: 'Failed to toggle multiple option: ${e.toString()}',
          component: currentState.component,
          formState: currentState.formState,
          errorText: currentState.errorText,
        ),
      );
    }
  }

  Future<void> _onToggleDropdown(
    ToggleDropdownEvent event,
    Emitter<DynamicSelectState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicSelectSuccess) return;

    debugPrint(
      '📥 [SelectBloc] ToggleDropdownEvent received',
    );
    debugPrint(
      '🔄 [SelectBloc] Toggling dropdown: ${currentState.isDropdownOpen} → ${!currentState.isDropdownOpen}',
    );

    emit(
      currentState.copyWith(
        isDropdownOpen: !currentState.isDropdownOpen,
      ),
    );

    debugPrint(
      '✅ [SelectBloc] Dropdown toggled: ${!currentState.isDropdownOpen}',
    );
  }

  Future<void> _onOpenDropdown(
    OpenDropdownEvent event,
    Emitter<DynamicSelectState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicSelectSuccess) return;

    try {
      debugPrint('📤 [SelectBloc] Creating overlay for dropdown');

      final overlayEntry = _createOverlayEntry(event.position, event.context);

      // Insert overlay
      Overlay.of(event.context).insert(overlayEntry);

      emit(
        currentState.copyWith(
          isDropdownOpen: true,
          dropdownPosition: event.position,
          overlayEntry: overlayEntry,
        ),
      );

      debugPrint('✅ [SelectBloc] Overlay created and opened');
    } catch (e) {
      debugPrint('❌ [SelectBloc] Error creating overlay: $e');
      emit(currentState.copyWith(isDropdownOpen: false));
    }
  }

  Future<void> _onCloseDropdown(
    CloseDropdownEvent event,
    Emitter<DynamicSelectState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicSelectSuccess) return;

    try {
      // Safely remove overlay
      if (currentState.overlayEntry != null) {
        currentState.overlayEntry!.remove();
      }

      emit(
        currentState.copyWith(
          isDropdownOpen: false,
          dropdownPosition: null,
          overlayEntry: null,
        ),
      );

      debugPrint('📥 [SelectBloc] Overlay removed and dropdown closed');
    } catch (e) {
      debugPrint('❌ [SelectBloc] Error removing overlay: $e');
      emit(currentState.copyWith(isDropdownOpen: false));
    }
  }

  Future<void> _onUpdateFromExternal(
    UpdateSelectFromExternalEvent event,
    Emitter<DynamicSelectState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicSelectSuccess) return;

    try {
      final styleConfig = StyleConfig.fromJson(event.component.style);
      final inputConfig = InputConfig.fromJson(event.component.config);

      // Extract updated configuration
      final options = event.component.config['options'] as List<dynamic>? ?? [];
      final isMultiple = event.component.config['multiple'] ?? false;
      final isSearchable = event.component.config['searchable'] ?? false;
      final isDisabled = event.component.config['disabled'] == true;

      // Get updated value
      final value = event.component.config[ValueKeyEnum.value.key];
      dynamic selectedValue;
      if (isMultiple) {
        selectedValue = value is List ? value : [];
      } else {
        selectedValue = value;
      }

      final formState = _computeFormState(event.component, selectedValue);
      final errorText = _validateSelect(event.component, selectedValue);

      debugPrint(
        '🔄 [SelectBloc] External update: ${event.component.id}, value: $selectedValue, state: $formState',
      );

      emit(
        currentState.copyWith(
          component: event.component,
          styleConfig: styleConfig,
          inputConfig: inputConfig,
          formState: formState,
          errorText: errorText,
          options: options,
          selectedValue: selectedValue,
          isMultiple: isMultiple,
          isSearchable: isSearchable,
          isDisabled: isDisabled,
        ),
      );
    } catch (e) {
      debugPrint('❌ [SelectBloc] External update error: $e');
      emit(
        DynamicSelectError(
          errorMessage: 'Failed to update from external: ${e.toString()}',
          component: event.component,
        ),
      );
    }
  }

  DynamicFormModel _updateComponentValue(
    DynamicFormModel component,
    dynamic newValue,
  ) {
    final updatedConfig = Map<String, dynamic>.from(component.config);
    updatedConfig[ValueKeyEnum.value.key] = newValue;

    return DynamicFormModel(
      id: component.id,
      type: component.type,
      order: component.order,
      config: updatedConfig,
      style: component.style,
      states: component.states,
      variants: component.variants,
      validation: component.validation,
      inputTypes: component.inputTypes,
    );
  }

  FormStateEnum _computeFormState(DynamicFormModel component, dynamic value) {
    final validationError = _validateSelect(component, value);

    if (validationError != null && validationError.isNotEmpty) {
      return FormStateEnum.error;
    }

    // Check if has value (success state)
    if (component.config['multiple'] == true) {
      if (value is List && value.isNotEmpty) {
        return FormStateEnum.success;
      }
    } else {
      if (value != null && value.toString().isNotEmpty) {
        return FormStateEnum.success;
      }
    }

    return FormStateEnum.base;
  }

  String? _validateSelect(DynamicFormModel component, dynamic value) {
    try {
      // Convert value to list for consistent validation
      List<String> values = [];
      if (component.config['multiple'] == true) {
        if (value is List) {
          values = value.cast<String>();
        }
      } else {
        if (value != null && value.toString().isNotEmpty) {
          values = [value.toString()];
        }
      }

      // Quick check for empty values (required field validation)
      if (values.isEmpty) {
        return ValidationUtils.validateForm(component, '');
      }

      // Fast path: Check max selections first (most common case)
      if (component.config['multiple'] == true) {
        final validationConfig = component.validation;
        if (validationConfig != null) {
          final maxSelectionsValidation =
              validationConfig['max_selections'] as Map<String, dynamic>?;
          if (maxSelectionsValidation != null) {
            final max = maxSelectionsValidation['max'];
            if (max != null && values.length > max) {
              return maxSelectionsValidation['error_message'] as String? ??
                  'Exceeds maximum allowed quantity';
            }
          }
        }
      }

      // Only validate individual values if there are multiple validation rules
      final hasComplexValidation =
          component.validation != null && component.validation!.length > 1;

      if (hasComplexValidation) {
        for (String val in values) {
          final validationError = ValidationUtils.validateForm(component, val);
          if (validationError != null) {
            return validationError;
          }
        }
      } else {
        // For simple cases, just validate the first value
        final validationError = ValidationUtils.validateForm(
          component,
          values.first,
        );
        if (validationError != null) {
          return validationError;
        }
      }

      return null;
    } catch (e) {
      debugPrint('Validation error for ${component.id}: $e');
      return 'Validation error occurred';
    }
  }

  // Overlay creation and management
  OverlayEntry _createOverlayEntry(Rect position, BuildContext context) {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Background to close dropdown
          Positioned.fill(
            child: GestureDetector(
              onTap: () => add(const CloseDropdownEvent()),
              child: Container(color: Colors.transparent),
            ),
          ),
          // Dropdown content
          Positioned(
            left: position.left,
            top: position.bottom,
            width: position.width,
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(8.0),
              child: BlocBuilder<DynamicSelectBloc, DynamicSelectState>(
                bloc: this,
                buildWhen: (previous, current) {
                  // Rebuild when selection changes
                  if (previous is DynamicSelectSuccess &&
                      current is DynamicSelectSuccess) {
                    return previous.selectedValue != current.selectedValue;
                  }
                  return true;
                },
                builder: (context, overlayState) {
                  if (overlayState is DynamicSelectSuccess) {
                    return _buildDropdownList(overlayState);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownList(DynamicSelectSuccess state) {
    final dynamic height = state.component!.config['height'];

    Widget listView = ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: height == null || height == 'auto',
      itemCount: state.options.length,
      itemBuilder: (context, index) {
        final option = state.options[index];
        final optionValue = option['value']?.toString() ?? '';
        final label = option['label']?.toString() ?? '';
        final avatarUrl = option['avatar']?.toString();

        if (state.isMultiple) {
          final selectedValues = state.selectedValue is List
              ? (state.selectedValue as List).cast<String>()
              : <String>[];
          bool isSelected = selectedValues.contains(optionValue);

          return CheckboxListTile(
            title: Text(label),
            value: isSelected,
            onChanged: (bool? newValue) {
              add(
                MultipleOptionToggleEvent(
                  optionValue: optionValue,
                  isSelected: newValue == true,
                ),
              );
            },
            secondary: avatarUrl != null
                ? CircleAvatar(backgroundImage: NetworkImage(avatarUrl))
                : null,
          );
        } else {
          return ListTile(
            leading: avatarUrl != null
                ? CircleAvatar(backgroundImage: NetworkImage(avatarUrl))
                : null,
            title: Text(label),
            onTap: () {
              add(SelectValueChangedEvent(value: optionValue));
              add(const CloseDropdownEvent());
            },
          );
        }
      },
    );

    Widget listContainer;
    if (height is num) {
      listContainer = SizedBox(height: height.toDouble(), child: listView);
    } else {
      listContainer = listView;
    }

    return Container(
      decoration: BoxDecoration(
        color: StyleUtils.parseColor(
          state.component!.style['background_color'],
        ),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: StyleUtils.parseColor(state.component!.style['border_color']),
        ),
      ),
      child: listContainer,
    );
  }
}
