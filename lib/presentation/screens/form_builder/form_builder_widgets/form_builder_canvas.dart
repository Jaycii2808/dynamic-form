import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_event.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form_builder/dynamic_form_builder_state.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/blocs/dropdown_form_builder_widget/dropdown_form_builder_widget_bloc.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/blocs/short_answer_form_builder_widget/short_answer_form_builder_widget_bloc.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/component_widgets/dropdown_form/dropdown_form_builder_widget.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/component_widgets/short_answer_form/short_answer_form_builder_widget.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
  // Logging removed; use Bloc Observer

  final keyboardBottomInset = MediaQuery.of(context).viewInsets.bottom;

  return ListView.builder(
    padding: EdgeInsets.only(
      bottom: keyboardBottomInset > 0 ? keyboardBottomInset + 20 : 0,
    ),
    itemCount: state.pages.length,
    itemBuilder: (context, pageIndex) {
      final page = state.pages[pageIndex];
      final isCurrentPage = page.pageId == state.currentPageId;

      // Logging removed; use Bloc Observer

      // Get components for this specific page
      final pageComponents = page.components;
      // Logging removed; use Bloc Observer

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

            // Logging removed; use Bloc Observer

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
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    ),
    decoration: BoxDecoration(
      color: isCurrentPage ? Colors.grey[800] : Colors.grey[900],
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: isCurrentPage
            ? Colors.blue.withValues(alpha: 0.3)
            : Colors.grey[700]!,
        width: 1,
      ),
    ),
    child: Row(
      spacing: 8,
      children: [
        // Page indicator "Page X of Y"
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          ),
          child: Text(
            'Page ${pageIndex + 1} of $totalPages',
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.orange,
            ),
          ),
        ),

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
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isCurrentPage
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.grey[800],
                borderRadius: BorderRadius.circular(6),
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
                    const Icon(
                      Icons.edit,
                      color: Colors.green,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Text(
                      page.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isCurrentPage ? Colors.white : Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Copy page button
        GestureDetector(
          onTap: () => _showCopyPageDialog(context, page, formBuilderBloc),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.copy,
                  color: Colors.blue,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        // Remove page button (only show for page 2 and above)
        GestureDetector(
          onTap: () => _showRemovePageDialog(context, page, formBuilderBloc),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
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
                  size: 20,
                ),
              ],
            ),
          ),
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
      // Start hover indicator regardless of source
      formBuilderBloc.add(
        StartHoverEvent(
          targetIndex: componentIndex,
          draggedComponent: details.data,
        ),
      );
      return true;
    },
    onAcceptWithDetails: (details) {
      // If dragging from canvas, move instead of cloning
      final currentState = formBuilderBloc.state;
      final draggingFromPageId = currentState is FormBuilderSuccess
          ? currentState.draggingFromPageId
          : null;
      final draggingFromIndex = currentState is FormBuilderSuccess
          ? currentState.draggingFromIndex
          : null;

      if (draggingFromPageId != null && draggingFromIndex != null) {
        formBuilderBloc.add(
          DropCanvasComponentEvent(
            targetPageId: pageId,
            insertIndex: componentIndex,
          ),
        );
      } else {
        // Insert a new copy from palette
        formBuilderBloc.add(SwitchPageEvent(pageId));
        formBuilderBloc.add(
          InsertComponentEvent(
            component: details.data,
            insertIndex: componentIndex,
          ),
        );
      }
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
          LongPressDraggable<DynamicFormModel>(
            data: component,
            onDragStarted: () {
              formBuilderBloc.add(
                StartCanvasComponentDragEvent(
                  pageId: pageId,
                  index: componentIndex,
                  component: component,
                ),
              );
            },
            onDragEnd: (_) {
              formBuilderBloc.add(const EndCanvasComponentDragEvent());
            },
            feedback: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    Icon(
                      _getComponentIcon(component.type),
                      color: Colors.white,
                      size: 16,
                    ),
                    Flexible(
                      child: Text(
                        component.config?.label?.isNotEmpty == true
                            ? component.config!.label!
                            : component.labelFormBuilder ??
                                  _getComponentTypeName(component.type),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF000000),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (state.highlightedComponentId == component.id)
                      ? Colors.red
                      : (isDragOver || isHovering
                            ? Colors.blue
                            : Colors.grey[200]!),
                  width: (state.highlightedComponentId == component.id)
                      ? 3
                      : (isDragOver || isHovering ? 2 : 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (state.highlightedComponentId == component.id)
                        ? Colors.red.withValues(alpha: 0.2)
                        : (isDragOver || isHovering
                              ? Colors.blue.withValues(alpha: 0.2)
                              : Colors.black.withValues(alpha: 0.05)),
                    blurRadius: (state.highlightedComponentId == component.id)
                        ? 10
                        : (isDragOver || isHovering ? 8 : 4),
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: (state.highlightedComponentId == component.id)
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.red.withValues(alpha: 0.06),
                            Colors.red.withValues(alpha: 0.03),
                          ],
                        )
                      : (isHovering
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.blue.withValues(alpha: 0.05),
                                  Colors.blue.withValues(alpha: 0.02),
                                ],
                              )
                            : null),
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
                          pageIndex, // Pass the page index
                          componentIndex, // Pass the component index for unique keys
                        ),
                      ),
                    ),
                  ],
                ),
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
      // Logging removed; use Bloc Observer
      // If pageId is provided, switch to that page and add component
      final currentState = formBuilderBloc.state;
      final draggingFromPageId = currentState is FormBuilderSuccess
          ? currentState.draggingFromPageId
          : null;
      final draggingFromIndex = currentState is FormBuilderSuccess
          ? currentState.draggingFromIndex
          : null;

      if (draggingFromPageId != null &&
          draggingFromIndex != null &&
          pageId != null) {
        formBuilderBloc.add(
          DropCanvasComponentEvent(
            targetPageId: pageId,
            insertIndex: 0,
          ),
        );
      } else {
        if (pageId != null) {
          formBuilderBloc.add(SwitchPageEvent(pageId));
        }
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
      // Logging removed; use Bloc Observer
      // If pageId is provided, switch to that page and insert component at specific index
      final currentState = formBuilderBloc.state;
      final draggingFromPageId = currentState is FormBuilderSuccess
          ? currentState.draggingFromPageId
          : null;
      final draggingFromIndex = currentState is FormBuilderSuccess
          ? currentState.draggingFromIndex
          : null;

      if (draggingFromPageId != null && draggingFromIndex != null) {
        formBuilderBloc.add(
          DropCanvasComponentEvent(
            targetPageId: pageId,
            insertIndex: componentIndex,
          ),
        );
      } else {
        formBuilderBloc.add(SwitchPageEvent(pageId));
        formBuilderBloc.add(
          InsertComponentEvent(
            component: details.data,
            insertIndex: componentIndex,
          ),
        );
      }
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
              fontWeight: FontWeight.w600,
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
  int pageIndex, // Page index
  int componentIndex, // Component index within the page
) {
  // Check if component is dropdown type
  if (component.type == FormTypeEnum.dropdownFormType) {
    // Get available pages for navigation options - use current state
    final availablePages = state.pages.map((page) => page.title).toList();

    // Use the page index where this component is being built
    final currentPageIndex = pageIndex;

    // Logging removed; use Bloc Observer

    // Use stable key that doesn't change on every rebuild
    final stableKey = ValueKey('dropdown_${component.id}_$pageIndex');

    return BlocProvider(
      key: stableKey, // Add stable key to BlocProvider
      create: (context) => DropdownFormBuilderWidgetBloc(),
      child: DropdownFormBuilderWidget(
        key: stableKey, // Use same stable key
        component: component,
        availablePages: availablePages, // Pass current available pages
        currentPageId: state.currentPageId, // Pass current page ID
        currentPageIndex:
            currentPageIndex, // Pass the page index where this component is being built
        onComponentUpdate: (updatedComponent) {
          // Prevent update loop by checking if component actually changed
          if (_hasComponentConfigChanged(component, updatedComponent)) {
            // Logging removed; use Bloc Observer
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
          }
        },
        onDuplicate: () {
          // Handle duplicate for dropdown
          final duplicatedComponent = component.copyWith(
            id: '${component.id}_${DateTime.now().millisecondsSinceEpoch}',
          );
          formBuilderBloc.add(AddComponentEvent(duplicatedComponent));
        },
        onDelete: () {
          formBuilderBloc.add(RemoveComponentEvent(componentIndex));
        },
      ),
    );
  }

  // Check if component is short answer type
  if (component.type == FormTypeEnum.shortAnswerFormType) {
    // Use stable key that doesn't change on every rebuild
    final stableKey = ValueKey('short_answer_${component.id}_$pageIndex');

    return BlocProvider(
      key: stableKey, // Add stable key to BlocProvider
      create: (context) => ShortAnswerFormBuilderWidgetBloc(),
      child: ShortAnswerFormBuilderWidget(
        key: stableKey, // Use same stable key
        component: component,
        availablePages: state.pages.map((page) => page.title).toList(),
        currentPageIndex: pageIndex,
        onComponentUpdate: (updatedComponent) {
          // Prevent update loop by checking if component actually changed
          if (_hasComponentConfigChanged(component, updatedComponent)) {
            // Logging removed; use Bloc Observer
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
              ),
            );
          }
        },
        onDuplicate: () {
          // Handle duplicate for short answer
          final duplicatedComponent = component.copyWith(
            id: '${component.id}_${DateTime.now().millisecondsSinceEpoch}',
          );
          formBuilderBloc.add(AddComponentEvent(duplicatedComponent));
        },
        onDelete: () {
          formBuilderBloc.add(RemoveComponentEvent(componentIndex));
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
        key: ValueKey('component_${component.id}_$pageIndex'), // Stable key
        component: component,
        onComponentValueChange: (componentId, value) => formBuilderBloc.add(
          UpdateComponentValueEvent(componentId: componentId, value: value),
        ),
        onComponentUpdate: (updatedComponent) {
          // Prevent update loop by checking if component actually changed
          if (_hasComponentConfigChanged(component, updatedComponent)) {
            // Logging removed; use Bloc Observer
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
          }
        },
        isSharedForm: false,
        currentPageId: state.currentPageId,
      ),
    ),
  );
}

