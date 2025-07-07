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

  // State variables for computed values
  late DynamicFormModel _currentComponent;
  String _currentState = 'base';
  Map<String, dynamic> _style = {};
  String? _errorText;
  Widget? _prefixIcon;
  String? _helperText;
  Color? _helperTextColor;

  // Flag to prevent infinite loops during state updates
  bool _isUpdatingFromState = false;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(handleFocusChange);

    // Initialize with widget component
    _currentComponent = widget.component;
    _computeStyles();
    _updateControllerFromComponent();
  }

  @override
  void dispose() {
    _controller.dispose();
    focusNode
      ..removeListener(handleFocusChange)
      ..dispose();
    super.dispose();
  }

  void _computeStyles() {
    _currentState = _currentComponent.config['current_state'] ?? 'base';

    _style = ComponentUtils.buildComponentStyles(
      _currentComponent,
      explicitState: _currentState,
    );

    _errorText = _currentComponent.config['error_text'] as String?;

    _computePrefixIcon();
    _computeHelperText();
  }

  void _updateControllerFromComponent() {
    final newValue = _currentComponent.config['value']?.toString() ?? '';

    // Only update controller if the value is different and we're not in the middle of user typing
    if (_controller.text != newValue && !focusNode.hasFocus) {
      _isUpdatingFromState = true;
      _controller.text = newValue;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
      _isUpdatingFromState = false;
    }
  }

  void _computePrefixIcon() {
    final iconName = _style.containsKey('icon') && _style['icon'] != null
        ? _style['icon'].toString()
        : (_currentComponent.config['icon'] ?? '').toString();

    if (iconName.isNotEmpty) {
      final iconColor = StyleUtils.parseColor(_style['icon_color']);
      final iconSize = (_style['icon_size'] is num)
          ? (_style['icon_size'] as num).toDouble()
          : 20.0;
      final iconData = mapIconNameToIconData(iconName);
      if (iconData != null) {
        _prefixIcon = Icon(iconData, color: iconColor, size: iconSize);
      }
    } else {
      _prefixIcon = null;
    }
  }

  void _computeHelperText() {
    _helperText = _style['helper_text']?.toString();
    _helperTextColor = StyleUtils.parseColor(_style['helper_text_color']);
  }

  void handleFocusChange() {
    if (!focusNode.hasFocus) {
      final newValue = _controller.text;
      final error = validate(newValue, _currentComponent);

      final updateData = ValidationUtils.createFieldUpdateData(
        value: newValue,
        errorText: error,
      );

      context.read<DynamicFormBloc>().add(
        UpdateFormFieldEvent(
          componentId: _currentComponent.id,
          value: updateData,
        ),
      );
      debugPrint(
        '[TextField] ${_currentComponent.id} value updated: $newValue, error: $error, state: ${updateData['current_state']}',
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
      return validation['error_message'] ?? 'Too short';
    }
    // Max length
    if (validation['max_length'] != null &&
        value.length > validation['max_length']) {
      return validation['error_message'] ?? 'Too long';
    }
    // Regex
    if (validation['regex'] != null && value.isNotEmpty) {
      final regex = RegExp(validation['regex']);
      if (!regex.hasMatch(value)) {
        return validation['error_message'] ?? 'Invalid format';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DynamicFormBloc, DynamicFormState>(
      listener: (context, state) {
        // Update component from state and recompute values only when necessary
        final updatedComponent = (state.page?.components != null)
            ? state.page!.components.firstWhere(
                (c) => c.id == widget.component.id,
                orElse: () => widget.component,
              )
            : widget.component;

        // Only update if component actually changed
        if (updatedComponent != _currentComponent ||
            updatedComponent.config['value'] !=
                _currentComponent.config['value'] ||
            updatedComponent.config['error_text'] !=
                _currentComponent.config['error_text'] ||
            updatedComponent.config['current_state'] !=
                _currentComponent.config['current_state']) {
          setState(() {
            _currentComponent = updatedComponent;
            _computeStyles();
            // Only update controller if not currently focused (user not typing)
            if (!focusNode.hasFocus) {
              _updateControllerFromComponent();
            }
          });
        }
      },
      child: BlocBuilder<DynamicFormBloc, DynamicFormState>(
        buildWhen: (previous, current) {
          // Only rebuild when something visual actually changes
          final prevComponent = previous.page?.components.firstWhere(
            (c) => c.id == widget.component.id,
            orElse: () => widget.component,
          );
          final currComponent = current.page?.components.firstWhere(
            (c) => c.id == widget.component.id,
            orElse: () => widget.component,
          );

          return prevComponent?.config['error_text'] !=
                  currComponent?.config['error_text'] ||
              prevComponent?.config['current_state'] !=
                  currComponent?.config['current_state'] ||
              prevComponent?.config['disabled'] !=
                  currComponent?.config['disabled'] ||
              prevComponent?.config['editable'] !=
                  currComponent?.config['editable'];
        },
        builder: (context, state) {
          return Container(
            key: Key(_currentComponent.id),
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            margin: StyleUtils.parsePadding(_style['margin']),
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(focusNode);
              },
              behavior: HitTestBehavior.translucent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_currentComponent.config['label'] != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 2, bottom: 7),
                      child: Text(
                        _currentComponent.config['label'],
                        style: TextStyle(
                          fontSize: _style['label_text_size']?.toDouble() ?? 16,
                          color: StyleUtils.parseColor(_style['label_color']),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  TextField(
                    controller: _controller,
                    focusNode: focusNode,
                    enabled:
                        (_currentComponent.config['editable'] ?? true) &&
                        (_currentComponent.config['disabled'] != true),
                    readOnly: _currentComponent.config['readOnly'] == true,
                    obscureText:
                        _currentComponent.inputTypes?.containsKey('password') ??
                        false,
                    keyboardType: getKeyboardType(_currentComponent),
                    onChanged: (value) {
                      // Immediately update bloc with simple value while user is typing
                      if (!_isUpdatingFromState) {
                        context.read<DynamicFormBloc>().add(
                          UpdateFormFieldEvent(
                            componentId: _currentComponent.id,
                            value: value, // Simple string value only
                          ),
                        );
                      }
                    },
                    onSubmitted: (value) {
                      final error = validate(value, _currentComponent);

                      final updateData = ValidationUtils.createFieldUpdateData(
                        value: value,
                        errorText: error,
                      );

                      context.read<DynamicFormBloc>().add(
                        UpdateFormFieldEvent(
                          componentId: _currentComponent.id,
                          value: updateData,
                        ),
                      );
                    },
                    decoration: InputDecoration(
                      hintText: _currentComponent.config['placeholder']
                          ?.toString(),
                      prefixIcon: _prefixIcon,
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 0,
                      ),
                      hintStyle: TextStyle(
                        color: StyleUtils.parseColor(
                          _style['color'],
                        ).withOpacity(0.6),
                      ),
                      border: buildBorder(_style, _currentState),
                      enabledBorder: buildBorder(_style, _currentState),
                      focusedBorder: buildBorder(_style, _currentState),
                      errorBorder: buildBorder(_style, _currentState),
                      errorText: _errorText,
                      errorStyle: const TextStyle(fontSize: 12),
                      filled: _style['background_color'] != null,
                      fillColor: StyleUtils.parseColor(
                        _style['background_color'],
                      ),
                      helperText: _helperText,
                      helperStyle: TextStyle(
                        color: _helperTextColor,
                        fontStyle: _style['font_style'] == 'italic'
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                      contentPadding: StyleUtils.parsePadding(
                        _style['padding'],
                      ),
                    ),
                    style: TextStyle(
                      fontSize: _style['font_size']?.toDouble() ?? 16,
                      color: StyleUtils.parseColor(_style['color']),
                      fontStyle: _style['font_style'] == 'italic'
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
