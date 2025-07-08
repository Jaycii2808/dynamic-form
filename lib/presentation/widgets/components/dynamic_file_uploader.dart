// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicFileUploader extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicFileUploader({super.key, required this.component});

  @override
  State<DynamicFileUploader> createState() => _DynamicFileUploaderState();
}

class _DynamicFileUploaderState extends State<DynamicFileUploader> {
  bool isMultipleFiles = false;
  Timer? _timer;
  final FocusNode focusNode = FocusNode();

  // State variables for computed values
  late DynamicFormModel _currentComponent;
  String _currentState = 'base';
  Map<String, dynamic> _style = {};
  Map<String, dynamic> _config = {};
  List<String> _files = [];
  int _progress = 0;
  String? _errorText;
  bool _isProcessing = false;
  bool _isDragging = false;
  bool _isDisabled = false;

  // Pre-computed UI elements
  Widget? _childWidget;
  VoidCallback? _onTapHandler;
  void Function(DragTargetDetails<List<XFile>>)? _onAcceptHandler;
  bool Function(DragTargetDetails<List<XFile>>)? _onWillAcceptHandler;
  void Function(List<XFile>?)? _onLeaveHandler;

  @override
  void initState() {
    super.initState();
    isMultipleFiles = widget.component.config['multiple_files'] == true;

    // Initialize with widget component
    _currentComponent = widget.component;
    _computeValues();
  }

  @override
  void dispose() {
    _timer?.cancel();
    focusNode.dispose();
    super.dispose();
  }

  void _computeValues() {
    // Extract value data
    dynamic rawValue = _currentComponent.config['value'];
    final Map<String, dynamic> value = rawValue is Map<String, dynamic>
        ? rawValue
        : {};

    _currentState = value['state'] as String? ?? 'base';
    _files = (value['files'] as List?)?.cast<String>() ?? [];
    _progress = (value['progress'] as num?)?.toInt() ?? 0;
    _errorText = value['error_text'] as String?;
    _isProcessing = value['is_processing'] == true;
    _isDragging = value['is_dragging'] == true;
    _isDisabled = _currentComponent.config['disabled'] == true;

    _computeStyles();
    _computeConfig();
    _computeUIElements();
    _computeEventHandlers();

    debugPrint(
      '[FileUploader][_computeValues] id=${_currentComponent.id} state=$_currentState files=${_files.length} progress=$_progress',
    );
  }

  void _computeStyles() {
    final Map<String, dynamic> baseStyle = Map.from(_currentComponent.style);
    final Map<String, dynamic> variantStyle = _isDragging
        ? Map.from(_currentComponent.variants?['dragging']?['style'] ?? {})
        : {};
    final Map<String, dynamic> stateStyle = Map.from(
      _currentComponent.states?[_currentState]?['style'] ?? {},
    );
    _style = {...baseStyle, ...variantStyle, ...stateStyle};
  }

  void _computeConfig() {
    final Map<String, dynamic> baseConfig = Map.from(_currentComponent.config);
    final Map<String, dynamic> variantConfig = _isDragging
        ? Map.from(_currentComponent.variants?['dragging']?['config'] ?? {})
        : {};
    final Map<String, dynamic> stateConfig = Map.from(
      _currentComponent.states?[_currentState]?['config'] ?? {},
    );
    _config = {...baseConfig, ...variantConfig, ...stateConfig};
  }

  void _computeUIElements() {
    switch (_currentState) {
      case 'loading':
        _childWidget = _buildLoadingWidget();
        break;
      case 'success':
        _childWidget = _buildSuccessWidget();
        break;
      case 'error':
        _childWidget = _buildErrorWidget();
        break;
      default:
        _childWidget = _buildBaseWidget();
    }
  }

  void _computeEventHandlers() {
    _onTapHandler = _isDisabled ? null : _handleTap;
    _onWillAcceptHandler = _handleWillAccept;
    _onAcceptHandler = _handleAccept;
    _onLeaveHandler = _handleLeave;
  }

