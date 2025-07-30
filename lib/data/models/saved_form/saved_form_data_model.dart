import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_multi/dynamic_form_multi_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/data/models/validation/validation_factory.dart';
import 'package:dynamic_form_bi/data/models/validation/base_validation.dart';
import 'package:equatable/equatable.dart';

/// Model for saved form data structure - replaces List<Map<String, dynamic>>
class SavedFormDataModel extends Equatable {
  final String formId;
  final List<SavedFormPageDataModel> pages;
  final Map<String, dynamic> componentValues;

  const SavedFormDataModel({
    required this.formId,
    required this.pages,
    required this.componentValues,
  });

  factory SavedFormDataModel.fromJson(Map<String, dynamic> json) {
    final List<SavedFormPageDataModel> pages = [];
    if (json['pages'] != null) {
      for (final pageJson in json['pages'] as List<dynamic>) {
        pages.add(
          SavedFormPageDataModel.fromJson(pageJson as Map<String, dynamic>),
        );
      }
    }

    return SavedFormDataModel(
      formId: json['form_id'] ?? '',
      pages: pages,
      componentValues: Map<String, dynamic>.from(
        json['component_values'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'form_id': formId,
      'pages': pages.map((page) => page.toJson()).toList(),
      'component_values': componentValues,
    };
  }

  @override
  List<Object?> get props => [formId, pages, componentValues];
}

/// Model for saved form page data
class SavedFormPageDataModel extends Equatable {
  final String pageId;
  final String title;
  final int order;
  final bool showNextButton;
  final bool showPreviousButton;
  final bool showSubmitButton;
  final List<SavedFormComponentDataModel> components;

  const SavedFormPageDataModel({
    required this.pageId,
    required this.title,
    required this.order,
    this.showNextButton = false,
    this.showPreviousButton = false,
    this.showSubmitButton = false,
    required this.components,
  });

  factory SavedFormPageDataModel.fromJson(Map<String, dynamic> json) {
    final List<SavedFormComponentDataModel> components = [];
    if (json['components'] != null) {
      for (final componentJson in json['components'] as List<dynamic>) {
        components.add(
          SavedFormComponentDataModel.fromJson(
            componentJson as Map<String, dynamic>,
          ),
        );
      }
    }

    return SavedFormPageDataModel(
      pageId: json['pageId'] ?? '',
      title: json['title'] ?? '',
      order: json['order'] ?? 0,
      showNextButton: json['show_next_button'] ?? false,
      showPreviousButton: json['show_previous_button'] ?? false,
      showSubmitButton: json['show_submit_button'] ?? false,
      components: components,
    );
  }

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

/// Model for saved form component data
class SavedFormComponentDataModel extends Equatable {
  final String id;
  final FormTypeEnum type;
  final int order;
  final ConfigModel config;
  final StyleModel style;
  final BaseValidation? validation;
  final List<SavedFormComponentDataModel>? children;

  const SavedFormComponentDataModel({
    required this.id,
    required this.type,
    required this.order,
    required this.config,
    required this.style,
    this.validation,
    this.children,
  });

  factory SavedFormComponentDataModel.fromJson(Map<String, dynamic> json) {
    final List<SavedFormComponentDataModel>? children = json['children'] != null
        ? (json['children'] as List<dynamic>)
              .map(
                (childJson) => SavedFormComponentDataModel.fromJson(
                  childJson as Map<String, dynamic>,
                ),
              )
              .toList()
        : null;

    return SavedFormComponentDataModel(
      id: json['id'] ?? '',
      type: FormTypeEnum.fromJson(json['type']),
      order: json['order'] ?? 0,
      config: ConfigModel.fromJson(json['config'] ?? {}),
      style: StyleModel.fromJson(json['style'] ?? {}),
      validation: json['validation'] != null
          ? ValidationFactory.fromJson(json['validation'])
          : null,
      children: children,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toJson(),
      'order': order,
      'config': config.toJson(),
      'style': style.toJson(),
      'validation': validation?.toJson(),
      if (children != null)
        'children': children!.map((child) => child.toJson()).toList(),
    };
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

  /// Create from DynamicFormModel for easy conversion
  factory SavedFormComponentDataModel.fromDynamicFormModel(
    DynamicFormModel model,
  ) {
    final List<SavedFormComponentDataModel>? children = model.children != null
        ? model.children!
              .map(
                (child) =>
                    SavedFormComponentDataModel.fromDynamicFormModel(child),
              )
              .toList()
        : null;

    return SavedFormComponentDataModel(
      id: model.id,
      type: model.type,
      order: model.order,
      config: model.config ?? const ConfigModel(),
      style: model.style,
      validation: model.validation,
      children: children,
    );
  }

  /// Convert to DynamicFormModel for easy conversion back
  DynamicFormModel toDynamicFormModel() {
    final List<DynamicFormModel>? children = this.children != null
        ? this.children!.map((child) => child.toDynamicFormModel()).toList()
        : null;

    return DynamicFormModel(
      id: id,
      type: type,
      order: order,
      config: config,
      style: style,
      inputTypes: null,
      variants: null,
      states: null,
      validation: validation,
      children: children,
    );
  }
}

/// Helper class for creating saved form data
class SavedFormDataBuilder {
  static SavedFormDataModel createFromMultiPageForm({
    required String formId,
    required List<FormForMultiPageModel> pages,
    required Map<String, dynamic> componentValues,
  }) {
    final List<SavedFormPageDataModel> savedPages = [];

    for (final page in pages) {
      final List<SavedFormComponentDataModel> savedComponents = [];

      for (final component in page.components) {
        final List<SavedFormComponentDataModel>? savedChildren =
            component.children != null
            ? component.children!
                  .map(
                    (child) => SavedFormComponentDataModel(
                      id: child.id,
                      type: child.type,
                      order: child.order,
                      config: child.config,
                      style: child.style,
                      validation: child.validation,
                      children: null,
                    ),
                  )
                  .toList()
            : null;

        savedComponents.add(
          SavedFormComponentDataModel(
            id: component.id,
            type: component.type,
            order: component.order,
            config: component.config,
            style: component.style,
            validation: component.validation,
            children: savedChildren,
          ),
        );
      }

      savedPages.add(
        SavedFormPageDataModel(
          pageId: page.pageId,
          title: page.title,
          order: page.order,
          showNextButton: page.showNextButton,
          showPreviousButton: page.showPreviousButton,
          showSubmitButton: page.showSubmitButton,
          components: savedComponents,
        ),
      );
    }

    return SavedFormDataModel(
      formId: formId,
      pages: savedPages,
      componentValues: componentValues,
    );
  }

  static SavedFormDataModel createFromDynamicFormPages({
    required String formId,
    required List<DynamicFormPageModel> pages,
    required Map<String, dynamic> componentValues,
  }) {
    final List<SavedFormPageDataModel> savedPages = [];

    for (final page in pages) {
      final List<SavedFormComponentDataModel> savedComponents = [];

      for (final component in page.components) {
        savedComponents.add(
          SavedFormComponentDataModel.fromDynamicFormModel(component),
        );
      }

      savedPages.add(
        SavedFormPageDataModel(
          pageId: page.pageId,
          title: page.title,
          order: page.order,
          showNextButton: true, // Default values for dynamic form pages
          showPreviousButton: true,
          showSubmitButton: false,
          components: savedComponents,
        ),
      );
    }

    return SavedFormDataModel(
      formId: formId,
      pages: savedPages,
      componentValues: componentValues,
    );
  }
}