// Add helper function to check if component config actually changed
bool _hasComponentConfigChanged(
  DynamicFormModel oldComponent,
  DynamicFormModel newComponent,
) {
  final oldConfig = oldComponent.config;
  final newConfig = newComponent.config;

  if (oldConfig == null && newConfig == null) return false;
  if (oldConfig == null || newConfig == null) return true;

  return oldConfig.label != newConfig.label ||
      oldConfig.placeholder != newConfig.placeholder ||
      oldConfig.description != newConfig.description ||
      oldConfig.value != newConfig.value ||
      oldConfig.errorText != newConfig.errorText ||
      oldConfig.isRequired != newConfig.isRequired ||
      _hasOptionsChanged(oldConfig.options, newConfig.options);
}

// Helper function to check if options changed
bool _hasOptionsChanged(List<dynamic>? oldOptions, List<dynamic>? newOptions) {
  if (oldOptions == null && newOptions == null) return false;
  if (oldOptions == null || newOptions == null) return true;
  if (oldOptions.length != newOptions.length) return true;

  for (int i = 0; i < oldOptions.length; i++) {
    final oldOption = oldOptions[i];
    final newOption = newOptions[i];

    if (oldOption is Map && newOption is Map) {
      if (oldOption['label'] != newOption['label'] ||
          oldOption['value'] != newOption['value'] ||
          oldOption['action'] != newOption['action']) {
        return true;
      }
    }
  }

  return false;
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
          textInputAction: TextInputAction.done,
          onSubmitted: (value) {
            formBuilderBloc.add(
              EditComponentLabelEvent(
                componentId: component.id,
                label: value,
              ),
            );
            dialogContext.pop();
          },
          onEditingComplete: () {
            formBuilderBloc.add(
              EditComponentLabelEvent(
                componentId: component.id,
                label: labelController.text,
              ),
            );
            dialogContext.pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
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
              dialogContext.pop();
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
            onPressed: () => dialogContext.pop(),
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
              dialogContext.pop();
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
            onPressed: () => dialogContext.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              formBuilderBloc.add(RemovePageEvent(page.pageId));
              dialogContext.pop();
            },
            child: const Text('Remove'),
          ),
        ],
      );
    },
  );
}

