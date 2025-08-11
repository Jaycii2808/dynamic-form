
import 'package:dynamic_form_bi/core/enums/button_action_enum.dart';
import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/data/models/states/style_states_model.dart';
import 'package:dynamic_form_bi/data/models/variants/variants_model.dart';
import 'package:dynamic_form_bi/data/models/validation/button_condition_validation_model.dart';
import 'package:dynamic_form_bi/data/models/validation/validation_factory.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_button/dynamic_button_event.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_button/dynamic_button_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicButtonBloc extends Bloc<DynamicButtonEvent, DynamicButtonState> {
  DynamicButtonBloc() : super(const DynamicButtonInitial()) {
    on<SetButtonComponentEvent>(_onSetButtonComponent);
    on<RecomputeButtonUiEvent>(_onRecomputeUi);
    on<ButtonPressedEvent>(_onPressed);
  }

  void _onSetButtonComponent(
    SetButtonComponentEvent event,
    Emitter<DynamicButtonState> emit,
  ) {
    final computed = _computeFromComponent(event.component, const {});
    emit(
      DynamicButtonSuccess(
        component: event.component,
        config: computed.config,
        style: computed.style,
        buttonText: computed.buttonText,
        action: computed.action,
        isVisible: computed.isVisible,
        isDisabled: computed.isDisabled,
        isLoading: false,
        iconData: computed.iconData,
      ),
    );
  }

  void _onRecomputeUi(
    RecomputeButtonUiEvent event,
    Emitter<DynamicButtonState> emit,
  ) {
    final current = state.component;
    if (current == null) return;
    final computed = _computeFromComponent(current, event.externalValues);
    emit(
      DynamicButtonSuccess(
        component: current,
        config: computed.config,
        style: computed.style,
        buttonText: computed.buttonText,
        action: computed.action,
        isVisible: computed.isVisible,
        isDisabled: computed.isDisabled,
        isLoading: false,
        iconData: computed.iconData,
      ),
    );
  }

  Future<void> _onPressed(
    ButtonPressedEvent event,
    Emitter<DynamicButtonState> emit,
  ) async {
    // Only set loading for navigation/custom; business handling lives in UI via callback
    emit(DynamicButtonLoading.fromState(state: state));
    await Future.delayed(const Duration(milliseconds: 100));
    emit(
      DynamicButtonSuccess(
        component: state.component,
        config: state.config,
        style: state.style,
        buttonText: state.buttonText,
        action: state.action,
        isVisible: state.isVisible,
        isDisabled: state.isDisabled,
        isLoading: false,
        iconData: state.iconData,
      ),
    );
  }

  _Computed _computeFromComponent(
    DynamicFormModel component,
    Map<String, dynamic> values,
  ) {
    final config = component.config ?? const ConfigModel();

    // Button text
    final buttonText =
        config.label?.toString() ?? config.buttonText?.toString() ?? 'Button';

    // Action
    ButtonAction actionEnum;
    try {
      final actionRaw = config.action?.toString();
      actionEnum = ButtonAction.fromString(
        actionRaw ?? ButtonAction.custom.value,
      );
    } catch (_) {
      actionEnum = ButtonAction.custom;
    }

    // Visible (default true)
    final isVisible = true;

    // Validation
    bool validationPassed = true;
    final validation = ValidationFactory.fromJson(config.validate);
    if (validation is ButtonConditionValidationModel) {
      final conditions = validation.conditions;
      if (conditions.isNotEmpty) {
        for (final condition in conditions) {
          final id = condition.idComponent;
          final isRequired = condition.isRequired ?? false;
          final regex = condition.regex ?? '';
          final value = values[id];
          if (isRequired) {
            final missing =
                value == null ||
                (value is bool
                    ? value == false
                    : value.toString().trim().isEmpty);
            if (missing) {
              validationPassed = false;
              break;
            }
          }
          if (regex.isNotEmpty &&
              value != null &&
              value.toString().isNotEmpty) {
            try {
              final pattern = RegExp(regex);
              if (!pattern.hasMatch(value.toString())) {
                validationPassed = false;
                break;
              }
            } catch (_) {
              validationPassed = false;
              break;
            }
          }
        }
      }
    }

    // Disabled
    final isDisabled = !validationPassed;

    // Style merging (variant/state-minimal)
    StyleModel style = component.style;
    final variants = component.variants;
    final variantKey = config.toJson()['variant']?.toString() ?? 'primary';
    final variantStyle = variants.getByKey(variantKey)?.style;
    if (variantStyle != null) {
      style = _mergeStyleModels(
        style,
        _convertStyleStatesToStyleModel(variantStyle),
      );
    }

    // Icon
    IconData? iconData;
    final iconName = config.icon?.toString() ?? style.icon;
    if (iconName != null && iconName.isNotEmpty) {
      iconData = IconTypeEnum.fromString(iconName).toIconData();
    }

    return _Computed(
      config: config,
      style: style,
      buttonText: buttonText,
      action: actionEnum,
      isVisible: isVisible,
      isDisabled: isDisabled,
      iconData: iconData,
    );
  }

  StyleModel _convertStyleStatesToStyleModel(StyleStatesModel stateStyle) {
    return StyleModel(
      borderColor: stateStyle.borderColor,
      borderWidth: stateStyle.borderWidth,
      helperText: stateStyle.helperText,
      helperTextColor: stateStyle.helperTextColor,
      textColor: stateStyle.textColor,
      icon: stateStyle.icon,
      iconColor: stateStyle.iconColor,
      iconSize: stateStyle.iconSize,
    );
  }

  StyleModel _mergeStyleModels(StyleModel base, StyleModel overlay) {
    return StyleModel(
      fontSize: overlay.fontSize ?? base.fontSize,
      fontStyle: overlay.fontStyle ?? base.fontStyle,
      contentVerticalPadding:
          overlay.contentVerticalPadding ?? base.contentVerticalPadding,
      contentHorizontalPadding:
          overlay.contentHorizontalPadding ?? base.contentHorizontalPadding,
      backgroundColor: overlay.backgroundColor ?? base.backgroundColor,
      helperText: overlay.helperText ?? base.helperText,
      helperTextColor: overlay.helperTextColor ?? base.helperTextColor,
      labelTextSize: overlay.labelTextSize ?? base.labelTextSize,
      labelColor: overlay.labelColor ?? base.labelColor,
      maxLines: overlay.maxLines ?? base.maxLines,
      minLines: overlay.minLines ?? base.minLines,
      borderRadius: overlay.borderRadius ?? base.borderRadius,
      borderColor: overlay.borderColor ?? base.borderColor,
      borderWidth: overlay.borderWidth ?? base.borderWidth,
      borderOpacity: overlay.borderOpacity ?? base.borderOpacity,
      iconColor: overlay.iconColor ?? base.iconColor,
      hintColor: overlay.hintColor ?? base.hintColor,
      width: overlay.width ?? base.width,
      height: overlay.height ?? base.height,
      activeColor: overlay.activeColor ?? base.activeColor,
      inactiveColor: overlay.inactiveColor ?? base.inactiveColor,
      inactiveTrackColor: overlay.inactiveTrackColor ?? base.inactiveTrackColor,
      tagBackgroundColor: overlay.tagBackgroundColor ?? base.tagBackgroundColor,
      tagRemoveIconColor: overlay.tagRemoveIconColor ?? base.tagRemoveIconColor,
      thumbColor: overlay.thumbColor ?? base.thumbColor,
      thumbIconColor: overlay.thumbIconColor ?? base.thumbIconColor,
      valueLabelColor: overlay.valueLabelColor ?? base.valueLabelColor,
      iconSize: overlay.iconSize ?? base.iconSize,
      textColor: overlay.textColor ?? base.textColor,
      buttonBackgroundColor:
          overlay.buttonBackgroundColor ?? base.buttonBackgroundColor,
      buttonBorderRadius: overlay.buttonBorderRadius ?? base.buttonBorderRadius,
      buttonTextColor: overlay.buttonTextColor ?? base.buttonTextColor,
      icon: overlay.icon ?? base.icon,
      iconPosition: overlay.iconPosition ?? base.iconPosition,
      fontWeight: overlay.fontWeight ?? base.fontWeight,
      elevation: overlay.elevation ?? base.elevation,
      shadowColor: overlay.shadowColor ?? base.shadowColor,
      focusedBorderColor: overlay.focusedBorderColor ?? base.focusedBorderColor,
      errorBorderColor: overlay.errorBorderColor ?? base.errorBorderColor,
    );
  }
}

class _Computed {
  final ConfigModel config;
  final StyleModel style;
  final String buttonText;
  final ButtonAction action;
  final bool isVisible;
  final bool isDisabled;
  final IconData? iconData;
  const _Computed({
    required this.config,
    required this.style,
    required this.buttonText,
    required this.action,
    required this.isVisible,
    required this.isDisabled,
    required this.iconData,
  });
}
