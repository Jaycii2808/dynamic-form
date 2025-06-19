import 'package:equatable/equatable.dart';
import '../../core/models/ui_component_model.dart';

abstract class UIState extends Equatable {
  const UIState();
  @override
  List<Object?> get props => [];
}

class UIInitial extends UIState {}

class UILoading extends UIState {}

class UILoaded extends UIState {
  final UIPageModel page;
  const UILoaded({required this.page});
  @override
  List<Object?> get props => [page];
}

class UIEmpty extends UIState {}

class UIError extends UIState {
  final String message;
  const UIError({required this.message});
  @override
  List<Object?> get props => [message];
}
