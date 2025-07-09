import 'package:equatable/equatable.dart';
import '../../../data/models/dynamic_form_model.dart';

/// Base class for all dynamic button events
abstract class DynamicButtonEvent extends Equatable {
  const DynamicButtonEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize the button with component data
class InitializeDynamicButtonEvent extends DynamicButtonEvent {
  final DynamicFormModel component;

  const InitializeDynamicButtonEvent({
    required this.component,
  });

  @override
  List<Object?> get props => [component];
}

/// Event when component is updated from external source (FormBloc)
class ComponentUpdatedEvent extends DynamicButtonEvent {
  final DynamicFormModel component;

  const ComponentUpdatedEvent({
    required this.component,
  });

  @override
  List<Object?> get props => [component];
}

/// Event when button is pressed
class ButtonPressedEvent extends DynamicButtonEvent {
  final String buttonId;

  const ButtonPressedEvent({
    required this.buttonId,
  });

  @override
  List<Object?> get props => [buttonId];
}

/// Event to update loading state
class ButtonLoadingEvent extends DynamicButtonEvent {
  final bool isLoading;

  const ButtonLoadingEvent({
    required this.isLoading,
  });

  @override
  List<Object?> get props => [isLoading];
}
