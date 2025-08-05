import 'package:equatable/equatable.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_multi/dynamic_form_multi_model.dart';

class FormDataModel extends Equatable {
  final String? id;
  final String? name;
  final String? description;
  final List<FormForMultiPageModel> pages;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FormDataModel({
    this.id,
    this.name,
    this.description,
    this.pages = const [],
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory FormDataModel.fromJson(Map<String, dynamic> json) {
    return FormDataModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      pages: json['pages'] != null
          ? (json['pages'] as List<dynamic>)
              .map((pageData) => FormForMultiPageModel.fromJson(pageData as Map<String, dynamic>))
              .toList()
          : [],
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pages': pages.map((page) => page.toJson()).toList(),
      'metadata': metadata,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  FormDataModel copyWith({
    String? id,
    String? name,
    String? description,
    List<FormForMultiPageModel>? pages,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FormDataModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      pages: pages ?? this.pages,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        pages,
        metadata,
        createdAt,
        updatedAt,
      ];
} 