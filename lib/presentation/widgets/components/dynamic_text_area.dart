import 'package:dynamic_form_bi/data/models/states/states_model.dart';

import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
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
          'value': state.component?.config?.value,
          'current_state': state.component?.config?.currentState,
          'error_text': state.errorText,
        };
        if (state is DynamicTextAreaSuccess) {
          onComplete(valueMap);
          if (state.textController!.text != (state.component?.config?.value?.toString() ?? '')) {
            state.textController!.text = state.component?.config?.value?.toString() ?? '';
          }
        } else if (state is DynamicTextAreaError) {
          onComplete(valueMap);
          DialogUtils.showErrorDialog(context, state.errorMessage!);
        } else if (state is DynamicTextAreaInitial ||
            state is DynamicTextAreaLoading) {
          debugPrint(
            'Listener: Handling ${state.runtimeType} state for id: ${state.component?.id}, value: ${state.component?.config!.value}',
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
    String currentState,
    String? errorText,
    TextEditingController textController,
    FocusNode focusNode,
    BuildContext context,
  ) {
    // Determine state from config['current_state'] if available
    final String? stateKey = component.config?.currentState;
    final String effectiveState =
        _getStatesModelFromKey(stateKey) ?? currentState;
    return Container(
      key: Key(component.id),
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 12.0,
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 12.0,
      ),
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

  // Helper to convert string to StatesModel
  String? _getStatesModelFromKey(String? key) {
    switch (key) {
      case 'base':
        return 'base';
      case 'error':
        return 'error';
      case 'success':
        return 'success';
      case 'focused':
        return 'focused';
      default:
        return null;
    }
  }

  Widget _buildLabel(StyleModel styleModel, InputConfig inputConfig) {
    if (inputConfig.label == null || inputConfig.label!.isEmpty) {
      return const SizedBox.shrink();
    }
    final bool isRequired = component.config?.isRequired == true;
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 7),
      child: Row(
        children: [
          Text(
            inputConfig.label!,
            style: TextStyle(
              fontSize: styleModel.labelTextSize,
              color: styleModel.labelColor,
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
    String currentState,
    String? errorText,
    TextEditingController textController,
    FocusNode focusNode,
    BuildContext context,
  ) {
    // Get state key
    final String stateKey = currentState;
    final StyleStatesModel? stateStyle = _getStateStyle(
      component.states,
      stateKey,
    );
    final String? helperText = stateStyle?.helperText ?? styleModel.helperText;
    final Color? helperTextColor = stateStyle?.helperTextColor;

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
        focusedBorder: _buildBorder(styleModel, 'focused'),
        errorBorder: _buildBorder(styleModel, 'error'),
        errorText: errorText,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 12.0,
        ),
        // filled: styleModel.fillColor != Colors.transparent,
        // fillColor: styleModel.fillColor,
        helperText: helperText,
        helperStyle: TextStyle(
          color: helperTextColor,
          fontSize: 12,
        ),
      ),
      style: TextStyle(
        fontSize: styleModel.fontSize,
        color: stateStyle?.textColor ?? styleModel.textColor,
      ),
    );
  }

  OutlineInputBorder _buildBorder(
    StyleModel styleModel,
    String state,
  ) {
    double width = styleModel.borderWidth ?? 1.0;
    Color color = styleModel.borderColor ?? Colors.grey;

    if (state == 'focused') {
      width += 1;
      color = styleModel.focusedBorderColor ?? Colors.blue;
    } else if (state == 'error') {
      color = styleModel.errorBorderColor ?? Colors.red;
      width = 2;
    }

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(styleModel.borderRadius ?? 4.0),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  StyleStatesModel? _getStateStyle(StatesModel? states, String key) {
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

  // String _componentStateEnumToKey(String state) {
  //   switch (state) {
  //     case 'base':
  //       return 'base';
  //     case 'error':
  //       return 'error';
  //     case 'success':
  //       return 'success';
  //     case 'focused':
  //       return 'focused';
  //     case 'enabled':
  //       return 'enabled';
  //     default:
  //       return 'base';
  //   }
  // }

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
