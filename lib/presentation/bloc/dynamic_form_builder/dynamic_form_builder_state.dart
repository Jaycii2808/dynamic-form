import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:equatable/equatable.dart';

abstract class FormBuilderState extends Equatable {
  final List<DynamicFormModel> components;
  final List<DynamicFormModel> canvasComponents;
  final List<DynamicFormModel> availableComponents;
  final List<DynamicFormModel> availableButtonComponents;
  final bool isDragging;
  final bool showComponentsPanel;
  final bool showButtonComponentsPanel;

  const FormBuilderState({
    this.components = const [],
    this.canvasComponents = const [],
    this.availableComponents = const [],
    this.availableButtonComponents = const [],
    this.isDragging = false,
    this.showComponentsPanel = true,
    this.showButtonComponentsPanel = false,
  });

  @override
  List<Object?> get props => [
    components,
    canvasComponents,
    availableComponents,
    availableButtonComponents,
    isDragging,
    showComponentsPanel,
    showButtonComponentsPanel,
  ];
}

class FormBuilderInitial extends FormBuilderState {
  const FormBuilderInitial({
    super.components,
    super.canvasComponents,
    super.availableComponents,
    super.availableButtonComponents,
    super.isDragging,
    super.showComponentsPanel,
    super.showButtonComponentsPanel,
  });
}

class FormBuilderLoading extends FormBuilderState {
  const FormBuilderLoading({
    super.components,
    super.canvasComponents,
    super.availableComponents,
    super.availableButtonComponents,
    super.isDragging,
    super.showComponentsPanel,
    super.showButtonComponentsPanel,
  });

  FormBuilderLoading.fromState({required FormBuilderState state})
    : super(
        components: state.components,
        canvasComponents: state.canvasComponents,
        availableComponents: state.availableComponents,
        availableButtonComponents: state.availableButtonComponents,
        isDragging: state.isDragging,
        showComponentsPanel: state.showComponentsPanel,
        showButtonComponentsPanel: state.showButtonComponentsPanel,
      );
}

class FormBuilderSuccess extends FormBuilderState {
  const FormBuilderSuccess({
    super.components,
    super.canvasComponents,
    super.availableComponents,
    super.availableButtonComponents,
    super.isDragging,
    super.showComponentsPanel,
    super.showButtonComponentsPanel,
  });

  FormBuilderSuccess.fromState({required FormBuilderState state})
    : super(
        components: state.components,
        canvasComponents: state.canvasComponents,
        availableComponents: state.availableComponents,
        availableButtonComponents: state.availableButtonComponents,
        isDragging: state.isDragging,
        showComponentsPanel: state.showComponentsPanel,
        showButtonComponentsPanel: state.showButtonComponentsPanel,
      );

  FormBuilderSuccess copyWith({
    List<DynamicFormModel>? components,
    List<DynamicFormModel>? canvasComponents,
    List<DynamicFormModel>? availableComponents,
    List<DynamicFormModel>? availableButtonComponents,
    bool? isDragging,
    bool? showComponentsPanel,
    bool? showButtonComponentsPanel,
  }) {
    return FormBuilderSuccess(
      components: components ?? this.components,
      canvasComponents: canvasComponents ?? this.canvasComponents,
      availableComponents: availableComponents ?? this.availableComponents,
      availableButtonComponents:
          availableButtonComponents ?? this.availableButtonComponents,
      isDragging: isDragging ?? this.isDragging,
      showComponentsPanel: showComponentsPanel ?? this.showComponentsPanel,
      showButtonComponentsPanel:
          showButtonComponentsPanel ?? this.showButtonComponentsPanel,
    );
  }
}

class FormBuilderError extends FormBuilderState {
  final String? errorMessage;

  const FormBuilderError({
    super.components,
    super.canvasComponents,
    super.availableComponents,
    super.availableButtonComponents,
    super.isDragging,
    super.showComponentsPanel,
    super.showButtonComponentsPanel,
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [
    components,
    canvasComponents,
    availableComponents,
    availableButtonComponents,
    isDragging,
    showComponentsPanel,
    showButtonComponentsPanel,
    errorMessage,
  ];
}
