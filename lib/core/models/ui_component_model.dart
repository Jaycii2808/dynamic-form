import 'package:equatable/equatable.dart';

class UIComponentModel extends Equatable {
  final String id;
  final String type;
  final int order;
  final Map<String, dynamic> config;
  final Map<String, dynamic> style;
  final Map<String, dynamic>? inputTypes;
  final Map<String, dynamic>? variants;
  final Map<String, dynamic>? states;
  final List<UIComponentModel>? children;

  const UIComponentModel({
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

  factory UIComponentModel.fromJson(Map<String, dynamic> json) {
    return UIComponentModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      order: json['order'] ?? 0,
      config: json['config'] ?? {},
      style: json['style'] ?? {},
      inputTypes: json['inputTypes'],
      variants: json['variants'],
      states: json['states'],
      children: json['children'] != null
          ? List<UIComponentModel>.from(
              json['children'].map((x) => UIComponentModel.fromJson(x)),
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

class UIPageModel extends Equatable {
  final String pageId;
  final String title;
  final List<UIComponentModel> components;

  const UIPageModel({
    required this.pageId,
    required this.title,
    required this.components,
  });

  factory UIPageModel.fromJson(Map<String, dynamic> json) {
    List<UIComponentModel> components = [];
    if (json['components'] != null) {
      components = List<UIComponentModel>.from(
        json['components'].map((x) => UIComponentModel.fromJson(x)),
      );
      components.sort((a, b) => a.order.compareTo(b.order));
    }

    return UIPageModel(
      pageId: json['pageId'] ?? '',
      title: json['title'] ?? '',
      components: components,
    );
  }

  @override
  List<Object?> get props => [pageId, title, components];
}
