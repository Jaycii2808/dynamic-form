// ignore_for_file: non_constant_identifier_names

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
  final FocusNode _focus_node = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus_node.addListener(_handle_focus_change);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus_node
      ..removeListener(_handle_focus_change)
      ..dispose();
    super.dispose();
  }

  void _handle_focus_change() {
    if (!_focus_node.hasFocus) {
      final new_value = _controller.text;
      final error = _validate(new_value, widget.component);

      // Determine new state based on validation
      String new_state = 'base';
      if (error != null) {
        new_state = 'error';
      } else if (new_value.isNotEmpty) {
        new_state = 'success';
      }

      context.read<DynamicFormBloc>().add(
        UpdateFormFieldEvent(
          componentId: widget.component.id,
          value: {
            'value': new_value,
            'error_text': error,
            'current_state': new_state,
          },
        ),
      );
      debugPrint(
        '[TextField] ${widget.component.id} value updated: $new_value, error: $error, state: $new_state',
      );
    }
  }

  String? _validate(String value, DynamicFormModel component) {
    final input_types = component.inputTypes;
    final validation =
        input_types?['text']?['validation'] as Map<String, dynamic>?;
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
        final current_state = component.config['current_state'] ?? 'base';
        Map<String, dynamic> style = Map<String, dynamic>.from(component.style);
        // Always apply variant with_icon if icon exists
        if ((component.config['icon'] != null || style['icon'] != null) &&
            component.variants != null &&
            component.variants!.containsKey('with_icon')) {
          final variant_style =
              component.variants!['with_icon']['style']
                  as Map<String, dynamic>?;
          if (variant_style != null) style.addAll(variant_style);
        }
        // Apply state style if available
        if (component.states != null &&
            component.states!.containsKey(current_state)) {
          final state_style =
              component.states![current_state]['style']
                  as Map<String, dynamic>?;
          if (state_style != null) {
            style.addAll(state_style);
          }
        }
        final value = component.config['value']?.toString() ?? '';
        final error_text = component.config['error_text'] as String?;
        // Sync controller if value changes from BLoC
        if (_controller.text != value) {
          _controller.text = value;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        }
        Widget? prefix_icon;
        final icon_name = style.containsKey('icon') && style['icon'] != null
            ? style['icon'].toString()
            : (component.config['icon'] ?? '').toString();
        if (icon_name.isNotEmpty) {
          final icon_color = StyleUtils.parseColor(style['icon_color']);
          final icon_size = (style['icon_size'] is num)
              ? (style['icon_size'] as num).toDouble()
              : 20.0;
          final icon_data = _map_icon_name_to_icon_data(icon_name);
          if (icon_data != null) {
            prefix_icon = Icon(icon_data, color: icon_color, size: icon_size);
          }
        }
        final helper_text = style['helper_text']?.toString();
        final helper_text_color = StyleUtils.parseColor(
          style['helper_text_color'],
        );
        return Container(
          key: Key(component.id),
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          margin: StyleUtils.parsePadding(style['margin']),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(_focus_node);
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
                  focusNode: _focus_node,
                  enabled:
                      (component.config['editable'] ?? true) &&
                      (component.config['disabled'] != true),
                  readOnly: component.config['readOnly'] == true,
                  obscureText:
                      component.inputTypes?.containsKey('password') ?? false,
                  keyboardType: _get_keyboard_type(component),
                  onChanged: (value) {
                    final error = _validate(value, component);

                    // Determine new state based on validation
                    String new_state = 'base';
                    if (error != null) {
                      new_state = 'error';
                    } else if (value.isNotEmpty) {
                      new_state = 'success';
                    }

                    context.read<DynamicFormBloc>().add(
                      UpdateFormFieldEvent(
                        componentId: component.id,
                        value: {
                          'value': value,
                          'error_text': error,
                          'current_state': new_state,
                        },
                      ),
                    );
                  },
                  onSubmitted: (value) {
                    final error = _validate(value, component);

                    // Determine new state based on validation
                    String new_state = 'base';
                    if (error != null) {
                      new_state = 'error';
                    } else if (value.isNotEmpty) {
                      new_state = 'success';
                    }

                    context.read<DynamicFormBloc>().add(
                      UpdateFormFieldEvent(
                        componentId: component.id,
                        value: {
                          'value': value,
                          'error_text': error,
                          'current_state': new_state,
                        },
                      ),
                    );
                  },
                  decoration: InputDecoration(
                    hintText: component.config['placeholder']?.toString(),
                    prefixIcon: prefix_icon,
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 0,
                    ),
                    hintStyle: TextStyle(
                      color: StyleUtils.parseColor(
                        style['color'],
                      ).withOpacity(0.6),
                    ),
                    border: _build_border(style, current_state),
                    enabledBorder: _build_border(style, current_state),
                    focusedBorder: _build_border(style, current_state),
                    errorBorder: _build_border(style, current_state),
                    errorText: error_text,
                    errorStyle: const TextStyle(fontSize: 12),
                    filled: style['background_color'] != null,
                    fillColor: StyleUtils.parseColor(style['background_color']),
                    helperText: helper_text,
                    helperStyle: TextStyle(
                      color: helper_text_color,
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

  TextInputType _get_keyboard_type(DynamicFormModel component) {
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

  IconData? _map_icon_name_to_icon_data(String name) {
    return IconTypeEnum.fromString(name).toIconData();
  }

  OutlineInputBorder _build_border(
    Map<String, dynamic> style,
    String current_state,
  ) {
    final border_radius = StyleUtils.parseBorderRadius(style['border_radius']);
    final border_color = StyleUtils.parseColor(style['border_color']);
    final border_width = 1.0;

    return OutlineInputBorder(
      borderRadius: border_radius,
      borderSide: BorderSide(color: border_color, width: border_width + 1),
    );
  }
}
