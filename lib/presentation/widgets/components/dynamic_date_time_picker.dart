import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicDateTimePicker extends StatefulWidget {
  final DynamicFormModel component;
  final Function(dynamic value) onComplete;

  const DynamicDateTimePicker({
    super.key,
    required this.component,
    required this.onComplete,
  });

  @override
  State<DynamicDateTimePicker> createState() {
    return _DynamicDateTimePickerState();
  }
}

class _DynamicDateTimePickerState extends State<DynamicDateTimePicker> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    // Initialize with value from config, if available
    final value = widget.component.config['value'] ?? '';
    if (value is String && value.isNotEmpty) {
      try {
        // Try parsing the value as HH:mm:ss dd/MM/yyyy
        final dateFormat = DateFormat('HH:mm:ss dd/MM/yyyy');
        dateFormat.parseStrict(value);
        _controller.text = value;
      } catch (e) {
        debugPrint('Error parsing initial value: $e');
        _controller.text = '';
      }
    }
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
        context.read<DynamicFormBloc>().add(UpdateFormFieldEvent(
          componentId: widget.component.id,
          value: newValue,
        ));
        widget.onComplete(newValue);
      }
      debugPrint('FocusNode changed for component ${widget.component.id}: hasFocus=${_focusNode.hasFocus}, value=${_controller.text}');
    }
    setState(() {});
  }

  Map<String, dynamic> _resolveStyles() {
    final style = Map<String, dynamic>.from(widget.component.style);
    if (widget.component.variants != null) {
      if (widget.component.config['value'] != null && widget.component.variants!.containsKey('single')) {
        final variantStyle = widget.component.variants!['single']['style'] as Map<String, dynamic>?;
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

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyles();
    final config = widget.component.config;

    return _buildBody(style, config, context);
  }

  Container _buildBody(Map<String, dynamic> style, Map<String, dynamic> config, BuildContext context) {
    return Container(
    key: Key(widget.component.id),
    padding: StyleUtils.parsePadding(style['padding']),
    margin: StyleUtils.parsePadding(style['margin'] ?? '0px 0px'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (config['label'] != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              config['label'],
              style: TextStyle(
                fontSize: style['labelTextSize']?.toDouble() ?? 16,
                color: StyleUtils.parseColor(style['labelColor'] ?? '#333333'),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: TextInputType.datetime,
          readOnly: true, // Prevent manual input to ensure format consistency
          decoration: InputDecoration(
            isDense: true,
            hintText: config['placeholder'] ?? 'HH:mm:ss dd/MM/yyyy',
            border: OutlineInputBorder(
              borderRadius: StyleUtils.parseBorderRadius(style['borderRadius']),
              borderSide: BorderSide(
                color: StyleUtils.parseColor(style['borderColor']),
                width: style['borderWidth']?.toDouble() ?? 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: StyleUtils.parseBorderRadius(style['borderRadius']),
              borderSide: BorderSide(
                color: StyleUtils.parseColor(style['borderColor']),
                width: style['borderWidth']?.toDouble() ?? 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: StyleUtils.parseBorderRadius(style['borderRadius']),
              borderSide: BorderSide(
                color: StyleUtils.parseColor(style['focusedBorderColor'] ?? style['iconColor'] ?? '#6979F8'),
                width: style['borderWidth']?.toDouble() ?? 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: StyleUtils.parseBorderRadius(style['borderRadius']),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            errorText: _errorText,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            filled: style['backgroundColor'] != null,
            fillColor: StyleUtils.parseColor(style['backgroundColor']),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                'assets/svg/SelectDate.svg',
                colorFilter: ColorFilter.mode(
                  StyleUtils.parseColor(style['iconColor'] ?? '#6979F8'),
                  BlendMode.srcIn,
                ),
                width: style['iconSize']?.toDouble() ?? 20,
                height: style['iconSize']?.toDouble() ?? 20,
              ),
            ),
          ),
          style: TextStyle(
            fontSize: style['fontSize']?.toDouble() ?? 14,
            color: StyleUtils.parseColor(style['color'] ?? '#333333'),
            fontStyle: style['fontStyle'] == 'italic' ? FontStyle.italic : FontStyle.normal,
          ),
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: StyleUtils.parseColor(style['iconColor'] ?? '#6979F8'),
                      onPrimary: Colors.white,
                      surface: StyleUtils.parseColor(style['backgroundColor'] ?? '#FFFFFF'),
                      onSurface: StyleUtils.parseColor(style['color'] ?? '#333333'),
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: StyleUtils.parseColor(style['iconColor'] ?? '#6979F8'),
                      ),
                    ),
                    dialogTheme: DialogThemeData(backgroundColor: StyleUtils.parseColor(style['backgroundColor'] ?? '#FFFFFF')),
                  ),
                  child: child!,
                );
              },
            );
            if (context.mounted && pickedDate != null) {
              final pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: StyleUtils.parseColor(style['iconColor'] ?? '#6979F8'),
                        onPrimary: Colors.white,
                        surface: StyleUtils.parseColor(style['backgroundColor'] ?? '#FFFFFF'),
                        onSurface: StyleUtils.parseColor(style['color'] ?? '#333333'),
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: StyleUtils.parseColor(style['iconColor'] ?? '#6979F8'),
                        ),
                      ),
                      dialogTheme: DialogThemeData(backgroundColor: StyleUtils.parseColor(style['backgroundColor'] ?? '#FFFFFF')),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedTime != null && context.mounted) {
                final dateTime = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );
                final formattedDateTime = DateFormat('HH:mm:ss dd/MM/yyyy').format(dateTime);
                setState(() {
                  _controller.text = formattedDateTime;
                  _errorText = validateForm(widget.component, formattedDateTime);
                });
                widget.component.config['value'] = formattedDateTime;
                widget.onComplete(formattedDateTime);
                context.read<DynamicFormBloc>().add(UpdateFormFieldEvent(
                  componentId: widget.component.id,
                  value: formattedDateTime,
                ));
              }
            }
          },
          onChanged: (value) {
            setState(() {
              _errorText = validateForm(widget.component, value);
            });
          },
        ),
      ],
    ),
  );
  }
}