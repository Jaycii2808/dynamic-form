import 'package:dynamic_form_bi/core/enums/component_action_enum.dart';
import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_event.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Widget formBuilderCanvas(
  FormBuilderState state,
  FormBuilderBloc formBuilderBloc,
) {
  return BlocBuilder<FormBuilderBloc, FormBuilderState>(
    builder: (context, currentState) => Container(
      color: const Color(0xFF000000),
      child: Column(
        children: [
          if (currentState.pages.length > 1) _buildPageInfoHeader(currentState),
          Expanded(
            child: currentState.canvasComponents.isEmpty
                ? _buildEmptyCanvas(formBuilderBloc)
                : _buildCanvasWithComponents(
                    currentState,
                    formBuilderBloc,
                    context,
                  ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildPageInfoHeader(FormBuilderState state) {
  final currentPageIndex = state.pages.indexWhere(
    (page) => page.pageId == state.currentPageId,
  );
  final currentPage = state.pages[currentPageIndex];
  final componentCount = currentPage.components.length;
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey[900],
      border: Border(bottom: BorderSide(color: Colors.grey[800]!)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
          ),
          child: Text(
            'Page ${currentPageIndex + 1}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            currentPage.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$componentCount component${componentCount != 1 ? 's' : ''}',
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
        ),
      ],
    ),
  );
}

Widget _buildEmptyCanvas(FormBuilderBloc formBuilderBloc) {
  return SingleChildScrollView(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildEmptyCanvasText(),
        const SizedBox(height: 32),
        ..._buildEmptyDropZones(formBuilderBloc),
      ],
    ),
  );
}

Widget _buildEmptyCanvasText() {
  return Text(
    'Drag components from the right panel\nto build your form',
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
  );
}

List<Widget> _buildEmptyDropZones(FormBuilderBloc formBuilderBloc) {
  return List.generate(5, (index) => _buildDropZone(index, formBuilderBloc));
}

Widget _buildDropZone(int index, FormBuilderBloc formBuilderBloc) {
  return DragTarget<DynamicFormModel>(
    builder: (context, candidateData, rejectedData) {
      final isDragOver = candidateData.isNotEmpty;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(
            color: isDragOver ? Colors.blue : Colors.grey[400]!,
            width: isDragOver ? 3 : 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isDragOver
              ? Colors.blue.withValues(alpha: 0.1)
              : const Color(0xFF000000),
        ),
        child: _buildDropZoneContent(isDragOver, formBuilderBloc),
      );
    },
    onWillAcceptWithDetails: (data) => true,
    onAcceptWithDetails: (details) {
      formBuilderBloc.add(AddComponentEvent(details.data));
    },
  );
}

Widget _buildDropZoneContent(bool isDragOver, FormBuilderBloc formBuilderBloc) {
  return GestureDetector(
    onTap: () => formBuilderBloc.add(const ToggleComponentsPanelEvent()),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isDragOver ? Icons.check_circle : Icons.add_circle_outline,
            size: 32,
            color: isDragOver ? Colors.blue : Colors.grey[500],
          ),
          const SizedBox(height: 4),
          Text(
            isDragOver ? 'Drop here!' : 'Drop component here',
            style: TextStyle(
              fontSize: 14,
              color: isDragOver ? Colors.blue : Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildCanvasWithComponents(
  FormBuilderState state,
  FormBuilderBloc formBuilderBloc,
  BuildContext context,
) {
  return ListView.builder(
    itemCount: state.canvasComponents.length + 1,
    itemBuilder: (context, index) {
      if (index == state.canvasComponents.length) {
        return _buildDropZone(index, formBuilderBloc);
      }
      if (state.insertIndicatorIndex == index) {
        return Column(
          children: [
            _buildInsertIndicator(),
            _buildCanvasItem(
              state.canvasComponents[index],
              index,
              state,
              formBuilderBloc,
            ),
          ],
        );
      }
      return _buildCanvasItem(
        state.canvasComponents[index],
        index,
        state,
        formBuilderBloc,
      );
    },
  );
}

Widget _buildInsertIndicator() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    height: 6,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.blue.withValues(alpha: 0.8),
          Colors.blue,
          Colors.blue.withValues(alpha: 0.8),
        ],
      ),
      borderRadius: BorderRadius.circular(3),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withValues(alpha: 0.4),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_circle, color: Colors.white, size: 12),
              SizedBox(width: 4),
              Text(
                'Insert Here',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildCanvasItem(
  DynamicFormModel component,
  int index,
  FormBuilderState state,
  FormBuilderBloc formBuilderBloc,
) {
  return DragTarget<DynamicFormModel>(
    onWillAcceptWithDetails: (details) {
      formBuilderBloc.add(
        StartHoverEvent(targetIndex: index, draggedComponent: details.data),
      );
      return true;
    },
    onAcceptWithDetails: (details) {
      formBuilderBloc.add(
        InsertComponentEvent(component: details.data, insertIndex: index),
      );
    },
    onLeave: (data) {
      formBuilderBloc.add(const EndHoverEvent());
      formBuilderBloc.add(const HideInsertIndicatorEvent());
    },
    builder: (context, candidateData, rejectedData) {
      final isDragOver = candidateData.isNotEmpty;
      final isHovering = state.isHovering && state.hoverTargetIndex == index;
      return Tooltip(
        message: isHovering
            ? 'Hold for 0.5s to insert component here'
            : 'Drag component here to insert',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF000000),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDragOver || isHovering ? Colors.blue : Colors.grey[200]!,
              width: isDragOver || isHovering ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDragOver || isHovering
                    ? Colors.blue.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: isDragOver || isHovering ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: isHovering
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.withValues(alpha: 0.05),
                        Colors.blue.withValues(alpha: 0.02),
                      ],
                    )
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    child: _buildComponentWidget(
                      component,
                      formBuilderBloc,
                      context,
                      state,
                    ),
                  ),
                ),
                _buildComponentActions(index, formBuilderBloc, context),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildComponentWidget(
  DynamicFormModel component,
  FormBuilderBloc formBuilderBloc,
  BuildContext context,
  FormBuilderState state,
) {
  return GestureDetector(
    onTap: () => _showEditLabelDialog(component, formBuilderBloc, context),
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ReusedWidget.buildFormComponent(
        key: ValueKey(
          '${component.id}_${component.config?.label}_${component.config?.placeholder}_${component.config?.value?.toString()}_${state.rebuildTimestamp}',
        ), // Force rebuild when config changes or rebuildTimestamp changes
        component: component,
        onComponentValueChange: (componentId, value) => formBuilderBloc.add(
          UpdateComponentValueEvent(componentId: componentId, value: value),
        ),
        onComponentUpdate: (updatedComponent) {
          // Update the component in the form builder
          formBuilderBloc.add(
            EditComponentConfigEvent(
              componentId: updatedComponent.id,
              label: updatedComponent.config?.label,
              placeholder: updatedComponent.config?.placeholder,
              value: updatedComponent.config?.value, // Keep original type
              errorText: updatedComponent.config?.errorText,
              isRequired: updatedComponent.config?.isRequired,
            ),
          );
        },
      ),
    ),
  );
}

