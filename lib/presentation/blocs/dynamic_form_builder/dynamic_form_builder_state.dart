import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/form_builder/form_builder_model.dart';
import 'package:equatable/equatable.dart';

abstract class FormBuilderState extends Equatable {
  final List<DynamicFormModel> components;
  final List<FormBuilderPageModel> pages;
  final String currentPageId;
  final List<DynamicFormModel> availableComponents;
  final List<DynamicFormModel> availableButtonComponents;
  final bool isDragging;
  final bool showComponentsPanel;
  final bool showButtonComponentsPanel;
  final String formTitle;
  // New properties for insert logic
  final int? insertIndicatorIndex;
  final bool isHovering;
  final DynamicFormModel? hoveredComponent;
  final int? hoverTargetIndex;
  // Force rebuild timestamp
  final int? rebuildTimestamp;
  // Highlight target component id for validation error navigation
  final String? highlightedComponentId;
  // Drag state for moving existing components on canvas
  final String? draggingFromPageId;
  final int? draggingFromIndex;
  final DynamicFormModel? draggingComponent;

  const FormBuilderState({
    this.components = const [],
    this.pages = const [],
    this.currentPageId = 'page_1',
    this.availableComponents = const [],
    this.availableButtonComponents = const [],
    this.isDragging = false,
    this.showComponentsPanel = true,
    this.showButtonComponentsPanel = false,
    this.formTitle = 'Untitled',
    this.insertIndicatorIndex,
    this.isHovering = false,
    this.hoveredComponent,
    this.hoverTargetIndex,
    this.rebuildTimestamp,
    this.highlightedComponentId,
    this.draggingFromPageId,
    this.draggingFromIndex,
    this.draggingComponent,
  });

  // Get current page components
  List<DynamicFormModel> get canvasComponents {
    final currentPage = pages.firstWhere(
      (page) => page.pageId == currentPageId,
      orElse: () => pages.isNotEmpty
          ? pages.first
          : const FormBuilderPageModel(
              pageId: 'page_1',
              title: 'Form Page',
              order: 1,
              components: [],
            ),
    );
    return currentPage.components;
  }

  // Get current page title
  String get currentPageTitle {
    final currentPage = pages.firstWhere(
      (page) => page.pageId == currentPageId,
      orElse: () => pages.isNotEmpty
          ? pages.first
          : const FormBuilderPageModel(
              pageId: 'page_1',
              title: 'Form Page',
              order: 1,
              components: [],
            ),
    );
    return currentPage.title;
  }

  @override
  List<Object?> get props => [
    components,
    pages,
    currentPageId,
    availableComponents,
    availableButtonComponents,
    isDragging,
    showComponentsPanel,
    showButtonComponentsPanel,
    formTitle,
    insertIndicatorIndex,
    isHovering,
    hoveredComponent,
    hoverTargetIndex,
    rebuildTimestamp,
    highlightedComponentId,
    draggingFromPageId,
    draggingFromIndex,
    draggingComponent,
  ];
}

class FormBuilderInitial extends FormBuilderState {
  const FormBuilderInitial({
    super.components,
    super.pages,
    super.currentPageId,
    super.availableComponents,
    super.availableButtonComponents,
    super.isDragging,
    super.showComponentsPanel,
    super.showButtonComponentsPanel,
    super.formTitle,
    super.insertIndicatorIndex,
    super.isHovering,
    super.hoveredComponent,
    super.hoverTargetIndex,
    super.rebuildTimestamp,
    super.highlightedComponentId,
    super.draggingFromPageId,
    super.draggingFromIndex,
    super.draggingComponent,
  });
}

class FormBuilderLoading extends FormBuilderState {
  const FormBuilderLoading({
    super.components,
    super.pages,
    super.currentPageId,
    super.availableComponents,
    super.availableButtonComponents,
    super.isDragging,
    super.showComponentsPanel,
    super.showButtonComponentsPanel,
    super.formTitle,
    super.insertIndicatorIndex,
    super.isHovering,
    super.hoveredComponent,
    super.hoverTargetIndex,
    super.rebuildTimestamp,
    super.highlightedComponentId,
    super.draggingFromPageId,
    super.draggingFromIndex,
    super.draggingComponent,
  });

  FormBuilderLoading.fromState({required FormBuilderState state})
    : super(
        components: state.components,
        pages: state.pages,
        currentPageId: state.currentPageId,
        availableComponents: state.availableComponents,
        availableButtonComponents: state.availableButtonComponents,
        isDragging: state.isDragging,
        showComponentsPanel: state.showComponentsPanel,
        showButtonComponentsPanel: state.showButtonComponentsPanel,
        formTitle: state.formTitle,
        insertIndicatorIndex: state.insertIndicatorIndex,
        isHovering: state.isHovering,
        hoveredComponent: state.hoveredComponent,
        hoverTargetIndex: state.hoverTargetIndex,
        rebuildTimestamp: state.rebuildTimestamp,
        highlightedComponentId: state.highlightedComponentId,
        draggingFromPageId: state.draggingFromPageId,
        draggingFromIndex: state.draggingFromIndex,
        draggingComponent: state.draggingComponent,
      );
}

