import 'package:equatable/equatable.dart';

/// Model for date time range data
class DateTimeRangeModel extends Equatable {
  final String? start;
  final String? end;

  const DateTimeRangeModel({
    this.start,
    this.end,
  });

  factory DateTimeRangeModel.fromJson(Map<String, dynamic> json) {
    return DateTimeRangeModel(
      start: json['start'] as String?,
      end: json['end'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
    };
  }

  bool get hasValue => start != null && end != null;

  @override
  List<Object?> get props => [start, end];

  DateTimeRangeModel copyWith({
    String? start,
    String? end,
  }) {
    return DateTimeRangeModel(
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }
}
