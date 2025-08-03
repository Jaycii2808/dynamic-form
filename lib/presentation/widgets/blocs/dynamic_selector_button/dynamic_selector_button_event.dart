import 'package:equatable/equatable.dart';

abstract class DynamicSelectorButtonEvent extends Equatable {
  const DynamicSelectorButtonEvent();

  @override
  List<Object?> get props => [];
}

class InitializeSelectorButtonEvent extends DynamicSelectorButtonEvent {
  const InitializeSelectorButtonEvent();
}

class SelectorButtonToggledEvent extends DynamicSelectorButtonEvent {
  final bool isSelected;

  const SelectorButtonToggledEvent({required this.isSelected});

  @override
  List<Object?> get props => [isSelected];
}