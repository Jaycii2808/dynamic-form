import 'package:equatable/equatable.dart';

abstract class TextInputEvent extends Equatable {
  const TextInputEvent();
  @override
  List<Object?> get props => [];
}

class LoadTextInputPageEvent extends TextInputEvent {}

class RefreshTextInputPageEvent extends TextInputEvent {}