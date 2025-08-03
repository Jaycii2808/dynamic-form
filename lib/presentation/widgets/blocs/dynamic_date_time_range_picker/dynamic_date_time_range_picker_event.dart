import 'package:equatable/equatable.dart';
import 'package:dynamic_form_bi/data/models/date_time_range/date_time_range_model.dart';

abstract class DynamicDateTimeRangePickerEvent extends Equatable {
  const DynamicDateTimeRangePickerEvent();

  @override
  List<Object?> get props => [];
}

class InitializeDateTimeRangePickerEvent
    extends DynamicDateTimeRangePickerEvent {
  const InitializeDateTimeRangePickerEvent();
}

class DateTimeRangePickerTappedEvent extends DynamicDateTimeRangePickerEvent {
  const DateTimeRangePickerTappedEvent();
}

class DateTimeRangePickedEvent extends DynamicDateTimeRangePickerEvent {
  final DateTimeRangeModel value;

  const DateTimeRangePickedEvent({required this.value});

  @override
  List<Object?> get props => [value];
}

class DateTimeRangePickerFocusLostEvent
    extends DynamicDateTimeRangePickerEvent {
  final DateTimeRangeModel? value;

  const DateTimeRangePickerFocusLostEvent({required this.value});

  @override
  List<Object?> get props => [value];
}
