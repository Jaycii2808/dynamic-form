import 'package:equatable/equatable.dart';

abstract class DynamicSwitchEvent extends Equatable {
  const DynamicSwitchEvent();

  @override
  List<Object?> get props => [];
}

class InitializeSwitchEvent extends DynamicSwitchEvent {
  const InitializeSwitchEvent();
}

class SwitchToggledEvent extends DynamicSwitchEvent {
  final bool value;

  const SwitchToggledEvent({required this.value});

  @override
  List<Object?> get props => [value];
}