import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/data/models/border_config.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
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
        if (state is DynamicTextAreaLoading ||
            state is DynamicTextAreaInitial) {
          return const Center(child: CircularProgressIndicator());
        }

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
            currentState,
            errorText,
            textController,
            focusNode,
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(StyleConfig styleConfig, InputConfig inputConfig) {
    if (inputConfig.label == null || inputConfig.label!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 7),
      child: Text(
        inputConfig.label!,
        style: TextStyle(
          fontSize: styleConfig.labelTextSize,
          color: styleConfig.labelColor,
          fontWeight: FontWeight.bold,
        ),
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
          FormStateEnum.base,
          context,
        ),
        enabledBorder: _buildBorder(
          styleConfig.borderConfig,
          FormStateEnum.base,
          context,
        ),
        focusedBorder: _buildBorder(
          styleConfig.borderConfig,
          FormStateEnum.focused,
          context,
        ),
        errorBorder: _buildBorder(
          styleConfig.borderConfig,
          FormStateEnum.error,
          context,
        ),
        errorText: errorText,
        contentPadding: EdgeInsets.symmetric(
          vertical: styleConfig.contentVerticalPadding,
          horizontal: styleConfig.contentHorizontalPadding,
        ),
        filled: styleConfig.fillColor != Colors.transparent,
        fillColor: styleConfig.fillColor,
        helperText: styleConfig.helperText,
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
    BuildContext? context,
  ) {
    double width = borderConfig.borderWidth;
    Color color = borderConfig.borderColor.withValues(
      alpha: borderConfig.borderOpacity,
    );
    if (state == FormStateEnum.focused) {
      width += 1;
      color = Theme.of(context!).primaryColor;
    }
    if (state == FormStateEnum.error) {
      color = const Color(0xFFFF4D4F);
      width = 2;
    }
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderConfig.borderRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
