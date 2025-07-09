import 'package:cross_file/cross_file.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class DynamicFileUploaderEvent extends Equatable {
  const DynamicFileUploaderEvent();

  @override
  List<Object?> get props => [];
}

class InitializeFileUploaderEvent extends DynamicFileUploaderEvent {
  const InitializeFileUploaderEvent();
}

class UpdateFileUploaderFromExternalEvent extends DynamicFileUploaderEvent {
  final DynamicFormModel component;

  const UpdateFileUploaderFromExternalEvent({required this.component});

  @override
  List<Object?> get props => [component];
}

class FileSelectionEvent extends DynamicFileUploaderEvent {
  final List<XFile> files;

  const FileSelectionEvent({required this.files});

  @override
  List<Object?> get props => [files];
}

class BrowseFilesEvent extends DynamicFileUploaderEvent {
  const BrowseFilesEvent();
}

class RemoveFileEvent extends DynamicFileUploaderEvent {
  final int index;

  const RemoveFileEvent({required this.index});

  @override
  List<Object?> get props => [index];
}

class ResetStateEvent extends DynamicFileUploaderEvent {
  const ResetStateEvent();
}

class UpdateDraggingStateEvent extends DynamicFileUploaderEvent {
  final bool isDragging;

  const UpdateDraggingStateEvent({required this.isDragging});

  @override
  List<Object?> get props => [isDragging];
}

class StartUploadEvent extends DynamicFileUploaderEvent {
  final List<XFile> files;

  const StartUploadEvent({required this.files});

  @override
  List<Object?> get props => [files];
}

class UpdateUploadProgressEvent extends DynamicFileUploaderEvent {
  final int progress;

  const UpdateUploadProgressEvent({required this.progress});

  @override
  List<Object?> get props => [progress];
}

class CompleteUploadEvent extends DynamicFileUploaderEvent {
  final List<String> filePaths;

  const CompleteUploadEvent({required this.filePaths});

  @override
  List<Object?> get props => [filePaths];
}

class FileUploadErrorEvent extends DynamicFileUploaderEvent {
  final String errorMessage;

  const FileUploadErrorEvent({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class ComputeFileUploaderStylesEvent extends DynamicFileUploaderEvent {
  final BuildContext context;

  const ComputeFileUploaderStylesEvent({required this.context});

  @override
  List<Object?> get props => [context];
}
