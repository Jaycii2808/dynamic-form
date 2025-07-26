import 'package:dynamic_form_bi/core/enums/component_state_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/states/states_model.dart';
import 'package:dynamic_form_bi/data/models/states/style_states_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_area/dynamic_text_area_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_area/dynamic_text_area_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_area/dynamic_text_area_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';

class DynamicTextArea extends StatelessWidget {
  final DynamicFormModel component;
  final Function(dynamic) onComplete;

  const DynamicTextArea({
    super.key,
    required this.component,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DynamicTextAreaBloc, DynamicTextAreaState>(
      listener: (context, state) {
        final valueMap = {
          ValueKeyEnum.value.key:
              state.component!.config[ValueKeyEnum.value.key],
          ValueKeyEnum.currentState.key:
              state.component!.config[ValueKeyEnum.currentState.key],
          ValueKeyEnum.errorText.key: state.errorText,
        };
        if (state is DynamicTextAreaSuccess) {
          onComplete(valueMap);
          if (state.textController!.text !=
              state.component!.config[ValueKeyEnum.value.key]) {
            state.textController!.text =
                state.component!.config[ValueKeyEnum.value.key] ?? '';
          }
        } else if (state is DynamicTextAreaError) {
          onComplete(valueMap);
          DialogUtils.showErrorDialog(context, state.errorMessage!);
        } else if (state is DynamicTextAreaInitial ||
            state is DynamicTextAreaLoading) {
          debugPrint(
            'Listener: Handling ${state.runtimeType} state for id: ${state.component?.id}, value: ${state.component?.config[ValueKeyEnum.value.key]}',
          );
        } else {
          onComplete(valueMap);
          DialogUtils.showErrorDialog(context, "Another Error");
        }
      },
      builder: (context, state) {
        // if (state is DynamicTextAreaLoading ||
        //     state is DynamicTextAreaInitial) {
        //   return const Center(child: Text("CC"),);
        // }
        // return _buildBody(
        //   state.styleModel!,
        //   state.inputConfig!,
        //   state.component!,
        //   state.formState!,
        //   state.errorText!,
        //   state.textController!,
        //   state.focusNode!,
        //   context,
        // );

        if (state is DynamicTextAreaSuccess) {
          return _buildBody(
            state.styleModel!,
            state.inputConfig!,
            state.component!,
            state.formState!,
            state.errorText,
            state.textController!,
            state.focusNode!,
            context,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBody(
    StyleModel styleModel,
    InputConfig inputConfig,
    DynamicFormModel component,
    ComponentStateEnum currentState,
    String? errorText,
    TextEditingController textController,
    FocusNode focusNode,
    BuildContext context,
  ) {
    // Determine state from config['current_state'] if available
    final String? stateKey = component.config['current_state']?.toString();
    final ComponentStateEnum effectiveState =
        _getComponentStateEnumFromKey(stateKey) ?? currentState;
    return Container(
      key: Key(component.id),
      padding: styleModel.paddingGeometry,
      margin: styleModel.marginGeometry,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(styleModel, inputConfig),
          _buildTextField(
            styleModel,
            inputConfig,
            component,
            effectiveState,
            errorText,
            textController,
            focusNode,
            context,
          ),
        ],
      ),
    );
  }

  // Helper to convert string to ComponentStateEnum
  ComponentStateEnum? _getComponentStateEnumFromKey(String? key) {
    switch (key) {
      case 'base':
        return ComponentStateEnum.base;
      case 'error':
        return ComponentStateEnum.error;
      case 'success':
        return ComponentStateEnum.success;
      case 'focused':
        return ComponentStateEnum.focused;
      default:
        return null;
    }
  }

  Widget _buildLabel(StyleModel styleModel, InputConfig inputConfig) {
    if (inputConfig.label == null || inputConfig.label!.isEmpty) {
      return const SizedBox.shrink();
    }
    final bool isRequired = component.config['is_required'] == true;
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 7),
      child: Row(
        children: [
          Text(
            inputConfig.label!,
            style: TextStyle(
              fontSize: styleModel.labelTextSize,
              color: styleModel.labelTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isRequired)
            const Text(
              ' *',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    StyleModel styleModel,
    InputConfig inputConfig,
    DynamicFormModel component,
    ComponentStateEnum currentState,
    String? errorText,
    TextEditingController textController,
    FocusNode focusNode,
    BuildContext context,
  ) {
    // Get state key
    final String stateKey = _componentStateEnumToKey(currentState);
    final StyleStatesModel? stateStyle = _getStateStyle(
      component.states,
      stateKey,
    );
    final String? helperText = stateStyle?.helperText ?? styleModel.helperText;
    final Color helperTextColor =
        stateStyle?.helperTextColor ??
        StyleUtils.parseColor(styleModel.helperTextColor);

    return TextField(
      controller: textController,
      focusNode: focusNode,
      enabled: inputConfig.editable && !inputConfig.disabled,
      readOnly: inputConfig.readOnly,
      onSubmitted: (value) {
        context.read<DynamicTextAreaBloc>().add(
          TextAreaFocusLostEvent(value: value),
        );
      },
      maxLines: styleModel.maxLines,
      minLines: styleModel.minLines,
      decoration: InputDecoration(
        isDense: true,
        hintText: inputConfig.placeholder ?? '',
        border: _buildBorder(styleModel, currentState),
        enabledBorder: _buildBorder(styleModel, currentState),
        focusedBorder: _buildBorder(styleModel, ComponentStateEnum.focused),
        errorBorder: _buildBorder(styleModel, ComponentStateEnum.error),
        errorText: errorText,
        contentPadding: EdgeInsets.symmetric(
          vertical: styleModel.contentVerticalPaddingValue,
          horizontal: styleModel.contentHorizontalPaddingValue,
        ),
        filled: styleModel.fillColor != Colors.transparent,
        fillColor: styleModel.fillColor,
        helperText: helperText,
        helperStyle: TextStyle(
          color: helperTextColor,
          fontSize: 12,
        ),
      ),
      style: TextStyle(
        fontSize: styleModel.fontSizeValue,
        color: styleModel.textColorValue,
      ),
    );
  }

  StyleStatesModel? _getStateStyle(StatesModel? states, String stateKey) {
    switch (stateKey) {
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

  OutlineInputBorder _buildBorder(
    StyleModel styleModel,
    ComponentStateEnum state,
  ) {
    double width = styleModel.borderWidthValue;
    Color color = styleModel.borderColorValue;

    if (state == ComponentStateEnum.focused) {
      width += 1;
      color = styleModel.focusedBorderColorValue;
    } else if (state == ComponentStateEnum.error) {
      color = styleModel.errorBorderColorValue;
      width = 2;
    }

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(styleModel.borderRadiusValue),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  String _componentStateEnumToKey(ComponentStateEnum state) {
    switch (state) {
      case ComponentStateEnum.base:
        return 'base';
      case ComponentStateEnum.error:
        return 'error';
      case ComponentStateEnum.success:
        return 'success';
      case ComponentStateEnum.focused:
        return 'focused';
      case ComponentStateEnum.enabled:
        return 'enabled';
    }
  }

  // Color? _parseColor(dynamic value) {
  //   if (value is int) return Color(value);
  //   if (value is String) {
  //     if (value.startsWith('#')) {
  //       final hex = value.replaceAll('#', '');
  //       if (hex.length == 6) {
  //         return Color(int.parse('FF$hex', radix: 16));
  //       } else if (hex.length == 8) {
  //         return Color(int.parse(hex, radix: 16));
  //       }
  //     }
  //   }
  //   return null;
  // }
}
