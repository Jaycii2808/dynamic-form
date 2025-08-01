import 'package:equatable/equatable.dart';
import 'package:dynamic_form_bi/data/models/validation/base_validation.dart';

class ButtonConditionValidationModel extends BaseValidation {
  final List<ButtonConditionModel> conditions;
  final String? nextPage;
  final String? previousPage;

  const ButtonConditionValidationModel({
    this.conditions = const [],
    this.nextPage,
    this.previousPage,
  });

  factory ButtonConditionValidationModel.fromJson(Map<String, dynamic> json) {
    final conditionJson = json['condition'];
    List<ButtonConditionModel> conditions = [];

    if (conditionJson != null) {
      if (conditionJson is List) {
        // Handle array of conditions
        conditions = conditionJson
            .map(
              (item) =>
                  ButtonConditionModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } else if (conditionJson is Map<String, dynamic>) {
        // Handle single condition object
        conditions = [ButtonConditionModel.fromJson(conditionJson)];
      }
    }

    // Don't assign next_page/previous_page to conditions by mistake
    return ButtonConditionValidationModel(
      conditions: conditions,
      nextPage: json['next_page'] as String?,
      previousPage: json['previous_page'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['condition'] = conditions.map((c) => c.toJson()).toList();
    if (nextPage != null) map['next_page'] = nextPage;
    if (previousPage != null) map['previous_page'] = previousPage;
    return map;
  }

  @override
  List<Object?> get props => [conditions, nextPage, previousPage];

  ButtonConditionValidationModel copyWith({
    List<ButtonConditionModel>? conditions,
    String? nextPage,
    String? previousPage,
  }) {
    return ButtonConditionValidationModel(
      conditions: conditions ?? this.conditions,
      nextPage: nextPage ?? this.nextPage,
      previousPage: previousPage ?? this.previousPage,
    );
  }
}

class ButtonConditionModel extends Equatable {
  final String idComponent;
  final bool? isRequired;
  final String? errorMessage;
  final String? regex;
  final String? regexError;

  const ButtonConditionModel({
    required this.idComponent,
    this.isRequired,
    this.errorMessage,
    this.regex,
    this.regexError,
  });

  factory ButtonConditionModel.fromJson(Map<String, dynamic> json) {
    return ButtonConditionModel(
      idComponent: json['id_component']?.toString() ?? '',
      isRequired: json['is_required'] is bool ? json['is_required'] : null,
      errorMessage: json['error_message']?.toString(),
      regex: json['regex']?.toString(),
      regexError: json['regex_error']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      'id_component': idComponent,
    };

    if (isRequired != null) result['is_required'] = isRequired;
    if (errorMessage != null) result['error_message'] = errorMessage;
    if (regex != null) result['regex'] = regex;
    if (regexError != null) result['regex_error'] = regexError;

    return result;
  }

  @override
  List<Object?> get props => [
    idComponent,
    isRequired,
    errorMessage,
    regex,
    regexError,
  ];

  ButtonConditionModel copyWith({
    String? idComponent,
    bool? isRequired,
    String? errorMessage,
    String? regex,
    String? regexError,
  }) {
    return ButtonConditionModel(
      idComponent: idComponent ?? this.idComponent,
      isRequired: isRequired ?? this.isRequired,
      errorMessage: errorMessage ?? this.errorMessage,
      regex: regex ?? this.regex,
      regexError: regexError ?? this.regexError,
    );
  }
}
