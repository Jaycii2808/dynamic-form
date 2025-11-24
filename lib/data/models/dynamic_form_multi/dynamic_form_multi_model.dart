import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:equatable/equatable.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/data/models/validation/validation_factory.dart';
import 'package:dynamic_form_bi/data/models/validation/base_validation.dart';
import 'package:flutter/foundation.dart';

class DynamicMultiPageFormModel extends Equatable {
  final String formId;
  final String name;
  // final String navigationType;
  final List<FormForMultiPageModel> pages;

  const DynamicMultiPageFormModel({
    required this.formId,
    required this.name,
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
      pages: pageList,
    );
    //empty factory
  }

  @override
  List<Object?> get props => [formId, name, pages];

  Map<String, dynamic> toJson() {
    return {
      'formId': formId,
      'name': name,
      'pages': pages.map((page) => page.toJson()).toList(),
    };
  }

  DynamicMultiPageFormModel copyWith({
    String? formId,
    String? name,
    String? navigationType,
    List<FormForMultiPageModel>? pages,
  }) {
    return DynamicMultiPageFormModel(
      formId: formId ?? this.formId,
      name: name ?? this.name,
      pages: pages ?? this.pages,
    );
  }
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
    debugPrint('🔄 [FormForMultiPageModel] Converting page: ${json['title']}');

    var componentList =
        (json['components'] as List<dynamic>?)?.map(
          (compJson) {
            debugPrint(
              '🔄 [FormForMultiPageModel] Converting component: ${compJson['id']} - ${compJson['type']}',
            );
            return FormComponentMultiPageModel.fromJson(
              compJson as Map<String, dynamic>,
            );
          },
        ).toList() ??
        [];

    componentList.sort((a, b) => a.order.compareTo(b.order));

    debugPrint(
      '🔄 [FormForMultiPageModel] Converted ${componentList.length} components',
    );

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

  Map<String, dynamic> toJson() {
    return {
      'pageId': pageId,
      'title': title,
      'order': order,
      'show_next_button': showNextButton,
      'show_previous_button': showPreviousButton,
      'show_submit_button': showSubmitButton,
      'components': components.map((component) => component.toJson()).toList(),
    };
  }

  FormForMultiPageModel copyWith({
    String? pageId,
    String? title,
    int? order,
    bool? showNextButton,
    bool? showPreviousButton,
    bool? showSubmitButton,
    List<FormComponentMultiPageModel>? components,
  }) {
    return FormForMultiPageModel(
      pageId: pageId ?? this.pageId,
      title: title ?? this.title,
      order: order ?? this.order,
      showNextButton: showNextButton ?? this.showNextButton,
      showPreviousButton: showPreviousButton ?? this.showPreviousButton,
      showSubmitButton: showSubmitButton ?? this.showSubmitButton,
      components: components ?? this.components,
    );
  }
}

class FormComponentMultiPageModel extends Equatable {
  final String id;
  final FormTypeEnum type;
  final int order;
  final ConfigModel config;
  final StyleModel style;
  final BaseValidation? validation;
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
    debugPrint(
      '🔍 [FormComponentMultiPageModel] Parsing component: ${json['id']}',
    );
    debugPrint('🔍 [FormComponentMultiPageModel] Type: ${json['type']}');
    debugPrint('🔍 [FormComponentMultiPageModel] Order: ${json['order']}');

    return FormComponentMultiPageModel(
      id: json['id'] ?? '',
      type: FormTypeEnum.fromJson(json['type']),
      order: json['order'] ?? 0,
      config: ConfigModel.fromJson(json['config'] ?? {}),
      style: StyleModel.fromJson(json['style'] ?? {}),
      validation: json['validate'] != null
          ? ValidationFactory.fromJson(json['validate'])
          : null,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toJson(),
      'order': order,
      'config': config.toJson(),
      'style': style.toJson(),
      'validate': validation?.toJson(),
      'children': children?.map((child) => child.toJson()).toList(),
    };
  }

  FormComponentMultiPageModel copyWith({
    String? id,
    FormTypeEnum? type,
    int? order,
    ConfigModel? config,
    StyleModel? style,
    BaseValidation? validation,
    List<FormComponentMultiPageModel>? children,
  }) {
    return FormComponentMultiPageModel(
      id: id ?? this.id,
      type: type ?? this.type,
      order: order ?? this.order,
      config: config ?? this.config,
      style: style ?? this.style,
      validation: validation ?? this.validation,
      children: children ?? this.children,
    );
  }
}
