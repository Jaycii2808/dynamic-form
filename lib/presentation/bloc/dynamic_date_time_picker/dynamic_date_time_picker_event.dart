import 'package:equatable/equatable.dart';

abstract class DynamicDateTimePickerEvent extends Equatable {
  const DynamicDateTimePickerEvent();

  @override
  List<Object?> get props => [];
}

class InitializeDateTimePickerEvent extends DynamicDateTimePickerEvent {
  const InitializeDateTimePickerEvent();
}

class DateTimePickerTappedEvent extends DynamicDateTimePickerEvent {
  const DateTimePickerTappedEvent();
}

class DateTimePickedEvent extends DynamicDateTimePickerEvent {
  final String value;

  const DateTimePickedEvent({required this.value});

  @override
  List<Object?> get props => [value];
}

class DateTimePickerFocusLostEvent extends DynamicDateTimePickerEvent {
  final String value;

  const DateTimePickerFocusLostEvent({required this.value});

  @override
  List<Object?> get props => [value];
}
