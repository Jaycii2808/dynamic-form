import 'package:equatable/equatable.dart';
import 'package:dynamic_form_bi/data/models/form/form_data_model.dart';

class SharedFormModel extends Equatable {
  final String? id;
  final FormDataModel formData;
  final String formName;
  final String? recipientEmail;
  final String? recipientName;
  final DateTime? createdAt;
  final bool isActive;

  const SharedFormModel({
    this.id,
    required this.formData,
    required this.formName,
    this.recipientEmail,
    this.recipientName,
    this.createdAt,
    this.isActive = true,
  });

  factory SharedFormModel.fromJson(Map<String, dynamic> json) {
    return SharedFormModel(
      id: json['id'] as String?,
      formData: FormDataModel.fromJson(
        json['formData'] as Map<String, dynamic>,
      ),
      formName: json['formName'] as String,
      recipientEmail: json['recipientEmail'] as String?,
      recipientName: json['recipientName'] as String?,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as dynamic).toDate() as DateTime?
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  factory SharedFormModel.fromFirestoreResult(Map<String, dynamic> result) {
    return SharedFormModel(
      formData: FormDataModel.fromJson(
        result['formData'] as Map<String, dynamic>,
      ),
      formName: result['formName'] as String,
      recipientEmail: result['recipientEmail'] as String?,
      recipientName: result['recipientName'] as String?,
      createdAt: result['createdAt'] != null
          ? (result['createdAt'] as dynamic).toDate() as DateTime?
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'formData': formData.toJson(),
      'formName': formName,
      'recipientEmail': recipientEmail,
      'recipientName': recipientName,
      'createdAt': createdAt,
      'isActive': isActive,
    };
  }

  SharedFormModel copyWith({
    String? id,
    FormDataModel? formData,
    String? formName,
    String? recipientEmail,
    String? recipientName,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return SharedFormModel(
      id: id ?? this.id,
      formData: formData ?? this.formData,
      formName: formName ?? this.formName,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      recipientName: recipientName ?? this.recipientName,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    formData,
    formName,
    recipientEmail,
    recipientName,
    createdAt,
    isActive,
  ];
}
