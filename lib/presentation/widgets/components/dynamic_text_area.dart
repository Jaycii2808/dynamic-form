import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/core/utils/validation_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
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

// Helper functions for parsing style data
Color _parseColor(dynamic value, {Color defaultColor = Colors.white}) {
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
  return defaultColor;
}

EdgeInsets _parsePadding(dynamic value) {
  if (value is String) {
    final parts = value.split(' ');
    if (parts.length == 2) {
      final horizontal = double.tryParse(parts[0].replaceAll('px', '')) ?? 0;
      final vertical = double.tryParse(parts[1].replaceAll('px', '')) ?? 0;
      return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
    } else if (parts.length == 4) {
      final top = double.tryParse(parts[0].replaceAll('px', '')) ?? 0;
      final right = double.tryParse(parts[1].replaceAll('px', '')) ?? 0;
      final bottom = double.tryParse(parts[2].replaceAll('px', '')) ?? 0;
      final left = double.tryParse(parts[3].replaceAll('px', '')) ?? 0;
      return EdgeInsets.fromLTRB(left, top, right, bottom);
    } else {
      final valueNum = double.tryParse(parts[0].replaceAll('px', '')) ?? 0;
      return EdgeInsets.all(valueNum);
    }
  }
  return EdgeInsets.zero;
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
    _textController.text =
        widget.component.config[ValueKeyEnum.value.key] ?? '';
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant DynamicTextArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newValue = widget.component.config[ValueKeyEnum.value.key] ?? '';
    if (oldWidget.component.config[ValueKeyEnum.value.key] != newValue &&
        !_focusNode.hasFocus) {
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

        final config = component.config;
        final currentState =
            FormStateEnum.fromString(config['current_state']) ??
            FormStateEnum.base;
        final componentValue = config['value']?.toString() ?? '';
        final componentError = config['error_text']?.toString();

        _errorText = componentError;

        if (!_focusNode.hasFocus && _textController.text != componentValue) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_focusNode.hasFocus) {
              _textController.text = componentValue;
            }
          });
        }

        return _buildBody(component, currentState);
      },
    );
  }

  Widget _buildBody(
    DynamicFormModel component,
    FormStateEnum currentState,
  ) {
    final style = component.style;
    return Container(
      key: Key(component.id),
      padding: _parsePadding(style['padding']),
      margin: _parsePadding(style['margin']),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(component, currentState),
          _buildTextField(component, currentState),
        ],
      ),
    );
  }

  Widget _buildLabel(
    DynamicFormModel component,
    FormStateEnum currentState,
  ) {
    final config = component.config;
    final style = component.style;
    final label = config['label']?.toString();

    if (label == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.only(left: 2, bottom: 7),
      child: Text(
        label,
        style: TextStyle(
          fontSize: (style['label_text_size'] as num?)?.toDouble() ?? 16.0,
          color: _parseColor(style['label_color']),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField(
    DynamicFormModel component,
    FormStateEnum currentState,
  ) {
    final config = component.config;
    final style = component.style;

    final isEditable =
        (config['editable'] != false) && (config['disabled'] != true);
    final isReadOnly = config['readOnly'] == true;
    final placeholder = config['placeholder']?.toString() ?? '';
    final maxLines = (style['max_lines'] as num?)?.toInt() ?? 10;
    final minLines = (style['min_lines'] as num?)?.toInt() ?? 6;
    final fontSize = (style['font_size'] as num?)?.toDouble() ?? 16.0;
    final textColor = _parseColor(style['color']);
    final fillColor = _parseColor(
      style['background_color'],
      defaultColor: Colors.transparent,
    );
    final helperText = style['helper_text']?.toString();
    final helperTextColor = _parseColor(
      style['helper_text_color'],
      defaultColor: Colors.grey,
    );
    final fontStyle = (style['font_style'] == 'italic')
        ? FontStyle.italic
        : FontStyle.normal;
    final contentVerticalPadding =
        (style['content_vertical_padding'] as num?)?.toDouble() ?? 12.0;
    final contentHorizontalPadding =
        (style['content_horizontal_padding'] as num?)?.toDouble() ?? 12.0;

    return TextField(
      controller: _textController,
      focusNode: _focusNode,
      enabled: isEditable,
      readOnly: isReadOnly,
      obscureText: component.inputTypes?.containsKey('password') ?? false,
      keyboardType: _getKeyboardType(component),
      onTapOutside: (pointer) {
        _focusNode.unfocus();
      },
      maxLines: maxLines,
      minLines: minLines,
      decoration: InputDecoration(
        isDense: true,
        hintText: placeholder,
        border: _buildBorder(style, FormStateEnum.base),
        enabledBorder: _buildBorder(style, FormStateEnum.base),
        focusedBorder: _buildBorder(style, FormStateEnum.focused),
        errorBorder: _buildBorder(style, FormStateEnum.error),
        errorText: _errorText,
        contentPadding: EdgeInsets.symmetric(
          vertical: contentVerticalPadding,
          horizontal: contentHorizontalPadding,
        ),
        filled: fillColor != Colors.transparent,
        fillColor: fillColor,
        helperText: helperText,
        helperStyle: TextStyle(
          color: helperTextColor,
          fontStyle: fontStyle,
        ),
      ),
      style: TextStyle(
        fontSize: fontSize,
        color: textColor,
        fontStyle: fontStyle,
      ),
      onSubmitted: (value) {
        _saveAndValidate();
      },
    );
  }

  OutlineInputBorder _buildBorder(
    Map<String, dynamic> style,
    FormStateEnum? state,
  ) {
    double width = (style['border_width'] as num?)?.toDouble() ?? 1.0;
    Color color = _parseColor(
      style['border_color'],
      defaultColor: const Color(0xFFCCCCCC),
    );
    final borderOpacity = (style['border_opacity'] as num?)?.toDouble() ?? 1.0;
    final borderRadius = (style['border_radius'] as num?)?.toDouble() ?? 4.0;

    color = color.withValues(alpha: borderOpacity);

    if (state == FormStateEnum.focused) {
      width += 1;
    } else if (state == FormStateEnum.error) {
      color = const Color(0xFFFF4D4F);
      width = 2;
    }

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
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
