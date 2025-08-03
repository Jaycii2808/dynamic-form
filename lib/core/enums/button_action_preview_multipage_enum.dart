enum ButtonActionPreviewMultipageEnum {
  previousPage('previous_page'),
  nextPage('next_page'),
  submitForm('submit_form'),
  saveForm('save_form'),
  clearForm('clear_form'),
  customAction('custom_action');

  final String value;
  const ButtonActionPreviewMultipageEnum(this.value);

  static ButtonActionPreviewMultipageEnum fromString(String value) {
    return values.firstWhere(
      (action) => action.value == value,
      orElse: () => throw Exception('Unknown preview action: $value'),
    );
  }

  static ButtonActionPreviewMultipageEnum? tryFromString(String value) {
    try {
      return fromString(value);
    } catch (e) {
      return null;
    }
  }
}
