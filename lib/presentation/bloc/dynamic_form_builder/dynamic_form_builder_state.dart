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
    required this.errorMessage,
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
  ];
}
