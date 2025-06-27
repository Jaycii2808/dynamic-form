import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
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
  final FocusNode _focusNode = FocusNode();
  String? _errorText;
  String _selectedFormat = '';

  @override
  void initState() {
    super.initState();
    final config = widget.component.config;
    _selectedFormat = _determineDefaultFormat(config);
    final value = config['value'] ?? '';
    debugPrint(
      'initState: componentId=${widget.component.id}, initialValue=$value, selectedFormat=$_selectedFormat',
    );
    if (value is String && value.isNotEmpty) {
      try {
        final normalizedValue = value.contains('YYYY')
            ? value.replaceAll('YYYY', DateTime.now().year.toString())
            : value;
        DateFormat(_selectedFormat).parseStrict(normalizedValue);
        _controller.text = normalizedValue;
        debugPrint(
          'initState: normalizedValue=$normalizedValue, controllerText=${_controller.text}',
        );
      } catch (e) {
        debugPrint('initState: Error parsing initial value: $e');
        _controller.text = '';
      }
    }
    _focusNode.addListener(_handleFocusChange);
  }

  String _determineDefaultFormat(Map<String, dynamic> config) {
    final pickerMode = config['pickerMode'] ?? 'fullDateTime';
    String format;
    switch (pickerMode) {
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
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      final newValue = _controller.text;
      debugPrint(
        'handleFocusChange: componentId=${widget.component.id}, newValue=$newValue',
      );
      if (newValue != widget.component.config['value']) {
        widget.component.config['value'] = newValue;
        context.read<DynamicFormBloc>().add(
          UpdateFormFieldEvent(
            componentId: widget.component.id,
            value: newValue,
          ),
        );
      }
      setState(() {
        _errorText = _validate(newValue);
      });
    }
  }

  Map<String, dynamic> _resolveStyles() {
    final style = Map<String, dynamic>.from(widget.component.style);
    final variantStyle =
        widget.component.variants?['single']?['style'] as Map<String, dynamic>?;
    if (variantStyle != null) style.addAll(variantStyle);
    final currentState = _determineState();
    final stateStyle =
        widget.component.states?[currentState]?['style']
            as Map<String, dynamic>?;
    if (stateStyle != null) style.addAll(stateStyle);
    return style;
  }

  String _determineState() {
    final value = _controller.text;
    if (value.isEmpty) return 'base';
    return _validate(value) != null ? 'error' : 'success';
  }

  String? _validate(String value) {
    final validationConfig = widget.component.validation;
    if (validationConfig == null) return null;

    final requiredValidation =
        validationConfig['required'] as Map<String, dynamic>?;
    if (requiredValidation?['isRequired'] == true && value.isEmpty) {
      debugPrint(
        'validate: componentId=${widget.component.id}, error=Required field empty',
      );
      return requiredValidation?['error_message'] as String? ??
          'Please select a date';
    }

    if (value.isNotEmpty) {
      try {
        String normalizedValue = value
            .replaceAll('h:', '#')
            .replaceAll('m:', '@')
            .replaceAll('s ', '\$')
            .replaceAll('h ', '#')
            .replaceAll('m ', '@');
        normalizedValue = normalizedValue.contains('YYYY')
            ? normalizedValue.replaceAll('YYYY', DateTime.now().year.toString())
            : normalizedValue;
        final parseFormat = _selectedFormat
            .replaceAll('\'h\':', '#')
            .replaceAll('\'m\':', '@')
            .replaceAll('\'s\' ', '\$')
            .replaceAll('\'h\' ', '#')
            .replaceAll('\'m\' ', '@');
        DateFormat(parseFormat).parseStrict(normalizedValue);
        debugPrint(
          'validate: componentId=${widget.component.id}, value=$value, normalizedValue=$normalizedValue, validation=success',
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

  Future<void> _pickDateTime(BuildContext context) async {
    final style = _resolveStyles();
    final config = widget.component.config;
    final pickerMode = config['pickerMode'] ?? 'fullDateTime';
    debugPrint(
      'pickDateTime: componentId=${widget.component.id}, pickerMode=$pickerMode, selectedFormat=$_selectedFormat',
    );

    DateTime? pickedDate;
    TimeOfDay? pickedTime;

    pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: StyleUtils.parseColor(style['iconColor'] ?? '#6979F8'),
            onPrimary: Colors.white,
            surface: StyleUtils.parseColor(
              style['backgroundColor'] ?? '#FFFFFF',
            ),
            onSurface: StyleUtils.parseColor(style['color'] ?? '#333333'),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: StyleUtils.parseColor(
                style['iconColor'] ?? '#6979F8',
              ),
            ),
          ),
        ),
        child: child!,
      ),
    );

    debugPrint(
      'pickDateTime: componentId=${widget.component.id}, pickedDate=$pickedDate',
    );

    if (pickerMode != 'dateOnly' && pickedDate != null && context.mounted) {
      pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: StyleUtils.parseColor(style['iconColor'] ?? '#6979F8'),
              onPrimary: Colors.white,
              surface: StyleUtils.parseColor(
                style['backgroundColor'] ?? '#FFFFFF',
              ),
              onSurface: StyleUtils.parseColor(style['color'] ?? '#333333'),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: StyleUtils.parseColor(
                  style['iconColor'] ?? '#6979F8',
                ),
              ),
            ),
          ),
          child: child!,
        ),
      );
      debugPrint(
        'pickDateTime: componentId=${widget.component.id}, pickedTime=$pickedTime',
      );
    }

    if (pickedDate != null &&
        (pickerMode == 'dateOnly' || pickedTime != null) &&
        context.mounted) {
      final dateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickerMode == 'dateOnly' ? 0 : pickedTime!.hour,
        pickerMode == 'dateOnly' || pickerMode == 'hourDate'
            ? 0
            : pickedTime!.minute,
      );
      final formattedDateTime = DateFormat(_selectedFormat).format(dateTime);
      debugPrint(
        'pickDateTime: componentId=${widget.component.id}, formattedDateTime=$formattedDateTime',
      );
      setState(() {
        _controller.text = formattedDateTime;
        _errorText = _validate(formattedDateTime);
      });
      widget.component.config['value'] = formattedDateTime;

      context.read<DynamicFormBloc>().add(
        UpdateFormFieldEvent(
          componentId: widget.component.id,
          value: formattedDateTime,
        ),
      );
    } else {
      debugPrint(
        'pickDateTime: componentId=${widget.component.id}, no valid selection',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyles();
    final config = widget.component.config;
    final isDisabled = config['disabled'] == true;

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
                  color: StyleUtils.parseColor(
                    style['labelColor'] ?? '#333333',
                  ),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            readOnly: true,
            onTapOutside: (pointer) {
              _focusNode.unfocus();
            },
            decoration: InputDecoration(
              isDense: true,
              //hintText: _selectedFormat,
              border: OutlineInputBorder(
                borderRadius: StyleUtils.parseBorderRadius(
                  style['borderRadius'],
                ),
                borderSide: BorderSide(
                  color: StyleUtils.parseColor(style['borderColor']),
                  width: style['borderWidth']?.toDouble() ?? 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: StyleUtils.parseBorderRadius(
                  style['borderRadius'],
                ),
                borderSide: BorderSide(
                  color: StyleUtils.parseColor(style['borderColor']),
                  width: style['borderWidth']?.toDouble() ?? 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: StyleUtils.parseBorderRadius(
                  style['borderRadius'],
                ),
                borderSide: BorderSide(
                  color: StyleUtils.parseColor(
                    style['focusedBorderColor'] ??
                        style['iconColor'] ??
                        '#6979F8',
                  ),
                  width: style['borderWidth']?.toDouble() ?? 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: StyleUtils.parseBorderRadius(
                  style['borderRadius'],
                ),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              errorText: _errorText,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
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
              fontStyle: style['fontStyle'] == 'italic'
                  ? FontStyle.italic
                  : FontStyle.normal,
            ),
            onTap: isDisabled ? null : () => _pickDateTime(context),
          ),
        ],
      ),
    );
  }
}
