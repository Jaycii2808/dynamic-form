import 'dart:async';
import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:dynamic_form_bi/core/enums/component_state_enum.dart';
import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_file_uploader/dynamic_file_uploader_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_file_uploader/dynamic_file_uploader_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicFileUploaderBloc
    extends Bloc<DynamicFileUploaderEvent, DynamicFileUploaderState> {
  final DynamicFormModel initialComponent;
  Timer? _uploadTimer;
  late FocusNode _focusNode;

  DynamicFileUploaderBloc({required this.initialComponent})
    : super(const DynamicFileUploaderInitial()) {
    _focusNode = FocusNode();

    on<InitializeFileUploaderEvent>(_onInitialize);
    on<UpdateFileUploaderFromExternalEvent>(_onUpdateFromExternal);
    on<FileSelectionEvent>(_onFileSelection);
    on<BrowseFilesEvent>(_onBrowseFiles);
    on<RemoveFileEvent>(_onRemoveFile);
    on<ResetStateEvent>(_onResetState);
    on<UpdateDraggingStateEvent>(_onUpdateDraggingState);
    on<StartUploadEvent>(_onStartUpload);
    on<UpdateUploadProgressEvent>(_onUpdateUploadProgress);
    on<CompleteUploadEvent>(_onCompleteUpload);
    on<FileUploadErrorEvent>(_onFileUploadError);
    on<ComputeFileUploaderStylesEvent>(_onComputeStyles);
  }

  @override
  Future<void> close() {
    _uploadTimer?.cancel();
    _focusNode.dispose();
    return super.close();
  }

  Future<void> _onInitialize(
    InitializeFileUploaderEvent event,
    Emitter<DynamicFileUploaderState> emit,
  ) async {
    emit(DynamicFileUploaderLoading(component: initialComponent));

    try {
      final state = _computeState(initialComponent);
      emit(state);

      debugPrint(
        '🟢 [FileUploader] Initialized: id=${initialComponent.id}',
      );
    } catch (e) {
      emit(
        DynamicFileUploaderError(
          errorMessage: 'Failed to initialize: $e',
          component: initialComponent,
        ),
      );
    }
  }

  Future<void> _onUpdateFromExternal(
    UpdateFileUploaderFromExternalEvent event,
    Emitter<DynamicFileUploaderState> emit,
  ) async {
    try {
      final newState = _computeState(event.component);
      emit(newState);

      debugPrint(
        '🔄 [FileUploader] External update: id=${event.component.id}',
      );
    } catch (e) {
      emit(
        DynamicFileUploaderError(
          errorMessage: 'Failed to update from external: $e',
          component: event.component,
        ),
      );
    }
  }

  Future<void> _onFileSelection(
    FileSelectionEvent event,
    Emitter<DynamicFileUploaderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicFileUploaderSuccess) return;

    try {
      // Validate file extensions
      final allowedExtensions = currentState.allowedExtensions;
      if (allowedExtensions.isNotEmpty) {
        for (final file in event.files) {
          final fileExtension = file.name.split('.').last.toLowerCase();
          if (!allowedExtensions.any(
            (ext) => ext.toLowerCase() == fileExtension,
          )) {
            add(
              const FileUploadErrorEvent(errorMessage: 'File type not allowed'),
            );
            return;
          }
        }
      }

      // Start upload
      add(StartUploadEvent(files: event.files));

      debugPrint(
        '📁 [FileUploader] Files selected: ${event.files.length} files',
      );
    } catch (e) {
      add(FileUploadErrorEvent(errorMessage: 'File selection error: $e'));
    }
  }

  Future<void> _onBrowseFiles(
    BrowseFilesEvent event,
    Emitter<DynamicFileUploaderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicFileUploaderSuccess) return;
    if (currentState.isProcessing || currentState.isDisabled) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: currentState.isMultipleFiles,
      );

      if (result != null && result.files.isNotEmpty) {
        final files = result.files.map((f) => XFile(f.path!)).toList();
        add(FileSelectionEvent(files: files));
      }

      debugPrint('📂 [FileUploader] Browse files completed');
    } catch (e) {
      add(FileUploadErrorEvent(errorMessage: 'Error picking files: $e'));
    }
  }

  Future<void> _onRemoveFile(
    RemoveFileEvent event,
    Emitter<DynamicFileUploaderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicFileUploaderSuccess) return;

    try {
      final newFiles = List<String>.from(currentState.files)
        ..removeAt(event.index);

      final newFormState = newFiles.isEmpty
          ? 'base'
          : currentState.currentState;

      final updatedState = currentState.copyWith(
        currentState: newFormState,
        files: newFiles,
        isProcessing: false,
        updateTimestamp: DateTime.now().millisecondsSinceEpoch,
      );

      emit(updatedState);

      debugPrint(
        '🗑️ [FileUploader] File removed: index=${event.index}',
      );
    } catch (e) {
      add(FileUploadErrorEvent(errorMessage: 'Error removing file: $e'));
    }
  }

  Future<void> _onResetState(
    ResetStateEvent event,
    Emitter<DynamicFileUploaderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicFileUploaderSuccess) return;

    try {
      _uploadTimer?.cancel();

      final updatedState = currentState.copyWith(
        currentState: 'base',
        files: [],
        progress: 0,
        isProcessing: false,
        isDragging: false,
        updateTimestamp: DateTime.now().millisecondsSinceEpoch,
      );

      emit(updatedState);

      debugPrint('🔄 [FileUploader] State reset');
    } catch (e) {
      add(FileUploadErrorEvent(errorMessage: 'Error resetting state: $e'));
    }
  }

  Future<void> _onUpdateDraggingState(
    UpdateDraggingStateEvent event,
    Emitter<DynamicFileUploaderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicFileUploaderSuccess) return;

    try {
      final updatedState = currentState.copyWith(
        isDragging: event.isDragging,
        updateTimestamp: DateTime.now().millisecondsSinceEpoch,
      );

      emit(updatedState);

      debugPrint(
        '📥 [FileUploader] Dragging state: ${event.isDragging}',
      );
    } catch (e) {
      add(
        FileUploadErrorEvent(errorMessage: 'Error updating dragging state: $e'),
      );
    }
  }

  Future<void> _onStartUpload(
    StartUploadEvent event,
    Emitter<DynamicFileUploaderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicFileUploaderSuccess) return;

    try {
      final updatedState = currentState.copyWith(
        currentState: 'loading',
        files: event.files.map((f) => f.path).toList(),
        progress: 0,
        isProcessing: true,
        isDragging: false,
        updateTimestamp: DateTime.now().millisecondsSinceEpoch,
      );

      emit(updatedState);

      // Simulate upload progress
      _uploadTimer?.cancel();
      int progress = 0;
      _uploadTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        progress += 5;
        if (progress >= 100) {
          timer.cancel();
          add(
            CompleteUploadEvent(
              filePaths: event.files.map((f) => f.path).toList(),
            ),
          );
        } else {
          add(UpdateUploadProgressEvent(progress: progress));
        }
      });

      debugPrint(
        '📤 [FileUploader] Upload started: ${event.files.length} files',
      );
    } catch (e) {
      add(FileUploadErrorEvent(errorMessage: 'Error starting upload: $e'));
    }
  }

  Future<void> _onUpdateUploadProgress(
    UpdateUploadProgressEvent event,
    Emitter<DynamicFileUploaderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicFileUploaderSuccess) return;

    try {
      final updatedState = currentState.copyWith(
        progress: event.progress,
        updateTimestamp: DateTime.now().millisecondsSinceEpoch,
      );

      emit(updatedState);
    } catch (e) {
      add(FileUploadErrorEvent(errorMessage: 'Error updating progress: $e'));
    }
  }

  Future<void> _onCompleteUpload(
    CompleteUploadEvent event,
    Emitter<DynamicFileUploaderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicFileUploaderSuccess) return;

    try {
      final updatedState = currentState.copyWith(
        currentState: 'success',
        files: event.filePaths,
        progress: 100,
        isProcessing: false,
        updateTimestamp: DateTime.now().millisecondsSinceEpoch,
      );

      emit(updatedState);

      debugPrint(
        '✅ [FileUploader] Upload completed: ${event.filePaths.length} files',
      );
    } catch (e) {
      add(FileUploadErrorEvent(errorMessage: 'Error completing upload: $e'));
    }
  }

  Future<void> _onFileUploadError(
    FileUploadErrorEvent event,
    Emitter<DynamicFileUploaderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicFileUploaderSuccess) return;

    try {
      _uploadTimer?.cancel();

      final updatedState = currentState.copyWith(
        currentState: 'error',
        files: [],
        progress: 0,
        isProcessing: false,
        errorText: event.errorMessage,
        updateTimestamp: DateTime.now().millisecondsSinceEpoch,
      );

      emit(updatedState);

      debugPrint(
        '❌ [FileUploader] Upload error: ${event.errorMessage}',
      );
    } catch (e) {
      emit(
        DynamicFileUploaderError(
          errorMessage: 'Error handling upload error: $e',
          component: currentState.component,
        ),
      );
    }
  }

  Future<void> _onComputeStyles(
    ComputeFileUploaderStylesEvent event,
    Emitter<DynamicFileUploaderState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DynamicFileUploaderSuccess) return;

    try {
      // Recompute styles with context
      final newState = _computeState(currentState.component!);
      emit(newState);

      debugPrint('🎨 [FileUploader] Styles computed');
    } catch (e) {
      add(FileUploadErrorEvent(errorMessage: 'Error computing styles: $e'));
    }
  }

  DynamicFileUploaderSuccess _computeState(DynamicFormModel component) {
    // Extract value data
    dynamic rawValue = component.config['value'];
    final Map<String, dynamic> value = rawValue is Map<String, dynamic>
        ? rawValue
        : {};

    final currentState = value['state'] as String? ?? 'base';
    final files = (value['files'] as List?)?.cast<String>() ?? [];
    final progress = (value['progress'] as num?)?.toInt() ?? 0;
    final errorText = value['error_text'] as String?;
    final isProcessing = value['is_processing'] == true;
    final isDragging = value['is_dragging'] == true;
    final isDisabled = component.config['disabled'] == true;
    final isMultipleFiles = component.config['multiple_files'] == true;
    final allowedExtensions =
        (component.config['allowed_extensions'] as List<dynamic>?)
            ?.cast<String>() ??
        [];

    // Compute styles
    final Map<String, dynamic> baseStyle = Map.from(component.style);
    final Map<String, dynamic> variantStyle = isDragging
        ? Map.from(component.variants?['dragging']?['style'] ?? {})
        : {};
    final Map<String, dynamic> stateStyle = Map.from(
      component.states?[currentState]?['style'] ?? {},
    );
    final computedStyle = {...baseStyle, ...variantStyle, ...stateStyle};

    // Compute config
    final Map<String, dynamic> baseConfig = Map.from(component.config);
    final Map<String, dynamic> variantConfig = isDragging
        ? Map.from(component.variants?['dragging']?['config'] ?? {})
        : {};
    final Map<String, dynamic> stateConfig = Map.from(
      component.states?[currentState]?['config'] ?? {},
    );
    final computedConfig = {...baseConfig, ...variantConfig, ...stateConfig};

    // Compute event handler flags
    final canTap = !isDisabled;
    final canAcceptDrop = !isProcessing && !isDisabled;
    final canBrowse = !isProcessing && !isDisabled;

    return DynamicFileUploaderSuccess(
      currentState: currentState,
      files: files,
      progress: progress,
      isProcessing: isProcessing,
      isDragging: isDragging,
      isDisabled: isDisabled,
      isMultipleFiles: isMultipleFiles,
      allowedExtensions: allowedExtensions,
      computedStyle: computedStyle,
      computedConfig: computedConfig,
      focusNode: _focusNode,
      canTap: canTap,
      canAcceptDrop: canAcceptDrop,
      canBrowse: canBrowse,
      component: component,
      formState: _parseFormState(currentState),
      errorText: errorText,
      updateTimestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  ComponentStateEnum? _parseFormState(String state) {
    switch (state) {
      case 'error':
        return ComponentStateEnum.error;
      case 'focused':
        return ComponentStateEnum.focused;
      case 'enabled':
        return ComponentStateEnum.enabled;
      default:
        return ComponentStateEnum.base;
    }
  }

  // Utility methods for UI
  static IconData? mapIconNameToIconData(String name) {
    return IconTypeEnum.fromString(name).toIconData();
  }

  static bool isImageFile(String filePath) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
    final extension = filePath.split('.').last.toLowerCase();
    return imageExtensions.contains(extension);
  }

  static Future<String> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      final size = await file.length();
      if (size < 1024) {
        return '$size B';
      } else if (size < 1024 * 1024) {
        return '${(size / 1024).toStringAsFixed(1)} KB';
      } else {
        return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    } catch (e) {
      return 'Unknown size';
    }
  }
}
