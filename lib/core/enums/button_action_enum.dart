enum ButtonAction {
  previewForm('preview_form'),
  submitForm('submit_form'),
  resetForm('reset_form'),
  previousPage('previous_page'),
  nextPage('next_page');


  final String value;
  const ButtonAction(this.value);

  static ButtonAction fromString(String value) {
    return values.firstWhere(
          (action) => action.value == value,
      orElse: () => throw Exception('Unknown action: $value'),
    );
  }
}

