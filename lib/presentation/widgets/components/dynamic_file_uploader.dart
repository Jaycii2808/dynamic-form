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
  bool _isMultipleFiles = false;
  Timer? _timer;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _isMultipleFiles = widget.component.config['multipleFiles'] == true;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _startUpload(List<XFile> files, DynamicFormModel component) {
    // Send event to BLoC: start upload (state=loading, progress=0, isProcessing=true)
    context.read<DynamicFormBloc>().add(
      UpdateFormFieldEvent(
        componentId: component.id,
        value: {
          'state': 'loading',
          'files': files.map((f) => f.path).toList(),
          'progress': 0,
          'isProcessing': true,
        },
      ),
    );
    // Simulate upload progress with timer, send progress event to BLoC
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
        // Send success event to BLoC
        context.read<DynamicFormBloc>().add(
          UpdateFormFieldEvent(
            componentId: component.id,
            value: {
              'state': 'success',
              'files': files.map((f) => f.path).toList(),
              'progress': 100,
              'isProcessing': false,
            },
          ),
        );
      } else {
        // Send progress event to BLoC
        context.read<DynamicFormBloc>().add(
          UpdateFormFieldEvent(
            componentId: component.id,
            value: {
              'state': 'loading',
              'files': files.map((f) => f.path).toList(),
              'progress': progress,
              'isProcessing': true,
            },
          ),
        );
      }
    });
  }

  void _handleFiles(List<XFile> files, DynamicFormModel component) {
    if (files.isEmpty) return;
    final allowedExtensions =
        (component.config['allowedExtensions'] as List<dynamic>?)
            ?.cast<String>() ??
        [];
    if (allowedExtensions.isNotEmpty) {
      for (final file in files) {
        final fileExtension = file.name.split('.').last.toLowerCase();
        if (!allowedExtensions.any(
          (ext) => ext.toLowerCase() == fileExtension,
        )) {
          // Send error event to BLoC
          context.read<DynamicFormBloc>().add(
            UpdateFormFieldEvent(
              componentId: component.id,
              value: {
                'state': 'error',
                'files': [],
                'progress': 0,
                'errorText': 'File type not allowed',
                'isProcessing': false,
              },
            ),
          );
          return;
        }
      }
    }
    _startUpload(files, component);
  }

  void _browseFiles(DynamicFormModel component, bool isProcessing) async {
    if (isProcessing) return;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: _isMultipleFiles,
      );
      if (result != null && result.files.isNotEmpty && mounted) {
        final files = result.files.map((f) => XFile(f.path!)).toList();
        _handleFiles(files, component);
      }
    } catch (e) {
      if (mounted) {
        context.read<DynamicFormBloc>().add(
          UpdateFormFieldEvent(
            componentId: widget.component.id,
            value: {
              'state': 'error',
              'files': [],
              'progress': 0,
              'errorText': 'Error picking files',
              'isProcessing': false,
            },
          ),
        );
      }
    }
  }

  void _resetState(DynamicFormModel component) {
    _timer?.cancel();
    context.read<DynamicFormBloc>().add(
      UpdateFormFieldEvent(
        componentId: component.id,
        value: {
          'state': 'base',
          'files': [],
          'progress': 0,
          'isProcessing': false,
        },
      ),
    );
  }

  void _removeFile(
    int index,
    DynamicFormModel component,
    List<String> files,
    int progress,
    String state,
  ) {
    final newFiles = List<String>.from(files)..removeAt(index);
    context.read<DynamicFormBloc>().add(
      UpdateFormFieldEvent(
        componentId: component.id,
        value: {
          'state': newFiles.isEmpty ? 'base' : state,
          'files': newFiles,
          'progress': progress,
          'isProcessing': false,
        },
      ),
    );
  }

  IconData? _mapIconNameToIconData(String name) {
    return IconTypeEnum.fromString(name).toIconData();
  }

  bool _isImageFile(String filePath) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
    final extension = filePath.split('.').last.toLowerCase();
    return imageExtensions.contains(extension);
  }

  Future<String> _getFileSize(String filePath) async {
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
    return BlocConsumer<DynamicFormBloc, DynamicFormState>(
      listener: (context, state) {},
      builder: (context, state) {
        final component = (state.page?.components != null)
            ? state.page!.components.firstWhere(
                (c) => c.id == widget.component.id,
                orElse: () => widget.component,
              )
            : widget.component;
        dynamic rawValue = component.config['value'];
        final Map<String, dynamic> value = rawValue is Map<String, dynamic>
            ? rawValue
            : {};
        final String currentState = value['state'] as String? ?? 'base';
        final List<String> files =
            (value['files'] as List?)?.cast<String>() ?? [];
        final int progress = (value['progress'] as num?)?.toInt() ?? 0;
        final String? errorText = value['errorText'] as String?;
        final bool isProcessing = value['isProcessing'] == true;
        final bool isDragging = value['isDragging'] == true;

        final Map<String, dynamic> baseStyle = Map.from(component.style);
        final Map<String, dynamic> variantStyle = isDragging
            ? Map.from(component.variants?['dragging']?['style'] ?? {})
            : {};
        final Map<String, dynamic> stateStyle = Map.from(
          component.states?[currentState]?['style'] ?? {},
        );
        final style = {...baseStyle, ...variantStyle, ...stateStyle};

        final Map<String, dynamic> baseConfig = Map.from(component.config);
        final Map<String, dynamic> variantConfig = isDragging
            ? Map.from(component.variants?['dragging']?['config'] ?? {})
            : {};
        final Map<String, dynamic> stateConfig = Map.from(
          component.states?[currentState]?['config'] ?? {},
        );
        final config = {...baseConfig, ...variantConfig, ...stateConfig};

        Widget child;
        switch (currentState) {
          case 'loading':
            child = SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (style['icon'] != null)
                    Icon(
                      _mapIconNameToIconData(style['icon']),
                      color: StyleUtils.parseColor(style['iconColor']),
                      size: 48,
                    ),
                  const SizedBox(height: 16),
                  Text(
                    files.isNotEmpty
                        ? '${files.length > 1 ? '${files.length} files' : files.first} uploading... $progress%'
                        : 'Uploading... $progress%',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: StyleUtils.parseColor(style['textColor']),
                    ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: progress / 100),
                ],
              ),
            );
            break;
          case 'success':
            child = SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (style['icon'] != null)
                    Icon(
                      _mapIconNameToIconData(style['icon']),
                      color: StyleUtils.parseColor(style['iconColor']),
                      size: 48,
                    ),
                  const SizedBox(height: 16),
                  if (files.isNotEmpty)
                    ...files.map(
                      (f) => ListTile(
                        leading: _isImageFile(f)
                            ? Image.file(
                                File(f),
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                Icons.insert_drive_file,
                                color: StyleUtils.parseColor(
                                  style['iconColor'],
                                ),
                              ),
                        title: Text(f.split('/').last),
                        subtitle: FutureBuilder<String>(
                          future: _getFileSize(f),
                          builder: (context, snapshot) =>
                              Text(snapshot.data ?? ''),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => _removeFile(
                            files.indexOf(f),
                            component,
                            files,
                            progress,
                            currentState,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _resetState(component),
                    child: Text(config['buttonText'] ?? 'Remove All'),
                  ),
                ],
              ),
            );
            break;
          case 'error':
            child = SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (style['icon'] != null)
                    Icon(
                      _mapIconNameToIconData(style['icon']),
                      color: StyleUtils.parseColor(style['iconColor']),
                      size: 48,
                    ),
                  const SizedBox(height: 16),
                  Text(
                    errorText ?? 'Error',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _resetState(component),
                    child: Text(config['buttonText'] ?? 'Retry'),
                  ),
                ],
              ),
            );
            break;
          default:
            child = SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (style['icon'] != null)
                    Icon(
                      _mapIconNameToIconData(style['icon']),
                      color: StyleUtils.parseColor(style['iconColor']),
                      size: 48,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    config['title'] ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: StyleUtils.parseColor(style['textColor']),
                    ),
                  ),
                  if (config['subtitle'] != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        config['subtitle'] ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: StyleUtils.parseColor(style['textColor']),
                        ),
                      ),
                    ),
                  if (config['buttonText'] != null &&
                      config['buttonText'].isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: isProcessing
                          ? null
                          : () => _browseFiles(component, isProcessing),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StyleUtils.parseColor(
                          style['buttonBackgroundColor'],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            (style['buttonBorderRadius'] as num?)?.toDouble() ??
                                8,
                          ),
                        ),
                      ),
                      child: Text(
                        config['buttonText'] ?? 'Browse',
                        style: TextStyle(
                          color: StyleUtils.parseColor(
                            style['buttonTextColor'],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
        }

        return Focus(
          focusNode: _focusNode,
          child: DragTarget<List<XFile>>(
            onWillAcceptWithDetails: (data) {
              if (isProcessing) return false;
              FocusScope.of(context).requestFocus(_focusNode);
              // Send event to BLoC to set isDragging=true
              context.read<DynamicFormBloc>().add(
                UpdateFormFieldEvent(
                  componentId: component.id,
                  value: {...value, 'isDragging': true},
                ),
              );
              return true;
            },
            onAcceptWithDetails: (details) {
              // Send event to BLoC to set isDragging=false
              context.read<DynamicFormBloc>().add(
                UpdateFormFieldEvent(
                  componentId: component.id,
                  value: {...value, 'isDragging': false},
                ),
              );
              _handleFiles(details.data, component);
            },
            onLeave: (data) {
              // Send event to BLoC to set isDragging=false
              context.read<DynamicFormBloc>().add(
                UpdateFormFieldEvent(
                  componentId: component.id,
                  value: {...value, 'isDragging': false},
                ),
              );
            },
            builder: (context, candidateData, rejectedData) {
              return GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(_focusNode);
                },
                child: Container(
                  key: Key(component.id),
                  margin: StyleUtils.parsePadding(style['margin']),
                  child: DottedBorder(
                    color: StyleUtils.parseColor(style['borderColor']),
                    strokeWidth:
                        (style['borderWidth'] as num?)?.toDouble() ?? 1,
                    radius: Radius.circular(
                      (style['borderRadius'] as num?)?.toDouble() ?? 0,
                    ),
                    dashPattern: const [6, 6],
                    borderType: BorderType.RRect,
                    child: Container(
                      width: (style['width'] as num?)?.toDouble() ?? 300,
                      height: (style['height'] as num?)?.toDouble() ?? 200,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        color: StyleUtils.parseColor(style['backgroundColor']),
                        borderRadius: BorderRadius.circular(
                          (style['borderRadius'] as num?)?.toDouble() ?? 0,
                        ),
                      ),
                      child: child,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
