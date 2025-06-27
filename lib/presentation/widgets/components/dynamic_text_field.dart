import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicTextField extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicTextField({super.key, required this.component});

  @override
  State<DynamicTextField> createState() => _DynamicTextFieldState();
}

class _DynamicTextFieldState extends State<DynamicTextField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
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
      final error = _validate(newValue);

      // Determine new state based on validation
      String newState = 'base';
      if (error != null) {
        newState = 'error';
      } else if (newValue.isNotEmpty) {
        newState = 'success';
      }

      context.read<DynamicFormBloc>().add(
        UpdateFormFieldEvent(
          componentId: widget.component.id,
          value: {
            'value': newValue,
            'errorText': error,
            'currentState': newState,
          },
        ),
      );
      debugPrint(
        '[TextField] ${widget.component.id} value updated: $newValue, error: $error, state: $newState',
      );
    }
  }

  String? _validate(String value) {
    final inputTypes = widget.component.inputTypes;
    final validation =
        inputTypes?['text']?['validation'] as Map<String, dynamic>?;
    if (validation == null) return null;
    // Min length
    if (validation['min_length'] != null &&
        value.length < validation['min_length']) {
      return validation['error_message'] ?? 'Quá ngắn';
    }
    // Max length
    if (validation['max_length'] != null &&
        value.length > validation['max_length']) {
      return validation['error_message'] ?? 'Quá dài';
    }
    // Regex
    if (validation['regex'] != null && value.isNotEmpty) {
      final regex = RegExp(validation['regex']);
      if (!regex.hasMatch(value)) {
        return validation['error_message'] ?? 'Sai định dạng';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DynamicFormBloc, DynamicFormState>(
      builder: (context, state) {
        // Get the latest component from BLoC state
        final component = (state.page?.components != null)
            ? state.page!.components.firstWhere(
                (c) => c.id == widget.component.id,
                orElse: () => widget.component,
              )
            : widget.component;
        // Get dynamic state
        final currentState = component.config['currentState'] ?? 'base';
        Map<String, dynamic> style = Map<String, dynamic>.from(component.style);
        // Always apply variant withIcon if icon exists
        if ((component.config['icon'] != null || style['icon'] != null) &&
            component.variants != null &&
            component.variants!.containsKey('withIcon')) {
          final variantStyle =
              component.variants!['withIcon']['style'] as Map<String, dynamic>?;
          if (variantStyle != null) style.addAll(variantStyle);
        }
        // Apply state style if available
        if (component.states != null &&
            component.states!.containsKey(currentState)) {
          final stateStyle =
              component.states![currentState]['style'] as Map<String, dynamic>?;
          if (stateStyle != null) style.addAll(stateStyle);
        }
        final value = component.config['value']?.toString() ?? '';
        final errorText = component.config['errorText'] as String?;
        // Sync controller if value changes from BLoC
        if (_controller.text != value) {
          _controller.text = value;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        }
        Widget? prefixIcon;
        final iconName = style.containsKey('icon') && style['icon'] != null
            ? style['icon'].toString()
            : (component.config['icon'] ?? '').toString();
        if (iconName.isNotEmpty) {
          final iconColor = StyleUtils.parseColor(style['iconColor']);
          final iconSize = (style['iconSize'] is num)
              ? (style['iconSize'] as num).toDouble()
              : 20.0;
          final iconData = _mapIconNameToIconData(iconName);
          if (iconData != null) {
            prefixIcon = Icon(iconData, color: iconColor, size: iconSize);
          }
        }
        final helperText = style['helperText']?.toString();
        final helperTextColor = StyleUtils.parseColor(style['helperTextColor']);
        return Container(
          key: Key(component.id),
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          margin: StyleUtils.parsePadding(style['margin']),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(_focusNode);
            },
            behavior: HitTestBehavior.translucent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (component.config['label'] != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 7),
                    child: Text(
                      component.config['label'],
                      style: TextStyle(
                        fontSize: style['labelTextSize']?.toDouble() ?? 16,
                        color: StyleUtils.parseColor(style['labelColor']),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled:
                      (component.config['editable'] ?? true) &&
                      (component.config['disabled'] != true),
                  readOnly: component.config['readOnly'] == true,
                  obscureText:
                      component.inputTypes?.containsKey('password') ?? false,
                  keyboardType: _getKeyboardType(component),
                  onChanged: (value) {
                    final error = _validate(value);

                    // Determine new state based on validation
                    String newState = 'base';
                    if (error != null) {
                      newState = 'error';
                    } else if (value.isNotEmpty) {
                      newState = 'success';
                    }

                    context.read<DynamicFormBloc>().add(
                      UpdateFormFieldEvent(
                        componentId: component.id,
                        value: {
                          'value': value,
                          'errorText': error,
                          'currentState': newState,
                        },
                      ),
                    );
                    debugPrint(
                      '[TextField] ${component.id} value updated: $value, error: $error, state: $newState',
                    );
                  },
                  onSubmitted: (value) {
                    final error = _validate(value);

                    // Determine new state based on validation
                    String newState = 'base';
                    if (error != null) {
                      newState = 'error';
                    } else if (value.isNotEmpty) {
                      newState = 'success';
                    }

                    context.read<DynamicFormBloc>().add(
                      UpdateFormFieldEvent(
                        componentId: component.id,
                        value: {
                          'value': value,
                          'errorText': error,
                          'currentState': newState,
                        },
                      ),
                    );
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    prefixIcon: prefixIcon,
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    hintText: component.config['placeholder'] ?? '',
                    border: _buildBorder(style, currentState),
                    enabledBorder: _buildBorder(style, 'enabled'),
                    focusedBorder: _buildBorder(style, 'focused'),
                    errorBorder: _buildBorder(style, 'error'),
                    errorText: errorText,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    filled: style['backgroundColor'] != null,
                    fillColor: StyleUtils.parseColor(style['backgroundColor']),
                    helperText: helperText,
                    helperStyle: TextStyle(
                      color: helperTextColor,
                      fontStyle: style['fontStyle'] == 'italic'
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: style['fontSize']?.toDouble() ?? 16,
                    color: StyleUtils.parseColor(style['color']),
                    fontStyle: style['fontStyle'] == 'italic'
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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

  IconData? _mapIconNameToIconData(String name) {
    return IconTypeEnum.fromString(name).toIconData();
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
}
