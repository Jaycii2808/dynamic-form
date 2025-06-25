import 'package:flutter/material.dart';

class FormStyleUtils {
  static const double fieldVerticalSpacing = 16.0;
  static const double fieldHorizontalPadding = 16.0;
  static const double fieldBorderRadius = 12.0;
  static const double fieldElevation = 1.5;

  static BoxDecoration fieldBoxDecoration({
    Color? color,
    bool error = false,
    bool focused = false,
  }) {
    return BoxDecoration(
      color: color ?? Colors.grey[900],
      borderRadius: BorderRadius.circular(fieldBorderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
      border: Border.all(
        color: error ? Colors.red : (focused ? Colors.blue : Colors.grey[700]!),
        width: 1.5,
      ),
    );
  }

  static TextStyle labelStyle(BuildContext context) => Theme.of(context)
      .textTheme
      .bodyLarge!
      .copyWith(fontWeight: FontWeight.bold, color: Colors.blue[200]);

  static TextStyle errorStyle(BuildContext context) => Theme.of(
    context,
  ).textTheme.bodySmall!.copyWith(color: Colors.red, fontSize: 12);

  static TextStyle hintStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey[500]);

  static EdgeInsets fieldPadding() => const EdgeInsets.symmetric(
    horizontal: fieldHorizontalPadding,
    vertical: 12,
  );

  static EdgeInsets fieldMargin() =>
      const EdgeInsets.only(bottom: fieldVerticalSpacing);
}
