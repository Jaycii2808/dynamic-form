// ignore_for_file: non_constant_identifier_names

import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/states/states_model.dart';
import 'package:dynamic_form_bi/data/models/states/style_states_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_field/dynamic_text_field_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_field/dynamic_text_field_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_field/dynamic_text_field_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicTextField extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicTextField({
    super.key,
    required this.component,
  });

  @override
  State<DynamicTextField> createState() => _DynamicTextFieldState();
}

class _DynamicTextFieldState extends State<DynamicTextField> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DynamicTextFieldBloc(initialComponent: widget.component),
      child: DynamicTextFieldWidget(
        component: widget.component,
      ),
    );
  }
}

class DynamicTextFieldWidget extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicTextFieldWidget({
    super.key,
    required this.component,
  });

  @override
  State<DynamicTextFieldWidget> createState() => _DynamicTextFieldWidgetState();
}

class _DynamicTextFieldWidgetState extends State<DynamicTextFieldWidget> {
  @override
  void initState() {
    super.initState();
    context.read<DynamicTextFieldBloc>().add(const InitializeTextFieldEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DynamicFormBloc, DynamicFormState>(
      listener: (context, formState) {
        // Listen to main form state changes and update text field bloc
        if (formState.page?.components != null) {
          final updatedComponent = formState.page!.components.firstWhere(
                (c) => c.id == widget.component.id,
            orElse: () => widget.component,
          );

          // Check if component state changed from external source
          if (updatedComponent.config?.currentState != widget.component.config?.currentState) {
            debugPrint(
              '🔄 [TextField] External state change detected: ${updatedComponent.config?.currentState}',
            );

            // Update the text field bloc with new component state
            context.read<DynamicTextFieldBloc>().add(
              UpdateTextFieldFromExternalEvent(component: updatedComponent),
            );
          }
        }
      },
      child: BlocConsumer<DynamicTextFieldBloc, DynamicTextFieldState>(
        listenWhen: (previous, current) {
          return previous is DynamicTextFieldLoading && current is DynamicTextFieldSuccess;
        },
        buildWhen: (previous, current) {
          // Rebuild when state, error, or form state changes
          return previous.formState != current.formState ||
              previous.errorText != current.errorText ||
              (previous.component?.config?.currentState ?? '') != (current.component?.config?.currentState ?? '');
        },
        listener: (context, state) {
          if (state is DynamicTextFieldSuccess) {
            final valueMap = {
              'value': state.component!.config?.value,
              'current_state': state.component!.config?.currentState ?? 'base',
              'error_text': state.errorText,
            };

            // Update the main form bloc with new value
            context.read<DynamicFormBloc>().add(
              UpdateFormFieldEvent(
                componentId: state.component!.id,
                value: valueMap,
              ),
            );

            if (state.textController!.text != (state.component!.config?.value?.toString() ?? '')) {
              state.textController!.text = state.component!.config?.value?.toString() ?? '';
            }
          }
        },
        builder: (context, state) {
          debugPrint(
            '🔵 [TextField] Building with state: ${state.runtimeType}, formState: ${state.formState}, errorText: ${state.errorText}',
          );

          if (state is DynamicTextFieldLoading || state is DynamicTextFieldInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DynamicTextFieldError) {
            return Center(
              child: Text(
                'Error: ${state.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is DynamicTextFieldSuccess) {
            debugPrint(
              '🎯 [TextField] Success state - formState: ${state.formState}, currentState: ${state.component?.config?.currentState}',
            );
            return _buildBody(
              state.styleModel!,
              state.inputConfig!,
              state.component!,
              state.formState!,
              state.errorText,
              state.textController!,
              state.focusNode!,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBody(
      StyleModel styleModel,
      InputConfig inputConfig,
      DynamicFormModel component,
      String currentState,
      String? errorText,
      TextEditingController textController,
      FocusNode focusNode,
      ) {
    // Determine the current state for styling
    String enabledBorderState = 'base';
    if (errorText != null && errorText.isNotEmpty) {
      enabledBorderState = 'error';
    } else if (currentState == 'success') {
      enabledBorderState = 'success';
    }
    final stateStyle = _getTypedStateStyle(component.states, enabledBorderState);


    return Container(
      key: Key(component.id),
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 12.0,
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 12.0,
      ) ,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(focusNode);
        },
        behavior: HitTestBehavior.translucent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✨ Label now uses state-based color
            _buildLabel(styleModel, inputConfig, stateStyle),
            _buildTextField(
              styleModel,
              inputConfig,
              component,
              currentState,
              errorText,
              textController,
              focusNode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(StyleModel styleModel, InputConfig inputConfig, StyleStatesModel? stateStyle) {
    if (inputConfig.label == null || inputConfig.label!.isEmpty) {
      return const SizedBox.shrink();
    }
    // ✨ Label color is now sourced from the state's iconColor
    final Color labelColor = stateStyle?.iconColor ?? styleModel.labelColor ?? Colors.white;

    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 7),
      child: Text(
        inputConfig.label!,
        style: TextStyle(
          fontSize: styleModel.labelTextSize,
          color: labelColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField(
      StyleModel styleModel,
      InputConfig inputConfig,
      DynamicFormModel component,
      String currentState,
      String? errorText,
      TextEditingController textController,
      FocusNode focusNode,
      ) {
    // Determine the appropriate border state based on current state and error
    String enabledBorderState = 'base';
    if (errorText != null && errorText.isNotEmpty) {
      enabledBorderState = 'error';
    } else if (currentState == 'success') {
      enabledBorderState = 'success';
    }

    // Get style from component states (as StyleStatesModel)
    final StyleStatesModel? stateStyle = _getTypedStateStyle(
      component.states,
      enabledBorderState,
    );

    // Determine text color from state or fallback to styleModel
    Color? textColor = stateStyle?.textColor ;

    // Determine helper text and color from state
    String? helperText = stateStyle?.helperText ?? styleModel.helperText;
    Color? helperTextColor = stateStyle?.helperTextColor ?? styleModel.helperTextColor;

    debugPrint(
      '🎨 [TextField] State: $enabledBorderState, textColor: $textColor, helperText: $helperText',
    );
    debugPrint('Debug: textColor before use: $textColor');
    debugPrint('Debug: helperTextColor before use: $helperTextColor');

    return TextField(
      controller: textController,
      focusNode: focusNode,
      enabled: inputConfig.editable && !inputConfig.disabled,
      readOnly: inputConfig.readOnly,
      obscureText: component.inputTypes?.password != null,
      keyboardType: _getKeyboardType(component),
      onChanged: (value) {
        context.read<DynamicTextFieldBloc>().add(
          TextFieldValueChangedEvent(value: value),
        );
      },
      decoration: InputDecoration(
        isDense: true,
        hintText: inputConfig.placeholder ?? '',
        prefixIcon: _buildPrefixIcon(component, currentState),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 0,
        ),
        // ✨ Borders now use state-based colors by passing the component
        border: _buildBorder(styleModel, component, enabledBorderState),
        enabledBorder: _buildBorder(styleModel, component, enabledBorderState),
        focusedBorder: _buildBorder(styleModel, component, 'focused'),
        errorBorder: _buildBorder(styleModel, component, 'error'),
        errorText: errorText,
        contentPadding: EdgeInsets.symmetric(
          vertical: styleModel.contentVerticalPadding ?? 12.0,
          horizontal: styleModel.contentHorizontalPadding ?? 12.0,
        ),
        helperText: helperText,
        helperStyle: TextStyle(
          color: helperTextColor ?? Colors.white,
          fontSize: 12,
        ),
        labelStyle: TextStyle(
          color: styleModel.labelColor ?? Colors.white,
        ),
      ),
      style: TextStyle(
        fontSize: styleModel.fontSize,
        color: textColor ?? Colors.white,
      ),
    );
  }

  Widget? _buildPrefixIcon(DynamicFormModel component, String currentState) {
    final stateStyle = _getTypedStateStyle(component.states, currentState);
    final iconName =component.config?.icon?.toString();
    if (iconName != null && iconName.isNotEmpty && stateStyle != null) {
      final iconColor = stateStyle.iconColor;
      final iconSize = stateStyle.iconSize;
      final iconData = IconTypeEnum.fromString(iconName).toIconData();
      if (iconData != null) {
        return Icon(iconData, color: iconColor, size: iconSize);
      }
    }
    return null;
  }
  TextInputType _getKeyboardType(DynamicFormModel component) {
    final inputTypes = component.inputTypes;
    if (inputTypes != null) {
      if (inputTypes.email != null) {
        return TextInputType.emailAddress;
      } else if (inputTypes.tel != null) {
        return TextInputType.phone;
      } else if (inputTypes.password != null) {
        return TextInputType.visiblePassword;
      }
    }
    return TextInputType.text;
  }

  StyleStatesModel? _getTypedStateStyle(StatesModel? states, String key) {
    switch (key) {
      case 'base':
        return states?.base;
      case 'error':
        return states?.error;
      case 'success':
        return states?.success;
      case 'focused':
        return states?.focused;
      default:
        return null;
    }
  }

  // ✨ UPDATED: This function now builds the border using the state-specific icon color
  OutlineInputBorder _buildBorder(
      StyleModel styleModel,
      DynamicFormModel component,
      String state,
      ) {
    final stateStyle = _getTypedStateStyle(component.states, state);

    // ✨ Border color now references the state's iconColor as requested
    final Color color = stateStyle?.iconColor ?? styleModel.borderColor ?? Colors.grey;
    final double width = stateStyle?.borderWidth ?? styleModel.borderWidth ?? 1.0;

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(styleModel.borderRadius ?? 8.0),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}