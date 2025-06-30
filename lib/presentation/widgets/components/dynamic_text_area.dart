// ignore_for_file: non_constant_identifier_names

import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
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
  final FocusNode _focus_node = FocusNode();
  String? _error_text;

  @override
  void initState() {
    super.initState();
    // Initialize controller with initial value from component
    _controller.text = widget.component.config['value'] ?? '';
    _focus_node.addListener(_handle_focus_change);
  }

  @override
  void didUpdateWidget(covariant DynamicTextArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller if the component's initial value changed
    final newValue = widget.component.config['value'] ?? '';
    if (oldWidget.component.config['value'] != newValue &&
        !_focus_node.hasFocus) {
      _controller.text = newValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus_node.removeListener(_handle_focus_change);
    _focus_node.dispose();
    super.dispose();
  }

  void _handle_focus_change() {
    if (!_focus_node.hasFocus) {
      _save_and_validate();
    }
  }

  void _save_and_validate() {
    // This method is called on blur - but since we now update immediately in onChanged,
    // we just need to ensure the final state is consistent
    final new_value = _controller.text;
    debugPrint(
      '📝 [${widget.component.id}] Text area blur - final value: "$new_value"',
    );
    // No need to dispatch event again since onChanged already did it
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
        final component_value = component.config['value'] ?? '';
        final component_error = component.config['error_text'];

        // Update error text from BLoC state
        _error_text = component_error;

        // Sync controller with BLoC updates (but only when not focused to avoid conflicts)
        if (!_focus_node.hasFocus && _controller.text != component_value) {
          // Use post-frame callback to avoid setState during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_focus_node.hasFocus) {
              _controller.text = component_value;
            }
          });
        }

        Map<String, dynamic> style = Map<String, dynamic>.from(component.style);

        final config = component.config;
        final has_label = config['label'] != null && config['label'].isNotEmpty;
        final has_placeholder =
            config['placeholder'] != null && config['placeholder'].isNotEmpty;
        final has_value =
            config['value'] != null && config['value'].toString().isNotEmpty;

        debugPrint(
          '🔍 [${component.id}] value: "${component_value}", current_state: $current_state, error: ${component_error ?? "none"}, controller: "${_controller.text}"',
        );

        // Apply variant styles
        if (component.variants != null) {
          if (has_placeholder &&
              component.variants!.containsKey('placeholders')) {
            final variant_style =
                component.variants!['placeholders']['style']
                    as Map<String, dynamic>?;
            if (variant_style != null) {
              debugPrint(
                '🎨 [${component.id}] Applying placeholders variant: $variant_style',
              );
              style.addAll(variant_style);
            }
          }
          if (has_label && component.variants!.containsKey('with_label')) {
            final variant_style =
                component.variants!['with_label']['style']
                    as Map<String, dynamic>?;
            if (variant_style != null) {
              debugPrint(
                '🎨 [${component.id}] Applying with_label variant: $variant_style',
              );
              style.addAll(variant_style);
            }
          }
          if (has_label &&
              has_value &&
              component.variants!.containsKey('with_label_value')) {
            final variant_style =
                component.variants!['with_label_value']['style']
                    as Map<String, dynamic>?;
            if (variant_style != null) {
              debugPrint(
                '🎨 [${component.id}] Applying with_label_value variant: $variant_style',
              );
              style.addAll(variant_style);
            }
          }
          if (has_value && component.variants!.containsKey('with_value')) {
            final variant_style =
                component.variants!['with_value']['style']
                    as Map<String, dynamic>?;
            if (variant_style != null) {
              debugPrint(
                '🎨 [${component.id}] Applying with_value variant: $variant_style',
              );
              style.addAll(variant_style);
            }
          }

          // Backward compatibility with camelCase variants
          if (has_label && component.variants!.containsKey('withLabel')) {
            final variant_style =
                component.variants!['withLabel']['style']
                    as Map<String, dynamic>?;
            if (variant_style != null) style.addAll(variant_style);
          }
          if (has_label &&
              has_value &&
              component.variants!.containsKey('withLabelValue')) {
            final variant_style =
                component.variants!['withLabelValue']['style']
                    as Map<String, dynamic>?;
            if (variant_style != null) style.addAll(variant_style);
          }
          if (has_value && component.variants!.containsKey('withValue')) {
            final variant_style =
                component.variants!['withValue']['style']
                    as Map<String, dynamic>?;
            if (variant_style != null) style.addAll(variant_style);
          }
        }

        // Apply state style if available
        if (component.states != null &&
            component.states!.containsKey(current_state)) {
          final state_style =
              component.states![current_state]['style']
                  as Map<String, dynamic>?;
          if (state_style != null) {
            debugPrint(
              '🎨 [${component.id}] Applying $current_state state: $state_style',
            );
            style.addAll(state_style);
          }
        }

        return _build_body(style, config, component, current_state);
      },
    );
  }

  Widget _build_body(
    Map<String, dynamic> style,
    Map<String, dynamic> config,
    DynamicFormModel component,
    String current_state,
  ) {
    return Container(
      key: Key(component.id),
      padding: StyleUtils.parsePadding(style['padding']),
      margin: StyleUtils.parsePadding(style['margin'] ?? '0 0 10 0'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _build_label(style, config, current_state),
          _build_text_field(style, config, component, current_state),
        ],
      ),
    );
  }

  Widget _build_label(
    Map<String, dynamic> style,
    Map<String, dynamic> config,
    String current_state,
  ) {
    if (config['label'] == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 7),
      child: Text(
        config['label'],
        style: TextStyle(
          fontSize:
              (style['label_text_size'] ?? style['labelTextSize'])
                  ?.toDouble() ??
              16,
          color: StyleUtils.parseColor(
            current_state == 'error' && style['label_color'] != null
                ? style['label_color']
                : style['label_color'] ?? style['labelColor'] ?? '#000000',
          ),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _build_text_field(
    Map<String, dynamic> style,
    Map<String, dynamic> config,
    DynamicFormModel component,
    String current_state,
  ) {
    return TextField(
      controller: _controller,
      focusNode: _focus_node,
      enabled: (config['editable'] ?? true) && (config['disabled'] != true),
      readOnly: config['readOnly'] == true,
      obscureText: component.inputTypes?.containsKey('password') ?? false,
      keyboardType: _get_keyboard_type(component),
      onTapOutside: (pointer) {
        _focus_node.unfocus();
      },
      maxLines:
          (style['max_lines'] ?? style['maxLines'] as num?)?.toInt() ?? 10,
      minLines: (style['min_lines'] ?? style['minLines'] as num?)?.toInt() ?? 6,
      decoration: InputDecoration(
        isDense: true,
        hintText: config['placeholder'] ?? '',
        border: _build_border(style, current_state),
        enabledBorder: _build_border(style, 'enabled'),
        focusedBorder: _build_border(style, 'focused'),
        errorBorder: _build_border(style, 'error'),
        errorText: _error_text,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
        filled:
            style['background_color'] != null ||
            style['backgroundColor'] != null,
        fillColor: StyleUtils.parseColor(
          style['background_color'] ?? style['backgroundColor'],
        ),
        helperText: (style['helper_text'] ?? style['helperText'])?.toString(),
        helperStyle: TextStyle(
          color: StyleUtils.parseColor(
            current_state == 'error' &&
                    (style['helper_text_color'] ?? style['helperTextColor']) !=
                        null
                ? (style['helper_text_color'] ?? style['helperTextColor'])
                : (style['helper_text_color'] ?? style['helperTextColor']) ??
                      '#000000',
          ),
          fontStyle: (style['font_style'] ?? style['fontStyle']) == 'italic'
              ? FontStyle.italic
              : FontStyle.normal,
        ),
      ),
      style: TextStyle(
        fontSize: (style['font_size'] ?? style['fontSize'])?.toDouble() ?? 16,
        color: StyleUtils.parseColor(
          current_state == 'error' && style['color'] != null
              ? style['color']
              : style['color'] ?? '#000000',
        ),
        fontStyle: (style['font_style'] ?? style['fontStyle']) == 'italic'
            ? FontStyle.italic
            : FontStyle.normal,
      ),
      onChanged: (value) {
        // Live validation and immediate update
        final validation_error = validateForm(component, value);
        String new_state = 'base';

        if (validation_error != null) {
          new_state = 'error';
        } else if (value.isNotEmpty) {
          new_state = 'success';
        }

        debugPrint(
          '⌨️ [${component.id}] Text changing: "${_controller.text}" → "$value"',
        );

        // Update BLoC immediately while typing
        context.read<DynamicFormBloc>().add(
          UpdateFormFieldEvent(
            componentId: component.id,
            value: {
              'value': value,
              'current_state': new_state,
              'error_text': validation_error,
            },
          ),
        );

        // Also update local state for immediate UI feedback
        setState(() {
          _error_text = validation_error;
        });
      },
      onSubmitted: (value) {
        _save_and_validate();
      },
    );
  }

  OutlineInputBorder _build_border(Map<String, dynamic> style, String state) {
    final border_radius = StyleUtils.parseBorderRadius(
      style['border_radius'] ?? style['borderRadius'],
    );
    final border_color = StyleUtils.parseColor(
      style['border_color'] ?? style['borderColor'],
    );
    final border_width =
        (style['border_width'] ?? style['borderWidth'])?.toDouble() ?? 1.0;
    final border_opacity =
        (style['border_opacity'] ?? style['borderOpacity'])?.toDouble() ?? 1.0;

    switch (state) {
      case 'focused':
        return OutlineInputBorder(
          borderRadius: border_radius,
          borderSide: BorderSide(
            color: border_color.withValues(alpha: border_opacity),
            width: border_width + 1,
          ),
        );
      case 'error':
        return OutlineInputBorder(
          borderRadius: border_radius,
          borderSide: BorderSide(
            color: StyleUtils.parseColor('#ff4d4f'),
            width: 2,
          ),
        );
      default:
        return OutlineInputBorder(
          borderRadius: border_radius,
          borderSide: BorderSide(
            color: border_color.withValues(alpha: border_opacity),
            width: border_width,
          ),
        );
    }
  }
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
  return TextInputType.multiline;
}
