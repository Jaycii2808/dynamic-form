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
  bool _is_multiple_files = false;
  Timer? _timer;
  final FocusNode _focus_node = FocusNode();

  @override
  void initState() {
    super.initState();
    _is_multiple_files = widget.component.config['multiple_files'] == true;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focus_node.dispose();
    super.dispose();
  }

  void _start_upload(List<XFile> files, DynamicFormModel component) {
    // Send event to BLoC: start upload (state=loading, progress=0, isProcessing=true)
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
              'is_processing': false,
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
              'is_processing': true,
            },
          ),
        );
      }
    });
  }

  void _handle_files(List<XFile> files, DynamicFormModel component) {
    if (files.isEmpty) return;
    final allowed_extensions =
        (component.config['allowed_extensions'] as List<dynamic>?)
            ?.cast<String>() ??
        [];
    if (allowed_extensions.isNotEmpty) {
      for (final file in files) {
        final file_extension = file.name.split('.').last.toLowerCase();
        if (!allowed_extensions.any(
          (ext) => ext.toLowerCase() == file_extension,
        )) {
          // Send error event to BLoC
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
    _start_upload(files, component);
  }

  void _browse_files(DynamicFormModel component, bool is_processing) async {
    if (is_processing) return;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: _is_multiple_files,
      );
      if (result != null && result.files.isNotEmpty && mounted) {
        final files = result.files.map((f) => XFile(f.path!)).toList();
        _handle_files(files, component);
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

  void _reset_state(DynamicFormModel component) {
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

  void _remove_file(
    int index,
    DynamicFormModel component,
    List<String> files,
    int progress,
    String state,
  ) {
    final new_files = List<String>.from(files)..removeAt(index);
    context.read<DynamicFormBloc>().add(
      UpdateFormFieldEvent(
        componentId: component.id,
        value: {
          'state': new_files.isEmpty ? 'base' : state,
          'files': new_files,
          'progress': progress,
          'is_processing': false,
        },
      ),
    );
  }

  IconData? _map_icon_name_to_icon_data(String name) {
    return IconTypeEnum.fromString(name).toIconData();
  }

  bool _is_image_file(String file_path) {
    final image_extensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
    final extension = file_path.split('.').last.toLowerCase();
    return image_extensions.contains(extension);
  }

  Future<String> _get_file_size(String file_path) async {
    try {
      final file = File(file_path);
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
        dynamic raw_value = component.config['value'];
        final Map<String, dynamic> value = raw_value is Map<String, dynamic>
            ? raw_value
            : {};
        final String current_state = value['state'] as String? ?? 'base';
        final List<String> files =
            (value['files'] as List?)?.cast<String>() ?? [];
        final int progress = (value['progress'] as num?)?.toInt() ?? 0;
        final String? error_text = value['error_text'] as String?;
        final bool is_processing = value['is_processing'] == true;
        final bool is_dragging = value['is_dragging'] == true;
        final bool is_disabled = component.config['disabled'] == true;

        final Map<String, dynamic> base_style = Map.from(component.style);
        final Map<String, dynamic> variant_style = is_dragging
            ? Map.from(component.variants?['dragging']?['style'] ?? {})
            : {};
        final Map<String, dynamic> state_style = Map.from(
          component.states?[current_state]?['style'] ?? {},
        );
        final style = {...base_style, ...variant_style, ...state_style};

        final Map<String, dynamic> base_config = Map.from(component.config);
        final Map<String, dynamic> variant_config = is_dragging
            ? Map.from(component.variants?['dragging']?['config'] ?? {})
            : {};
        final Map<String, dynamic> state_config = Map.from(
          component.states?[current_state]?['config'] ?? {},
        );
        final config = {...base_config, ...variant_config, ...state_config};

        Widget child;
        switch (current_state) {
          case 'loading':
            child = SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (style['icon'] != null)
                    Icon(
                      _map_icon_name_to_icon_data(style['icon']),
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
                      _map_icon_name_to_icon_data(style['icon']),
                      color: StyleUtils.parseColor(style['icon_color']),
                      size: 48,
                    ),
                  const SizedBox(height: 16),
                  if (files.isNotEmpty)
                    ...files.map(
                      (f) => ListTile(
                        leading: _is_image_file(f)
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
                          future: _get_file_size(f),
                          builder: (context, snapshot) =>
                              Text(snapshot.data ?? ''),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => _remove_file(
                            files.indexOf(f),
                            component,
                            files,
                            progress,
                            current_state,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _reset_state(component),
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
                      _map_icon_name_to_icon_data(style['icon']),
                      color: StyleUtils.parseColor(style['icon_color']),
                      size: 48,
                    ),
                  const SizedBox(height: 16),
                  Text(
                    error_text ?? 'Error',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _reset_state(component),
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
                      _map_icon_name_to_icon_data(style['icon']),
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
                      onPressed: (is_processing || is_disabled)
                          ? null
                          : () => _browse_files(component, is_processing),
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
          focusNode: _focus_node,
          child: DragTarget<List<XFile>>(
            onWillAcceptWithDetails: (data) {
              if (is_processing || is_disabled) return false;
              FocusScope.of(context).requestFocus(_focus_node);
              // Send event to BLoC to set is_dragging=true
              context.read<DynamicFormBloc>().add(
                UpdateFormFieldEvent(
                  componentId: component.id,
                  value: {...value, 'is_dragging': true},
                ),
              );
              return true;
            },
            onAcceptWithDetails: (details) {
              // Send event to BLoC to set is_dragging=false
              context.read<DynamicFormBloc>().add(
                UpdateFormFieldEvent(
                  componentId: component.id,
                  value: {...value, 'is_dragging': false},
                ),
              );
              _handle_files(details.data, component);
            },
            onLeave: (data) {
              // Send event to BLoC to set is_dragging=false
              context.read<DynamicFormBloc>().add(
                UpdateFormFieldEvent(
                  componentId: component.id,
                  value: {...value, 'is_dragging': false},
                ),
              );
            },
            builder: (context, candidate_data, rejected_data) {
              return GestureDetector(
                onTap: is_disabled
                    ? null
                    : () {
                        FocusScope.of(context).requestFocus(_focus_node);
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
