
import 'package:dynamic_form_bi/data/models/dynamic_form/input_type_validation_model.dart';

class InputTypesModel {
  final InputTypeValidationModel? text;
  final InputTypeValidationModel? email;
  final InputTypeValidationModel? tel;
  final InputTypeValidationModel? password;
  final InputTypeValidationModel? multiline;

  InputTypesModel({
    this.text,
    this.email,
    this.tel,
    this.password,
    this.multiline,
  });

  factory InputTypesModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return InputTypesModel();
    return InputTypesModel(
      text: json['text'] != null
          ? InputTypeValidationModel.fromJson(json['text']['validation'])
          : null,
      email: json['email'] != null
          ? InputTypeValidationModel.fromJson(json['email']['validation'])
          : null,
      tel: json['tel'] != null
          ? InputTypeValidationModel.fromJson(json['tel']['validation'])
          : null,
      password: json['password'] != null
          ? InputTypeValidationModel.fromJson(json['password']['validation'])
          : null,
      multiline: json['multiline'] != null
          ? InputTypeValidationModel.fromJson(json['multiline']['validation'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (text != null) 'text': {'validation': text!.toJson()},
    if (email != null) 'email': {'validation': email!.toJson()},
    if (tel != null) 'tel': {'validation': tel!.toJson()},
    if (password != null) 'password': {'validation': password!.toJson()},
    if (multiline != null) 'multiline': {'validation': multiline!.toJson()},
  };

  @override
  String toString() => toJson().toString();

  bool get isEmpty =>
      text == null && email == null && tel == null && password == null;
}
