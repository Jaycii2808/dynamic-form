import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:equatable/equatable.dart';

class DynamicMultiPageFormModel extends Equatable {
  final String formId;
  final String name;
  final String navigationType;
  final List<FormForMultiPageModel> pages;

  const DynamicMultiPageFormModel({
    required this.formId,
    required this.name,
    required this.navigationType,
    required this.pages,
  });

  factory DynamicMultiPageFormModel.fromJson(Map<String, dynamic> json) {
    var pageList =
        (json['pages'] as List<dynamic>?)
            ?.map(
              (pageJson) => FormForMultiPageModel.fromJson(
                pageJson as Map<String, dynamic>,
              ),
            )
            .toList() ??
        [];

    pageList.sort((a, b) => a.order.compareTo(b.order));

    return DynamicMultiPageFormModel(
      formId: json['formId'] ?? '',
      name: json['name'] ?? '',
      navigationType: json['navigationType'] ?? 'sequential',
      pages: pageList,
    );
    //empty factory
  }

  @override
  List<Object?> get props => [formId, name, navigationType, pages];
}

class FormForMultiPageModel extends Equatable {
  final String pageId;
  final String title;
  final int order;
  final bool showNextButton;
  final bool showPreviousButton;
  final bool showSubmitButton;
  final List<FormComponentMultiPageModel> components;

  const FormForMultiPageModel({
    required this.pageId,
    required this.title,
    required this.order,
    this.showNextButton = false,
    this.showPreviousButton = false,
    this.showSubmitButton = false,
    required this.components,
  });

  factory FormForMultiPageModel.fromJson(Map<String, dynamic> json) {
    var componentList =
        (json['components'] as List<dynamic>?)
            ?.map(
              (compJson) => FormComponentMultiPageModel.fromJson(
                compJson as Map<String, dynamic>,
              ),
            )
            .toList() ??
        [];

    componentList.sort((a, b) => a.order.compareTo(b.order));

    return FormForMultiPageModel(
      pageId: json['pageId'] ?? '',
      title: json['title'] ?? '',
      order: json['order'] ?? 0,
      showNextButton: json['show_next_button'] ?? false,
      showPreviousButton: json['show_previous_button'] ?? false,
      showSubmitButton: json['show_submit_button'] ?? false,
      components: componentList,
    );
  }

  @override
  List<Object?> get props => [
    pageId,
    title,
    order,
    showNextButton,
    showPreviousButton,
    showSubmitButton,
    components,
  ];
}

class FormComponentMultiPageModel extends Equatable {
  final String id;
  final FormTypeEnum type;
  final int order;
  final Map<String, dynamic> config;
  final Map<String, dynamic> style;
  final Map<String, dynamic>? validation;
  final List<FormComponentMultiPageModel>? children;

  const FormComponentMultiPageModel({
    required this.id,
    required this.type,
    required this.order,
    required this.config,
    required this.style,
    this.validation,
    this.children,
  });

  factory FormComponentMultiPageModel.fromJson(Map<String, dynamic> json) {
    return FormComponentMultiPageModel(
      id: json['id'] ?? '',
      type: FormTypeEnum.fromJson(json['type']),
      order: json['order'] ?? 0,
      config: json['config'] ?? {},
      style: json['style'] ?? {},
      validation: json['validate'], // <-- fix đúng ánh xạ validate
      children: (json['children'] as List<dynamic>?)
          ?.map(
            (child) => FormComponentMultiPageModel.fromJson(
              child as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    order,
    config,
    style,
    validation,
    children,
  ];
}
