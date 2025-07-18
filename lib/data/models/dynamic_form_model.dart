import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:equatable/equatable.dart';

class DynamicFormModel extends Equatable {
  final String id;
  final FormTypeEnum type;
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
      type: FormTypeEnum.fromJson(json['type']),
      order: json['order'] ?? 0,
      config: json['config'] ?? {},
      style: json['style'] ?? {},
      inputTypes: json['inputTypes'] ?? json['input_types'],
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
    final result = <String, dynamic>{
      'id': id,
      'type': type.toJson(),
      'order': order,
      'config': config,
      'style': style,
    };

    if (inputTypes != null) result['inputTypes'] = inputTypes;
    if (variants != null) result['variants'] = variants;
    if (states != null) result['states'] = states;
    if (validation != null) result['validation'] = validation;
    if (children != null) {
      result['children'] = children!.map((c) => c.toJson()).toList();
    }

    return result;
  }

  factory DynamicFormModel.empty() => const DynamicFormModel(
    id: '',
    config: {},
    style: {},
    type: FormTypeEnum.unknown,
    order: 0,
  );
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
      pageId: json['pageId'] ?? '',
      title: json['title'] ?? '',
      order: json['order'] ?? 1,
      components: components,
    );
  }

  @override
  List<Object?> get props => [pageId, title, order, components];

  Map<String, dynamic> toJson() {
    return {
      'pageId': pageId,
      'order': order,
      'title': title,
      'components': components.map((c) => c.toJson()).toList(),
    };
  }

  // Convert to the format {pageId: id, layout: [components]}
  Map<String, dynamic> toFormLayoutJson() {
    return {
      'pageId': pageId,
      'layout': components.map((c) => c.toJson()).toList(),
    };
  }

  // Create from the format {pageId: id, layout: [components]}
  factory DynamicFormPageModel.fromFormLayoutJson(Map<String, dynamic> json) {
    List<DynamicFormModel> components = [];
    if (json['layout'] != null) {
      components = List<DynamicFormModel>.from(
        json['layout'].map((x) => DynamicFormModel.fromJson(x)),
      );
      components.sort((a, b) => a.order.compareTo(b.order));
    }

    return DynamicFormPageModel(
      pageId: json['pageId'] ?? '',
      title: json['title'] ?? '',
      order: json['order'] ?? 1,
      components: components,
    );
  }
}

class FormTemplateModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String originalConfigKey;
  final DynamicFormPageModel formData;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  const FormTemplateModel({
    required this.id,
    required this.name,
    required this.description,
    required this.originalConfigKey,
    required this.formData,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  factory FormTemplateModel.fromJson(Map<String, dynamic> json) {
    return FormTemplateModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      originalConfigKey: json['originalConfigKey'] ?? '',
      formData: DynamicFormPageModel.fromJson(json['formData'] ?? {}),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      metadata: json['metadata'],
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    originalConfigKey,
    formData,
    createdAt,
    updatedAt,
    metadata,
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'originalConfigKey': originalConfigKey,
      'formData': formData.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  // Get form data in the format {pageId: id, layout: [components]}
  Map<String, dynamic> getFormLayoutData() {
    return formData.toFormLayoutJson();
  }

  // Create from form layout data with pageId format
  factory FormTemplateModel.fromFormLayoutData({
    required String id,
    required String name,
    required String description,
    required String originalConfigKey,
    required Map<String, dynamic> formLayoutData,
    Map<String, dynamic>? metadata,
  }) {
    final formData = DynamicFormPageModel.fromFormLayoutJson(formLayoutData);
    return FormTemplateModel(
      id: id,
      name: name,
      description: description,
      originalConfigKey: originalConfigKey,
      formData: formData,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      metadata: metadata,
    );
  }

  FormTemplateModel copyWith({
    String? id,
    String? name,
    String? description,
    String? originalConfigKey,
    DynamicFormPageModel? formData,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return FormTemplateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      originalConfigKey: originalConfigKey ?? this.originalConfigKey,
      formData: formData ?? this.formData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
