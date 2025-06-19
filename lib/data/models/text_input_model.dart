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
}

class TextInputScreenModel extends Equatable {
  final String pageId;
  final String title;
  final List<TextInputModel> components;

  const TextInputScreenModel({
    required this.pageId,
    required this.title,
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
      pageId: json['pageId'] ?? '',
      title: json['title'] ?? '',
      components: components,
    );
  }

  @override
  List<Object?> get props => [pageId, title, components];
}
