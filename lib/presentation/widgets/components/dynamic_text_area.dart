import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/data/models/border_config.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_area/dynamic_text_area_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_area/dynamic_text_area_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_area/dynamic_text_area_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicTextArea extends StatefulWidget {
  final DynamicFormModel component;
  final Function(dynamic) onComplete;

  const DynamicTextArea({
    super.key,
    required this.component,
    required this.onComplete,
  });

  @override
  State<DynamicTextArea> createState() => _DynamicTextAreaState();
}

class _DynamicTextAreaState extends State<DynamicTextArea> {
  @override
  void initState() {
    super.initState();

    context.read<DynamicTextAreaBloc>().add(const InitializeTextAreaEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DynamicTextAreaBloc, DynamicTextAreaState>(
      listenWhen: (previous, current) {
        return previous is DynamicTextAreaLoading && current is DynamicTextAreaSuccess;
      },
      listener: (context, state) {
        if (state is DynamicTextAreaSuccess) {
          final valueMap = {
            ValueKeyEnum.value.key: state.component!.config[ValueKeyEnum.value.key],
            ValueKeyEnum.currentState.key: state.component!.config[ValueKeyEnum.currentState.key],
            ValueKeyEnum.errorText.key: state.errorText,
          };
          widget.onComplete(valueMap);

          if (state.textController!.text != state.component!.config[ValueKeyEnum.value.key]) {
            state.textController!.text = state.component!.config[ValueKeyEnum.value.key] ?? '';
          }
        }
      },
      builder: (context, state) {
        if (state is DynamicTextAreaLoading || state is DynamicTextAreaInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DynamicTextAreaError) {
          return Center(
            child: Text(
              'Error: ${state.errorMessage}',
              style: const TextStyle(color: Colors.red),
            ),
          );
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
  ) {
    return TextField(
      controller: textController,
      focusNode: focusNode,
      enabled: inputConfig.editable && !inputConfig.disabled,
      readOnly: inputConfig.readOnly,
      onChanged: (value) {
        context.read<DynamicTextAreaBloc>().add(TextAreaValueChangedEvent(value: value));
      },
      maxLines: styleConfig.maxLines,
      minLines: styleConfig.minLines,
      decoration: InputDecoration(
        isDense: true,
        hintText: inputConfig.placeholder ?? '',
        border: _buildBorder(styleConfig.borderConfig, FormStateEnum.base),
        enabledBorder: _buildBorder(styleConfig.borderConfig, FormStateEnum.base),
        focusedBorder: _buildBorder(styleConfig.borderConfig, FormStateEnum.focused),
        errorBorder: _buildBorder(styleConfig.borderConfig, FormStateEnum.error),
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
  ) {
    double width = borderConfig.borderWidth;
    Color color = borderConfig.borderColor.withValues(
      alpha: borderConfig.borderOpacity,
    );
    if (state == FormStateEnum.focused) {
      width += 1;
      color = Theme.of(context).primaryColor;
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