void _showCopyPageDialog(
  BuildContext context,
  dynamic page,
  FormBuilderBloc formBuilderBloc,
) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Copy Page'),
        content: Text(
          'Are you sure you want to copy the page "${page.title}" with all its components?',
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              formBuilderBloc.add(CopyPageEvent(page.pageId));
              dialogContext.pop();
            },
            child: const Text('Copy'),
          ),
        ],
      );
    },
  );
}

/// Helper function to get display name for component type
String _getComponentTypeName(FormTypeEnum type) {
  switch (type) {
    case FormTypeEnum.buttonFormType:
      return 'Button';
    case FormTypeEnum.dropdownFormType:
      return 'Dropdown';
    case FormTypeEnum.shortAnswerFormType:
      return 'Short Answer';
    case FormTypeEnum.unknown:
      return 'Component';
  }
}

/// Helper function to get icon for component type
IconData _getComponentIcon(FormTypeEnum type) {
  switch (type) {
    case FormTypeEnum.buttonFormType:
      return Icons.smart_button;
    case FormTypeEnum.dropdownFormType:
      return Icons.arrow_drop_down_circle;
    case FormTypeEnum.shortAnswerFormType:
      return Icons.short_text;
    case FormTypeEnum.unknown:
      return Icons.widgets;
  }
}
