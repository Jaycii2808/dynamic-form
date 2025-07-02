import 'package:dynamic_form_bi/core/enums/date_picker_enum.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDateRangePickerDialog extends StatefulWidget {
  final DateTimeRange? initialDateRange;
  final Function(DateTimeRange?) onConfirm;
  final Map<String, dynamic> style;

  const CustomDateRangePickerDialog({
    required this.initialDateRange,
    required this.onConfirm,
    required this.style,
  });

  @override
  State<CustomDateRangePickerDialog> createState() =>
      _CustomDateRangePickerDialogState();
}

class _CustomDateRangePickerDialogState
    extends State<CustomDateRangePickerDialog> {
  late DateTime? _startDate;
  late DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialDateRange?.start;
    _endDate = widget.initialDateRange?.end;
  }

  Future<void> _selectStartDate() async {
    final pickedDate = await _showConfiguredDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      style: widget.style,
    );

    if (pickedDate != null && mounted) {
      setState(() {
        _startDate = pickedDate;
        // If end date is before new start date, reset it
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    // End date can only be picked if start date is set
    if (_startDate == null) return;

    final pickedDate = await _showConfiguredDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: _startDate!,
      lastDate: DateTime(2100),
      style: widget.style,
    );

    if (pickedDate != null && mounted) {
      setState(() {
        _endDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor =
    StyleUtils.parseColor(widget.style['iconColor'] ?? '#6979F8');
    final surfaceColor =
    StyleUtils.parseColor(widget.style['backgroundColor'] ?? '#FFFFFF');
    final textColor =
    StyleUtils.parseColor(widget.style['color'] ?? '#333333');

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
            _buildTitle(textColor),
            const SizedBox(height: 16),
            _buildDateSelectionRow(primaryColor, textColor),
            const SizedBox(height: 16),
            _buildActionButtons(primaryColor, surfaceColor),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(Color textColor) {
    return Text(
      'Select Date Range',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  Widget _buildDateSelectionRow(Color primaryColor, Color textColor) {
    return Row(
      children: [
        Expanded(
          child: _buildDateSelectionBox(
            label: _startDate != null
                ? DateFormat(DateFormatCustomPattern.mmmDyyyy.pattern)
                .format(_startDate!)
                : 'Start Date',
            onTap: _selectStartDate,
            borderColor: primaryColor,
            textColor: textColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDateSelectionBox(
            label: _endDate != null
                ? DateFormat(DateFormatCustomPattern.mmmDyyyy.pattern)
                .format(_endDate!)
                : 'End Date',
            onTap: _startDate != null ? _selectEndDate : null,
            borderColor:
            _startDate != null ? primaryColor : primaryColor.withValues(alpha:0.3),
            textColor: textColor,
            isActive: _startDate != null,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Color primaryColor, Color surfaceColor) {
    final isConfirmEnabled = _startDate != null && _endDate != null;
    return Row(
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
          onPressed: isConfirmEnabled
              ? () {
            widget.onConfirm(
                DateTimeRange(start: _startDate!, end: _endDate!));
            Navigator.pop(context);
          }
              : null,
          isPrimary: true,
          primaryColor: primaryColor,
          surfaceColor: surfaceColor,
        ),
      ],
    );
  }

  Widget _buildDateSelectionBox({
    required String label,
    required VoidCallback? onTap,
    required Color borderColor,
    required Color textColor,
    bool isActive = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isActive ? textColor : textColor.withValues(alpha:0.5),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

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
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          disabledBackgroundColor: primaryColor.withValues(alpha:0.3),
        ),
        child: Text(text, style: const TextStyle(fontSize: 14)),
      );
    } else {
      return TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(text, style: TextStyle(fontSize: 14, color: primaryColor)),
      );
    }
  }
}
Future<DateTime?> _showConfiguredDatePicker({
  required BuildContext context,
  required DateTime? initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  required Map<String, dynamic> style,
  bool Function(DateTime)? selectableDayPredicate,
}) {
  final primaryColor = StyleUtils.parseColor(style['iconColor'] ?? '#6979F8');
  final surfaceColor =
  StyleUtils.parseColor(style['backgroundColor'] ?? '#FFFFFF');
  final onSurfaceColor = StyleUtils.parseColor(style['color'] ?? '#333333');

  return showDatePicker(
    context: context,
    initialDate: initialDate ?? DateTime.now(),
    firstDate: firstDate,
    lastDate: lastDate,
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: primaryColor,
            onPrimary: Colors.white,
            surface: surfaceColor,
            onSurface: onSurfaceColor,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: primaryColor),
          ),
        ),
        child: child!,
      );
    },
    initialEntryMode: DatePickerEntryMode.calendar,
    selectableDayPredicate: selectableDayPredicate,
  );
}