class FormBuilderSuccess extends FormBuilderState {
  const FormBuilderSuccess({
    super.components,
    super.pages,
    super.currentPageId,
    super.availableComponents,
    super.availableButtonComponents,
    super.isDragging,
    super.showComponentsPanel,
    super.showButtonComponentsPanel,
    super.formTitle,
    super.insertIndicatorIndex,
    super.isHovering,
    super.hoveredComponent,
    super.hoverTargetIndex,
    super.rebuildTimestamp,
    super.highlightedComponentId,
    super.draggingFromPageId,
    super.draggingFromIndex,
    super.draggingComponent,
  });

  FormBuilderSuccess.fromState({required FormBuilderState state})
    : super(
        components: state.components,
        pages: state.pages,
        currentPageId: state.currentPageId,
        availableComponents: state.availableComponents,
        availableButtonComponents: state.availableButtonComponents,
        isDragging: state.isDragging,
        showComponentsPanel: state.showComponentsPanel,
        showButtonComponentsPanel: state.showButtonComponentsPanel,
        formTitle: state.formTitle,
        insertIndicatorIndex: state.insertIndicatorIndex,
        isHovering: state.isHovering,
        hoveredComponent: state.hoveredComponent,
        hoverTargetIndex: state.hoverTargetIndex,
        rebuildTimestamp: state.rebuildTimestamp,
        highlightedComponentId: state.highlightedComponentId,
        draggingFromPageId: state.draggingFromPageId,
        draggingFromIndex: state.draggingFromIndex,
        draggingComponent: state.draggingComponent,
      );

  FormBuilderSuccess copyWith({
    List<DynamicFormModel>? components,
    List<FormBuilderPageModel>? pages,
    String? currentPageId,
    List<DynamicFormModel>? availableComponents,
    List<DynamicFormModel>? availableButtonComponents,
    bool? isDragging,
    bool? showComponentsPanel,
    bool? showButtonComponentsPanel,
    String? formTitle,
    int? insertIndicatorIndex,
    bool? isHovering,
    DynamicFormModel? hoveredComponent,
    int? hoverTargetIndex,
    int? rebuildTimestamp,
    String? highlightedComponentId,
    String? draggingFromPageId,
    int? draggingFromIndex,
    DynamicFormModel? draggingComponent,
  }) {
    return FormBuilderSuccess(
      components: components ?? this.components,
      pages: pages ?? this.pages,
      currentPageId: currentPageId ?? this.currentPageId,
      availableComponents: availableComponents ?? this.availableComponents,
      availableButtonComponents:
          availableButtonComponents ?? this.availableButtonComponents,
      isDragging: isDragging ?? this.isDragging,
      showComponentsPanel: showComponentsPanel ?? this.showComponentsPanel,
      showButtonComponentsPanel:
          showButtonComponentsPanel ?? this.showButtonComponentsPanel,
      formTitle: formTitle ?? this.formTitle,
      insertIndicatorIndex: insertIndicatorIndex ?? this.insertIndicatorIndex,
      isHovering: isHovering ?? this.isHovering,
      hoveredComponent: hoveredComponent ?? this.hoveredComponent,
      hoverTargetIndex: hoverTargetIndex ?? this.hoverTargetIndex,
      rebuildTimestamp: rebuildTimestamp ?? this.rebuildTimestamp,
      highlightedComponentId:
          highlightedComponentId ?? this.highlightedComponentId,
      draggingFromPageId: draggingFromPageId ?? this.draggingFromPageId,
      draggingFromIndex: draggingFromIndex ?? this.draggingFromIndex,
      draggingComponent: draggingComponent ?? this.draggingComponent,
    );
  }
}

class FormBuilderError extends FormBuilderState {
  final String? errorMessage;

  const FormBuilderError({
    super.components,
    super.pages,
    super.currentPageId,
    super.availableComponents,
    super.availableButtonComponents,
    super.isDragging,
    super.showComponentsPanel,
    super.showButtonComponentsPanel,
    super.formTitle,
    super.insertIndicatorIndex,
    super.isHovering,
    super.hoveredComponent,
    super.hoverTargetIndex,
    super.rebuildTimestamp,
    required this.errorMessage,
    super.highlightedComponentId,
    super.draggingFromPageId,
    super.draggingFromIndex,
    super.draggingComponent,
  });

  @override
  List<Object?> get props => [
    components,
    pages,
    currentPageId,
    availableComponents,
    availableButtonComponents,
    isDragging,
    showComponentsPanel,
    showButtonComponentsPanel,
    formTitle,
    errorMessage,
    insertIndicatorIndex,
    isHovering,
    hoveredComponent,
    hoverTargetIndex,
    rebuildTimestamp,
    highlightedComponentId,
    draggingFromPageId,
    draggingFromIndex,
    draggingComponent,
  ];
}
