import 'package:equatable/equatable.dart';
import 'package:dynamic_form_bi/data/models/validation/base_validation.dart';

class ButtonConditionValidation extends BaseValidation {
  final List<ButtonCondition> conditions;
  final String? nextPage;
  final String? previousPage;

  const ButtonConditionValidation({
    this.conditions = const [],
    this.nextPage,
    this.previousPage,
  });

  factory ButtonConditionValidation.fromJson(Map<String, dynamic> json) {
    final conditionsJson = json['condition'] as List<dynamic>?;
    List<ButtonCondition> conditions = [];

    if (conditionsJson != null) {
      conditions = conditionsJson
          .map((item) => ButtonCondition.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    // Không gán nhầm next_page/previous_page vào conditions
    return ButtonConditionValidation(
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

  ButtonConditionValidation copyWith({
    List<ButtonCondition>? conditions,
    String? nextPage,
    String? previousPage,
  }) {
    return ButtonConditionValidation(
      conditions: conditions ?? this.conditions,
      nextPage: nextPage ?? this.nextPage,
      previousPage: previousPage ?? this.previousPage,
    );
  }
}

class ButtonCondition extends Equatable {
  final String idComponent;
  final bool? isRequired;
  final String? errorMessage;
  final String? regex;
  final String? regexError;

  const ButtonCondition({
    required this.idComponent,
    this.isRequired,
    this.errorMessage,
    this.regex,
    this.regexError,
  });

  factory ButtonCondition.fromJson(Map<String, dynamic> json) {
    return ButtonCondition(
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

  ButtonCondition copyWith({
    String? idComponent,
    bool? isRequired,
    String? errorMessage,
    String? regex,
    String? regexError,
  }) {
    return ButtonCondition(
      idComponent: idComponent ?? this.idComponent,
      isRequired: isRequired ?? this.isRequired,
      errorMessage: errorMessage ?? this.errorMessage,
      regex: regex ?? this.regex,
      regexError: regexError ?? this.regexError,
    );
  }
}
