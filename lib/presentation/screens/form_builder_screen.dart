import 'package:dynamic_form_bi/core/enums/component_action_enum.dart';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form_builder/dynamic_form_builder_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form_builder/dynamic_form_builder_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form_builder/dynamic_form_builder_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FormBuilderScreen extends StatefulWidget {
  const FormBuilderScreen({super.key});

  @override
  State<FormBuilderScreen> createState() => _FormBuilderScreenState();
}

class _FormBuilderScreenState extends State<FormBuilderScreen> {
  late FormBuilderBloc formBuilderBloc;

  @override
  void initState() {
    super.initState();
    formBuilderBloc = context.read<FormBuilderBloc>();
    formBuilderBloc.add(const LoadComponentsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: const Color(0xFF000000),
      floatingActionButton: _buildFloatingActionButton(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return BlocConsumer<FormBuilderBloc, FormBuilderState>(
      listener: (context, state) {
        if (state is FormBuilderError) {
          DialogUtils.showErrorDialog(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        if (state is FormBuilderLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        //error and success
        if (state is FormBuilderSuccess) {
          return _buildMainContent(state);
        }
        return const Text('Error');
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return BlocBuilder<FormBuilderBloc, FormBuilderState>(
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            FloatingActionButton(
              onPressed: () {
                formBuilderBloc.add(
                  const ToggleComponentsPanelEvent(),
                );
              },
              backgroundColor: Colors.blue.shade100,
              foregroundColor: Colors.blue,
              child: Icon(
                state.showComponentsPanel ? Icons.hide_source : Icons.widgets,
              ),
            ),
            //implement show list button
            FloatingActionButton(
              onPressed: () {
                formBuilderBloc.add(const LoadButtonComponentsEvent());
                formBuilderBloc.add(const ToggleButtonComponentsPanelEvent());
              },
              backgroundColor: Colors.blue.shade100,
              foregroundColor: Colors.blue,
              child: const Icon(
                Icons.radio_button_unchecked_sharp,
              ),
            ),
          ],
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Form Builder'),
      backgroundColor: const Color(0xFF000000),
      foregroundColor: Colors.white,
      elevation: 1,
    );
  }

  Widget _buildMainContent(FormBuilderState state) {
    return Stack(
      children: [
        // Main form canvas - takes full width
        _buildFormCanvas(state),
        // Floating components panel
        if (state.showComponentsPanel) _buildFloatingComponentsPanel(state),
        // Floating button components panel
        if (state.showButtonComponentsPanel)
          _buildFloatingButtonComponentsPanel(state),
      ],
    );
  }

  Widget _buildFloatingComponentsPanel(FormBuilderState state) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      right: 0,
      top: 0,
      bottom: 0,
      width: 300,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF000000),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(-2, 0),
            ),
          ],
          border: Border(
            left: BorderSide(
              color: Colors.blue.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            _buildComponentsPanelHeader(),
            Expanded(
              child: state.availableComponents.isEmpty
                  ? _buildEmptyComponentsList()
                  : _buildComponentsList(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingButtonComponentsPanel(FormBuilderState state) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      right: state.showComponentsPanel ? 300 : 0,
      top: 0,
      bottom: 0,
      width: 300,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF000000),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(-2, 0),
            ),
          ],
          border: Border(
            left: BorderSide(
              color: Colors.green.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            _buildButtonComponentsPanelHeader(),
            Expanded(
              child: state.availableButtonComponents.isEmpty
                  ? _buildEmptyButtonComponentsList()
                  : _buildButtonComponentsList(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCanvas(FormBuilderState state) {
    return Container(
      color: const Color(0xFF000000),
      child: Column(
        children: [
          _buildCanvasHeader(state),
          Expanded(
            child: state.canvasComponents.isEmpty
                ? _buildEmptyCanvas()
                : _buildCanvasWithComponents(state),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvasHeader(FormBuilderState state) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF000000),
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.dashboard_customize, color: Colors.blue),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Form Canvas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const Spacer(),
            if (state.canvasComponents.isNotEmpty) _buildClearCanvasButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildClearCanvasButton() {
    return GestureDetector(
      onTap: () => formBuilderBloc.add(const ClearCanvasEvent()),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: const Icon(
          Icons.cleaning_services_rounded,
          color: Colors.red,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildEmptyCanvas() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildEmptyCanvasText(),
        const SizedBox(height: 32),
        ..._buildEmptyDropZones(),
      ],
    );
  }

  Widget _buildEmptyCanvasText() {
    return Text(
      'Drag components from the right panel\nto build your form',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[600],
        height: 1.5,
      ),
    );
  }

  List<Widget> _buildEmptyDropZones() {
    return List.generate(5, (index) => _buildDropZone(index));
  }

  Widget _buildDropZone(int index) {
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
          child: _buildDropZoneContent(isDragOver),
        );
      },
      onWillAcceptWithDetails: (data) => true,
      onAcceptWithDetails: (details) =>
          formBuilderBloc.add(AddComponentEvent(details.data)),
    );
  }

  Widget _buildDropZoneContent(bool isDragOver) {
    return GestureDetector(
      onTap: () {
        formBuilderBloc.add(
          const ToggleComponentsPanelEvent(),
        );
      },
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

  Widget _buildCanvasWithComponents(FormBuilderState state) {
    return ListView.builder(
      itemCount: state.canvasComponents.length + 1, // +1 for drop zone at end
      itemBuilder: (context, index) {
        if (index == state.canvasComponents.length) {
          return _buildDropZone(index);
        }
        return _buildCanvasItem(state.canvasComponents[index], index);
      },
    );
  }

  Widget _buildCanvasItem(DynamicFormModel component, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              child: _buildComponentWidget(component),
            ),
          ),
          _buildComponentActions(index),
        ],
      ),
    );
  }

  Widget _buildComponentWidget(DynamicFormModel component) {
    return ReusedWidget.buildFormComponent(
      component: component,
      onComponentValueChange: (componentId, value) => formBuilderBloc.add(
        UpdateComponentValueEvent(
          componentId: componentId,
          value: value,
        ),
      ),
    );
  }

  Widget _buildComponentActions(int index) {
    return PopupMenuButton<ComponentActionEnum>(
      onSelected: (value) => formBuilderBloc.add(
        HandleComponentActionEvent(
          action: value,
          index: index,
        ),
      ),
      itemBuilder: (context) => _buildActionMenuItems(),
      child: Container(
        margin: const EdgeInsets.all(8),
        child: const Icon(Icons.more_vert, color: Colors.grey),
      ),
    );
  }

  List<PopupMenuEntry<ComponentActionEnum>> _buildActionMenuItems() {
    return [
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
        ComponentActionEnum.delete,
        Icons.delete,
        'Delete',
        Colors.red,
      ),
    ];
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

  Widget _buildComponentsPanelHeader() {
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
              onTap: () => formBuilderBloc.add(
                const ToggleComponentsPanelEvent(),
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.red,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonComponentsPanelHeader() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
          left: BorderSide(color: Colors.green.withValues(alpha: 0.3)),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.widgets, color: Colors.green, size: 16),
            const SizedBox(width: 4),
            const Flexible(
              child: Text(
                'Button Components',
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
              onTap: () => formBuilderBloc.add(
                const ToggleButtonComponentsPanelEvent(),
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.red,
                  size: 16,
                ),
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

  Widget _buildEmptyButtonComponentsList() {
    return const Center(
      child: Text(
        'No button components available',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildComponentsList(FormBuilderState state) {
    return ListView.builder(
      itemCount: state.availableComponents.length,
      itemBuilder: (context, index) {
        return _buildDraggableComponent(state.availableComponents[index]);
      },
    );
  }

  Widget _buildButtonComponentsList(FormBuilderState state) {
    return ListView.builder(
      itemCount: state.availableButtonComponents.length,
      itemBuilder: (context, index) {
        return _buildDraggableButtonComponent(
          state.availableButtonComponents[index],
        );
      },
    );
  }

  Widget _buildDraggableComponent(DynamicFormModel component) {
    return LongPressDraggable<DynamicFormModel>(
      data: component,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: () => formBuilderBloc.add(StartDragEvent(component)),
      onDragEnd: (details) => formBuilderBloc.add(EndDragEvent(component)),
      feedback: _buildDragFeedback(component),
      childWhenDragging: _buildComponentListItemDragging(component),
      child: _buildComponentListItem(component),
    );
  }

  Widget _buildDraggableButtonComponent(DynamicFormModel component) {
    return LongPressDraggable<DynamicFormModel>(
      data: component,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: () => formBuilderBloc.add(StartDragEvent(component)),
      onDragEnd: (details) => formBuilderBloc.add(EndDragEvent(component)),
      feedback: _buildDragFeedback(component),
      childWhenDragging: _buildComponentListItemDragging(component),
      child: _buildComponentListItem(component),
    );
  }

  Widget _buildComponentListItem(DynamicFormModel component) {
    return GestureDetector(
      onTap: () => formBuilderBloc.add(AddComponentEvent(component)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF000000).withValues(alpha: 0.8),
        ),
        child: Container(
          margin: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Component header with icon and title
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
              // Component preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: _buildComponentPreview(component),
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
            // Component header with icon and title
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
            // Component preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: _buildComponentPreview(component),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentIcon() {
    return const Icon(
      Icons.widgets,
      color: Colors.blue,
      size: 10,
    );
  }

  Widget _buildDragHandle() {
    return Icon(
      Icons.drag_handle,
      color: Colors.grey[400],
      size: 16,
    );
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
              // Component header
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
              // Component preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: _buildComponentPreview(component),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComponentPreview(DynamicFormModel component) {
    switch (component.type) {
      case FormTypeEnum.textFieldFormType:
        return _buildTextFieldPreview(component);
      case FormTypeEnum.textAreaFormType:
        return _buildTextAreaPreview(component);
      case FormTypeEnum.switchFormType:
        return _buildSwitchPreview(component);
      case FormTypeEnum.selectorButtonFormType:
        return _buildSelectorButtonPreview(component);
      case FormTypeEnum.dateTimePickerFormType:
        return _buildDateTimePickerPreview(component);
      case FormTypeEnum.dateTimeRangePickerFormType:
        return _buildDateTimeRangePickerPreview(component);
      default:
        return _buildDefaultPreview(component);
    }
  }

  Widget _buildTextFieldPreview(DynamicFormModel component) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (component.config?.label != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Text(
                component.config!.label!,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          Expanded(
            child: Row(
              children: [
                if (component.config?.icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.mail,
                    color: Colors.grey[400],
                    size: 10,
                  ),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    component.config?.placeholder ?? 'Text Field',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 9,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextAreaPreview(DynamicFormModel component) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (component.config?.label != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Text(
                component.config!.label!,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                component.config?.placeholder ?? 'Text Area',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 9,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultPreview(DynamicFormModel component) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: const Center(
        child: Text(
          'Component',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchPreview(DynamicFormModel component) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 8),
                const Icon(
                  Icons.toggle_on,
                  color: Colors.blue,
                  size: 12,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    component.config!.label!,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorButtonPreview(DynamicFormModel component) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 8),
                const Icon(
                  Icons.radio_button_checked,
                  color: Colors.blue,
                  size: 12,
                ),
                const SizedBox(width: 8),
                if (component.config?.label != null) ...[
                  Expanded(
                    child: Text(
                      component.config!.label!,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePickerPreview(DynamicFormModel component) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (component.config?.label != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Text(
                component.config!.label!,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 8),
                const Icon(
                  Icons.calendar_today,
                  color: Colors.blue,
                  size: 12,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    component.config?.placeholder ?? 'Select Date',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 9,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeRangePickerPreview(DynamicFormModel component) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (component.config?.label != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Text(
                component.config!.label!,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          Expanded(
            child: Row(
              spacing: 8,
              children: [
                const Icon(
                  Icons.date_range,
                  color: Colors.blue,
                  size: 12,
                ),
                Expanded(
                  child: Text(
                    component.config?.placeholder ?? 'Select Date Range',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 9,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
