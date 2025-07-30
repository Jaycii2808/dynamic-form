import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:equatable/equatable.dart';

class ComponentValueUpdateModel extends Equatable {
  final String componentId;
  final dynamic value;
  final StatesEnum? currentState;
  final String? errorText;
  final bool? selected;

  const ComponentValueUpdateModel({
    required this.componentId,
    required this.value,
    this.currentState,
    this.errorText,
    this.selected,
  });

  factory ComponentValueUpdateModel.create({
    required String componentId,
    required dynamic value,
    StatesEnum? currentState,
    String? errorText,
    bool? selected,
  }) {
    return ComponentValueUpdateModel(
      componentId: componentId,
      value: value,
      currentState: currentState ?? StatesEnum.base,
      errorText: errorText,
      selected: selected,
    );
  }

  factory ComponentValueUpdateModel.fromMap(Map<String, dynamic> map) {
    return ComponentValueUpdateModel(
      componentId: map['componentId'] as String? ?? '',
      value: map['value'],
      currentState: map['current_state'] != null
          ? StatesEnum.values.firstWhere(
              (e) => e.toString() == map['current_state'],
              orElse: () => StatesEnum.base,
            )
          : StatesEnum.base,
      errorText: map['error_text'] as String?,
      selected: map['selected'] as bool?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'componentId': componentId,
      'value': value,
      'current_state': currentState?.toString(),
      'error_text': errorText,
      'selected': selected,
    };
  }

  @override
  List<Object?> get props => [
    componentId,
    value,
    currentState,
    errorText,
    selected,
  ];

  @override
  String toString() {
    return 'ComponentValueUpdateModel(componentId: $componentId, value: $value, currentState: $currentState, errorText: $errorText, selected: $selected)';
  }
}
