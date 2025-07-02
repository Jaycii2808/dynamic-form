// ignore_for_file: non_constant_identifier_names

import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/core/utils/validation_utils.dart';
import 'package:dynamic_form_bi/core/utils/component_utils.dart';

class DynamicTextField extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicTextField({super.key, required this.component});

  @override
  State<DynamicTextField> createState() => _DynamicTextFieldState();
}

class _DynamicTextFieldState extends State<DynamicTextField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(handleFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    focusNode
      ..removeListener(handleFocusChange)
      ..dispose();
    super.dispose();
  }

  void handleFocusChange() {
    if (!focusNode.hasFocus) {
      final newValue = _controller.text;
      final error = validate(newValue, widget.component);

      final updateData = ValidationUtils.createFieldUpdateData(
        value: newValue,
        errorText: error,
      );

      context.read<DynamicFormBloc>().add(
        UpdateFormFieldEvent(
          componentId: widget.component.id,
          value: updateData,
        ),
      );
      debugPrint(
        '[TextField] ${widget.component.id} value updated: $newValue, error: $error, state: ${updateData['current_state']}',
      );
    }
  }

  String? validate(String value, DynamicFormModel component) {
    final inputTypes = component.inputTypes;
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
        final component = (state.page?.components != null)
            ? state.page!.components.firstWhere(
                (c) => c.id == widget.component.id,
                orElse: () => widget.component,
              )
            : widget.component;

        final currentState = component.config['current_state'] ?? 'base';

        final style = ComponentUtils.buildComponentStyles(
          component,
          explicitState: currentState,
        );
        final value = component.config['value']?.toString() ?? '';
        final errorText = component.config['error_text'] as String?;

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
          final iconColor = StyleUtils.parseColor(style['icon_color']);
          final iconSize = (style['icon_size'] is num)
              ? (style['icon_size'] as num).toDouble()
              : 20.0;
          final iconData = mapIconNameToIconData(iconName);
          if (iconData != null) {
            prefixIcon = Icon(iconData, color: iconColor, size: iconSize);
          }
        }
        final helperText = style['helper_text']?.toString();
        final helperTextColor = StyleUtils.parseColor(
          style['helper_text_color'],
        );
        return Container(
          key: Key(component.id),
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          margin: StyleUtils.parsePadding(style['margin']),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(focusNode);
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
                        fontSize: style['label_text_size']?.toDouble() ?? 16,
                        color: StyleUtils.parseColor(style['label_color']),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                TextField(
                  controller: _controller,
                  focusNode: focusNode,
                  enabled:
                      (component.config['editable'] ?? true) &&
                      (component.config['disabled'] != true),
                  readOnly: component.config['readOnly'] == true,
                  obscureText:
                      component.inputTypes?.containsKey('password') ?? false,
                  keyboardType: getKeyboardType(component),
                  onChanged: (value) {
                    // Only update value on change, validation happens on focus lost
                    context.read<DynamicFormBloc>().add(
                      UpdateFormFieldEvent(
                        componentId: component.id,
                        value: value, // Simple string value only
                      ),
                    );
                  },
                  onSubmitted: (value) {
                    final error = validate(value, component);

                    final updateData = ValidationUtils.createFieldUpdateData(
                      value: value,
                      errorText: error,
                    );

                    context.read<DynamicFormBloc>().add(
                      UpdateFormFieldEvent(
                        componentId: component.id,
                        value: updateData,
                      ),
                    );
                  },
                  decoration: InputDecoration(
                    hintText: component.config['placeholder']?.toString(),
                    prefixIcon: prefixIcon,
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 0,
                    ),
                    hintStyle: TextStyle(
                      color: StyleUtils.parseColor(
                        style['color'],
                      ).withOpacity(0.6),
                    ),
                    border: buildBorder(style, currentState),
                    enabledBorder: buildBorder(style, currentState),
                    focusedBorder: buildBorder(style, currentState),
                    errorBorder: buildBorder(style, currentState),
                    errorText: errorText,
                    errorStyle: const TextStyle(fontSize: 12),
                    filled: style['background_color'] != null,
                    fillColor: StyleUtils.parseColor(style['background_color']),
                    helperText: helperText,
                    helperStyle: TextStyle(
                      color: helperTextColor,
                      fontStyle: style['font_style'] == 'italic'
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                    contentPadding: StyleUtils.parsePadding(style['padding']),
                  ),
                  style: TextStyle(
                    fontSize: style['font_size']?.toDouble() ?? 16,
                    color: StyleUtils.parseColor(style['color']),
                    fontStyle: style['font_style'] == 'italic'
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

  TextInputType getKeyboardType(DynamicFormModel component) {
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

  IconData? mapIconNameToIconData(String name) {
    return IconTypeEnum.fromString(name).toIconData();
  }

  OutlineInputBorder buildBorder(
    Map<String, dynamic> style,
    String currentState,
  ) {
    final borderRadius = StyleUtils.parseBorderRadius(style['border_radius']);
    final borderColor = StyleUtils.parseColor(style['border_color']);
    final borderWidth = 1.0;

    return OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: borderColor, width: borderWidth + 1),
    );
  }
}
