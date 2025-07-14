import 'package:dynamic_form_bi/data/models/states/style_model.dart';

class StatesModel {
  final StyleModel? base;
  final StyleModel? focused;
  final StyleModel? error;
  final StyleModel? success;

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
          ? StyleModel.fromJson(json['base']['style'] as Map<String, dynamic>?)
          : null,
      json['focused'] != null
          ? StyleModel.fromJson(
              json['focused']['style'] as Map<String, dynamic>?,
            )
          : null,
      json['error'] != null
          ? StyleModel.fromJson(json['error']['style'] as Map<String, dynamic>?)
          : null,
      json['success'] != null
          ? StyleModel.fromJson(
              json['success']['style'] as Map<String, dynamic>?,
            )
          : null,
    );
  }
}
