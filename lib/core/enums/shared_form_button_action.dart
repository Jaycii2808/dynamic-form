// Button action enum for shared form
enum SharedFormButtonAction {
  submitForm('submit_form'),
  nextPage('next_page'),
  previousPage('previous_page');

  const SharedFormButtonAction(this.value);
  final String value;

  static SharedFormButtonAction? fromString(String? value) {
    if (value == null) return null;
    return SharedFormButtonAction.values.firstWhere(
          (action) => action.value == value,
      orElse: () => throw ArgumentError('Unknown button action: $value'),
    );
  }
}