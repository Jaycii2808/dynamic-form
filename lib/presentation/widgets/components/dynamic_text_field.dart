// ignore_for_file: non_constant_identifier_names

import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/data/models/border_config.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_field/dynamic_text_field_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_field/dynamic_text_field_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_field/dynamic_text_field_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicTextField extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicTextField({
    super.key,
    required this.component,
  });

  @override
  State<DynamicTextField> createState() => _DynamicTextFieldState();
}

class _DynamicTextFieldState extends State<DynamicTextField> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DynamicTextFieldBloc(initialComponent: widget.component),
      child: DynamicTextFieldWidget(
        component: widget.component,
      ),
    );
  }
}

class DynamicTextFieldWidget extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicTextFieldWidget({
    super.key,
    required this.component,
  });

  @override
  State<DynamicTextFieldWidget> createState() => _DynamicTextFieldWidgetState();
}

class _DynamicTextFieldWidgetState extends State<DynamicTextFieldWidget> {
  @override
  void initState() {
    super.initState();

    context.read<DynamicTextFieldBloc>().add(const InitializeTextFieldEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DynamicFormBloc, DynamicFormState>(
      listener: (context, formState) {
        // Listen to main form state changes and update text field bloc
        if (formState.page?.components != null) {
          final updatedComponent = formState.page!.components.firstWhere(
            (c) => c.id == widget.component.id,
            orElse: () => widget.component,
          );

          // Check if component state changed from external source
          if (updatedComponent.config['current_state'] != null &&
              updatedComponent.config['current_state'] !=
                  widget.component.config['current_state']) {
            debugPrint(
              '🔄 [TextField] External state change detected: ${updatedComponent.config['current_state']}',
            );

            // Update the text field bloc with new component state
            context.read<DynamicTextFieldBloc>().add(
              UpdateTextFieldFromExternalEvent(component: updatedComponent),
            );
          }
        }
      },
      child: BlocConsumer<DynamicTextFieldBloc, DynamicTextFieldState>(
        listenWhen: (previous, current) {
          return previous is DynamicTextFieldLoading &&
              current is DynamicTextFieldSuccess;
        },
        buildWhen: (previous, current) {
          // Rebuild when state, error, or form state changes
          return previous.formState != current.formState ||
              previous.errorText != current.errorText ||
              previous.component?.config['current_state'] !=
                  current.component?.config['current_state'];
        },
        listener: (context, state) {
          if (state is DynamicTextFieldSuccess) {
            final valueMap = {
              ValueKeyEnum.value.key:
                  state.component!.config[ValueKeyEnum.value.key],
              'current_state': state.component!.config['current_state'],
              'error_text': state.errorText,
            };

            // Update the main form bloc with new value
            context.read<DynamicFormBloc>().add(
              UpdateFormFieldEvent(
                componentId: state.component!.id,
                value: valueMap,
              ),
            );

            if (state.textController!.text !=
                (state.component!.config[ValueKeyEnum.value.key]?.toString() ??
                    '')) {
              state.textController!.text =
                  state.component!.config[ValueKeyEnum.value.key]?.toString() ??
                  '';
            }
          }
        },
        builder: (context, state) {
          debugPrint(
            '🔵 [TextField] Building with state: ${state.runtimeType}, formState: ${state.formState}, errorText: ${state.errorText}',
          );

          if (state is DynamicTextFieldLoading ||
              state is DynamicTextFieldInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DynamicTextFieldError) {
            return Center(
              child: Text(
                'Error: ${state.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is DynamicTextFieldSuccess) {
            debugPrint(
              '🎯 [TextField] Success state - formState: ${state.formState}, currentState: ${state.component?.config['current_state']}',
            );
            return _buildBody(
              state.styleConfig!,
              state.inputConfig!,
              state.component!,
              state.formState!,
              state.errorText,
              state.textController!,
              state.focusNode!,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBody(
    StyleConfig styleConfig,
    InputConfig inputConfig,
    DynamicFormModel component,
    FormStateEnum currentState,
    String? errorText,
    TextEditingController textController,
    FocusNode focusNode,
  ) {
    return Container(
      key: Key(component.id),
      padding: styleConfig.padding,
      margin: styleConfig.margin,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(focusNode);
        },
        behavior: HitTestBehavior.translucent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel(styleConfig, inputConfig),
            _buildTextField(
              styleConfig,
              inputConfig,
              component,
              currentState,
              errorText,
              textController,
              focusNode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(StyleConfig styleConfig, InputConfig inputConfig) {
    if (inputConfig.label == null || inputConfig.label!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
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
    String? errorText,
    TextEditingController textController,
    FocusNode focusNode,
  ) {
    // Determine the appropriate border state based on current state and error
    FormStateEnum enabledBorderState = FormStateEnum.base;
    if (errorText != null && errorText.isNotEmpty) {
      enabledBorderState = FormStateEnum.error;
    } else if (currentState == FormStateEnum.success) {
      enabledBorderState = FormStateEnum.success;
    }

    // Get style from component states
    Map<String, dynamic>? stateStyle = _getStateStyle(
      component,
      enabledBorderState,
    );

    // Determine text color from state or fallback to styleConfig
    Color textColor = styleConfig.textColor;
    if (stateStyle?['color'] != null) {
      textColor = _parseColor(stateStyle!['color']) ?? styleConfig.textColor;
    }

    // Determine helper text and color from state
    String? helperText = styleConfig.helperText;
    Color? helperTextColor;

    if (stateStyle?['helper_text'] != null) {
      helperText = stateStyle!['helper_text'].toString();
    }

    if (stateStyle?['helper_text_color'] != null) {
      helperTextColor = _parseColor(stateStyle!['helper_text_color']);
    }

    debugPrint(
      '🎨 [TextField] State: $enabledBorderState, textColor: $textColor, helperText: $helperText',
    );

    return TextField(
      controller: textController,
      focusNode: focusNode,
      enabled: inputConfig.editable && !inputConfig.disabled,
      readOnly: inputConfig.readOnly,
      obscureText: component.inputTypes?.containsKey('password') ?? false,
      keyboardType: _getKeyboardType(component),
      onChanged: (value) {
        context.read<DynamicTextFieldBloc>().add(
          TextFieldValueChangedEvent(value: value),
        );
      },
      decoration: InputDecoration(
        isDense: true,
        hintText: inputConfig.placeholder ?? '',
        prefixIcon: _buildPrefixIcon(component),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 0,
        ),
        border: _buildBorder(
          styleConfig.borderConfig,
          enabledBorderState,
          component,
        ),
        enabledBorder: _buildBorder(
          styleConfig.borderConfig,
          enabledBorderState,
          component,
        ),
        focusedBorder: _buildBorder(
          styleConfig.borderConfig,
          FormStateEnum.focused,
          component,
        ),
        errorBorder: _buildBorder(
          styleConfig.borderConfig,
          FormStateEnum.error,
          component,
        ),
        errorText: errorText,
        contentPadding: EdgeInsets.symmetric(
          vertical: styleConfig.contentVerticalPadding,
          horizontal: styleConfig.contentHorizontalPadding,
        ),
        filled: styleConfig.fillColor != Colors.transparent,
        fillColor: styleConfig.fillColor,
        helperText: helperText,
        helperStyle: TextStyle(
          color: helperTextColor ?? Colors.grey,
          fontSize: 12,
        ),
      ),
      style: TextStyle(
        fontSize: styleConfig.fontSize,
        color: textColor,
      ),
    );
  }

  Widget? _buildPrefixIcon(DynamicFormModel component) {
    // Get icon from component style or config
    final iconName =
        component.style['icon']?.toString() ??
        component.config['icon']?.toString();

    if (iconName != null && iconName.isNotEmpty) {
      final iconColor =
          _parseColor(component.style['icon_color']) ?? Colors.grey;
      final iconSize =
          (component.style['icon_size'] as num?)?.toDouble() ?? 20.0;
      final iconData = IconTypeEnum.fromString(iconName).toIconData();
      if (iconData != null) {
        return Icon(iconData, color: iconColor, size: iconSize);
      }
    }
    return null;
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

  Map<String, dynamic>? _getStateStyle(
    DynamicFormModel component,
    FormStateEnum state,
  ) {
    if (component.states == null) return null;

    String stateKey;
    switch (state) {
      case FormStateEnum.base:
        stateKey = 'base';
        break;
      case FormStateEnum.error:
        stateKey = 'error';
        break;
      case FormStateEnum.success:
        stateKey = 'success';
        break;
      case FormStateEnum.focused:
        stateKey = 'focused';
        break;
    }

    return component.states![stateKey]?['style'] as Map<String, dynamic>?;
  }

  OutlineInputBorder _buildBorder(
    BorderConfig borderConfig,
    FormStateEnum? state,
    DynamicFormModel component,
  ) {
    double width = borderConfig.borderWidth;
    Color color = borderConfig.borderColor.withValues(
      alpha: borderConfig.borderOpacity,
    );

    // Get border color from component states if available
    if (state != null) {
      Map<String, dynamic>? stateStyle = _getStateStyle(component, state);
      if (stateStyle?['border_color'] != null) {
        Color? stateColor = _parseColor(stateStyle!['border_color']);
        if (stateColor != null) {
          color = stateColor;
          width = 2; // Use thicker border for state styles
        }
      }
    }

    // Special handling for focused state
    if (state == FormStateEnum.focused) {
      width += 1;
      // Only use theme color if no state style is defined
      Map<String, dynamic>? focusedStyle = _getStateStyle(
        component,
        FormStateEnum.focused,
      );
      if (focusedStyle?['border_color'] == null) {
        color = Theme.of(context).primaryColor;
      }
    }

    debugPrint(
      '🎨 [TextField] Border - state: $state, color: $color, width: $width',
    );

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderConfig.borderRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Color? _parseColor(dynamic value) {
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
    return null;
  }
}
