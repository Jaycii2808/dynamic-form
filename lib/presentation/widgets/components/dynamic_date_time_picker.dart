// ignore_for_file: non_constant_identifier_names

import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicDateTimePicker extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicDateTimePicker({super.key, required this.component});

  @override
  State<DynamicDateTimePicker> createState() => _DynamicDateTimePickerState();
}

class _DynamicDateTimePickerState extends State<DynamicDateTimePicker> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus_node = FocusNode();
  String? _error_text;
  String _selected_format = '';

  @override
  void initState() {
    super.initState();
    final config = widget.component.config;
    _selected_format = _determine_default_format(config);
    final value = config['value'] ?? '';
    debugPrint(
      'initState: componentId=${widget.component.id}, initialValue=$value, selectedFormat=$_selected_format',
    );
    if (value is String && value.isNotEmpty) {
      try {
        final normalized_value = value.contains('YYYY')
            ? value.replaceAll('YYYY', DateTime.now().year.toString())
            : value;
        DateFormat(_selected_format).parseStrict(normalized_value);
        _controller.text = normalized_value;
        debugPrint(
          'initState: normalizedValue=$normalized_value, controllerText=${_controller.text}',
        );
      } catch (e) {
        debugPrint('initState: Error parsing initial value: $e');
        _controller.text = '';
      }
    }
    _focus_node.addListener(_handle_focus_change);
  }

  String _determine_default_format(Map<String, dynamic> config) {
    final picker_mode =
        config['picker_mode'] ?? config['pickerMode'] ?? 'fullDateTime';
    String format;
    switch (picker_mode) {
      case 'dateOnly':
        format = 'dd/MM/yyyy';
        break;
      case 'hourDate':
        format = 'h\'h\' dd/MM/yyyy';
        break;
      case 'hourMinuteDate':
        format = 'h\'h\':mm\'m\' dd/MM/yyyy';
        break;
      default:
        format = 'h\'h\':mm\'m\':ss\'s\' dd/MM/yyyy';
    }
    return format.replaceAll('YYYY', 'yyyy');
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
      final error = _validate(new_value);

      // Determine new state based on validation
      String new_state = 'base';
      if (error != null) {
        new_state = 'error';
      } else if (new_value.isNotEmpty) {
        new_state = 'success';
      }

      debugPrint(
        'handleFocusChange: componentId=${widget.component.id}, newValue=$new_value',
      );

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
    }
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

        // Apply variant style if available
        final variant_style =
            component.variants?['single']?['style'] as Map<String, dynamic>?;
        if (variant_style != null) style.addAll(variant_style);

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

        final config = component.config;
        final is_disabled = config['disabled'] == true;
        final value = component.config['value']?.toString() ?? '';
        final error_text = component.config['error_text'] as String?;

        // Sync controller if value changes from BLoC
        if (_controller.text != value) {
          _controller.text = value;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        }

        return Container(
          key: Key(component.id),
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
                      fontSize: style['label_text_size']?.toDouble() ?? 16,
                      color: StyleUtils.parseColor(
                        style['label_color'] ?? '#333333',
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              TextField(
                controller: _controller,
                focusNode: _focus_node,
                readOnly: true,
                onTapOutside: (pointer) {
                  _focus_node.unfocus();
                },
                decoration: InputDecoration(
                  isDense: true,
                  hintText: config['placeholder']?.toString(),
                  border: _build_border(style, current_state),
                  enabledBorder: _build_border(style, current_state),
                  focusedBorder: _build_border(style, current_state),
                  errorBorder: _build_border(style, current_state),
                  errorText: error_text,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                  filled: style['background_color'] != null,
                  fillColor: StyleUtils.parseColor(style['background_color']),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      'assets/svg/SelectDate.svg',
                      colorFilter: ColorFilter.mode(
                        StyleUtils.parseColor(style['icon_color'] ?? '#6979F8'),
                        BlendMode.srcIn,
                      ),
                      width: style['icon_size']?.toDouble() ?? 20,
                      height: style['icon_size']?.toDouble() ?? 20,
                    ),
                  ),
                ),
                style: TextStyle(
                  fontSize: style['font_size']?.toDouble() ?? 14,
                  color: StyleUtils.parseColor(style['color'] ?? '#333333'),
                  fontStyle: style['font_style'] == 'italic'
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
                onTap: is_disabled
                    ? null
                    : () => _pick_date_time(context, component),
              ),
            ],
          ),
        );
      },
    );
  }

  OutlineInputBorder _build_border(
    Map<String, dynamic> style,
    String current_state,
  ) {
    final border_radius = StyleUtils.parseBorderRadius(style['border_radius']);
    final border_color = StyleUtils.parseColor(style['border_color']);
    final border_width = style['border_width']?.toDouble() ?? 1.0;

    return OutlineInputBorder(
      borderRadius: border_radius,
      borderSide: BorderSide(color: border_color, width: border_width),
    );
  }

  String? _validate(String value) {
    final validation_config = widget.component.validation;
    if (validation_config == null) return null;

    final required_validation =
        validation_config['required'] as Map<String, dynamic>?;
    if (required_validation?['is_required'] == true && value.isEmpty) {
      debugPrint(
        'validate: componentId=${widget.component.id}, error=Required field empty',
      );
      return required_validation?['error_message'] as String? ??
          'Please select a date';
    }

    if (value.isNotEmpty) {
      try {
        String normalized_value = value
            .replaceAll('h:', '#')
            .replaceAll('m:', '@')
            .replaceAll('s ', '\$')
            .replaceAll('h ', '#')
            .replaceAll('m ', '@');
        normalized_value = normalized_value.contains('YYYY')
            ? normalized_value.replaceAll(
                'YYYY',
                DateTime.now().year.toString(),
              )
            : normalized_value;
        final parse_format = _selected_format
            .replaceAll('\'h\':', '#')
            .replaceAll('\'m\':', '@')
            .replaceAll('\'s\' ', '\$')
            .replaceAll('\'h\' ', '#')
            .replaceAll('\'m\' ', '@');
        DateFormat(parse_format).parseStrict(normalized_value);
        debugPrint(
          'validate: componentId=${widget.component.id}, value=$value, normalizedValue=$normalized_value, validation=success',
        );
      } catch (e) {
        debugPrint(
          'validate: componentId=${widget.component.id}, value=$value, error=Invalid date format: $e',
        );
        return 'Invalid date format';
      }
    }
    return null;
  }

  Future<void> _pick_date_time(
    BuildContext context,
    DynamicFormModel component,
  ) async {
    final current_state = component.config['current_state'] ?? 'base';
    Map<String, dynamic> style = Map<String, dynamic>.from(component.style);

    // Apply variant style if available
    final variant_style =
        component.variants?['single']?['style'] as Map<String, dynamic>?;
    if (variant_style != null) style.addAll(variant_style);

    // Apply state style if available
    if (component.states != null &&
        component.states!.containsKey(current_state)) {
      final state_style =
          component.states![current_state]['style'] as Map<String, dynamic>?;
      if (state_style != null) {
        style.addAll(state_style);
      }
    }

    final config = component.config;
    final picker_mode =
        config['picker_mode'] ?? config['pickerMode'] ?? 'fullDateTime';
    debugPrint(
      'pickDateTime: componentId=${component.id}, pickerMode=$picker_mode, selectedFormat=$_selected_format',
    );

    DateTime? picked_date;
    TimeOfDay? picked_time;

    picked_date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: StyleUtils.parseColor(style['icon_color'] ?? '#6979F8'),
            onPrimary: Colors.white,
            surface: StyleUtils.parseColor(
              style['background_color'] ?? '#FFFFFF',
            ),
            onSurface: StyleUtils.parseColor(style['color'] ?? '#333333'),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: StyleUtils.parseColor(
                style['icon_color'] ?? '#6979F8',
              ),
            ),
          ),
        ),
        child: child!,
      ),
    );

    debugPrint(
      'pickDateTime: componentId=${component.id}, pickedDate=$picked_date',
    );

    if (picker_mode != 'dateOnly' && picked_date != null && context.mounted) {
      picked_time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: StyleUtils.parseColor(style['icon_color'] ?? '#6979F8'),
              onPrimary: Colors.white,
              surface: StyleUtils.parseColor(
                style['background_color'] ?? '#FFFFFF',
              ),
              onSurface: StyleUtils.parseColor(style['color'] ?? '#333333'),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: StyleUtils.parseColor(
                  style['icon_color'] ?? '#6979F8',
                ),
              ),
            ),
          ),
          child: child!,
        ),
      );
      debugPrint(
        'pickDateTime: componentId=${component.id}, pickedTime=$picked_time',
      );
    }

    if (picked_date != null &&
        (picker_mode == 'dateOnly' || picked_time != null) &&
        context.mounted) {
      final date_time = DateTime(
        picked_date.year,
        picked_date.month,
        picked_date.day,
        picker_mode == 'dateOnly' ? 0 : picked_time!.hour,
        picker_mode == 'dateOnly' || picker_mode == 'hourDate'
            ? 0
            : picked_time!.minute,
      );
      final formatted_date_time = DateFormat(
        _selected_format,
      ).format(date_time);
      final error = _validate(formatted_date_time);

      // Determine new state based on validation
      String new_state = 'base';
      if (error != null) {
        new_state = 'error';
      } else if (formatted_date_time.isNotEmpty) {
        new_state = 'success';
      }

      debugPrint(
        'pickDateTime: componentId=${component.id}, formattedDateTime=$formatted_date_time',
      );

      context.read<DynamicFormBloc>().add(
        UpdateFormFieldEvent(
          componentId: component.id,
          value: {
            'value': formatted_date_time,
            'error_text': error,
            'current_state': new_state,
          },
        ),
      );
    } else {
      debugPrint(
        'pickDateTime: componentId=${component.id}, no valid selection',
      );
    }
  }
}
