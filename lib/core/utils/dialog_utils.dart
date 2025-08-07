import 'package:flutter/material.dart';

class DialogUtils {
  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static Future<Map<String, dynamic>?> showComponentConfigDialog(
    BuildContext context,
    Map<String, dynamic> currentConfig,
  ) async {
    final TextEditingController labelController = TextEditingController(
      text: currentConfig['label'] ?? '',
    );
    final TextEditingController placeholderController = TextEditingController(
      text: currentConfig['placeholder'] ?? '',
    );
    final TextEditingController descriptionController = TextEditingController(
      text: currentConfig['description'] ?? '',
    );
    final TextEditingController valueController = TextEditingController(
      text: currentConfig['value']?.toString() ?? '',
    );
    final TextEditingController errorTextController = TextEditingController(
      text: currentConfig['errorText'] ?? '',
    );
    bool isRequired = currentConfig['isRequired'] ?? false;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Component Configuration'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(
                    labelText: 'Label',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: placeholderController,
                  decoration: const InputDecoration(
                    labelText: 'Placeholder',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    hintText: 'Enter description for this field...',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: valueController,
                  decoration: const InputDecoration(
                    labelText: 'Default Value',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: errorTextController,
                  decoration: const InputDecoration(
                    labelText: 'Error Text',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: isRequired,
                      onChanged: (value) => isRequired = value ?? false,
                    ),
                    const Text('Required'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'label': labelController.text,
                  'placeholder': placeholderController.text,
                  'description': descriptionController.text, // Add description
                  'value': valueController.text,
                  'errorText': errorTextController.text,
                  'isRequired': isRequired,
                });
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
