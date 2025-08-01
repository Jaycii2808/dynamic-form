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
  ];
}
