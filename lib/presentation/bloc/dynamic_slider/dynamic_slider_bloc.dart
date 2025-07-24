import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/core/enums/component_state_enum.dart';
import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/core/utils/validation_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/data/models/variants/variants_model.dart';
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

  double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
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

      final styleConfig = StyleConfig.fromJson(initialComponent.style.toJson());
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
            _parseDouble(values[0]) ?? computedData['min'] as double,
            _parseDouble(values[1]) ?? computedData['max'] as double,
          );
        } else {
          sliderRangeValues = RangeValues(
            computedData['min'] as double,
            computedData['max'] as double,
          );
        }
      } else {
        final value = initialComponent.config['value'];
        sliderValue = _parseDouble(value) ?? computedData['min'] as double;
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
      final styleConfig = StyleConfig.fromJson(event.component.style.toJson());
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
            _parseDouble(values[0]) ?? computedData['min'] as double,
            _parseDouble(values[1]) ?? computedData['max'] as double,
          );
        }
      } else {
        final value = event.component.config['value'];
        sliderValue = _parseDouble(value) ?? computedData['min'] as double;
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
      final styleModel = StyleModel.fromJson(currentState.computedStyle);
      final sliderTheme = SliderTheme.of(event.context).copyWith(
        activeTrackColor: StyleUtils.parseColor(
          styleModel.activeColor,
        ),
        inactiveTrackColor: StyleUtils.parseColor(
          styleModel.inactiveColor,
        ),
        thumbColor: StyleUtils.parseColor(
          styleModel.thumbColor,
        ),
        overlayColor: StyleUtils.parseColor(
          styleModel.activeColor,
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
    Map<String, dynamic> style = component.style.toJson();

    final bool isRange = config['range'] == true;
    final double min = _parseDouble(config['min']) ?? 0;
    final double max = _parseDouble(config['max']) ?? 100;
    final int? divisions = _parseInt(config['divisions']);
    final String prefix = config['prefix']?.toString() ?? '';
    final String? hint = config['hint'] as String?;
    final String? iconName = config['icon'] as String?;
    final String? thumbIconName = config['thumb_icon'] as String?;
    final bool isDisabled = config['disabled'] == true;

    // Apply variants to style
    final withHintStyle =
        component.variants?.getByKey('with_hint')?.style
            as Map<String, dynamic>?;
    final withIconStyle =
        component.variants?.getByKey('with_icon')?.style
            as Map<String, dynamic>?;
    final withThumbIconStyle =
        component.variants?.getByKey('with_thumb_icon')?.style
            as Map<String, dynamic>?;

    if (withHintStyle != null) style.addAll(withHintStyle);
    if (withIconStyle != null) style.addAll(withIconStyle);
    if (withThumbIconStyle != null) style.addAll(withThumbIconStyle);

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

  ComponentStateEnum _computeFormState(
    DynamicFormModel component,
    dynamic value,
  ) {
    final validationError = _validateSlider(component, value);

    if (validationError != null && validationError.isNotEmpty) {
      return ComponentStateEnum.error;
    }

    // Check if has value (success state)
    if (value != null) {
      if (value is RangeValues) {
        return ComponentStateEnum.success;
      } else if (value is double) {
        return ComponentStateEnum.success;
      }
    }

    return ComponentStateEnum.base;
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
