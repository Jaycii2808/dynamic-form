class FormMemoryRepository {
  static final Map<String, Map<String, dynamic>> _forms = {};

  static void saveForm(String id, Map<String, dynamic> formJson) {
    _forms[id] = formJson;
  }

  static Map<String, dynamic>? getFormById(String id) {
    return _forms[id];
  }

  static List<Map<String, dynamic>> getAllForms() {
    return _forms.values.toList();
  }
}
