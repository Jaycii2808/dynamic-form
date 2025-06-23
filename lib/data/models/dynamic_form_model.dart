import 'package:equatable/equatable.dart';

class DynamicFormModel extends Equatable {
  final String id;
  final String type;
  final int order;
  final Map<String, dynamic> config;
  final Map<String, dynamic> style;
  final Map<String, dynamic>? inputTypes;
  final Map<String, dynamic>? variants;
  final Map<String, dynamic>? states;
  final Map<String, dynamic>? validation;
  final List<DynamicFormModel>? children;

  const DynamicFormModel({
    required this.id,
    required this.type,
    required this.order,
    required this.config,
    required this.style,
    this.inputTypes,
    this.variants,
    this.states,
    this.validation,
    this.children,
  });

  factory DynamicFormModel.fromJson(Map<String, dynamic> json) {
    return DynamicFormModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      order: json['order'] ?? 0,
      config: json['config'] ?? {},
      style: json['style'] ?? {},
      inputTypes: json['inputTypes'],
      variants: json['variants'],
      states: json['states'],
      validation: json['validation'],
      children: json['children'] != null
          ? List<DynamicFormModel>.from(
              json['children'].map((x) => DynamicFormModel.fromJson(x)),
            )
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    order,
    config,
    style,
    inputTypes,
    variants,
    states,
    validation,
    children,
  ];

  Map<String, dynamic> toJson() {
    // Deep copy config để lấy giá trị hiện tại
    Map<String, dynamic> deepCopyConfig(Map<String, dynamic> map) {
      final result = <String, dynamic>{};
      map.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          result[key] = deepCopyConfig(value);
        } else if (value is List) {
          result[key] = value
              .map((e) => e is Map<String, dynamic> ? deepCopyConfig(e) : e)
              .toList();
        } else {
          result[key] = value;
        }
      });
      return result;
    }

    return {
      'id': id,
      'type': type,
      'order': order,
      'config': deepCopyConfig(config),
      'style': style,
      if (inputTypes != null) 'inputTypes': inputTypes,
      if (variants != null) 'variants': variants,
      if (states != null) 'states': states,
      if (validation != null) 'validation': validation,
      if (children != null)
        'children': children!.map((c) => c.toJson()).toList(),
    };
  }
}

class DynamicFormPageModel extends Equatable {
  final String pageId;
  final String title;
  final int order;
  final List<DynamicFormModel> components;

  const DynamicFormPageModel({
    required this.pageId,
    required this.title,
    required this.order,
    required this.components,
  });

  factory DynamicFormPageModel.fromJson(Map<String, dynamic> json) {
    List<DynamicFormModel> components = [];
    if (json['components'] != null) {
      components = List<DynamicFormModel>.from(
        json['components'].map((x) => DynamicFormModel.fromJson(x)),
      );
      components.sort((a, b) => a.order.compareTo(b.order));
    }

    return DynamicFormPageModel(
      pageId: json['id_form'] ?? json['pageId'] ?? '',
      title: json['title'] ?? '',
      order: json['order'] ?? 1,
      components: components,
    );
  }

  @override
  List<Object?> get props => [pageId, title, order, components];

  Map<String, dynamic> toJson() {
    return {
      'id_form': pageId,
      'order': order,
      'title': title,
      'components': components.map((c) => c.toJson()).toList(),
    };
  }
}
