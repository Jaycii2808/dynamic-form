import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicTextArea extends StatefulWidget {
  final DynamicFormModel component;
  final Function(dynamic value) onComplete;

  const DynamicTextArea({super.key, required this.component, required this.onComplete});

  @override
  State<DynamicTextArea> createState() {
    return _DynamicTextArea();
  }
}

class _DynamicTextArea extends State<DynamicTextArea> {
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
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      final newValue = _controller.text;
      if (newValue != widget.component.config['value']) {
        widget.component.config['value'] = newValue;
        context.read<DynamicFormBloc>().add(
          UpdateFormField(componentId: widget.component.id, value: newValue),
        );
        widget.onComplete(newValue);
      }
      debugPrint(
        'FocusNode changed for component ${widget.component.id}: hasFocus=${_focusNode.hasFocus}, value=${_controller.text}',
      );
    }
    setState(() {});
  }

  Map<String, dynamic> _resolveStyles() {
    final style = Map<String, dynamic>.from(widget.component.style);

    if (widget.component.variants != null) {
      if (widget.component.config['placeholder'] != null &&
          widget.component.variants!.containsKey('placeholders')) {
        final variantStyle =
            widget.component.variants!['placeholders']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (widget.component.config['label'] != null &&
          widget.component.variants!.containsKey('withLabel')) {
        final variantStyle =
            widget.component.variants!['withLabel']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (widget.component.config['label'] != null &&
          widget.component.config['value'] != null &&
          widget.component.variants!.containsKey('withLabelValue')) {
        final variantStyle =
            widget.component.variants!['withLabelValue']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (widget.component.config['value'] != null &&
          widget.component.variants!.containsKey('withValue')) {
        final variantStyle =
            widget.component.variants!['withValue']['style'] as Map<String, dynamic>?;
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
    final validationError = _validate(widget.component, value);
    return validationError != null ? 'error' : 'success';
  }

  OutlineInputBorder _buildBorder(Map<String, dynamic> style, String state) {
    final borderRadius = StyleUtils.parseBorderRadius(style['borderRadius']);
    final borderColor = StyleUtils.parseColor(style['borderColor']);
    final borderWidth = style['borderWidth']?.toDouble() ?? 1.0;

    switch (state) {
      case 'focused':
        return OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: borderColor, width: borderWidth + 1),
        );
      case 'error':
        return OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: Colors.red, width: 2),
        );
      default:
        return OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: borderColor, width: borderWidth),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyles();
    final currentState = _determineState();
    final helperTextColor = StyleUtils.parseColor(style['helperTextColor']);

    return Container(
      key: Key(widget.component.id),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
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
                  color: StyleUtils.parseColor(style['labelColor']),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Stack(
            children: [
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.component.config['editable'] ?? true,
                obscureText: widget.component.inputTypes?.containsKey('password') ?? false,
                keyboardType: _getKeyboardType(widget.component),
                maxLines: (style['maxLines'] is num) ? (style['maxLines'] as num).toInt() : 10,
                minLines: (style['minLines'] is num) ? (style['minLines'] as num).toInt() : 6,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: widget.component.config['placeholder'] ?? '',
                  border: _buildBorder(style, currentState),
                  enabledBorder: _buildBorder(style, 'enabled'),
                  focusedBorder: _buildBorder(style, 'focused'),
                  errorBorder: _buildBorder(style, 'error'),
                  errorText: null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  filled: style['backgroundColor'] != null,
                  fillColor: StyleUtils.parseColor(style['backgroundColor']),
                  helperText: _errorText,
                  helperStyle: TextStyle(
                    color: helperTextColor,
                    fontStyle: style['fontStyle'] == 'italic' ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
                style: TextStyle(
                  fontSize: style['fontSize']?.toDouble() ?? 16,
                  color: StyleUtils.parseColor(style['color']),
                  fontStyle: style['fontStyle'] == 'italic' ? FontStyle.italic : FontStyle.normal,
                ),
                onChanged: (value) {
                  setState(() {
                    _errorText = _validate(widget.component, value);
                  });
                },
              ),
              if (_errorText != null)
                Positioned(
                  right: 10,
                  bottom: 0,
                  child: Text(
                    '$_errorText (Now ${_controller.text.length - 100})',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
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
  return TextInputType.text;
}

String? _validate(DynamicFormModel component, String value) {
  if ((component.config['isRequired'] ?? false) && value.trim().isEmpty) {
    return 'Trường này là bắt buộc';
  }

  if (value.trim().isEmpty) {
    return null;
  }

  final inputTypes = component.inputTypes;
  if (inputTypes != null && inputTypes.isNotEmpty) {
    String? selectedType;

    if (component.config['inputType'] != null) {
      selectedType = component.config['inputType'];
    }

    if (selectedType == null) {
      if (inputTypes.containsKey('email') && value.contains('@')) {
        selectedType = 'email';
      } else if (inputTypes.containsKey('tel') && RegExp(r'^[0-9+\-\s()]+$').hasMatch(value)) {
        selectedType = 'tel';
      } else if (inputTypes.containsKey('password')) {
        selectedType = 'password';
      } else if (inputTypes.containsKey('text')) {
        selectedType = 'text';
      }
    }

    selectedType ??= inputTypes.keys.first;

    if (inputTypes.containsKey(selectedType)) {
      final typeConfig = inputTypes[selectedType];
      final validation = typeConfig['validation'] as Map<String, dynamic>?;

      if (validation != null) {
        final minLength = validation['min_length'] ?? 0;
        final maxLength = validation['max_length'] ?? 9999;
        final regexStr = validation['regex'] ?? '';
        final errorMsg = validation['error_message'] ?? 'Invalid input';

        if (value.length < minLength || value.length > maxLength) {
          return errorMsg;
        }

        if (regexStr.isNotEmpty) {
          try {
            final regex = RegExp(regexStr);
            if (!regex.hasMatch(value)) {
              return errorMsg;
            }
          } catch (e) {
            debugPrint('Invalid regex pattern: $regexStr');
          }
        }
      }
    }
  }

  return null;
}
