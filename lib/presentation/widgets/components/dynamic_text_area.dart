import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicTextArea extends StatefulWidget {
  final DynamicFormModel component;
  final Function(dynamic value) onComplete;

  const DynamicTextArea({super.key, required this.component, required this.onComplete});

  @override
  State<DynamicTextArea> createState() => _DynamicTextAreaState();
}

class _DynamicTextAreaState extends State<DynamicTextArea> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.component.config['value'] ?? '';
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _saveAndValidate();
    }
  }
  //Handle three cases (click outside, press Enter, click on another field).
  void _saveAndValidate() {
    final newValue = _controller.text;
    if (newValue != widget.component.config['value']) {
      widget.component.config['value'] = newValue;
      context.read<DynamicFormBloc>().add(
        UpdateFormField(componentId: widget.component.id, value: newValue),
      );
      widget.onComplete(newValue);
    }
    setState(() {
      _errorText = validateForm(widget.component, newValue);
    });
  }

  Map<String, dynamic> _resolveStyles() {
    final style = Map<String, dynamic>.from(widget.component.style);

    if (widget.component.variants != null) {
      if (widget.component.config['placeholder'] != null &&
          widget.component.variants!.containsKey('placeholders')) {
        final variantStyle = widget.component.variants!['placeholders']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (widget.component.config['label'] != null &&
          widget.component.variants!.containsKey('withLabel')) {
        final variantStyle = widget.component.variants!['withLabel']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (widget.component.config['label'] != null &&
          widget.component.config['value'] != null &&
          widget.component.variants!.containsKey('withLabelValue')) {
        final variantStyle = widget.component.variants!['withLabelValue']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (widget.component.config['value'] != null &&
          widget.component.variants!.containsKey('withValue')) {
        final variantStyle = widget.component.variants!['withValue']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
    }

    final currentState = _determineState();
    if (widget.component.states != null && widget.component.states!.containsKey(currentState)) {
      final stateStyle = widget.component.states![currentState]['style'] as Map<String, dynamic>?;
      if (stateStyle != null) style.addAll(stateStyle);
    }

    return style;
  }

  String _determineState() {
    final value = _controller.text;
    if (value.isEmpty) return 'base';
    final validationError = validateForm(widget.component, value);
    return validationError != null ? 'error' : 'success';
  }

  OutlineInputBorder _buildBorder(Map<String, dynamic> style, String state) {
    final borderRadius = StyleUtils.parseBorderRadius(style['borderRadius']);
    final borderColor = StyleUtils.parseColor(style['borderColor']);
    final borderWidth = style['borderWidth']?.toDouble() ?? 1.0;
    final borderOpacity = style['borderOpacity']?.toDouble() ?? 1.0;

    switch (state) {
      case 'focused':
        return OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: borderColor.withAlpha(borderOpacity),
            width: borderWidth + 1,
          ),
        );
      case 'error':
        return OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: StyleUtils.parseColor('#ff4d4f'),
            width: 2,
          ),
        );
      default:
        return OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: borderColor.withAlpha(borderOpacity),
            width: borderWidth,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyles();
    final currentState = _determineState();

    return Container(
      key: Key(widget.component.id),
      padding: StyleUtils.parsePadding(style['padding']),
      margin: StyleUtils.parsePadding(style['margin']),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.component.config['label'] != null)
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 7),
              child: Text(
                widget.component.config['label'],
                style: TextStyle(
                  fontSize: style['labelTextSize']?.toDouble() ?? 16,
                  color: StyleUtils.parseColor(
                    currentState == 'error' && style['labelColor'] != null
                        ? style['labelColor']
                        : style['labelColor'] ?? '#000000',
                  ),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: widget.component.config['editable'] ?? true,
            obscureText: widget.component.inputTypes?.containsKey('password') ?? false,
            keyboardType: _getKeyboardType(widget.component),
            maxLines: (style['maxLines'] as num?)?.toInt() ?? 10,
            minLines: (style['minLines'] as num?)?.toInt() ?? 6,
            decoration: InputDecoration(
              isDense: true,
              hintText: widget.component.config['placeholder'] ?? '',
              border: _buildBorder(style, currentState),
              enabledBorder: _buildBorder(style, 'enabled'),
              focusedBorder: _buildBorder(style, 'focused'),
              errorBorder: _buildBorder(style, 'error'),
              errorText: _errorText,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              filled: style['backgroundColor'] != null,
              fillColor: StyleUtils.parseColor(style['backgroundColor']),
              helperText: style['helperText']?.toString(),
              helperStyle: TextStyle(
                color: StyleUtils.parseColor(
                  currentState == 'error' && style['helperTextColor'] != null
                      ? style['helperTextColor']
                      : style['helperTextColor'] ?? '#000000',
                ),
                fontStyle: style['fontStyle'] == 'italic' ? FontStyle.italic : FontStyle.normal,
              ),
            ),
            style: TextStyle(
              fontSize: style['fontSize']?.toDouble() ?? 16,
              color: StyleUtils.parseColor(
                currentState == 'error' && style['color'] != null
                    ? style['color']
                    : style['color'] ?? '#000000',
              ),
              fontStyle: style['fontStyle'] == 'italic' ? FontStyle.italic : FontStyle.normal,
            ),
            onChanged: (value) {
              setState(() {
                _errorText = validateForm(widget.component, value);
              });
            },
            onSubmitted: (value) {
              _saveAndValidate();
            },
          ),
        ],
      ),
    );
  }
}

TextInputType _getKeyboardType(DynamicFormModel component) {
  if (component.inputTypes != null) {
    if (component.inputTypes!.containsKey('email')) {
      return TextInputType.emailAddress;
    } else if (component.inputTypes!.containsKey('tel')) {
      return TextInputType.phone;
    } else if (component.inputTypes!.containsKey('password')) {
      return TextInputType.visiblePassword;
    }
  }
  return TextInputType.multiline;
}