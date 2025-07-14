import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/data/models/border_config.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_area/dynamic_text_area_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_area/dynamic_text_area_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_area/dynamic_text_area_state.dart';
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
        //   state.styleConfig!,
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
            state.styleConfig!,
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
    StyleConfig styleConfig,
    InputConfig inputConfig,
    DynamicFormModel component,
    FormStateEnum currentState,
    String? errorText,
    TextEditingController textController,
    FocusNode focusNode,
    BuildContext context,
  ) {
    // Determine state from config['current_state'] if available
    final String? stateKey = component.config['current_state']?.toString();
    final FormStateEnum effectiveState =
        _formStateEnumFromKey(stateKey) ?? currentState;
    return Container(
      key: Key(component.id),
      padding: styleConfig.padding,
      margin: styleConfig.margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(styleConfig, inputConfig),
          _buildTextField(
            styleConfig,
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

  // Helper to convert string to FormStateEnum
  FormStateEnum? _formStateEnumFromKey(String? key) {
    switch (key) {
      case 'base':
        return FormStateEnum.base;
      case 'error':
        return FormStateEnum.error;
      case 'success':
        return FormStateEnum.success;
      case 'focused':
        return FormStateEnum.focused;
      default:
        return null;
    }
  }

  Widget _buildLabel(StyleConfig styleConfig, InputConfig inputConfig) {
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
              fontSize: styleConfig.labelTextSize,
              color: styleConfig.labelColor,
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
    StyleConfig styleConfig,
    InputConfig inputConfig,
    DynamicFormModel component,
    FormStateEnum currentState,
    String? errorText,
    TextEditingController textController,
    FocusNode focusNode,
    BuildContext context,
  ) {
    // Get state key
    final String stateKey = _formStateEnumToKey(currentState);
    final Map<String, dynamic>? stateStyle =
        component.states != null && component.states![stateKey] != null
        ? component.states![stateKey]['style'] as Map<String, dynamic>?
        : null;
    final String? helperText =
        stateStyle?['helper_text'] as String? ?? styleConfig.helperText;
    final Color helperTextColor =
        _parseColor(stateStyle?['helper_text_color']) ??
        styleConfig.helperTextColor;

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
      maxLines: styleConfig.maxLines,
      minLines: styleConfig.minLines,
      decoration: InputDecoration(
        isDense: true,
        hintText: inputConfig.placeholder ?? '',
        border: _buildBorder(
          styleConfig.borderConfig,
          currentState,
          component,
          context,
        ),
        enabledBorder: _buildBorder(
          styleConfig.borderConfig,
          currentState,
          component,
          context,
        ),
        focusedBorder: _buildBorder(
          styleConfig.borderConfig,
          FormStateEnum.focused,
          component,
          context,
        ),
        errorBorder: _buildBorder(
          styleConfig.borderConfig,
          FormStateEnum.error,
          component,
          context,
        ),
        errorText: errorText,
        contentPadding: EdgeInsets.symmetric(
          vertical: styleConfig.contentVerticalPadding,
          horizontal: styleConfig.contentHorizontalPadding,
        ),
        filled: styleConfig.fillColor != Colors.transparent,
        fillColor: styleConfig.fillColor,
        helperText: helperText,
        helperStyle: TextStyle(
          color: helperTextColor ?? Colors.grey,
          fontSize: 12,
        ),
      ),
      style: TextStyle(
        fontSize: styleConfig.fontSize,
        color: styleConfig.textColor,
      ),
    );
  }

  OutlineInputBorder _buildBorder(
    BorderConfig borderConfig,
    FormStateEnum? state,
    DynamicFormModel component,
    BuildContext? context,
  ) {
    double width = borderConfig.borderWidth;
    Color color = borderConfig.borderColor.withValues(
      alpha: borderConfig.borderOpacity,
    );

    // Get border color from component states if available
    if (state != null && component.states != null) {
      final stateKey = _formStateEnumToKey(state);
      final stateStyle =
          component.states![stateKey]?['style'] as Map<String, dynamic>?;
      if (stateStyle?['border_color'] != null) {
        final stateColor = _parseColor(stateStyle!['border_color']);
        if (stateColor != null) {
          color = stateColor;
          width = 2; // Use thicker border for state styles
        }
      }
    }

    // Special handling for focused state
    if (state == FormStateEnum.focused) {
      width += 1;
      // Only use theme color if no state style is defined
      final focusedStyle =
          component.states?['focused']?['style'] as Map<String, dynamic>?;
      if (focusedStyle?['border_color'] == null && context != null) {
        color = Theme.of(context).primaryColor;
      }
    }

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderConfig.borderRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  String _formStateEnumToKey(FormStateEnum state) {
    switch (state) {
      case FormStateEnum.base:
        return 'base';
      case FormStateEnum.error:
        return 'error';
      case FormStateEnum.success:
        return 'success';
      case FormStateEnum.focused:
        return 'focused';
    }
  }

  Color? _parseColor(dynamic value) {
    if (value is int) return Color(value);
    if (value is String) {
      if (value.startsWith('#')) {
        final hex = value.replaceAll('#', '');
        if (hex.length == 6) {
          return Color(int.parse('FF$hex', radix: 16));
        } else if (hex.length == 8) {
          return Color(int.parse(hex, radix: 16));
        }
      }
    }
    return null;
  }
}
