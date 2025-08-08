import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_event.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_state.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/blocs/dropdown_form_builder_widget/dropdown_form_builder_widget_bloc.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/component_widgets/dropdown_form/dropdown_form_builder_widget.dart'; // Add import
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart'; // Add import
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Widget formBuilderCanvas(
  FormBuilderState state,
  FormBuilderBloc formBuilderBloc,
) {
  return BlocBuilder<FormBuilderBloc, FormBuilderState>(
    builder: (context, currentState) => Container(
      color: const Color(0xFF000000),
      child: currentState.pages.isEmpty
          ? _buildEmptyCanvas(formBuilderBloc)
          : _buildAllPagesCanvas(currentState, formBuilderBloc, context),
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

Widget _buildAllPagesCanvas(
  FormBuilderState state,
  FormBuilderBloc formBuilderBloc,
  BuildContext context,
) {
  debugPrint(
    '🔄 [FormBuilderCanvas] Building all pages canvas with ${state.pages.length} pages',
  );
  debugPrint('🔄 [FormBuilderCanvas] Current page ID: ${state.currentPageId}');

  return ListView.builder(
    itemCount: state.pages.length,
    itemBuilder: (context, pageIndex) {
      final page = state.pages[pageIndex];
      final isCurrentPage = page.pageId == state.currentPageId;

      debugPrint(
        '🔄 [FormBuilderCanvas] Building page $pageIndex: ${page.title} (isCurrentPage: $isCurrentPage)',
      );

      // Get components for this specific page
      final pageComponents = page.components;
      debugPrint(
        '🔄 [FormBuilderCanvas] Page $pageIndex has ${pageComponents.length} components',
      );

      return Column(
        children: [
          // Page header
          _buildPageHeader(
            page,
            pageIndex,
            state.pages.length,
            pageComponents.length,
            isCurrentPage,
            context,
            formBuilderBloc,
          ),

          // Components and drop zones
          ...pageComponents.asMap().entries.map((entry) {
            final componentIndex = entry.key;
            final component = entry.value;

            debugPrint(
              '🔄 [FormBuilderCanvas] Building component $componentIndex: ${component.type}',
            );

            return _buildComponentWithDropZone(
              component,
              componentIndex,
              state,
              formBuilderBloc,
              context,
              pageIndex,
              page.pageId,
            );
          }),

          // Drop zone after all components (if page has components)
          if (pageComponents.isNotEmpty)
            _buildDropZoneBetweenComponents(
              pageIndex,
              pageComponents.length,
              formBuilderBloc,
              page.pageId,
            ),

          // Empty drop zone if no components
          if (pageComponents.isEmpty)
            _buildDropZone(0, formBuilderBloc, page.pageId),
        ],
      );
    },
  );
}

Widget _buildPageHeader(
  dynamic page,
  int pageIndex,
  int totalPages,
  int componentCount,
  bool isCurrentPage,
  BuildContext context,
  FormBuilderBloc formBuilderBloc,
) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isCurrentPage ? Colors.grey[800] : Colors.grey[900],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isCurrentPage
            ? Colors.blue.withValues(alpha: 0.3)
            : Colors.grey[700]!,
        width: 1,
      ),
    ),
    child: Column(
      children: [
        // Page indicator "Page X of Y" - centered at top
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          ),
          child: Text(
            'Page ${pageIndex + 1} of $totalPages',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.orange,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Main content row
        Row(
          children: [
            // Editable Page title
            Expanded(
              child: GestureDetector(
                onTap: () => _showEditPageTitleDialog(
                  context,
                  page,
                  pageIndex,
                  formBuilderBloc,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrentPage
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCurrentPage
                          ? Colors.green.withValues(alpha: 0.3)
                          : Colors.grey[700]!,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isCurrentPage) ...[
                        const Icon(Icons.edit, color: Colors.green, size: 14),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          page.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isCurrentPage
                                ? Colors.white
                                : Colors.white70,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Component count for this specific page
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isCurrentPage
                    ? Colors.blue.withValues(alpha: 0.1)
                    : Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$componentCount component${componentCount != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: isCurrentPage ? Colors.blue : Colors.grey[400],
                ),
              ),
            ),

            // Remove page button (only show for page 2 and above)
            if (pageIndex > 0) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () =>
                    _showRemovePageDialog(context, page, formBuilderBloc),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Remove',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    ),
  );
}

Widget _buildComponentWithDropZone(
  DynamicFormModel component,
  int componentIndex,
  FormBuilderState state,
  FormBuilderBloc formBuilderBloc,
  BuildContext context,
  int pageIndex,
  String pageId,
) {
  return DragTarget<DynamicFormModel>(
    onWillAcceptWithDetails: (details) {
      formBuilderBloc.add(
        StartHoverEvent(
          targetIndex: componentIndex,
          draggedComponent: details.data,
        ),
      );
      return true;
    },
    onAcceptWithDetails: (details) {
      // Switch to target page and insert component
      formBuilderBloc.add(SwitchPageEvent(pageId));
      formBuilderBloc.add(
        InsertComponentEvent(
          component: details.data,
          insertIndex: componentIndex,
        ),
      );
    },
    onLeave: (data) {
      formBuilderBloc.add(const EndHoverEvent());
      formBuilderBloc.add(const HideInsertIndicatorEvent());
    },
    builder: (context, candidateData, rejectedData) {
      final isDragOver = candidateData.isNotEmpty;
      final isHovering =
          state.isHovering && state.hoverTargetIndex == componentIndex;

      return Column(
        children: [
          // Insert indicator if needed
          if (state.insertIndicatorIndex == componentIndex &&
              state.currentPageId == pageId)
            _buildInsertIndicator(),

          // Component
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF000000),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDragOver || isHovering
                    ? Colors.blue
                    : Colors.grey[200]!,
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
                  // Component content
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
                  // _buildComponentActions(
                  //   componentIndex,
                  //   formBuilderBloc,
                  //   context,
                  // ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildDropZone(
  int index,
  FormBuilderBloc formBuilderBloc, [
  String? pageId,
]) {
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
        child: _buildDropZoneContent(isDragOver, formBuilderBloc, pageId, 0),
      );
    },
    onWillAcceptWithDetails: (data) => true,
    onAcceptWithDetails: (details) {
      debugPrint(
        '🔄 [FormBuilderCanvas] Dropping component in empty drop zone',
      );
      // If pageId is provided, switch to that page and add component
      if (pageId != null) {
        formBuilderBloc.add(SwitchPageEvent(pageId));
        formBuilderBloc.add(AddComponentEvent(details.data));
      } else {
        formBuilderBloc.add(AddComponentEvent(details.data));
      }
    },
  );
}

Widget _buildDropZoneBetweenComponents(
  int pageIndex,
  int componentIndex,
  FormBuilderBloc formBuilderBloc,
  String pageId,
) {
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
        child: _buildDropZoneContent(
          isDragOver,
          formBuilderBloc,
          pageId,
          componentIndex,
        ),
      );
    },
    onWillAcceptWithDetails: (data) => true,
    onAcceptWithDetails: (details) {
      debugPrint(
        '🔄 [FormBuilderCanvas] Dropping component at index: $componentIndex',
      );
      // If pageId is provided, switch to that page and insert component at specific index
      formBuilderBloc.add(SwitchPageEvent(pageId));
      formBuilderBloc.add(
        InsertComponentEvent(
          component: details.data,
          insertIndex: componentIndex,
        ),
      );
    },
  );
}

Widget _buildDropZoneContent(
  bool isDragOver,
  FormBuilderBloc formBuilderBloc, [
  String? pageId,
  int? componentIndex,
]) {
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

Widget _buildComponentWidget(
  DynamicFormModel component,
  FormBuilderBloc formBuilderBloc,
  BuildContext context,
  FormBuilderState state,
) {
  // Check if component is dropdown type
  if (component.type == FormTypeEnum.dropdownFormType) {
    // Get available pages for navigation options - use current state
    final availablePages = state.pages.map((page) => page.title).toList();

    debugPrint(
      '🔍 [FormBuilderCanvas] Building dropdown with available pages: $availablePages',
    );

    return BlocProvider(
      create: (context) => DropdownFormBuilderWidgetBloc(),
      child: DropdownFormBuilderWidget(
        key: ValueKey(
          '${component.id}_${availablePages.join('_')}',
        ), // Force rebuild when pages change
        component: component,
        availablePages: availablePages, // Pass current available pages
        onComponentUpdate: (updatedComponent) {
          debugPrint(
            '🔍 [FormBuilderCanvas] Dropdown onComponentUpdate called',
          );
          debugPrint(
            '🔍 [FormBuilderCanvas] Updated component options: ${updatedComponent.config?.options?.map((o) => '${o.label}(${o.action}->${o.targetSection})').toList()}',
          );
          // Update the component in the form builder
          formBuilderBloc.add(
            EditComponentConfigEvent(
              componentId: updatedComponent.id,
              label: updatedComponent.config?.label,
              placeholder: updatedComponent.config?.placeholder,
              description:
                  updatedComponent.config?.description, // Add description
              value: updatedComponent.config?.value,
              errorText: updatedComponent.config?.errorText,
              isRequired: updatedComponent.config?.isRequired,
              options: updatedComponent.config?.options, // Add options
            ),
          );
        },
        onDuplicate: () {
          // Handle duplicate for dropdown
          final duplicatedComponent = component.copyWith(
            id: '${component.id}_${DateTime.now().millisecondsSinceEpoch}',
          );
          formBuilderBloc.add(AddComponentEvent(duplicatedComponent));
        },
        onDelete: () {
          // Handle delete for dropdown - find component in current page
          final currentPage = state.pages.firstWhere(
            (page) => page.pageId == state.currentPageId,
          );
          final index = currentPage.components.indexWhere(
            (c) => c.id == component.id,
          );
          if (index != -1) {
            formBuilderBloc.add(RemoveComponentEvent(index));
          }
        },
      ),
    );
  }

  // Default component widget for other types
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
          debugPrint(
            '🔍 [FormBuilderCanvas] onComponentUpdate called with description: ${updatedComponent.config?.description}',
          );
          debugPrint(
            '🔍 [FormBuilderCanvas] Component config: ${updatedComponent.config}',
          );
          // Update the component in the form builder
          formBuilderBloc.add(
            EditComponentConfigEvent(
              componentId: updatedComponent.id,
              label: updatedComponent.config?.label,
              placeholder: updatedComponent.config?.placeholder,
              description:
                  updatedComponent.config?.description, // Add description
              value: updatedComponent.config?.value,
              // Keep original type
              errorText: updatedComponent.config?.errorText,
              isRequired: updatedComponent.config?.isRequired,
            ),
          );
        },
        isSharedForm: false,
        currentPageId: state.currentPageId,
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

void _showEditPageTitleDialog(
  BuildContext context,
  dynamic page,
  int pageIndex,
  FormBuilderBloc formBuilderBloc,
) {
  final TextEditingController titleController = TextEditingController(
    text: page.title,
  );

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Edit Page Title'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Page Title',
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
              final newTitle = titleController.text.trim();
              if (newTitle.isNotEmpty) {
                formBuilderBloc.add(
                  UpdatePageTitleEvent(
                    pageId: page.pageId,
                    title: newTitle,
                  ),
                );
              }
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

void _showRemovePageDialog(
  BuildContext context,
  dynamic page,
  FormBuilderBloc formBuilderBloc,
) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Remove Page'),
        content: Text(
          'Are you sure you want to remove the page "${page.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              formBuilderBloc.add(RemovePageEvent(page.pageId));
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Remove'),
          ),
        ],
      );
    },
  );
}
