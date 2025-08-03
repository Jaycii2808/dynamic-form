import 'package:dynamic_form_bi/core/enums/component_action_enum.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_event.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:flutter/material.dart';

Widget formBuilderCanvas(FormBuilderState state, FormBuilderBloc formBuilderBloc) {
  return Container(
    color: const Color(0xFF000000),
    child: Column(
      children: [
        if (state.pages.length > 1) _buildPageInfoHeader(state),
        Expanded(
          child: state.canvasComponents.isEmpty
              ? _buildEmptyCanvas(formBuilderBloc)
              : _buildCanvasWithComponents(state, formBuilderBloc),
        ),
      ],
    ),
  );
}

Widget _buildPageInfoHeader(FormBuilderState state) {
  final currentPageIndex = state.pages.indexWhere((page) => page.pageId == state.currentPageId);
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
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.blue),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            currentPage.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
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
          color: isDragOver ? Colors.blue.withValues(alpha: 0.1) : const Color(0xFF000000),
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

Widget _buildCanvasWithComponents(FormBuilderState state, FormBuilderBloc formBuilderBloc) {
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
            _buildCanvasItem(state.canvasComponents[index], index, state, formBuilderBloc),
          ],
        );
      }
      return _buildCanvasItem(state.canvasComponents[index], index, state, formBuilderBloc);
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
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildCanvasItem(
    DynamicFormModel component, int index, FormBuilderState state, FormBuilderBloc formBuilderBloc) {
  return DragTarget<DynamicFormModel>(
    onWillAcceptWithDetails: (details) {
      formBuilderBloc.add(StartHoverEvent(targetIndex: index, draggedComponent: details.data));
      return true;
    },
    onAcceptWithDetails: (details) {
      formBuilderBloc.add(InsertComponentEvent(component: details.data, insertIndex: index));
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
                    child: _buildComponentWidget(component, formBuilderBloc),
                  ),
                ),
                _buildComponentActions(index, formBuilderBloc),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildComponentWidget(DynamicFormModel component, FormBuilderBloc formBuilderBloc) {
  return ReusedWidget.buildFormComponent(
    component: component,
    onComponentValueChange: (componentId, value) => formBuilderBloc.add(
      UpdateComponentValueEvent(componentId: componentId, value: value),
    ),
  );
}

Widget _buildComponentActions(int index, FormBuilderBloc formBuilderBloc) {
  return PopupMenuButton<ComponentActionEnum>(
    onSelected: (value) => formBuilderBloc.add(
      HandleComponentActionEvent(action: value, index: index),
    ),
    itemBuilder: (context) => [
      _buildActionMenuItem(ComponentActionEnum.moveUp, Icons.arrow_upward, 'Move Up', Colors.blue),
      _buildActionMenuItem(ComponentActionEnum.moveDown, Icons.arrow_downward, 'Move Down', Colors.blue),
      _buildActionMenuItem(ComponentActionEnum.delete, Icons.delete, 'Delete', Colors.red),
    ],
    child: Container(
      margin: const EdgeInsets.all(8),
      child: const Icon(Icons.more_vert, color: Colors.grey),
    ),
  );
}

PopupMenuItem<ComponentActionEnum> _buildActionMenuItem(
    ComponentActionEnum action, IconData icon, String text, Color color) {
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