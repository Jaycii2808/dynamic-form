import 'package:flutter/material.dart';

/// Shared widget for optimized input components that handle focus loss and submission events consistently
class SharedOptimizedInputWidgets {
  /// Builds an optimized question input TextField with consistent focus handling
  static Widget buildOptimizedQuestionInput({
    required BuildContext context,
    required TextEditingController controller,
    required Function(String) onUpdate,
    String? hintText,
    TextStyle? textStyle,
    TextStyle? hintStyle,
    VoidCallback? onUpdateComponent,
  }) {
    return TextField(
      controller: controller,
      style:
          textStyle ??
          const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            height: 1.3,
          ),
      decoration: InputDecoration(
        hintText: hintText ?? 'Question',
        hintStyle:
            hintStyle ??
            const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.3,
              fontStyle: FontStyle.italic,
            ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
        onUpdate(controller.text);
        onUpdateComponent?.call();
      },
      onSubmitted: (value) {
        FocusScope.of(context).unfocus();
        onUpdate(value);
        onUpdateComponent?.call();
      },
      onEditingComplete: () {
        FocusScope.of(context).unfocus();
        onUpdate(controller.text);
        onUpdateComponent?.call();
      },
    );
  }

  /// Builds an optimized option input TextField with consistent focus handling for dropdown options
  static Widget buildOptimizedOptionInput({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required Function(String) onUpdate,
    String? hintText,
    TextStyle? textStyle,
    TextStyle? hintStyle,
    VoidCallback? onUpdateComponent,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      style:
          textStyle ??
          const TextStyle(
            fontSize: 13,
            color: Colors.white,
          ),
      decoration: InputDecoration(
        hintText: hintText ?? 'Option',
        hintStyle:
            hintStyle ??
            const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 13,
            ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
        onUpdate(controller.text);
        onUpdateComponent?.call();
      },
      onSubmitted: (value) {
        FocusScope.of(context).unfocus();
        onUpdate(value);
        onUpdateComponent?.call();
      },
      onEditingComplete: () {
        FocusScope.of(context).unfocus();
        onUpdate(controller.text);
        onUpdateComponent?.call();
      },
      onChanged: (value) => onUpdate(value),
    );
  }

  /// Builds an optimized dropdown with consistent focus handling
  static Widget buildOptimizedDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onUpdate,
    required BuildContext context,
    VoidCallback? onUpdateComponent,
    Color? dropdownColor,
    TextStyle? style,
    double? iconSize,
    bool isExpanded = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: dropdownColor ?? const Color(0xFF374151),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF4B5563)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          onChanged: (T? newValue) {
            onUpdate(newValue);
            onUpdateComponent?.call();
            // Unfocus after selection
            FocusScope.of(context).unfocus();
          },
          dropdownColor: dropdownColor ?? const Color(0xFF374151),
          style:
              style ??
              const TextStyle(
                color: Colors.white,
                fontSize: 11,
              ),
          items: items,
          isExpanded: isExpanded,
          iconSize: iconSize ?? 12,
        ),
      ),
    );
  }

  /// Builds an optimized compact dropdown for validation panels
  static Widget buildOptimizedCompactDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onUpdate,
    required BuildContext context,
    VoidCallback? onUpdateComponent,
  }) {
    return buildOptimizedDropdown<T>(
      value: value,
      items: items,
      onUpdate: onUpdate,
      context: context,
      onUpdateComponent: onUpdateComponent,
      dropdownColor: const Color(0xFF374151),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
      ),
      iconSize: 12,
      isExpanded: true,
    );
  }

  /// Builds an optimized compact text field for validation panels
  static Widget buildOptimizedCompactTextField({
    required BuildContext context,
    required TextEditingController controller,
    String? hintText,
    TextInputType? keyboardType,
    Function(String)? onUpdate,
    VoidCallback? onUpdateComponent,
  }) {
    return TextField(
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
        onUpdate?.call(controller.text);
        onUpdateComponent?.call();
      },
      controller: controller,
      keyboardType: keyboardType,
      onSubmitted: (value) {
        FocusScope.of(context).unfocus();
        onUpdate?.call(value);
        onUpdateComponent?.call();
      },
      onEditingComplete: () {
        FocusScope.of(context).unfocus();
        onUpdate?.call(controller.text);
        onUpdateComponent?.call();
      },
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 10,
        ),
        filled: true,
        fillColor: const Color(0xFF374151),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF4B5563)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF4B5563)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 3,
        ),
      ),
    );
  }
}
