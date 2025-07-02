import 'package:dynamic_form_bi/core/enums/component_state_enum.dart';
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
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _textController.text = widget.component.config['value'] ?? '';
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant DynamicTextArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newValue = widget.component.config['value'] ?? '';
    if (oldWidget.component.config['value'] != newValue && !_focusNode.hasFocus) {
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
    debugPrint('📝 [${widget.component.id}] Text area blur/submit - final value: "$newValue"');

    final validationError = validateForm(widget.component, newValue);
    String newState = 'base';

    if (validationError != null) {
      newState = 'error';
    } else if (newValue.isNotEmpty) {
      newState = 'success';
    }

    context.read<DynamicFormBloc>().add(
      UpdateFormFieldEvent(
        componentId: widget.component.id,
        value: {'value': newValue, 'current_state': newState, 'error_text': validationError},
      ),
    );

    setState(() {
      _errorText = validationError;
    });
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
        final componentValue = component.config['value'] ?? '';
        final componentError = component.config['error_text'];

        _errorText = componentError;

        if (!_focusNode.hasFocus && _textController.text != componentValue) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_focusNode.hasFocus) {
              _textController.text = componentValue;
            }
          });
        }

        Map<String, dynamic> style = Map<String, dynamic>.from(component.style);
        final config = component.config;

        final hasLabel = config['label'] != null && config['label'].isNotEmpty;
        final hasPlaceholder = config['placeholder'] != null && config['placeholder'].isNotEmpty;
        final hasValue = config['value'] != null && config['value'].toString().isNotEmpty;

        debugPrint(
          '🔍 [${component.id}] value: "$componentValue", currentState: $currentState, error: ${componentError ?? "none"}, controller: "${_textController.text}"',
        );

        if (component.variants != null) {
          if (hasPlaceholder && component.variants!.containsKey('placeholders')) {
            final variantStyle =
                component.variants!['placeholders']['style'] as Map<String, dynamic>?;
            if (variantStyle != null) {
              debugPrint('🎨 [${component.id}] Applying placeholders variant: $variantStyle');
              style.addAll(variantStyle);
            }
          }

          if (hasLabel) {
            final variantStyle =
                component.variants!['with_label']?['style'] as Map<String, dynamic>?;
            if (variantStyle != null) {
              debugPrint('🎨 [${component.id}] Applying with_label variant: $variantStyle');
              style.addAll(variantStyle);
            }
          }

          if (hasLabel && hasValue) {
            final variantStyle =
                component.variants!['with_label_value']?['style'] as Map<String, dynamic>?;
            if (variantStyle != null) {
              debugPrint('🎨 [${component.id}] Applying with_label_value variant: $variantStyle');
              style.addAll(variantStyle);
            }
          }

          if (hasValue) {
            final variantStyle =
                component.variants!['with_value']?['style'] as Map<String, dynamic>?;
            if (variantStyle != null) {
              debugPrint('🎨 [${component.id}] Applying with_value variant: $variantStyle');
              style.addAll(variantStyle);
            }
          }
        }

        if (component.states != null && component.states!.containsKey(currentState)) {
          final stateStyle = component.states![currentState]['style'] as Map<String, dynamic>?;
          if (stateStyle != null) {
            debugPrint('🎨 [${component.id}] Applying $currentState state: $stateStyle');
            style.addAll(stateStyle);
          }
        }

        return _buildBody(style, config, component, currentState);
      },
    );
  }

  Widget _buildBody(
    Map<String, dynamic> style,
    Map<String, dynamic> config,
    DynamicFormModel component,
    String currentState,
  ) {
    return Container(
      key: Key(component.id),
      padding: StyleUtils.parsePadding(style['padding']),
      margin: StyleUtils.parsePadding(style['margin'] ?? '0 0 10 0'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(style, config, currentState),
          _buildTextField(style, config, component, currentState),
        ],
      ),
    );
  }

  Widget _buildLabel(Map<String, dynamic> style, Map<String, dynamic> config, String currentState) {
    if (config['label'] == null) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.only(left: 2, bottom: 7),
      child: Text(
        config['label'],
        style: TextStyle(
          fontSize: style['label_text_size']?.toDouble() ?? 16,
          color: StyleUtils.parseColor(
            currentState == 'error' && style['label_color'] != null
                ? style['label_color']
                : style['label_color'] ?? '#000000',
          ),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField(
    Map<String, dynamic> style,
    Map<String, dynamic> config,
    DynamicFormModel component,
    String currentState,
  ) {
    final double fontSize = style['font_size']?.toDouble() ?? 16;
    final Color textColor = StyleUtils.parseColor(
      currentState == 'error' && style['color'] != null
          ? style['color']
          : style['color'] ?? '#000000',
    );
    final FontStyle fontStyle = (style['font_style'] == 'italic')
        ? FontStyle.italic
        : FontStyle.normal;
    final double contentVerticalPadding = style['content_vertical_padding']?.toDouble() ?? 12;
    final double contentHorizontalPadding = style['content_horizontal_padding']?.toDouble() ?? 12;
    final Color fillColor = StyleUtils.parseColor(style['background_color']);
    final String? helperText = style['helper_text']?.toString();
    final Color helperTextColor = StyleUtils.parseColor(
      currentState == 'error' && style['helper_text_color'] != null
          ? style['helper_text_color']
          : style['helper_text_color'] ?? '#000000',
    );

    return TextField(
      controller: _textController,
      focusNode: _focusNode,

      enabled: (config['editable'] ?? true) && (config['disabled'] != true),

      readOnly: config['readOnly'] == true,
      obscureText: component.inputTypes?.containsKey('password') ?? false,
      keyboardType: _getKeyboardType(component),
      onTapOutside: (pointer) {
        _focusNode.unfocus();
      },
      maxLines: (style['max_lines'] as num?)?.toInt() ?? 10,
      minLines: (style['min_lines'] as num?)?.toInt() ?? 6,
      decoration: InputDecoration(
        isDense: true,
        hintText: config['placeholder'] ?? '',
        border: _buildBorder(style, currentState),
        enabledBorder: _buildBorder(style, 'enabled'),
        focusedBorder: _buildBorder(style, 'focused'),
        errorBorder: _buildBorder(style, 'error'),
        errorText: _errorText,
        contentPadding: EdgeInsets.symmetric(
          vertical: contentVerticalPadding,
          horizontal: contentHorizontalPadding,
        ),
        filled: style['background_color'] != null,
        fillColor: fillColor,
        helperText: helperText,
        helperStyle: TextStyle(color: helperTextColor, fontStyle: fontStyle),
      ),
      style: TextStyle(fontSize: fontSize, color: textColor, fontStyle: fontStyle),
      onChanged: (value) {
        debugPrint('⌨️ [${component.id}] Text changing: "${_textController.text}" → "$value"');
      },
      onSubmitted: (value) {
        _saveAndValidate();
      },
    );
  }

  // OutlineInputBorder _buildBorder(Map<String, dynamic> style, String state) {
  //   final borderRadiusValue = StyleUtils.parseBorderRadius(style['border_radius']);
  //   final borderColorValue = StyleUtils.parseColor(style['border_color']);
  //   final borderWidthValue = style['border_width']?.toDouble() ?? 1.0;
  //   final borderOpacityValue = style['border_opacity']?.toDouble() ?? 1.0;
  //   //
  //   // switch (ComponentStateEnum.fromString(state)) {
  //   //   case ComponentStateEnum.focused:
  //   //     return OutlineInputBorder(
  //   //       borderRadius: borderRadiusValue,
  //   //       borderSide: BorderSide(
  //   //         color: borderColorValue.withOpacity(borderOpacityValue),
  //   //         width: borderWidthValue + 1,
  //   //       ),
  //   //     );
  //   //   case ComponentStateEnum.error:
  //   //     return OutlineInputBorder(
  //   //       borderRadius: borderRadiusValue,
  //   //       borderSide: BorderSide(color: StyleUtils.parseColor('#ff4d4f'), width: 2),
  //   //     );
  //   //   default:
  //   //     return OutlineInputBorder(
  //   //       borderRadius: borderRadiusValue,
  //   //       borderSide: BorderSide(
  //   //         color: borderColorValue.withOpacity(borderOpacityValue),
  //   //         width: borderWidthValue,
  //   //       ),
  //   //     );
  //   // }
  // }
  OutlineInputBorder _buildBorder(Map<String, dynamic> style, String state) {
    final borderRadiusValue = StyleUtils.parseBorderRadius(style['border_radius']);

    final borderColorValue = StyleUtils.parseColor(style['border_color']);

    final borderWidthValue = style['border_width']?.toDouble() ?? 1.0;

    final borderOpacityValue = style['border_opacity']?.toDouble() ?? 1.0;

    switch (state) {
      case 'focused':
        return OutlineInputBorder(
          borderRadius: borderRadiusValue,

          borderSide: BorderSide(
            color: borderColorValue.withOpacity(borderOpacityValue),

            width: borderWidthValue + 1,
          ),
        );

      case 'error':
        return OutlineInputBorder(
          borderRadius: borderRadiusValue,

          borderSide: BorderSide(color: StyleUtils.parseColor('#ff4d4f'), width: 2),
        );

      default:
        return OutlineInputBorder(
          borderRadius: borderRadiusValue,

          borderSide: BorderSide(
            color: borderColorValue.withOpacity(borderOpacityValue),

            width: borderWidthValue,
          ),
        );
    }
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