void _showEditLabelDialog(
  DynamicFormModel component,
  FormBuilderBloc formBuilderBloc,
  BuildContext context,
) {
  final TextEditingController labelController = TextEditingController(
    text: component.config?.label ?? component.labelFormBuilder ?? '',
  );

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Edit Label'),
        content: TextField(
          controller: labelController,
          decoration: const InputDecoration(
            labelText: 'Label',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              formBuilderBloc.add(
                EditComponentLabelEvent(
                  componentId: component.id,
                  label: labelController.text,
                ),
              );
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

Widget _buildComponentActions(
  int index,
  FormBuilderBloc formBuilderBloc,
  BuildContext context,
) {
  return PopupMenuButton<ComponentActionEnum>(
    onSelected: (value) {
      if (value == ComponentActionEnum.editConfig) {
        _showEditConfigDialog(
          formBuilderBloc.state.canvasComponents[index],
          formBuilderBloc,
          context,
        );
      } else {
        formBuilderBloc.add(
          HandleComponentActionEvent(action: value, index: index),
        );
      }
    },
    itemBuilder: (context) => [
      _buildActionMenuItem(
        ComponentActionEnum.moveUp,
        Icons.arrow_upward,
        'Move Up',
        Colors.blue,
      ),
      _buildActionMenuItem(
        ComponentActionEnum.moveDown,
        Icons.arrow_downward,
        'Move Down',
        Colors.blue,
      ),
      _buildActionMenuItem(
        ComponentActionEnum.editConfig,
        Icons.edit,
        'Edit Config',
        Colors.green,
      ),
      _buildActionMenuItem(
        ComponentActionEnum.delete,
        Icons.delete,
        'Delete',
        Colors.red,
      ),
    ],
    child: Container(
      margin: const EdgeInsets.all(8),
      child: const Icon(Icons.more_vert, color: Colors.grey),
    ),
  );
}

void _showEditConfigDialog(
  DynamicFormModel component,
  FormBuilderBloc formBuilderBloc,
  BuildContext context,
) {
  final currentConfig = {
    'label': component.config?.label ?? component.labelFormBuilder ?? '',
    'placeholder': component.config?.placeholder ?? '',
    'value': component.config?.value ?? '',
    'errorText': component.config?.errorText ?? '',
    'isRequired': component.config?.isRequired ?? false,
  };

  DialogUtils.showComponentConfigDialog(
    context,
    currentConfig,
  ).then((result) {
    if (result != null) {
      formBuilderBloc.add(
        EditComponentConfigEvent(
          componentId: component.id,
          label: result['label'],
          placeholder: result['placeholder'],
          value: result['value'],
          errorText: result['errorText'],
          isRequired: result['isRequired'],
        ),
      );
    }
  });
}

PopupMenuItem<ComponentActionEnum> _buildActionMenuItem(
  ComponentActionEnum action,
  IconData icon,
  String text,
  Color color,
) {
  return PopupMenuItem(
    value: action,
    child: Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: color)),
      ],
    ),
  );
}
