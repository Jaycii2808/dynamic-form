class ButtonCondition {
  final String componentId;
  final String type; // 'input' or 'toggle'
  final String rule; // 'not_null', 'equals', 'not_empty', etc.
  final dynamic expectedValue; // for 'equals' rule
  final String errorMessage;

  ButtonCondition({
    required this.componentId,
    required this.type,
    required this.rule,
    this.expectedValue,
    required this.errorMessage,
  });

  factory ButtonCondition.fromJson(Map<String, dynamic> json) {
    return ButtonCondition(
      componentId: json['component_id'] as String,
      type: json['type'] as String,
      rule: json['rule'] as String,
      expectedValue: json['expected_value'],
      errorMessage:
          json['error_message'] as String? ?? 'Điều kiện không thỏa mãn',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'component_id': componentId,
      'type': type,
      'rule': rule,
      'expected_value': expectedValue,
      'error_message': errorMessage,
    };
  }
}
