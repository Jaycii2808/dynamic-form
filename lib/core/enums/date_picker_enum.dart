// ignore_for_file: non_constant_identifier_names

/// Date picker types - const enum to avoid memory allocation in build methods
enum DatePickerType {
  dateOnly('date_only'),
  timeOnly('time_only'),
  dateTime('date_time'),
  dateTimeRange('date_time_range');

  const DatePickerType(this.value);
  final String value;

  /// Get DatePickerType from string value with null safety
  static DatePickerType? fromString(String? value) {
    if (value == null) return null;

    switch (value.toLowerCase()) {
      case 'date_only':
      case 'dateonly':
      case 'date':
        return DatePickerType.dateOnly;
      case 'time_only':
      case 'time':
        return DatePickerType.timeOnly;
      case 'date_time':
      case 'datetime':
      case 'date_time_picker':
        return DatePickerType.dateTime;
      case 'date_time_range':
      case 'datetimerange':
      case 'range':
        return DatePickerType.dateTimeRange;
      default:
        return null;
    }
  }

  /// Get display name
  String get displayName {
    switch (this) {
      case DatePickerType.dateOnly:
        return 'Date Only';
      case DatePickerType.timeOnly:
        return 'Time Only';
      case DatePickerType.dateTime:
        return 'Date & Time';
      case DatePickerType.dateTimeRange:
        return 'Date Range';
    }
  }

  /// Check if this type supports time selection
  bool get hasTime {
    switch (this) {
      case DatePickerType.dateOnly:
        return false;
      case DatePickerType.timeOnly:
      case DatePickerType.dateTime:
      case DatePickerType.dateTimeRange:
        return true;
    }
  }

  /// Check if this type supports date selection
  bool get hasDate {
    switch (this) {
      case DatePickerType.timeOnly:
        return false;
      case DatePickerType.dateOnly:
      case DatePickerType.dateTime:
      case DatePickerType.dateTimeRange:
        return true;
    }
  }

  /// Check if this type supports range selection
  bool get isRange {
    return this == DatePickerType.dateTimeRange;
  }
}

/// Date format patterns - const enum for performance
enum DateFormatPattern {
  dateOnly('dd/MM/yyyy'),
  timeOnly('HH:mm'),
  dateTime24('dd/MM/yyyy HH:mm'),
  dateTime12('dd/MM/yyyy hh:mm a'),
  iso8601('yyyy-MM-ddTHH:mm:ss');

  const DateFormatPattern(this.pattern);
  final String pattern;

  /// Get pattern for DatePickerType
  static DateFormatPattern getForType(
    DatePickerType type, {
    bool use24Hour = true,
  }) {
    switch (type) {
      case DatePickerType.dateOnly:
        return DateFormatPattern.dateOnly;
      case DatePickerType.timeOnly:
        return DateFormatPattern.timeOnly;
      case DatePickerType.dateTime:
        return use24Hour
            ? DateFormatPattern.dateTime24
            : DateFormatPattern.dateTime12;
      case DatePickerType.dateTimeRange:
        return use24Hour
            ? DateFormatPattern.dateTime24
            : DateFormatPattern.dateTime12;
    }
  }
}

/// Validation rules for date picker - const enum
enum DateValidationRule {
  required('required'),
  minDate('min_date'),
  maxDate('max_date'),
  dateRange('date_range');

  const DateValidationRule(this.value);
  final String value;

  static DateValidationRule? fromString(String? value) {
    if (value == null) return null;

    for (final rule in DateValidationRule.values) {
      if (rule.value == value) return rule;
    }
    return null;
  }
}

/// Picker mode for dynamic date/time picker
/// Provides mapping to format string and parsing from string
enum PickerModeEnum {
  dateOnly('dateOnly', 'dd/MM/yyyy'),
  hourDate('hourDate', "h'h' dd/MM/yyyy"),
  hourMinuteDate('hourMinuteDate', "h'h':mm'm' dd/MM/yyyy"),
  fullDateTime('fullDateTime', "h'h':mm'm':ss's' dd/MM/yyyy");

  const PickerModeEnum(this.value, this.format);
  final String value;
  final String format;

  static PickerModeEnum fromString(String? value) {
    switch (value) {
      case 'dateOnly':
        return PickerModeEnum.dateOnly;
      case 'hourDate':
        return PickerModeEnum.hourDate;
      case 'hourMinuteDate':
        return PickerModeEnum.hourMinuteDate;
      case 'fullDateTime':
      default:
        return PickerModeEnum.fullDateTime;
    }
  }

  /// Get format string for this mode
  String get dateFormat => format;
}

/// Custom date format patterns for app-specific needs
/// Add new patterns here as needed
enum DateFormatCustomPattern {
  mmmDyyyy('MMM d,yyyy'),
  mmmDdYyyyHhMm('MMM dd, yyyy - HH:mm');

  const DateFormatCustomPattern(this.pattern);
  final String pattern;
}
