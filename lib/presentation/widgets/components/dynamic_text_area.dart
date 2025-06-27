import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicTextArea extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicTextArea({super.key, required this.component});

  @override
  State<DynamicTextArea> createState() => _DynamicTextAreaState();
}

class _DynamicTextAreaState extends State<DynamicTextArea> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _errorText;

  late Map<String, dynamic> _resolvedStyle;
  late String _currentState;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.component.config['value'] ?? '';
    _focusNode.addListener(_handleFocusChange);
    _resolvedStyle = _resolveStyles();
    _currentState = _determineState();
  }

  @override
  void didUpdateWidget(covariant DynamicTextArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.component.config['value'] !=
            widget.component.config['value'] &&
        _controller.text != widget.component.config['value']) {
      _controller.text = widget.component.config['value'] ?? '';
    }
    _resolvedStyle = _resolveStyles();
    _currentState = _determineState();
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

  void _saveAndValidate() {
    final newValue = _controller.text;
    if (newValue != widget.component.config['value']) {
      widget.component.config['value'] = newValue;
      context.read<DynamicFormBloc>().add(
        UpdateFormFieldEvent(componentId: widget.component.id, value: newValue),
      );
    }
    setState(() {
      _errorText = validateForm(widget.component, newValue);
      _currentState = _determineState();
    });
  }

  Map<String, dynamic> _resolveStyles() {
    final style = Map<String, dynamic>.from(widget.component.style);

    if (widget.component.variants != null) {
      if (widget.component.config['placeholder'] != null &&
          widget.component.variants!.containsKey('placeholders')) {
        final variantStyle =
            widget.component.variants!['placeholders']['style']
                as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (widget.component.config['label'] != null &&
          widget.component.variants!.containsKey('withLabel')) {
        final variantStyle =
            widget.component.variants!['withLabel']['style']
                as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (widget.component.config['label'] != null &&
          widget.component.config['value'] != null &&
          widget.component.variants!.containsKey('withLabelValue')) {
        final variantStyle =
            widget.component.variants!['withLabelValue']['style']
                as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (widget.component.config['value'] != null &&
          widget.component.variants!.containsKey('withValue')) {
        final variantStyle =
            widget.component.variants!['withValue']['style']
                as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
    }

    final currentState = _determineState();
    if (widget.component.states != null &&
        widget.component.states!.containsKey(currentState)) {
      final stateStyle =
          widget.component.states![currentState]['style']
              as Map<String, dynamic>?;
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

  OutlineInputBorder _buildBorder(String state) {
    final borderRadius = StyleUtils.parseBorderRadius(
      _resolvedStyle['borderRadius'],
    );
    final borderColor = StyleUtils.parseColor(_resolvedStyle['borderColor']);
    final borderWidth = _resolvedStyle['borderWidth']?.toDouble() ?? 1.0;
    final borderOpacity = _resolvedStyle['borderOpacity']?.toDouble() ?? 1.0;

    switch (state) {
      case 'focused':
        return OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: borderColor.withValues(alpha: borderOpacity),
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
            color: borderColor.withValues(alpha: borderOpacity),
            width: borderWidth,
          ),
        );
    }
  }

  Widget _buildLabel() {
    if (widget.component.config['label'] == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 7),
      child: Text(
        widget.component.config['label'],
        style: TextStyle(
          fontSize: _resolvedStyle['labelTextSize']?.toDouble() ?? 16,
          color: StyleUtils.parseColor(
            _currentState == 'error' && _resolvedStyle['labelColor'] != null
                ? _resolvedStyle['labelColor']
                : _resolvedStyle['labelColor'] ?? '#000000',
          ),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      enabled:
          (widget.component.config['editable'] ?? true) &&
          (widget.component.config['disabled'] != true),
      readOnly: widget.component.config['readOnly'] == true,
      obscureText:
          widget.component.inputTypes?.containsKey('password') ?? false,
      keyboardType: _getKeyboardType(widget.component),
      onTapOutside: (pointer) {
        _focusNode.unfocus();
      },
      maxLines: (_resolvedStyle['maxLines'] as num?)?.toInt() ?? 10,
      minLines: (_resolvedStyle['minLines'] as num?)?.toInt() ?? 6,
      decoration: InputDecoration(
        isDense: true,
        hintText: widget.component.config['placeholder'] ?? '',
        border: _buildBorder(_currentState),
        enabledBorder: _buildBorder('enabled'),
        focusedBorder: _buildBorder('focused'),
        errorBorder: _buildBorder('error'),
        errorText: _errorText,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
        filled: _resolvedStyle['backgroundColor'] != null,
        fillColor: StyleUtils.parseColor(_resolvedStyle['backgroundColor']),
        helperText: _resolvedStyle['helperText']?.toString(),
        helperStyle: TextStyle(
          color: StyleUtils.parseColor(
            _currentState == 'error' &&
                    _resolvedStyle['helperTextColor'] != null
                ? _resolvedStyle['helperTextColor']
                : _resolvedStyle['helperTextColor'] ?? '#000000',
          ),
          fontStyle: _resolvedStyle['fontStyle'] == 'italic'
              ? FontStyle.italic
              : FontStyle.normal,
        ),
      ),
      style: TextStyle(
        fontSize: _resolvedStyle['fontSize']?.toDouble() ?? 16,
        color: StyleUtils.parseColor(
          _currentState == 'error' && _resolvedStyle['color'] != null
              ? _resolvedStyle['color']
              : _resolvedStyle['color'] ?? '#000000',
        ),
        fontStyle: _resolvedStyle['fontStyle'] == 'italic'
            ? FontStyle.italic
            : FontStyle.normal,
      ),
      onChanged: (value) {
        setState(() {
          _errorText = validateForm(widget.component, value);
          _currentState = _determineState();
        });
      },
      onSubmitted: (value) {
        _saveAndValidate();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _resolvedStyle = _resolveStyles();
    _currentState = _determineState();

    return Container(
      key: Key(widget.component.id),
      padding: StyleUtils.parsePadding(_resolvedStyle['padding']),
      margin: StyleUtils.parsePadding(_resolvedStyle['margin']),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildLabel(), _buildTextField()],
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