  Widget _buildLoadingWidget() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_style['icon'] != null)
            Icon(
              mapIconNameToIconData(_style['icon']),
              color: StyleUtils.parseColor(_style['icon_color']),
              size: 48,
            ),
          const SizedBox(height: 16),
          Text(
            _files.isNotEmpty
                ? '${_files.length > 1 ? '${_files.length} files' : _files.first} uploading... $_progress%'
                : 'Uploading... $_progress%',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: StyleUtils.parseColor(_style['text_color']),
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: _progress / 100),
        ],
      ),
    );
  }

  Widget _buildSuccessWidget() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_style['icon'] != null)
            Icon(
              mapIconNameToIconData(_style['icon']),
              color: StyleUtils.parseColor(_style['icon_color']),
              size: 48,
            ),
          const SizedBox(height: 16),
          if (_files.isNotEmpty)
            ..._files.map(
              (f) => ListTile(
                leading: isImageFile(f)
                    ? Image.file(
                        File(f),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.insert_drive_file,
                        color: StyleUtils.parseColor(
                          _style['icon_color'],
                        ),
                      ),
                title: Text(f.split('/').last),
                subtitle: FutureBuilder<String>(
                  future: getFileSize(f),
                  builder: (context, snapshot) => Text(snapshot.data ?? ''),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _handleRemoveFile(_files.indexOf(f)),
                ),
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _handleResetState,
            child: Text(_config['button_text'] ?? 'Remove All'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_style['icon'] != null)
            Icon(
              mapIconNameToIconData(_style['icon']),
              color: StyleUtils.parseColor(_style['icon_color']),
              size: 48,
            ),
          const SizedBox(height: 16),
          Text(
            _errorText ?? 'Error',
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _handleResetState,
            child: Text(_config['button_text'] ?? 'Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBaseWidget() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_style['icon'] != null)
            Icon(
              mapIconNameToIconData(_style['icon']),
              color: StyleUtils.parseColor(_style['icon_color']),
              size: 48,
            ),
          const SizedBox(height: 8),
          Text(
            _config['title'] ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: StyleUtils.parseColor(_style['text_color']),
            ),
          ),
          if (_config['subtitle'] != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                _config['subtitle'] ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: StyleUtils.parseColor(_style['text_color']),
                ),
              ),
            ),
          if (_config['button_text'] != null &&
              _config['button_text'].isNotEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: (_isProcessing || _isDisabled)
                  ? null
                  : _handleBrowseFiles,
              style: ElevatedButton.styleFrom(
                backgroundColor: StyleUtils.parseColor(
                  _style['button_background_color'],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    (_style['button_border_radius'] as num?)?.toDouble() ?? 8,
                  ),
                ),
              ),
              child: Text(
                _config['button_text'] ?? 'Browse',
                style: TextStyle(
                  color: StyleUtils.parseColor(
                    _style['button_text_color'],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Event handlers - business logic
  void _handleTap() {
    FocusScope.of(context).requestFocus(focusNode);
  }

  bool _handleWillAccept(DragTargetDetails<List<XFile>> details) {
    if (_isProcessing || _isDisabled) return false;
    FocusScope.of(context).requestFocus(focusNode);
    _updateDraggingState(true);
    return true;
  }

  void _handleAccept(DragTargetDetails<List<XFile>> details) {
    _updateDraggingState(false);
    handleFiles(details.data);
  }

  void _handleLeave(List<XFile>? data) {
    _updateDraggingState(false);
  }

  void _handleBrowseFiles() async {
    if (_isProcessing) return;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: isMultipleFiles,
      );
      if (result != null && result.files.isNotEmpty && mounted) {
        final files = result.files.map((f) => XFile(f.path!)).toList();
        handleFiles(files);
      }
    } catch (e) {
      if (mounted) {
        context.read<DynamicFormBloc>().add(
          UpdateFormFieldEvent(
            componentId: _currentComponent.id,
            value: {
              'state': 'error',
              'files': [],
              'progress': 0,
              'error_text': 'Error picking files',
              'is_processing': false,
            },
          ),
        );
      }
    }
  }

  void _handleRemoveFile(int index) {
    final newFiles = List<String>.from(_files)..removeAt(index);
    context.read<DynamicFormBloc>().add(
      UpdateFormFieldEvent(
        componentId: _currentComponent.id,
        value: {
          'state': newFiles.isEmpty ? 'base' : _currentState,
          'files': newFiles,
          'progress': _progress,
          'is_processing': false,
        },
      ),
    );
  }

  void _handleResetState() {
    _timer?.cancel();
    context.read<DynamicFormBloc>().add(
      UpdateFormFieldEvent(
        componentId: _currentComponent.id,
        value: {
          'state': 'base',
          'files': [],
          'progress': 0,
          'is_processing': false,
        },
      ),
    );
  }

  void _updateDraggingState(bool isDragging) {
    final value =
        _currentComponent.config['value'] as Map<String, dynamic>? ?? {};
    context.read<DynamicFormBloc>().add(
      UpdateFormFieldEvent(
        componentId: _currentComponent.id,
        value: {...value, 'is_dragging': isDragging},
      ),
    );
  }

  void startUpload(List<XFile> files) {
    context.read<DynamicFormBloc>().add(
      UpdateFormFieldEvent(
        componentId: _currentComponent.id,
        value: {
          'state': 'loading',
          'files': files.map((f) => f.path).toList(),
          'progress': 0,
          'is_processing': true,
        },
      ),
    );

    _timer?.cancel();
    int progress = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      progress += 5;
      if (progress >= 100) {
        timer.cancel();
        context.read<DynamicFormBloc>().add(
          UpdateFormFieldEvent(
            componentId: _currentComponent.id,
            value: {
              'state': 'success',
              'files': files.map((f) => f.path).toList(),
              'progress': 100,
              'is_processing': false,
            },
          ),
        );
      } else {
        context.read<DynamicFormBloc>().add(
          UpdateFormFieldEvent(
            componentId: _currentComponent.id,
            value: {
              'state': 'loading',
              'files': files.map((f) => f.path).toList(),
              'progress': progress,
              'is_processing': true,
            },
          ),
        );
      }
    });
  }

  void handleFiles(List<XFile> files) {
    if (files.isEmpty) return;
    final allowedExtensions =
        (_currentComponent.config['allowed_extensions'] as List<dynamic>?)
            ?.cast<String>() ??
        [];
    if (allowedExtensions.isNotEmpty) {
      for (final file in files) {
        final fileExtension = file.name.split('.').last.toLowerCase();
        if (!allowedExtensions.any(
          (ext) => ext.toLowerCase() == fileExtension,
        )) {
          context.read<DynamicFormBloc>().add(
            UpdateFormFieldEvent(
              componentId: _currentComponent.id,
              value: {
                'state': 'error',
                'files': [],
                'progress': 0,
                'error_text': 'File type not allowed',
                'is_processing': false,
              },
            ),
          );
          return;
        }
      }
    }
    startUpload(files);
  }

  IconData? mapIconNameToIconData(String name) {
    return IconTypeEnum.fromString(name).toIconData();
  }

  bool isImageFile(String filePath) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
    final extension = filePath.split('.').last.toLowerCase();
    return imageExtensions.contains(extension);
  }

  Future<String> getFileSize(String filePath) async {
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<DynamicFormBloc, DynamicFormState>(
      listener: (context, state) {
        // Update component from state and recompute values only when necessary
        final updatedComponent = (state.page?.components != null)
            ? state.page!.components.firstWhere(
                (c) => c.id == widget.component.id,
                orElse: () => widget.component,
              )
            : widget.component;

        // Only update if component actually changed
        if (updatedComponent != _currentComponent ||
            updatedComponent.config['value'] !=
                _currentComponent.config['value'] ||
            updatedComponent.config['disabled'] !=
                _currentComponent.config['disabled']) {
          setState(() {
            _currentComponent = updatedComponent;
            _computeValues();
          });
        }
      },
      child: BlocBuilder<DynamicFormBloc, DynamicFormState>(
        buildWhen: (previous, current) {
          // Only rebuild when something visual actually changes
          final prevComponent = previous.page?.components.firstWhere(
            (c) => c.id == widget.component.id,
            orElse: () => widget.component,
          );
          final currComponent = current.page?.components.firstWhere(
            (c) => c.id == widget.component.id,
            orElse: () => widget.component,
          );

          return prevComponent?.config['value'] !=
                  currComponent?.config['value'] ||
              prevComponent?.config['disabled'] !=
                  currComponent?.config['disabled'];
        },
        builder: (context, state) {
          // Pure UI rendering - NO LOGIC HERE
          return Focus(
            focusNode: focusNode,
            child: DragTarget<List<XFile>>(
              onWillAcceptWithDetails: _onWillAcceptHandler,
              onAcceptWithDetails: _onAcceptHandler,
              onLeave: _onLeaveHandler,
              builder: (context, candidateData, rejectedData) {
                return GestureDetector(
                  onTap: _onTapHandler,
                  child: Container(
                    key: Key(_currentComponent.id),
                    margin: StyleUtils.parsePadding(_style['margin']),
                    child: DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        color: StyleUtils.parseColor(_style['border_color']),
                        strokeWidth:
                            (_style['border_width'] as num?)?.toDouble() ?? 1,
                        radius: Radius.circular(
                          (_style['border_radius'] as num?)?.toDouble() ?? 0,
                        ),
                        dashPattern: const [6, 6],
                        padding: const EdgeInsets.all(0),
                      ),
                      child: Container(
                        width: (_style['width'] as num?)?.toDouble() ?? 300,
                        height: (_style['height'] as num?)?.toDouble() ?? 200,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: StyleUtils.parseColor(
                            _style['background_color'],
                          ),
                          borderRadius: BorderRadius.circular(
                            (_style['border_radius'] as num?)?.toDouble() ?? 0,
                          ),
                        ),
                        child: _childWidget,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
