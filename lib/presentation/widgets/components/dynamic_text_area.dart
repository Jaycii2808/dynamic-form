import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/core/utils/validation_utils.dart';
import 'package:dynamic_form_bi/data/models/border_config.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/core/enums/input_type_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';

String? _validateForm(DynamicFormModel component, String? value) {
  try {
    return ValidationUtils.validateForm(component, value);
  } catch (e) {
    debugPrint('Validation error for ${component.id}: $e');
    return 'Validation error occurred';
  }
}

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
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _textController.text = widget.component.config[ValueKeyEnum.value.key] ?? '';
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant DynamicTextArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newValue = widget.component.config[ValueKeyEnum.value.key] ?? '';
    if (oldWidget.component.config[ValueKeyEnum.value.key] != newValue && !_focusNode.hasFocus) {
      _textController.text = newValue;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _saveAndValidate();
    }
  }

  void _saveAndValidate() {
    final newValue = _textController.text;

    final validationError = _validateForm(widget.component, newValue);
    FormStateEnum newState = FormStateEnum.base;

    if (validationError != null) {
      newState = FormStateEnum.error;
    } else if (newValue.isNotEmpty) {
      newState = FormStateEnum.success;
    }

    final valueMap = {
      'value': newValue,
      'currentState': newState.value,
      'errorText': validationError,
    };

    setState(() {
      _errorText = validationError;
    });

    widget.onComplete(valueMap);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DynamicFormBloc, DynamicFormState>(
      builder: (context, state) {
        final component = (state.page?.components != null)
            ? state.page!.components.firstWhere(
                (c) => c.id == widget.component.id,
                orElse: () => widget.component,
              )
            : widget.component;

        final inputConfig = InputConfig.fromMap(component.config);
        final currentState =
            FormStateEnum.fromString(inputConfig.currentState) ?? FormStateEnum.base;
        final componentValue = inputConfig.value;
        final componentError = inputConfig.errorText;

        _errorText = componentError;

        if (!_focusNode.hasFocus && _textController.text != componentValue) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_focusNode.hasFocus) {
              _textController.text = componentValue;
            }
          });
        }

        final styleConfig = StyleConfig.fromMap(component.style);

        return _buildBody(styleConfig, inputConfig, component, currentState);
      },
    );
  }

  Widget _buildBody(
    StyleConfig styleConfig,
    InputConfig inputConfig,
    DynamicFormModel component,
    FormStateEnum currentState,
  ) {
    return Container(
      key: Key(component.id),
      padding: styleConfig.padding,
      margin: styleConfig.margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(styleConfig, inputConfig, currentState),
          _buildTextField(styleConfig, inputConfig, component, currentState),
        ],
      ),
    );
  }

  Widget _buildLabel(
    StyleConfig styleConfig,
    InputConfig inputConfig,
    FormStateEnum currentState,
  ) {
    if (inputConfig.label == null) {
      return const SizedBox.shrink();
    }
    return Container(
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
  ) {
    return TextField(
      controller: _textController,
      focusNode: _focusNode,
      enabled: inputConfig.editable && !inputConfig.disabled,
      readOnly: inputConfig.readOnly,
      obscureText: component.inputTypes?.containsKey('password') ?? false,
      keyboardType: _getKeyboardType(component),
      onTapOutside: (pointer) {
        _focusNode.unfocus();
      },
      maxLines: styleConfig.maxLines,
      minLines: styleConfig.minLines,
      decoration: InputDecoration(
        isDense: true,
        hintText: inputConfig.placeholder ?? '',
        border: _buildBorder(styleConfig.borderConfig, FormStateEnum.base),
        enabledBorder: _buildBorder(
          styleConfig.borderConfig,
          FormStateEnum.base,
        ),
        focusedBorder: _buildBorder(
          styleConfig.borderConfig,
          FormStateEnum.focused,
        ),
        errorBorder: _buildBorder(
          styleConfig.borderConfig,
          FormStateEnum.error,
        ),
        errorText: _errorText,
        contentPadding: EdgeInsets.symmetric(
          vertical: styleConfig.contentVerticalPadding,
          horizontal: styleConfig.contentHorizontalPadding,
        ),
        filled: styleConfig.fillColor != Colors.transparent,
        fillColor: styleConfig.fillColor,
        helperText: styleConfig.helperText,
        helperStyle: TextStyle(
          color: styleConfig.helperTextColor,
          fontStyle: styleConfig.fontStyle,
        ),
      ),
      style: TextStyle(
        fontSize: styleConfig.fontSize,
        color: styleConfig.textColor,
        fontStyle: styleConfig.fontStyle,
      ),
      onSubmitted: (value) {
        _saveAndValidate();
      },
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

  TextInputType _getKeyboardType(DynamicFormModel component) {
    if (component.inputTypes != null) {
      for (final key in component.inputTypes!.keys) {
        final inputType = InputTypeEnum.fromString(key);
        switch (inputType) {
          case InputTypeEnum.email:
            return TextInputType.emailAddress;
          case InputTypeEnum.tel:
            return TextInputType.phone;
          case InputTypeEnum.password:
            return TextInputType.visiblePassword;
          case InputTypeEnum.multiline:
            return TextInputType.multiline;
        }
      }
    }
    return TextInputType.multiline;
  }
}
