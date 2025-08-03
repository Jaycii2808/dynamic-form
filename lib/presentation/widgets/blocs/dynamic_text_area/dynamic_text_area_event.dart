import 'package:equatable/equatable.dart';

abstract class DynamicTextAreaEvent extends Equatable {
  const DynamicTextAreaEvent();

  @override
  List<Object?> get props => [];
}

class InitializeTextAreaEvent extends DynamicTextAreaEvent {
  const InitializeTextAreaEvent();
}

class TextAreaFocusLostEvent extends DynamicTextAreaEvent {
  final String value;

  const TextAreaFocusLostEvent({required this.value});

  @override
  List<Object?> get props => [value];
}
