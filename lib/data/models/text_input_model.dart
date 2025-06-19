import 'package:equatable/equatable.dart';

class TextInputModel extends Equatable {
  final String id;
  final String type;
  final int order;
  final Map<String, dynamic> config;
  final Map<String, dynamic> style;
  final Map<String, dynamic>? inputTypes;
  final Map<String, dynamic>? variants;
  final Map<String, dynamic>? states;
  final List<TextInputModel>? children;

  const TextInputModel({
    required this.id,
    required this.type,
    required this.order,
    required this.config,
    required this.style,
    this.inputTypes,
    this.variants,
    this.states,
    this.children,
  });

  factory TextInputModel.fromJson(Map<String, dynamic> json) {
    return TextInputModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      order: json['order'] ?? 0,
      config: json['config'] ?? {},
      style: json['style'] ?? {},
      inputTypes: json['inputTypes'],
      variants: json['variants'],
      states: json['states'],
      children: json['children'] != null
          ? List<TextInputModel>.from(
              json['children'].map((x) => TextInputModel.fromJson(x)),
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
    children,
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'order': order,
      'config': config,
      'style': style,
      if (inputTypes != null) 'inputTypes': inputTypes,
      if (variants != null) 'variants': variants,
      if (states != null) 'states': states,
      if (children != null)
        'children': children!.map((c) => c.toJson()).toList(),
    };
  }
}

class TextInputScreenModel extends Equatable {
  final String pageId;
  final String title;
  final int order;
  final List<TextInputModel> components;

  const TextInputScreenModel({
    required this.pageId,
    required this.title,
    required this.order,
    required this.components,
  });

  factory TextInputScreenModel.fromJson(Map<String, dynamic> json) {
    List<TextInputModel> components = [];
    if (json['components'] != null) {
      components = List<TextInputModel>.from(
        json['components'].map((x) => TextInputModel.fromJson(x)),
      );
      components.sort((a, b) => a.order.compareTo(b.order));
    }

    return TextInputScreenModel(
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
