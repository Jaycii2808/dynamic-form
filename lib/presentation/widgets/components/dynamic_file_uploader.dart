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

  @override
  void initState() {
    super.initState();
    isMultipleFiles = widget.component.config['multiple_files'] == true;
  }

  @override
  void dispose() {
    _timer?.cancel();
    focusNode.dispose();
    super.dispose();
  }

  void startUpload(List<XFile> files, DynamicFormModel component) {
    context.read<DynamicFormBloc>().add(
      UpdateFormFieldEvent(
        componentId: component.id,
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
            componentId: component.id,
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
            componentId: component.id,
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

  void handleFiles(List<XFile> files, DynamicFormModel component) {
    if (files.isEmpty) return;
    final allowedExtensions =
        (component.config['allowed_extensions'] as List<dynamic>?)
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
              componentId: component.id,
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
    startUpload(files, component);
  }

  void browseFiles(DynamicFormModel component, bool isProcessing) async {
    if (isProcessing) return;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: isMultipleFiles,
      );
      if (result != null && result.files.isNotEmpty && mounted) {
        final files = result.files.map((f) => XFile(f.path!)).toList();
        handleFiles(files, component);
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
              'error_text': 'Error picking files',
              'is_processing': false,
            },
          ),
        );
      }
    }
  }

  void resetState(DynamicFormModel component) {
    _timer?.cancel();
    context.read<DynamicFormBloc>().add(
      UpdateFormFieldEvent(
        componentId: component.id,
        value: {
          'state': 'base',
          'files': [],
          'progress': 0,
          'is_processing': false,
        },
      ),
    );
  }

  void removeFile(
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
          'is_processing': false,
        },
      ),
    );
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
        final String? errorText = value['error_text'] as String?;
        final bool isProcessing = value['is_processing'] == true;
        final bool isDragging = value['is_dragging'] == true;
        final bool isDisabled = component.config['disabled'] == true;

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
                      mapIconNameToIconData(style['icon']),
                      color: StyleUtils.parseColor(style['icon_color']),
                      size: 48,
                    ),
                  const SizedBox(height: 16),
                  Text(
                    files.isNotEmpty
                        ? '${files.length > 1 ? '${files.length} files' : files.first} uploading... $progress%'
                        : 'Uploading... $progress%',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: StyleUtils.parseColor(style['text_color']),
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
                      mapIconNameToIconData(style['icon']),
                      color: StyleUtils.parseColor(style['icon_color']),
                      size: 48,
                    ),
                  const SizedBox(height: 16),
                  if (files.isNotEmpty)
                    ...files.map(
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
                                  style['icon_color'],
                                ),
                              ),
                        title: Text(f.split('/').last),
                        subtitle: FutureBuilder<String>(
                          future: getFileSize(f),
                          builder: (context, snapshot) =>
                              Text(snapshot.data ?? ''),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => removeFile(
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
                    onPressed: () => resetState(component),
                    child: Text(config['button_text'] ?? 'Remove All'),
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
                      mapIconNameToIconData(style['icon']),
                      color: StyleUtils.parseColor(style['icon_color']),
                      size: 48,
                    ),
                  const SizedBox(height: 16),
                  Text(
                    errorText ?? 'Error',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => resetState(component),
                    child: Text(config['button_text'] ?? 'Retry'),
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
                      mapIconNameToIconData(style['icon']),
                      color: StyleUtils.parseColor(style['icon_color']),
                      size: 48,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    config['title'] ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: StyleUtils.parseColor(style['text_color']),
                    ),
                  ),
                  if (config['subtitle'] != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        config['subtitle'] ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: StyleUtils.parseColor(style['text_color']),
                        ),
                      ),
                    ),
                  if (config['button_text'] != null &&
                      config['button_text'].isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: (isProcessing || isDisabled)
                          ? null
                          : () => browseFiles(component, isProcessing),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StyleUtils.parseColor(
                          style['button_background_color'],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            (style['button_border_radius'] as num?)
                                    ?.toDouble() ??
                                8,
                          ),
                        ),
                      ),
                      child: Text(
                        config['button_text'] ?? 'Browse',
                        style: TextStyle(
                          color: StyleUtils.parseColor(
                            style['button_text_color'],
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
          focusNode: focusNode,
          child: DragTarget<List<XFile>>(
            onWillAcceptWithDetails: (data) {
              if (isProcessing || isDisabled) return false;
              FocusScope.of(context).requestFocus(focusNode);
              context.read<DynamicFormBloc>().add(
                UpdateFormFieldEvent(
                  componentId: component.id,
                  value: {...value, 'is_dragging': true},
                ),
              );
              return true;
            },
            onAcceptWithDetails: (details) {
              context.read<DynamicFormBloc>().add(
                UpdateFormFieldEvent(
                  componentId: component.id,
                  value: {...value, 'is_dragging': false},
                ),
              );
              handleFiles(details.data, component);
            },
            onLeave: (data) {
              context.read<DynamicFormBloc>().add(
                UpdateFormFieldEvent(
                  componentId: component.id,
                  value: {...value, 'is_dragging': false},
                ),
              );
            },
            builder: (context, candidateData, rejectedData) {
              return GestureDetector(
                onTap: isDisabled
                    ? null
                    : () {
                        FocusScope.of(context).requestFocus(focusNode);
                      },
                child: Container(
                  key: Key(component.id),
                  margin: StyleUtils.parsePadding(style['margin']),
                  child: DottedBorder(
                    options: RoundedRectDottedBorderOptions(
                      color: StyleUtils.parseColor(style['border_color']),
                      strokeWidth:
                          (style['border_width'] as num?)?.toDouble() ?? 1,
                      radius: Radius.circular(
                        (style['border_radius'] as num?)?.toDouble() ?? 0,
                      ),
                      dashPattern: const [6, 6],
                      padding: const EdgeInsets.all(0),
                    ),
                    child: Container(
                      width: (style['width'] as num?)?.toDouble() ?? 300,
                      height: (style['height'] as num?)?.toDouble() ?? 200,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        color: StyleUtils.parseColor(style['background_color']),
                        borderRadius: BorderRadius.circular(
                          (style['border_radius'] as num?)?.toDouble() ?? 0,
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
