import 'base_validation.dart';

class MaxSelectionsValidation extends BaseValidation {
  final int max;
  final String? errorMessage;

  const MaxSelectionsValidation({
    required this.max,
    this.errorMessage,
  });

  factory MaxSelectionsValidation.fromJson(Map<String, dynamic> json) {
    return MaxSelectionsValidation(
      max: json['max'] is int ? json['max'] : 0,
      errorMessage: json['error_message']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      'max': max,
    };

    if (errorMessage != null) result['error_message'] = errorMessage;

    return result;
  }

  @override
  List<Object?> get props => [max, errorMessage];

  MaxSelectionsValidation copyWith({
    int? max,
    String? errorMessage,
  }) {
    return MaxSelectionsValidation(
      max: max ?? this.max,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
