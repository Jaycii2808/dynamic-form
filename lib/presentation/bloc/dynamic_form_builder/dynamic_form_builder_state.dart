import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:equatable/equatable.dart';

abstract class FormBuilderState extends Equatable {
  final List<DynamicFormModel> components;
  final List<DynamicFormModel> canvasComponents;
  final List<DynamicFormModel> availableComponents;
  final bool isDragging;
  final bool showComponentsPanel;

  const FormBuilderState({
    this.components = const [],
    this.canvasComponents = const [],
    this.availableComponents = const [],
    this.isDragging = false,
    this.showComponentsPanel = true,
  });

  @override
  List<Object?> get props => [
    components,
    canvasComponents,
    availableComponents,
    isDragging,
    showComponentsPanel,
  ];
}

class FormBuilderInitial extends FormBuilderState {
  const FormBuilderInitial({
    super.components,
    super.canvasComponents,
    super.availableComponents,
    super.isDragging,
    super.showComponentsPanel,
  });
}

class FormBuilderLoading extends FormBuilderState {
  const FormBuilderLoading({
    super.components,
    super.canvasComponents,
    super.availableComponents,
    super.isDragging,
    super.showComponentsPanel,
  });

  FormBuilderLoading.fromState({required FormBuilderState state})
    : super(
        components: state.components,
        canvasComponents: state.canvasComponents,
        availableComponents: state.availableComponents,
        isDragging: state.isDragging,
        showComponentsPanel: state.showComponentsPanel,
      );
}

class FormBuilderSuccess extends FormBuilderState {
  const FormBuilderSuccess({
    super.components,
    super.canvasComponents,
    super.availableComponents,
    super.isDragging,
    super.showComponentsPanel,
  });

  FormBuilderSuccess.fromState({required FormBuilderState state})
    : super(
        components: state.components,
        canvasComponents: state.canvasComponents,
        availableComponents: state.availableComponents,
        isDragging: state.isDragging,
        showComponentsPanel: state.showComponentsPanel,
      );

  FormBuilderSuccess copyWith({
    List<DynamicFormModel>? components,
    List<DynamicFormModel>? canvasComponents,
    List<DynamicFormModel>? availableComponents,
    bool? isDragging,
    bool? showComponentsPanel,
  }) {
    return FormBuilderSuccess(
      components: components ?? this.components,
      canvasComponents: canvasComponents ?? this.canvasComponents,
      availableComponents: availableComponents ?? this.availableComponents,
      isDragging: isDragging ?? this.isDragging,
      showComponentsPanel: showComponentsPanel ?? this.showComponentsPanel,
    );
  }
}

class FormBuilderError extends FormBuilderState {
  final String? errorMessage;

  const FormBuilderError({
    super.components,
    super.canvasComponents,
    super.availableComponents,
    super.isDragging,
    super.showComponentsPanel,
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [
    components,
    canvasComponents,
    availableComponents,
    isDragging,
    showComponentsPanel,
    errorMessage,
  ];
}
