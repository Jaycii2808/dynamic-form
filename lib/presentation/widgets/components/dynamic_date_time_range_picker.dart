import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicDateTimeRangePicker extends StatefulWidget {
  final DynamicFormModel component;
  final Function(Map<String, String>) onComplete;

  const DynamicDateTimeRangePicker({
    super.key,
    required this.component,
    required this.onComplete,
  });

  @override
  State<DynamicDateTimeRangePicker> createState() => _DynamicDateTimeRangePickerState();
}

class _DynamicDateTimeRangePickerState extends State<DynamicDateTimeRangePicker> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;
  late FocusNode _focusNode;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);

    final value = widget.component.config['value'];
    if (value is Map<String, dynamic> && value.containsKey('start') && value.containsKey('end')) {
      try {
        final startDate = DateFormat('MMM d,yyyy').parse(value['start']);
        final endDate = DateFormat('MMM d,yyyy').parse(value['end']);
        _selectedDateRange = DateTimeRange(start: startDate, end: endDate);
        _controller.text = '${value['start']} - ${value['end']}';
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
    if (_selectedDateRange == null) {
      setState(() {
        _errorText = _validate();
      });
      return;
    }

    final newValue = {
      'start': DateFormat('MMM d,yyyy').format(_selectedDateRange!.start),
      'end': DateFormat('MMM d,yyyy').format(_selectedDateRange!.end),
    };

    if (newValue['start'] != widget.component.config['value']?['start'] ||
        newValue['end'] != widget.component.config['value']?['end']) {
      widget.component.config['value'] = newValue;
      context.read<DynamicFormBloc>().add(
        UpdateFormField(componentId: widget.component.id, value: newValue),
      );
      widget.onComplete(newValue);
    }

    setState(() {
      _errorText = _validate();
    });
  }

  String? _validate() {
    final validationConfig = widget.component.validation;
    if (validationConfig == null) return null;

    final requiredValidation = validationConfig['required'] as Map<String, dynamic>?;
    if (requiredValidation?['isRequired'] == true && _selectedDateRange == null) {
      return requiredValidation?['error_message'] as String? ?? 'Please select a date range';
    }

    return null;
  }

  void _showDateRangePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildCustomDateRangePickerDialog(
        context,
        initialDateRange: _selectedDateRange,
        onConfirm: (selectedRange) {
          if (selectedRange != null) {
            setState(() {
              _selectedDateRange = selectedRange;
              _controller.text =
              '${DateFormat('MMM d,yyyy').format(selectedRange.start)} - ${DateFormat('MMM d,yyyy').format(selectedRange.end)}';
              _errorText = _validate();
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
    final Map<String, dynamic> combinedStyle = Map<String, dynamic>.from(widget.component.style);
    final config = widget.component.config;

    if (widget.component.variants?.containsKey('range') == true) {
      final variantStyle = widget.component.variants!['range']['style'] as Map<String, dynamic>?;
      if (variantStyle != null) combinedStyle.addAll(variantStyle);
    }

    String currentState = 'base';
    if (_selectedDateRange != null) {
      currentState = _errorText != null ? 'error' : 'success';
    }

    if (widget.component.states?.containsKey(currentState) == true) {
      final stateStyle = widget.component.states![currentState]['style'] as Map<String, dynamic>?;
      if (stateStyle != null) combinedStyle.addAll(stateStyle);
    }

    return Container(
      padding: StyleUtils.parsePadding(combinedStyle['padding']),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (config['label'] != null)
            _buildLabelText(
              label: config['label'],
              style: combinedStyle,
            ),
          _buildDatePickerTextField(
            context,
            controller: _controller,
            focusNode: _focusNode,
            errorText: _errorText,
            hintText: config['placeholder'] ?? 'MMM d,yyyy - MMM d,yyyy',
            style: combinedStyle,
            onTap: _showDateRangePickerDialog,
          ),
        ],
      ),
    );
  }

  // Helper function for the label text widget
  Widget _buildLabelText({
    required String label,
    required Map<String, dynamic> style,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: TextStyle(
          fontSize: style['labelTextSize']?.toDouble() ?? 16,
          color: StyleUtils.parseColor(style['labelColor'] ?? '#333333'),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Helper function for the date picker text field widget
  Widget _buildDatePickerTextField(
      BuildContext context, {
        required TextEditingController controller,
        required FocusNode focusNode,
        String? errorText,
        String? hintText,
        required Map<String, dynamic> style,
        required VoidCallback onTap,
      }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      readOnly: true,
      decoration: InputDecoration(
        isDense: true,
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
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: StyleUtils.parseColor(style['borderColor'] ?? '#CCCCCC'),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: StyleUtils.parseColor(style['borderColor'] ?? '#CCCCCC'),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: StyleUtils.parseColor(style['focusedBorderColor'] ?? style['iconColor'] ?? '#6979F8'),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        errorText: errorText,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        filled: style['backgroundColor'] != null,
        fillColor: StyleUtils.parseColor(style['backgroundColor']),
      ),
      style: TextStyle(
        fontSize: 14,
        color: StyleUtils.parseColor(style['color'] ?? '#333333'),
        fontStyle: style['fontStyle'] == 'italic' ? FontStyle.italic : FontStyle.normal,
      ),
      onTap: onTap,
    );
  }

  // Helper function for the custom date range picker dialog
  Widget _buildCustomDateRangePickerDialog(
      BuildContext context, {
        required DateTimeRange? initialDateRange,
        required Function(DateTimeRange?) onConfirm,
        required Map<String, dynamic> style,
      }) {
    DateTime? startDate = initialDateRange?.start;
    DateTime? endDate = initialDateRange?.end;

    Future<void> pickDate({
      required BuildContext context,
      required DateTime? initialDate,
      required DateTime firstDate,
      required DateTime lastDate,
      required Function(DateTime?) onDatePicked,
      required bool Function(DateTime) selectableDayPredicate,
    }) async {
      final primaryColor = StyleUtils.parseColor(style['iconColor'] ?? '#6979F8');
      final surfaceColor = StyleUtils.parseColor(style['backgroundColor'] ?? '#FFFFFF');
      final onSurfaceColor = StyleUtils.parseColor(style['color'] ?? '#333333');

      final pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate ?? DateTime.now(),
        firstDate: firstDate,
        lastDate: lastDate,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: primaryColor,
                onPrimary: Colors.deepPurple,
                surface: surfaceColor,
                onSurface: onSurfaceColor,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(foregroundColor: primaryColor),
              ),
              // dialogTheme: DialogTheme(
              //   backgroundColor: surfaceColor,
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(16),
              //   ),
              // ),
            ),
            child: child!,
          );
        },
        initialEntryMode: DatePickerEntryMode.calendar,
        selectableDayPredicate: selectableDayPredicate,
      );

      onDatePicked(pickedDate);
    }

    return StatefulBuilder(
      builder: (context, setDialogState) {
        final primaryColor = StyleUtils.parseColor(style['iconColor'] ?? '#6979F8');
        final surfaceColor = StyleUtils.parseColor(style['backgroundColor'] ?? '#FFFFFF');
        final textColor = StyleUtils.parseColor(style['color'] ?? '#333333');

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Date Range',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateSelectionBox(
                        label: startDate != null
                            ? DateFormat('MMM d,yyyy').format(startDate!)
                            : 'Start Date',
                        onTap: () {
                          pickDate(
                            context: context,
                            initialDate: startDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                            onDatePicked: (pickedDate) {
                              if (pickedDate != null) {
                                setDialogState(() {
                                  startDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
                                  if (endDate != null && endDate!.isBefore(startDate!)) {
                                    endDate = null;
                                  }
                                });
                              }
                            },
                            selectableDayPredicate: (day) => true,
                          );
                        },
                        borderColor: primaryColor,
                        textColor: textColor,
                        isActive: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateSelectionBox(
                        label: endDate != null
                            ? DateFormat('MMM d,yyyy').format(endDate!)
                            : 'End Date',
                        onTap: startDate != null
                            ? () {
                          pickDate(
                            context: context,
                            initialDate: endDate,
                            firstDate: startDate ?? DateTime.now().subtract(const Duration(days: 365 * 10)),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                            onDatePicked: (pickedDate) {
                              if (pickedDate != null) {
                                setDialogState(() {
                                  endDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
                                });
                              }
                            },
                            selectableDayPredicate: (day) => !day.isBefore(startDate ?? DateTime.now()),
                          );
                        }
                            : null,
                        borderColor: startDate != null ? primaryColor : primaryColor.withValues(alpha:0.3),
                        textColor: textColor,
                        isActive: startDate != null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildDialogButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                      isPrimary: false,
                      primaryColor: primaryColor,
                      surfaceColor: surfaceColor,
                    ),
                    const SizedBox(width: 8),
                    _buildDialogButton(
                      text: 'Confirm',
                      onPressed: startDate != null && endDate != null
                          ? () {
                        onConfirm(DateTimeRange(start: startDate!, end: endDate!));
                        Navigator.pop(context);
                      }
                          : null,
                      isPrimary: true,
                      primaryColor: primaryColor,
                      surfaceColor: surfaceColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper function for the date selection box in the dialog
  Widget _buildDateSelectionBox({
    required String label,
    required VoidCallback? onTap,
    required Color borderColor,
    required Color textColor,
    bool isActive = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isActive ? textColor : textColor.withValues(alpha:0.5),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Helper function for dialog buttons
  Widget _buildDialogButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isPrimary,
    required Color primaryColor,
    required Color surfaceColor,
  }) {
    if (isPrimary) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          disabledBackgroundColor: primaryColor.withValues(alpha: 0.3),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 14, color: surfaceColor),
        ),
      );
    } else {
      return TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: primaryColor,
          ),
        ),
      );
    }
  }
}