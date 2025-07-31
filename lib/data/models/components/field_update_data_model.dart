import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:dynamic_form_bi/data/models/components/additional_field_data_model.dart';
import 'package:equatable/equatable.dart';

class FieldUpdateDataModel extends Equatable {
  final dynamic value;
  final StatesEnum currentState;
  final String? errorText;
  final bool? selected;
  final AdditionalFieldDataModel? additionalData;

  const FieldUpdateDataModel({
    required this.value,
    required this.currentState,
    this.errorText,
    this.selected,
    this.additionalData,
  });

  factory FieldUpdateDataModel.create({
    required dynamic value,
    required StatesEnum currentState,
    String? errorText,
    bool? selected,
    AdditionalFieldDataModel? additionalData,
  }) {
    return FieldUpdateDataModel(
      value: value,
      currentState: currentState,
      errorText: errorText,
      selected: selected,
      additionalData: additionalData,
    );
  }

  factory FieldUpdateDataModel.fromJson(Map<String, dynamic> map) {
    return FieldUpdateDataModel(
      value: map['value'],
      currentState: map['current_state'] != null
          ? StatesEnum.values.firstWhere(
              (e) => e.toString() == map['current_state'],
              orElse: () => StatesEnum.base,
            )
          : StatesEnum.base,
      errorText: map['error_text'] as String?,
      selected: map['selected'] as bool?,
      additionalData: map['additional_data'] != null
          ? AdditionalFieldDataModel.fromJson(map['additional_data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'value': value,
      'current_state': currentState.toString(),
      'error_text': errorText,
    };

    if (selected != null) {
      data['selected'] = selected;
    }

    if (additionalData != null) {
      data['additional_data'] = additionalData!.toJson();
    }

    return data;
  }

  // Convert to legacy Map format for backward compatibility
  Map<String, dynamic> toLegacyMap() {
    final data = <String, dynamic>{
      'value': value,
      'current_state': currentState,
      'error_text': errorText,
    };

    if (selected != null) {
      data['selected'] = selected;
    }

    if (additionalData != null) {
      data.addAll(additionalData!.toLegacyMap());
    }

    return data;
  }

  @override
  List<Object?> get props => [
    value,
    currentState,
    errorText,
    selected,
    additionalData,
  ];

  @override
  String toString() {
    return 'FieldUpdateDataModel(value: $value, currentState: $currentState, errorText: $errorText, selected: $selected, additionalData: $additionalData)';
  }
}
