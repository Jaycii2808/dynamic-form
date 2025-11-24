import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:equatable/equatable.dart';

class TextFieldValueModel extends Equatable {
  final String? value;
  final StatesEnum currentState;
  final String? errorText;

  const TextFieldValueModel({
    this.value,
    this.currentState = StatesEnum.base,
    this.errorText,
  });

  factory TextFieldValueModel.fromComponent(dynamic component) {
    return TextFieldValueModel(
      value: component?.config?.value?.toString(),
      currentState: component?.config?.currentState ?? StatesEnum.base,
      errorText: component?.config?.errorText,
    );
  }

  factory TextFieldValueModel.create({
    String? value,
    StatesEnum? currentState,
    String? errorText,
  }) {
    return TextFieldValueModel(
      value: value,
      currentState: currentState ?? StatesEnum.base,
      errorText: errorText,
    );
  }

  TextFieldValueModel copyWith({
    String? value,
    StatesEnum? currentState,
    String? errorText,
  }) {
    return TextFieldValueModel(
      value: value ?? this.value,
      currentState: currentState ?? this.currentState,
      errorText: errorText ?? this.errorText,
    );
  }

  @override
  List<Object?> get props => [value, currentState, errorText];

  @override
  String toString() {
    return 'TextFieldValueModel(value: $value, currentState: $currentState, errorText: $errorText)';
  }
}
