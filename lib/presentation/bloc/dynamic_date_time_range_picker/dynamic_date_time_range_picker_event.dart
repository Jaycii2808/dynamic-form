import 'package:equatable/equatable.dart';

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
  final Map<String, String> value;

  const DateTimeRangePickedEvent({required this.value});

  @override
  List<Object?> get props => [value];
}

class DateTimeRangePickerFocusLostEvent
    extends DynamicDateTimeRangePickerEvent {
  final Map<String, String>? value;

  const DateTimeRangePickerFocusLostEvent({required this.value});

  @override
  List<Object?> get props => [value];
}
