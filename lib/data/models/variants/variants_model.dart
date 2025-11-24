import 'package:dynamic_form_bi/data/models/states/style_states_model.dart';
import 'package:dynamic_form_bi/data/models/input_types/input_types_model.dart';

class VariantItemModel {
  final StyleStatesModel? style;
  final InputTypesModel? config;

  VariantItemModel({this.style, this.config});

  factory VariantItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return VariantItemModel();
    return VariantItemModel(
      style: json['style'] != null
          ? StyleStatesModel.fromJson(json['style'] as Map<String, dynamic>?)
          : null,
      config: json['config'] != null
          ? InputTypesModel.fromJson(json['config'] as Map<String, dynamic>?)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (style != null) 'style': style!.toJson(),
    if (config != null) 'config': config!.toJson(),
  };
}

class VariantsModel {
  final VariantItemModel? withLabel;
  final VariantItemModel? withIcon;
  final VariantItemModel? multiple;
  final VariantItemModel? searchable;
  // Can add more variants if needed

  VariantsModel({
    this.withLabel,
    this.withIcon,
    this.multiple,
    this.searchable,
  });

  factory VariantsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return VariantsModel();
    return VariantsModel(
      withLabel: json['with_label'] != null
          ? VariantItemModel.fromJson(json['with_label'])
          : null,
      withIcon: json['with_icon'] != null
          ? VariantItemModel.fromJson(json['with_icon'])
          : null,
      multiple: json['multiple'] != null
          ? VariantItemModel.fromJson(json['multiple'])
          : null,
      searchable: json['searchable'] != null
          ? VariantItemModel.fromJson(json['searchable'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (withLabel != null) 'with_label': withLabel!.toJson(),
    if (withIcon != null) 'with_icon': withIcon!.toJson(),
    if (multiple != null) 'multiple': multiple!.toJson(),
    if (searchable != null) 'searchable': searchable!.toJson(),
  };
}

extension VariantsModelExt on VariantsModel? {
  VariantItemModel? getByKey(String key) {
    switch (key) {
      case 'with_label':
        return this?.withLabel;
      case 'with_icon':
        return this?.withIcon;
      case 'multiple':
        return this?.multiple;
      case 'searchable':
        return this?.searchable;
      default:
        return null;
    }
  }
}
