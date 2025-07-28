import 'package:equatable/equatable.dart';

abstract class DynamicTextFieldTagsEvent extends Equatable {
  const DynamicTextFieldTagsEvent();

  @override
  List<Object?> get props => [];
}

class InitializeTextFieldTagsEvent extends DynamicTextFieldTagsEvent {
  const InitializeTextFieldTagsEvent();
}

class TagAddedEvent extends DynamicTextFieldTagsEvent {
  final String tag;
  const TagAddedEvent({required this.tag});
  @override
  List<Object?> get props => [tag];
}

class TagRemovedEvent extends DynamicTextFieldTagsEvent {
  final String tag;
  const TagRemovedEvent({required this.tag});
  @override
  List<Object?> get props => [tag];
}

class TagsFinalizedEvent extends DynamicTextFieldTagsEvent {
  const TagsFinalizedEvent();
}

class StartEditingTagsEvent extends DynamicTextFieldTagsEvent {
  const StartEditingTagsEvent();
}

class DoneEditingTagsEvent extends DynamicTextFieldTagsEvent {
  const DoneEditingTagsEvent();
}
