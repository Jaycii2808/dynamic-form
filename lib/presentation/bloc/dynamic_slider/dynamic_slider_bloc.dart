import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/core/utils/validation_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_slider/dynamic_slider_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_slider/dynamic_slider_state.dart';
import 'package:flutter/material.dart';

class DynamicSliderBloc extends Bloc<DynamicSliderEvent, DynamicSliderState> {
  final DynamicFormModel initialComponent;
  late FocusNode focusNode;

  DynamicSliderBloc({required this.initialComponent})
    : super(const DynamicSliderInitial()) {
    focusNode = FocusNode();

    on<InitializeSliderEvent>(_onInitialize);
    on<SliderValueChangedEvent>(_onValueChanged);
    on<SliderChangeStartEvent>(_onChangeStart);
    on<SliderChangeEndEvent>(_onChangeEnd);
    on<UpdateSliderFromExternalEvent>(_onUpdateFromExternal);
    on<ComputeSliderThemeEvent>(_onComputeTheme);
  }

  @override
  Future<void> close() {
    focusNode.dispose();
    return super.close();
  }

  Future<void> _onInitialize(
    InitializeSliderEvent event,
    Emitter<DynamicSliderState> emit,
  ) async {
    try {
      emit(DynamicSliderLoading(component: initialComponent));

      final styleConfig = StyleConfig.fromJson(initialComponent.style);
      final inputConfig = InputConfig.fromJson(initialComponent.config);

      // Compute all values from component
      final computedData = _computeSliderData(initialComponent);

      // Get initial values
      dynamic sliderValue;
      RangeValues? sliderRangeValues;

      if (computedData['isRange']) {
        final values = initialComponent.config['values'];
        if (values is List && values.length == 2) {
          sliderRangeValues = RangeValues(
            (values[0] as num).toDouble(),
            (values[1] as num).toDouble(),
          );
        } else {
          sliderRangeValues = RangeValues(
            computedData['min'] as double,
            computedData['max'] as double,
          );
        }
      } else {
        final value = initialComponent.config['value'];
        sliderValue = value is num
            ? value.toDouble()
            : computedData['min'] as double;
      }

      final formState = _computeFormState(
        initialComponent,
        computedData['isRange'] ? sliderRangeValues : sliderValue,
      );
      final errorText = _validateSlider(
        initialComponent,
        computedData['isRange'] ? sliderRangeValues : sliderValue,
      );

      debugPrint(
        '🟢 [SliderBloc] Initialized: ${initialComponent.id}, state: $formState',
      );

      emit(
        DynamicSliderSuccess(
          component: initialComponent,
          styleConfig: styleConfig,
          inputConfig: inputConfig,
          formState: formState,
          errorText: errorText,
          sliderValue: sliderValue,
          sliderRangeValues: sliderRangeValues,
          isRange: computedData['isRange'] as bool,
          min: computedData['min'] as double,
          max: computedData['max'] as double,
          divisions: computedData['divisions'] as int?,
          prefix: computedData['prefix'] as String,
          hint: computedData['hint'] as String?,
          iconName: computedData['iconName'] as String?,
          thumbIconName: computedData['thumbIconName'] as String?,
          isDisabled: computedData['isDisabled'] as bool,
          computedStyle: computedData['style'] as Map<String, dynamic>,
          thumbIcon: computedData['thumbIcon'] as IconData?,
          focusNode: focusNode,
          valueTimestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } catch (e) {
      debugPrint('❌ [SliderBloc] Initialization error: $e');
      emit(
        DynamicSliderError(
          errorMessage: 'Failed to initialize slider: ${e.toString()}',
          component: initialComponent,
        ),
      );
    }
  }

  Future<void> _onValueChanged(
    SliderValueChangedEvent event,
    Emitter<DynamicSliderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicSliderSuccess) return;

    try {
      dynamic newValue;
      double? sliderValue = currentState.sliderValue;
      RangeValues? sliderRangeValues = currentState.sliderRangeValues;

      if (currentState.isRange && event.value is RangeValues) {
        sliderRangeValues = event.value as RangeValues;
        newValue = [sliderRangeValues.start, sliderRangeValues.end];
      } else if (!currentState.isRange && event.value is double) {
        sliderValue = event.value as double;
        newValue = sliderValue;
      } else {
        return; // Invalid value type
      }

      // Only update local state during sliding, don't send to form bloc yet
      emit(
        currentState.copyWith(
          sliderValue: sliderValue,
          sliderRangeValues: sliderRangeValues,
          valueTimestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      debugPrint(
        '🔄 [SliderBloc] Value changed: ${currentState.component!.id} = $newValue',
      );
    } catch (e) {
      debugPrint('❌ [SliderBloc] Value change error: $e');
    }
  }

  Future<void> _onChangeStart(
    SliderChangeStartEvent event,
    Emitter<DynamicSliderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicSliderSuccess) return;

    emit(currentState.copyWith(isUserSliding: true));
    debugPrint('🎯 [SliderBloc] User started sliding');
  }

  Future<void> _onChangeEnd(
    SliderChangeEndEvent event,
    Emitter<DynamicSliderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicSliderSuccess) return;

    try {
      dynamic finalValue;
      double? sliderValue = currentState.sliderValue;
      RangeValues? sliderRangeValues = currentState.sliderRangeValues;

      if (currentState.isRange && event.value is RangeValues) {
        sliderRangeValues = event.value as RangeValues;
        finalValue = [sliderRangeValues.start, sliderRangeValues.end];
      } else if (!currentState.isRange && event.value is double) {
        sliderValue = event.value as double;
        finalValue = sliderValue;
      } else {
        return; // Invalid value type
      }

      // Update component with final value
      final updatedComponent = _updateComponentValue(
        currentState.component!,
        finalValue,
      );

      final formState = _computeFormState(updatedComponent, finalValue);
      final errorText = _validateSlider(updatedComponent, finalValue);

      emit(
        currentState.copyWith(
          component: updatedComponent,
          sliderValue: sliderValue,
          sliderRangeValues: sliderRangeValues,
          formState: formState,
          errorText: errorText,
          isUserSliding: false,
          valueTimestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      debugPrint(
        '✅ [SliderBloc] User finished sliding: ${updatedComponent.id} = $finalValue',
      );
    } catch (e) {
      debugPrint('❌ [SliderBloc] Change end error: $e');
      emit(currentState.copyWith(isUserSliding: false));
    }
  }

  Future<void> _onUpdateFromExternal(
    UpdateSliderFromExternalEvent event,
    Emitter<DynamicSliderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicSliderSuccess) return;

    // Don't sync while user is sliding
    if (currentState.isUserSliding) return;

    try {
      final styleConfig = StyleConfig.fromJson(event.component.style);
      final inputConfig = InputConfig.fromJson(event.component.config);

      // Compute all values from updated component
      final computedData = _computeSliderData(event.component);

      // Get updated values
      dynamic sliderValue;
      RangeValues? sliderRangeValues;

      if (computedData['isRange']) {
        final values = event.component.config['values'];
        if (values is List && values.length == 2) {
          sliderRangeValues = RangeValues(
            (values[0] as num).toDouble(),
            (values[1] as num).toDouble(),
          );
        }
      } else {
        final value = event.component.config['value'];
        if (value is num) {
          sliderValue = value.toDouble();
        }
      }

      final formState = _computeFormState(
        event.component,
        computedData['isRange'] ? sliderRangeValues : sliderValue,
      );
      final errorText = _validateSlider(
        event.component,
        computedData['isRange'] ? sliderRangeValues : sliderValue,
      );

      debugPrint(
        '🔄 [SliderBloc] External update: ${event.component.id}, state: $formState',
      );

      emit(
        currentState.copyWith(
          component: event.component,
          styleConfig: styleConfig,
          inputConfig: inputConfig,
          formState: formState,
          errorText: errorText,
          sliderValue: sliderValue,
          sliderRangeValues: sliderRangeValues,
          isRange: computedData['isRange'] as bool,
          min: computedData['min'] as double,
          max: computedData['max'] as double,
          divisions: computedData['divisions'] as int?,
          prefix: computedData['prefix'] as String,
          hint: computedData['hint'] as String?,
          iconName: computedData['iconName'] as String?,
          thumbIconName: computedData['thumbIconName'] as String?,
          isDisabled: computedData['isDisabled'] as bool,
          computedStyle: computedData['style'] as Map<String, dynamic>,
          thumbIcon: computedData['thumbIcon'] as IconData?,
          valueTimestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } catch (e) {
      debugPrint('❌ [SliderBloc] External update error: $e');
      emit(
        DynamicSliderError(
          errorMessage: 'Failed to update from external: ${e.toString()}',
          component: event.component,
        ),
      );
    }
  }

  Future<void> _onComputeTheme(
    ComputeSliderThemeEvent event,
    Emitter<DynamicSliderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicSliderSuccess) return;

    try {
      final sliderTheme = SliderTheme.of(event.context).copyWith(
        activeTrackColor: StyleUtils.parseColor(
          currentState.computedStyle['active_color'],
        ),
        inactiveTrackColor: StyleUtils.parseColor(
          currentState.computedStyle['inactive_color'],
        ),
        thumbColor: StyleUtils.parseColor(
          currentState.computedStyle['thumb_color'],
        ),
        overlayColor: StyleUtils.parseColor(
          currentState.computedStyle['active_color'],
        ).withValues(alpha: 0.2),
        trackHeight: 6.0,
      );

      emit(currentState.copyWith(sliderTheme: sliderTheme));
    } catch (e) {
      debugPrint('❌ [SliderBloc] Theme computation error: $e');
    }
  }

  // Helper methods
  Map<String, dynamic> _computeSliderData(DynamicFormModel component) {
    final config = component.config;
    Map<String, dynamic> style = Map<String, dynamic>.from(component.style);

    final bool isRange = config['range'] == true;
    final double min = (config['min'] as num?)?.toDouble() ?? 0;
    final double max = (config['max'] as num?)?.toDouble() ?? 100;
    final int? divisions = (config['divisions'] as num?)?.toInt();
    final String prefix = config['prefix']?.toString() ?? '';
    final String? hint = config['hint'] as String?;
    final String? iconName = config['icon'] as String?;
    final String? thumbIconName = config['thumb_icon'] as String?;
    final bool isDisabled = config['disabled'] == true;

    // Apply variants to style
    if (component.variants != null) {
      if (hint != null && component.variants!.containsKey('with_hint')) {
        final variantStyle =
            component.variants!['with_hint']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (iconName != null && component.variants!.containsKey('with_icon')) {
        final variantStyle =
            component.variants!['with_icon']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (thumbIconName != null &&
          component.variants!.containsKey('with_thumb_icon')) {
        final variantStyle =
            component.variants!['with_thumb_icon']['style']
                as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
    }

    // Compute thumb icon
    final IconData? thumbIcon = thumbIconName != null
        ? IconTypeEnum.fromString(thumbIconName).toIconData()
        : null;

    return {
      'isRange': isRange,
      'min': min,
      'max': max,
      'divisions': divisions,
      'prefix': prefix,
      'hint': hint,
      'iconName': iconName,
      'thumbIconName': thumbIconName,
      'isDisabled': isDisabled,
      'style': style,
      'thumbIcon': thumbIcon,
    };
  }

  DynamicFormModel _updateComponentValue(
    DynamicFormModel component,
    dynamic newValue,
  ) {
    final updatedConfig = Map<String, dynamic>.from(component.config);

    if (newValue is List && newValue.length == 2) {
      // Range values
      updatedConfig['values'] = newValue;
    } else {
      // Single value
      updatedConfig[ValueKeyEnum.value.key] = newValue;
    }

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
    final validationError = _validateSlider(component, value);

    if (validationError != null && validationError.isNotEmpty) {
      return FormStateEnum.error;
    }

    // Check if has value (success state)
    if (value != null) {
      if (value is RangeValues) {
        return FormStateEnum.success;
      } else if (value is double) {
        return FormStateEnum.success;
      }
    }

    return FormStateEnum.base;
  }

  String? _validateSlider(DynamicFormModel component, dynamic value) {
    try {
      if (value == null) {
        return ValidationUtils.validateForm(component, '');
      }

      String valueString;
      if (value is RangeValues) {
        valueString = '${value.start}-${value.end}';
      } else {
        valueString = value.toString();
      }

      return ValidationUtils.validateForm(component, valueString);
    } catch (e) {
      debugPrint('Validation error for ${component.id}: $e');
      return 'Validation error occurred';
    }
  }
}
