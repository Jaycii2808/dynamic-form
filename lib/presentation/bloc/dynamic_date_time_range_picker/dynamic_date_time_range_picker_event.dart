import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class DynamicDateTimeRangePickerEvent extends Equatable {
  const DynamicDateTimeRangePickerEvent();

  @override
  List<Object?> get props => [];
}

class InitializeDateTimeRangePickerEvent extends DynamicDateTimeRangePickerEvent {
  const InitializeDateTimeRangePickerEvent();
}

class DateTimeRangePickedEvent extends DynamicDateTimeRangePickerEvent {
  final DateTimeRange value;

  const DateTimeRangePickedEvent({required this.value});

  @override
  List<Object?> get props => [value];
}

class DateTimeRangePickerFocusLostEvent extends DynamicDateTimeRangePickerEvent {
  const DateTimeRangePickerFocusLostEvent();
}