import 'package:dynamic_form_bi/data/models/states/style_states_model.dart';

class StatesModel {
  final StyleStatesModel? base;
  final StyleStatesModel? focused;
  final StyleStatesModel? error;
  final StyleStatesModel? success;

  StatesModel(this.base, this.focused, this.error, this.success);
  //toString, toJson, fromJson

  Map<String, dynamic> toJson() => {
    if (base != null) 'base': base?.toJson(),
    if (focused != null) 'focused': focused?.toJson(),
    if (error != null) 'error': error?.toJson(),
    if (success != null) 'success': success?.toJson(),
  };

  @override
  String toString() => toJson().toString();

  factory StatesModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return StatesModel(null, null, null, null);
    return StatesModel(
      json['base'] != null
          ? StyleStatesModel.fromJson(
              json['base']['style'] as Map<String, dynamic>?,
            )
          : null,
      json['focused'] != null
          ? StyleStatesModel.fromJson(
              json['focused']['style'] as Map<String, dynamic>?,
            )
          : null,
      json['error'] != null
          ? StyleStatesModel.fromJson(
              json['error']['style'] as Map<String, dynamic>?,
            )
          : null,
      json['success'] != null
          ? StyleStatesModel.fromJson(
              json['success']['style'] as Map<String, dynamic>?,
            )
          : null,
    );
  }
}
