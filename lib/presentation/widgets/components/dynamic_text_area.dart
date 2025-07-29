import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/components/input_config.dart';
import 'package:dynamic_form_bi/data/models/states/style_states_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_area/dynamic_text_area_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_area/dynamic_text_area_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_area/dynamic_text_area_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          if (state.textController!.text !=
              (state.component?.config?.value?.toString() ?? '')) {
            state.textController!.text =
                state.component?.config?.value?.toString() ?? '';
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
      StatesEnum currentState,
    String? errorText,
    TextEditingController textController,
    FocusNode focusNode,
    BuildContext context,
  ) {
    // Determine state from config['current_state'] if available
    final StatesEnum? stateKey = component.config?.currentState;
    final StatesEnum effectiveState =stateKey ?? currentState;
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
      StatesEnum currentState,
    String? errorText,
    TextEditingController textController,
    FocusNode focusNode,
    BuildContext context,
  ) {
    // Get state key
    final StatesEnum stateKey = currentState;
    final StyleStatesModel? stateStyle = ReusedWidget.getStateStyle(
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
        focusedBorder: _buildBorder(styleModel, StatesEnum.focused),
        errorBorder: _buildBorder(styleModel, StatesEnum.error),
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
      StatesEnum state,
  ) {
    double width = styleModel.borderWidth ?? 1.0;
    Color color = styleModel.borderColor ?? Colors.grey;

    if (state == StatesEnum.focused) {
      width += 1;
      color = styleModel.focusedBorderColor ?? Colors.blue;
    } else if (state == StatesEnum.error) {
      color = styleModel.errorBorderColor ?? Colors.red;
      width = 2;
    }

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(styleModel.borderRadius ?? 4.0),
      borderSide: BorderSide(color: color, width: width),
    );
  }



  // String _componentStateEnumToKey(String state) {
  //   switch (state) {
  //     case StatesEnum.base:
  //       return StatesEnum.base;
  //     case StatesEnum.error:
  //       return StatesEnum.error;
  //     case StatesEnum.success:
  //       return StatesEnum.success;
  //     case StatesEnum.focused:
  //       return StatesEnum.focused;
  //     case 'enabled':
  //       return 'enabled';
  //     default:
  //       return StatesEnum.base;
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
