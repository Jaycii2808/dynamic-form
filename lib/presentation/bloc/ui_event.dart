import 'package:equatable/equatable.dart';

abstract class UIEvent extends Equatable {
  const UIEvent();
  @override
  List<Object?> get props => [];
}

class LoadUIPage extends UIEvent {}

class RefreshUIPage extends UIEvent {}
