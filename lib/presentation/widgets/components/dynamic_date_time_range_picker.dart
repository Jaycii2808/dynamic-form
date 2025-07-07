import 'package:dynamic_form_bi/core/enums/date_picker_enum.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/widgets/custom_date_range_picker_dialog.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class DynamicDateTimeRangePicker extends StatefulWidget {
  final DynamicFormModel component;
  final Function(Map<String, dynamic>) onComplete;

  const DynamicDateTimeRangePicker({
    super.key,
    required this.component,
    required this.onComplete,
  });

  @override
  State<DynamicDateTimeRangePicker> createState() =>
      _DynamicDateTimeRangePickerState();
}

class _DynamicDateTimeRangePickerState
    extends State<DynamicDateTimeRangePicker> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;
  late FocusNode _focusNode;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _initializeValue();
  }

  void _initializeValue() {
    final value = widget.component.config['value'];
    if (value is Map<String, dynamic> &&
        value.containsKey('start') &&
        value.containsKey('end')) {
      try {
        final startDate = DateFormat(
          DateFormatCustomPattern.mmmDyyyy.pattern,
        ).parse(value['start']);
        final endDate = DateFormat(
          DateFormatCustomPattern.mmmDyyyy.pattern,
        ).parse(value['end']);
        _selectedDateRange = DateTimeRange(start: startDate, end: endDate);
        _updateControllerText();
      } catch (e) {
        debugPrint('Error parsing initial date range: $e');
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _saveAndValidate();
    }
  }

  void _saveAndValidate() {
    final validationError = _validateDateTimeRangePicker();
    setState(() {
      _errorText = validationError;
    });

    if (_selectedDateRange == null) {
      return;
    }

    final newValue = {
      'start': DateFormat(
        DateFormatCustomPattern.mmmDyyyy.pattern,
      ).format(_selectedDateRange!.start),
      'end': DateFormat(
        DateFormatCustomPattern.mmmDyyyy.pattern,
      ).format(_selectedDateRange!.end),
    };

    widget.component.config['value'] = newValue;

    final valueMap = {
      'value': newValue,
      'currentState': _errorText == null ? 'success' : 'error',
      'errorText': _errorText,
    };
    widget.onComplete.call(valueMap);
  }

  String? _validateDateTimeRangePicker() {
    final validationConfig = widget.component.validation;
    if (validationConfig == null) return null;

    final requiredValidation =
        validationConfig['required'] as Map<String, dynamic>?;
    if (requiredValidation?['isRequired'] == true &&
        _selectedDateRange == null) {
      return requiredValidation?['error_message'] as String? ??
          'Please select a date range';
    }

    return null;
  }

  void _updateControllerText() {
    if (_selectedDateRange != null) {
      final start = DateFormat(
        DateFormatCustomPattern.mmmDyyyy.pattern,
      ).format(_selectedDateRange!.start);
      final end = DateFormat(
        DateFormatCustomPattern.mmmDyyyy.pattern,
      ).format(_selectedDateRange!.end);
      _controller.text = '$start - $end';
    }
  }

  void _showDateRangePickerDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => CustomDateRangePickerDialog(
        initialDateRange: _selectedDateRange,
        onConfirm: (selectedRange) {
          if (selectedRange != null) {
            setState(() {
              _selectedDateRange = selectedRange;
              _updateControllerText();
            });
            _saveAndValidate();
          }
        },
        style: widget.component.style,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> combinedStyle = Map<String, dynamic>.from(
      widget.component.style,
    );
    final config = widget.component.config;
    final isDisabled = config['disabled'] == true;

    if (widget.component.variants?.containsKey('range') == true) {
      final variantStyle =
          widget.component.variants!['range']['style'] as Map<String, dynamic>?;
      if (variantStyle != null) combinedStyle.addAll(variantStyle);
    }

    String currentState = 'base';
    if (_selectedDateRange != null) {
      currentState = _errorText != null ? 'error' : 'success';
    }
    if (widget.component.states?.containsKey(currentState) == true) {
      final stateStyle =
          widget.component.states![currentState]['style']
              as Map<String, dynamic>?;
      if (stateStyle != null) combinedStyle.addAll(stateStyle);
    }

    return _buildBody(combinedStyle, config, context, isDisabled);
  }

  Widget _buildBody(
    Map<String, dynamic> combinedStyle,
    Map<String, dynamic> config,
    BuildContext context,
    bool isDisabled,
  ) {
    return Container(
      key: Key(widget.component.id),
      padding: StyleUtils.parsePadding(combinedStyle['padding']),
      margin: StyleUtils.parsePadding(combinedStyle['margin']),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (config['label'] != null)
            _buildLabelText(label: config['label'], style: combinedStyle),
          _buildDatePickerTextField(
            context,
            controller: _controller,
            focusNode: _focusNode,
            errorText: _errorText,
            hintText: config['placeholder'] ?? 'MMM d,yyyy - MMM d,yyyy',
            style: combinedStyle,
            onTap: isDisabled ? () {} : _showDateRangePickerDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildLabelText({
    required String label,
    required Map<String, dynamic> style,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 7),
      child: Text(
        label,
        style: TextStyle(
          fontSize: style['label_text_size']?.toDouble() ?? 16,
          color: StyleUtils.parseColor(style['label_color'] ?? '#333333'),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDatePickerTextField(
    BuildContext context, {
    required TextEditingController controller,
    required FocusNode focusNode,
    String? errorText,
    String? hintText,
    required Map<String, dynamic> style,
    required VoidCallback onTap,
  }) {
    final borderColor = StyleUtils.parseColor(
      style['border_color'] ?? '#CCCCCC',
    );
    final focusedBorderColor = StyleUtils.parseColor(
      style['focused_border_color'] ?? style['icon_color'] ?? '#6979F8',
    );
    final errorBorderColor = Colors.red;
    final borderRadius = (style['border_radius'] is num)
        ? (style['border_radius'] as num).toDouble()
        : 8.0;
    final borderWidth = (style['border_width'] is num)
        ? (style['border_width'] as num).toDouble()
        : 1.0;
    final textColor = StyleUtils.parseColor(style['color'] ?? '#333333');
    final fillColor = StyleUtils.parseColor(
      style['background_color'] ?? '#FFFFFF',
    );
    final iconColor = StyleUtils.parseColor(
      style['icon_color'] ?? style['color'] ?? '#6979F8',
    );
    final iconSize = (style['icon_size'] is num)
        ? (style['icon_size'] as num).toDouble()
        : 20.0;
    final fontSize = (style['font_size'] is num)
        ? (style['font_size'] as num).toDouble()
        : 14.0;
    final contentVerticalPadding = (style['content_vertical_padding'] is num)
        ? (style['content_vertical_padding'] as num).toDouble()
        : 16.0;
    final contentHorizontalPadding =
        (style['content_horizontal_padding'] is num)
        ? (style['content_horizontal_padding'] as num).toDouble()
        : 16.0;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      onTapOutside: (_) => _focusNode.unfocus(),
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        isDense: true,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            'assets/svg/SelectDate.svg',
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            width: iconSize,
            height: iconSize,
          ),
        ),
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor, width: borderWidth),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor, width: borderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: focusedBorderColor,
            width: borderWidth + 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: errorBorderColor, width: borderWidth),
        ),
        errorText: errorText,
        contentPadding: EdgeInsets.symmetric(
          vertical: contentVerticalPadding,
          horizontal: contentHorizontalPadding,
        ),
        filled: style['background_color'] != null,
        fillColor: fillColor,
      ),
      style: TextStyle(
        fontSize: fontSize,
        color: textColor,
        fontStyle: style['font_style'] == 'italic'
            ? FontStyle.italic
            : FontStyle.normal,
      ),
    );
  }
}
