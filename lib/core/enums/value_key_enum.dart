enum ValueKeyEnum {
  value('value'),
  label('label'),
  errorText('error_text'),
  currentState('current_state'),
  editable('editable'),
  disabled('disabled'),
  readOnly('readOnly'),
  isRequired('is_required');

  final String key;
  const ValueKeyEnum(this.key);
}
