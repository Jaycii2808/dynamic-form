import 'package:equatable/equatable.dart';

class ComponentValuesModel extends Equatable {
  final Map<String, dynamic> values;

  const ComponentValuesModel({
    this.values = const {},
  });

  factory ComponentValuesModel.fromJson(Map<String, dynamic> map) {
    return ComponentValuesModel(values: Map<String, dynamic>.from(map));
  }

  factory ComponentValuesModel.empty() {
    return const ComponentValuesModel();
  }

  dynamic getValue(String componentId) {
    return values[componentId];
  }

  ComponentValuesModel setValue(String componentId, dynamic value) {
    final newValues = Map<String, dynamic>.from(values);
    newValues[componentId] = value;
    return ComponentValuesModel(values: newValues);
  }

  ComponentValuesModel removeValue(String componentId) {
    final newValues = Map<String, dynamic>.from(values);
    newValues.remove(componentId);
    return ComponentValuesModel(values: newValues);
  }

  bool hasValue(String componentId) {
    return values.containsKey(componentId);
  }

  bool get isEmpty => values.isEmpty;
  bool get isNotEmpty => values.isNotEmpty;
  int get length => values.length;

  Map<String, dynamic> toJson() {
    return Map<String, dynamic>.from(values);
  }

  @override
  List<Object?> get props => [values];

  @override
  String toString() {
    return 'ComponentValuesModel(values: $values)';
  }
}
