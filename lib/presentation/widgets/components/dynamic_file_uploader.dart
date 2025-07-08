// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_file_uploader/dynamic_file_uploader_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_file_uploader/dynamic_file_uploader_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_file_uploader/dynamic_file_uploader_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicFileUploader extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicFileUploader({super.key, required this.component});

  @override
  State<DynamicFileUploader> createState() => _DynamicFileUploaderState();
}

class _DynamicFileUploaderState extends State<DynamicFileUploader> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DynamicFileUploaderBloc(initialComponent: widget.component)
            ..add(const InitializeFileUploaderEvent()),
      child: DynamicFileUploaderWidget(component: widget.component),
    );
  }
}

class DynamicFileUploaderWidget extends StatelessWidget {
  final DynamicFormModel component;

  const DynamicFileUploaderWidget({
    super.key,
    required this.component,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<DynamicFormBloc, DynamicFormState>(
      listener: (context, formState) {
        // Listen to main form state changes and update file uploader bloc
        if (formState.page?.components != null) {
          final updatedComponent = formState.page!.components.firstWhere(
            (c) => c.id == component.id,
            orElse: () => component,
          );

          // Check if component changed from external source
          if (updatedComponent.config['value'] != component.config['value'] ||
              updatedComponent.config['disabled'] !=
                  component.config['disabled'] ||
              updatedComponent.config['multiple_files'] !=
                  component.config['multiple_files'] ||
              updatedComponent.config['allowed_extensions'] !=
                  component.config['allowed_extensions']) {
            debugPrint(
              '🔄 [FileUploader] External change detected',
            );

            context.read<DynamicFileUploaderBloc>().add(
              UpdateFileUploaderFromExternalEvent(component: updatedComponent),
            );
          }
        }
      },
      child: BlocConsumer<DynamicFileUploaderBloc, DynamicFileUploaderState>(
        listenWhen: (previous, current) {
          return current is DynamicFileUploaderSuccess;
        },
        buildWhen: (previous, current) {
          // Rebuild when state changes or important fields update
          return previous.formState != current.formState ||
              previous.errorText != current.errorText ||
              (previous is DynamicFileUploaderSuccess &&
                  current is DynamicFileUploaderSuccess &&
                  (previous.currentState != current.currentState ||
                      previous.files != current.files ||
                      previous.progress != current.progress ||
                      previous.isProcessing != current.isProcessing ||
                      previous.isDragging != current.isDragging ||
                      previous.isDisabled != current.isDisabled ||
                      previous.updateTimestamp != current.updateTimestamp));
        },
        listener: (context, state) {
          if (state is DynamicFileUploaderSuccess) {
            // Update main form with current state
            final valueMap = {
              'state': state.currentState,
              'files': state.files,
              'progress': state.progress,
              'is_processing': state.isProcessing,
              'is_dragging': state.isDragging,
              'error_text': state.errorText,
            };

            context.read<DynamicFormBloc>().add(
              UpdateFormFieldEvent(
                componentId: state.component!.id,
                value: valueMap,
              ),
            );
          }
        },
        builder: (context, state) {
          debugPrint(
            '🔵 [FileUploader] Building with state: ${state.runtimeType}',
          );

          if (state is DynamicFileUploaderLoading ||
              state is DynamicFileUploaderInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DynamicFileUploaderError) {
            return Center(
              child: Text(
                'Error: ${state.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is DynamicFileUploaderSuccess) {
            return _buildBody(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, DynamicFileUploaderSuccess state) {
    return Focus(
      focusNode: state.focusNode,
      child: DragTarget<List<XFile>>(
        onWillAcceptWithDetails: state.canAcceptDrop
            ? (details) {
                context.read<DynamicFileUploaderBloc>().add(
                  const UpdateDraggingStateEvent(isDragging: true),
                );
                return true;
              }
            : null,
        onAcceptWithDetails: (details) {
          context.read<DynamicFileUploaderBloc>().add(
            const UpdateDraggingStateEvent(isDragging: false),
          );
          context.read<DynamicFileUploaderBloc>().add(
            FileSelectionEvent(files: details.data),
          );
        },
        onLeave: (_) {
          context.read<DynamicFileUploaderBloc>().add(
            const UpdateDraggingStateEvent(isDragging: false),
          );
        },
        builder: (context, candidateData, rejectedData) {
          return GestureDetector(
            onTap: state.canTap
                ? () {
                    FocusScope.of(context).requestFocus(state.focusNode);
                  }
                : null,
            child: Container(
              key: Key(state.component!.id),
              margin: StyleUtils.parsePadding(state.computedStyle['margin']),
              child: DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  color: StyleUtils.parseColor(
                    state.computedStyle['border_color'],
                  ),
                  strokeWidth:
                      (state.computedStyle['border_width'] as num?)
                          ?.toDouble() ??
                      1,
                  radius: Radius.circular(
                    (state.computedStyle['border_radius'] as num?)
                            ?.toDouble() ??
                        0,
                  ),
                  dashPattern: const [6, 6],
                  padding: const EdgeInsets.all(0),
                ),
                child: Container(
                  width:
                      (state.computedStyle['width'] as num?)?.toDouble() ?? 300,
                  height:
                      (state.computedStyle['height'] as num?)?.toDouble() ??
                      200,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: StyleUtils.parseColor(
                      state.computedStyle['background_color'],
                    ),
                    borderRadius: BorderRadius.circular(
                      (state.computedStyle['border_radius'] as num?)
                              ?.toDouble() ??
                          0,
                    ),
                  ),
                  child: _buildStateContent(context, state),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStateContent(
    BuildContext context,
    DynamicFileUploaderSuccess state,
  ) {
    switch (state.currentState) {
      case 'loading':
        return _buildLoadingWidget(state);
      case 'success':
        return _buildSuccessWidget(context, state);
      case 'error':
        return _buildErrorWidget(context, state);
      default:
        return _buildBaseWidget(context, state);
    }
  }

  Widget _buildLoadingWidget(DynamicFileUploaderSuccess state) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (state.computedStyle['icon'] != null)
            Icon(
              DynamicFileUploaderBloc.mapIconNameToIconData(
                state.computedStyle['icon'],
              ),
              color: StyleUtils.parseColor(state.computedStyle['icon_color']),
              size: 48,
            ),
          const SizedBox(height: 16),
          Text(
            state.files.isNotEmpty
                ? '${state.files.length > 1 ? '${state.files.length} files' : state.files.first} uploading... ${state.progress}%'
                : 'Uploading... ${state.progress}%',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: StyleUtils.parseColor(state.computedStyle['text_color']),
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: state.progress / 100),
        ],
      ),
    );
  }

  Widget _buildSuccessWidget(
    BuildContext context,
    DynamicFileUploaderSuccess state,
  ) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (state.computedStyle['icon'] != null)
            Icon(
              DynamicFileUploaderBloc.mapIconNameToIconData(
                state.computedStyle['icon'],
              ),
              color: StyleUtils.parseColor(state.computedStyle['icon_color']),
              size: 48,
            ),
          const SizedBox(height: 16),
          if (state.files.isNotEmpty)
            ...state.files.asMap().entries.map(
              (entry) => ListTile(
                leading: DynamicFileUploaderBloc.isImageFile(entry.value)
                    ? Image.file(
                        File(entry.value),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.insert_drive_file,
                        color: StyleUtils.parseColor(
                          state.computedStyle['icon_color'],
                        ),
                      ),
                title: Text(entry.value.split('/').last),
                subtitle: FutureBuilder<String>(
                  future: DynamicFileUploaderBloc.getFileSize(entry.value),
                  builder: (context, snapshot) => Text(snapshot.data ?? ''),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    context.read<DynamicFileUploaderBloc>().add(
                      RemoveFileEvent(index: entry.key),
                    );
                  },
                ),
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<DynamicFileUploaderBloc>().add(
                const ResetStateEvent(),
              );
            },
            child: Text(state.computedConfig['button_text'] ?? 'Remove All'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(
    BuildContext context,
    DynamicFileUploaderSuccess state,
  ) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (state.computedStyle['icon'] != null)
            Icon(
              DynamicFileUploaderBloc.mapIconNameToIconData(
                state.computedStyle['icon'],
              ),
              color: StyleUtils.parseColor(state.computedStyle['icon_color']),
              size: 48,
            ),
          const SizedBox(height: 16),
          Text(
            state.errorText ?? 'Error',
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<DynamicFileUploaderBloc>().add(
                const ResetStateEvent(),
              );
            },
            child: Text(state.computedConfig['button_text'] ?? 'Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBaseWidget(
    BuildContext context,
    DynamicFileUploaderSuccess state,
  ) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (state.computedStyle['icon'] != null)
            Icon(
              DynamicFileUploaderBloc.mapIconNameToIconData(
                state.computedStyle['icon'],
              ),
              color: StyleUtils.parseColor(state.computedStyle['icon_color']),
              size: 48,
            ),
          const SizedBox(height: 8),
          Text(
            state.computedConfig['title'] ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: StyleUtils.parseColor(state.computedStyle['text_color']),
            ),
          ),
          if (state.computedConfig['subtitle'] != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                state.computedConfig['subtitle'] ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: StyleUtils.parseColor(
                    state.computedStyle['text_color'],
                  ),
                ),
              ),
            ),
          if (state.computedConfig['button_text'] != null &&
              state.computedConfig['button_text'].isNotEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: state.canBrowse
                  ? () {
                      context.read<DynamicFileUploaderBloc>().add(
                        const BrowseFilesEvent(),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: StyleUtils.parseColor(
                  state.computedStyle['button_background_color'],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    (state.computedStyle['button_border_radius'] as num?)
                            ?.toDouble() ??
                        8,
                  ),
                ),
              ),
              child: Text(
                state.computedConfig['button_text'] ?? 'Browse',
                style: TextStyle(
                  color: StyleUtils.parseColor(
                    state.computedStyle['button_text_color'],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
