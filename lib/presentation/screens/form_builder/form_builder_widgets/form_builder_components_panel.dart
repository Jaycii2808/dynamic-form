import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_event.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_state.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/form_builder_widgets/form_builder_component_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Widget formBuilderComponentsPanel(
  FormBuilderState state,
  FormBuilderBloc formBuilderBloc,
) {
  return BlocBuilder<FormBuilderBloc, FormBuilderState>(
    builder: (context, currentState) => AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      right: 16,
      top: 0,
      width: 250,
      height: 600,
      // Fixed height for floating window
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF000000),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: Colors.blue.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            _buildComponentsPanelHeader(formBuilderBloc),
            Expanded(
              child: currentState.availableComponents.isEmpty
                  ? _buildEmptyComponentsList()
                  : _buildComponentsList(currentState, formBuilderBloc),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildComponentsPanelHeader(FormBuilderBloc formBuilderBloc) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF000000),
      border: Border(
        bottom: BorderSide(color: Colors.grey[200]!),
        left: BorderSide(color: Colors.blue.withValues(alpha: 0.3)),
      ),
    ),
    child: Container(
      margin: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.widgets, color: Colors.blue, size: 16),
          const SizedBox(width: 4),
          const Flexible(
            child: Text(
              'Form Components',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () =>
                formBuilderBloc.add(const ToggleComponentsPanelEvent()),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.close, color: Colors.red, size: 16),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildEmptyComponentsList() {
  return const Center(
    child: Text(
      'No components available',
      style: TextStyle(color: Colors.grey),
    ),
  );
}

Widget _buildComponentsList(
  FormBuilderState state,
  FormBuilderBloc formBuilderBloc,
) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(
        color: Colors.grey,
        width: 3,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    child: ListView.builder(
      padding: const EdgeInsets.only(bottom: 32), // Add bottom padding
      itemCount: state.availableComponents.length,
      itemBuilder: (context, index) {
        return _buildDraggableComponent(
          state.availableComponents[index],
          formBuilderBloc,
        );
      },
    ),
  );
}

Widget _buildDraggableComponent(
  DynamicFormModel component,
  FormBuilderBloc formBuilderBloc,
) {
  return LongPressDraggable<DynamicFormModel>(
    data: component,
    onDragStarted: () => formBuilderBloc.add(StartDragEvent(component)),
    onDragEnd: (details) => formBuilderBloc.add(EndDragEvent(component)),
    feedback: _buildDragFeedback(component),
    childWhenDragging: _buildComponentListItemDragging(component),
    child: _buildComponentListItem(component, formBuilderBloc),
  );
}

Widget _buildComponentListItem(
  DynamicFormModel component,
  FormBuilderBloc formBuilderBloc,
) {
  return GestureDetector(
    onTap: () => formBuilderBloc.add(AddComponentEvent(component)),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.4),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF000000).withValues(alpha: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildComponentIcon(),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    component.labelFormBuilder ?? "Component",
                    style: const TextStyle(
                      fontSize: 6,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                _buildDragHandle(),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: buildComponentPreview(component),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildComponentListItemDragging(DynamicFormModel component) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey[300]!),
      borderRadius: BorderRadius.circular(8),
      color: const Color(0xFF000000),
    ),
    child: Container(
      margin: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildComponentIcon(),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  component.labelFormBuilder ?? "Component",
                  style: const TextStyle(
                    fontSize: 6,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              _buildDragHandle(),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: buildComponentPreview(component),
          ),
        ],
      ),
    ),
  );
}

Widget _buildComponentIcon() {
  return const Icon(Icons.widgets, color: Colors.blue, size: 10);
}

Widget _buildDragHandle() {
  return Icon(Icons.drag_handle, color: Colors.grey[400], size: 16);
}

Widget _buildDragFeedback(DynamicFormModel component) {
  return Material(
    elevation: 8,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      width: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: Container(
        margin: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.widgets, color: Colors.blue, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    component.labelFormBuilder ?? "Component",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: buildComponentPreview(component),
            ),
          ],
        ),
      ),
    ),
  );
}
