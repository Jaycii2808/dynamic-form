import 'package:flutter/material.dart';

class SharedFormBuilderWidgets {
  // Question header widget - reusable across different form types
  static Widget buildQuestionHeader({
    required Widget imageIcon,
    required Widget questionInput,
    Widget? formTypeIcon,
    String? formTypeLabel,
    EdgeInsets? padding,
    Color? borderColor,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: borderColor ?? const Color(0xFF374151),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              imageIcon,
              if (formTypeIcon != null) ...[
                Row(
                  spacing: 4,
                  children: [
                    if (formTypeLabel != null) ...[
                      Text(
                        formTypeLabel,
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    formTypeIcon,
                  ],
                ),
              ],
            ],
          ),
          questionInput,
        ],
      ),
    );
  }

  // Image icon widget - reusable
  static Widget buildImageIcon({
    VoidCallback? onTap,
    Color? backgroundColor,
    Color? iconColor,
    double? size,
  }) {
    Widget iconWidget = Container(
      width: size ?? 40,
      height: size ?? 40,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.blue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image,
        color: iconColor ?? Colors.blue,
        size: (size ?? 40) * 0.5,
      ),
    );

    if (onTap != null) {
      iconWidget = GestureDetector(
        onTap: onTap,
        child: iconWidget,
      );
    }

    return iconWidget;
  }

  // Generic form type icon widget - reusable for different form types
  static Widget buildFormTypeIcon({
    required IconData icon,
    Color? backgroundColor,
    Color? iconColor,
    double? size,
    VoidCallback? onTap,
    String? tooltip,
  }) {
    Widget iconWidget = Container(
      width: size ?? 40,
      height: size ?? 40,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.green.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: iconColor ?? Colors.green,
        size: (size ?? 40) * 0.5,
      ),
    );

    if (onTap != null) {
      iconWidget = GestureDetector(
        onTap: onTap,
        child: iconWidget,
      );
    }

    if (tooltip != null) {
      iconWidget = Tooltip(
        message: tooltip,
        child: iconWidget,
      );
    }

    return iconWidget;
  }

  // Dropdown icon widget - specific for dropdown type
  static Widget buildDropdownIcon({
    Color? backgroundColor,
    Color? iconColor,
    double? size,
    VoidCallback? onTap,
  }) {
    return buildFormTypeIcon(
      icon: Icons.arrow_drop_down,
      backgroundColor: backgroundColor ?? Colors.green.withValues(alpha: 0.2),
      iconColor: iconColor ?? Colors.green,
      size: size,
      onTap: onTap,
      tooltip: 'Dropdown',
    );
  }

  // Text field icon widget - specific for text field type
  static Widget buildTextFieldIcon({
    Color? backgroundColor,
    Color? iconColor,
    double? size,
    VoidCallback? onTap,
  }) {
    return buildFormTypeIcon(
      icon: Icons.text_fields,
      backgroundColor: backgroundColor ?? Colors.blue.withValues(alpha: 0.2),
      iconColor: iconColor ?? Colors.blue,
      size: size,
      onTap: onTap,
      tooltip: 'Text Field',
    );
  }

  // Switch icon widget - specific for switch type
  static Widget buildSwitchIcon({
    Color? backgroundColor,
    Color? iconColor,
    double? size,
    VoidCallback? onTap,
  }) {
    return buildFormTypeIcon(
      icon: Icons.toggle_on,
      backgroundColor: backgroundColor ?? Colors.orange.withValues(alpha: 0.2),
      iconColor: iconColor ?? Colors.orange,
      size: size,
      onTap: onTap,
      tooltip: 'Switch',
    );
  }

  // Date picker icon widget - specific for date picker type
  static Widget buildDatePickerIcon({
    Color? backgroundColor,
    Color? iconColor,
    double? size,
    VoidCallback? onTap,
  }) {
    return buildFormTypeIcon(
      icon: Icons.calendar_today,
      backgroundColor: backgroundColor ?? Colors.purple.withValues(alpha: 0.2),
      iconColor: iconColor ?? Colors.purple,
      size: size,
      onTap: onTap,
      tooltip: 'Date Picker',
    );
  }

  // Text area icon widget - specific for text area type
  static Widget buildTextAreaIcon({
    Color? backgroundColor,
    Color? iconColor,
    double? size,
    VoidCallback? onTap,
  }) {
    return buildFormTypeIcon(
      icon: Icons.text_fields_outlined,
      backgroundColor: backgroundColor ?? Colors.teal.withValues(alpha: 0.2),
      iconColor: iconColor ?? Colors.teal,
      size: size,
      onTap: onTap,
      tooltip: 'Text Area',
    );
  }

  // Button icon widget - specific for button type
  static Widget buildButtonIcon({
    Color? backgroundColor,
    Color? iconColor,
    double? size,
    VoidCallback? onTap,
  }) {
    return buildFormTypeIcon(
      icon: Icons.smart_button,
      backgroundColor: backgroundColor ?? Colors.red.withValues(alpha: 0.2),
      iconColor: iconColor ?? Colors.red,
      size: size,
      onTap: onTap,
      tooltip: 'Button',
    );
  }

  // Question input widget - reusable
  static Widget buildQuestionInput({
    required TextEditingController controller,
    required Function(String) onChanged,
    String? hintText,
    TextStyle? textStyle,
    TextStyle? hintStyle,
  }) {
    return TextField(
      controller: controller,
      style:
          textStyle ??
          const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
      decoration: InputDecoration(
        hintText: hintText ?? 'Question',
        hintStyle:
            hintStyle ??
            const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      onChanged: onChanged,
    );
  }

  // Loading widget - reusable
  static Widget buildLoadingWidget() {
    return const Center(child: CircularProgressIndicator());
  }

  // Error widget - reusable
  static Widget buildErrorWidget({
    required String errorMessage,
    EdgeInsets? margin,
    EdgeInsets? padding,
    Color? backgroundColor,
    Color? borderColor,
    Color? textColor,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor ?? Colors.red),
      ),
      child: Text(
        'Error: $errorMessage',
        style: TextStyle(color: textColor ?? Colors.red),
      ),
    );
  }

  // Main container widget - reusable
  static Widget buildMainContainer({
    required Widget child,
    EdgeInsets? margin,
    Color? backgroundColor,
    Color? borderColor,
    double? borderRadius,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
        border: Border.all(color: borderColor ?? const Color(0xFF374151)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  // Common bottom controls widget - reusable for form elements
  static Widget buildCommonBottomControls({
    VoidCallback? onDuplicate,
    VoidCallback? onDelete,
    required bool isRequired,
    ValueChanged<bool>? onRequiredChanged,
    VoidCallback? onMoreOptions,
  }) {
    debugPrint('Building CommonBottomControls with isRequired: $isRequired');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFF374151),
            width: 1,
          ), // Dark border
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Duplicate button
          GestureDetector(
            onTap: onDuplicate,
            child: Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 4),
              child: const Icon(
                Icons.content_copy,
                color: Color(0xFF9CA3AF), // Light gray
                size: 18,
              ),
            ),
          ),

          // Delete button
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 4),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 18,
              ),
            ),
          ),

          // Required toggle - make it flexible
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Required',
                  style: TextStyle(
                    color: Colors.white, // White text
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Switch(
                  value: isRequired,
                  onChanged: onRequiredChanged,
                  activeColor: Colors.blue,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),

          const SizedBox(width: 4),

          // More options
          GestureDetector(
            onTap: onMoreOptions,
            child: const SizedBox(
              width: 28,
              height: 28,
              child: Icon(
                Icons.more_vert,
                color: Color(0xFF9CA3AF), // Light gray
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for dropdown question header
  static Widget buildDropdownQuestionHeader({
    required Widget questionInput,
    VoidCallback? onImageTap,
    VoidCallback? onDropdownTap,
  }) {
    return buildQuestionHeader(
      imageIcon: buildImageIcon(onTap: onImageTap),
      formTypeIcon: buildDropdownIcon(onTap: onDropdownTap),
      formTypeLabel: 'Dropdown',
      questionInput: questionInput,
    );
  }

  // Helper method for text field question header
  static Widget buildTextFieldQuestionHeader({
    required Widget questionInput,
    VoidCallback? onImageTap,
    VoidCallback? onTextFieldTap,
  }) {
    return buildQuestionHeader(
      imageIcon: buildImageIcon(onTap: onImageTap),
      formTypeIcon: buildTextFieldIcon(onTap: onTextFieldTap),
      formTypeLabel: 'Text Field',
      questionInput: questionInput,
    );
  }

  // Helper method for switch question header
  static Widget buildSwitchQuestionHeader({
    required Widget questionInput,
    VoidCallback? onImageTap,
    VoidCallback? onSwitchTap,
  }) {
    return buildQuestionHeader(
      imageIcon: buildImageIcon(onTap: onImageTap),
      formTypeIcon: buildSwitchIcon(onTap: onSwitchTap),
      formTypeLabel: 'Switch',
      questionInput: questionInput,
    );
  }

  // Helper method for date picker question header
  static Widget buildDatePickerQuestionHeader({
    required Widget questionInput,
    VoidCallback? onImageTap,
    VoidCallback? onDatePickerTap,
  }) {
    return buildQuestionHeader(
      imageIcon: buildImageIcon(onTap: onImageTap),
      formTypeIcon: buildDatePickerIcon(onTap: onDatePickerTap),
      formTypeLabel: 'Date Picker',
      questionInput: questionInput,
    );
  }

  // Helper method for text area question header
  static Widget buildTextAreaQuestionHeader({
    required Widget questionInput,
    VoidCallback? onImageTap,
    VoidCallback? onTextAreaTap,
  }) {
    return buildQuestionHeader(
      imageIcon: buildImageIcon(onTap: onImageTap),
      formTypeIcon: buildTextAreaIcon(onTap: onTextAreaTap),
      formTypeLabel: 'Text Area',
      questionInput: questionInput,
    );
  }

  // Helper method for button question header
  static Widget buildButtonQuestionHeader({
    required Widget questionInput,
    VoidCallback? onImageTap,
    VoidCallback? onButtonTap,
  }) {
    return buildQuestionHeader(
      imageIcon: buildImageIcon(onTap: onImageTap),
      formTypeIcon: buildButtonIcon(onTap: onButtonTap),
      formTypeLabel: 'Button',
      questionInput: questionInput,
    );
  }

  // Generic helper method for any form type
  static Widget buildFormTypeQuestionHeader({
    required Widget questionInput,
    required IconData formTypeIcon,
    required String formTypeLabel,
    Color? formTypeIconColor,
    Color? formTypeIconBackgroundColor,
    VoidCallback? onImageTap,
    VoidCallback? onFormTypeTap,
  }) {
    return buildQuestionHeader(
      imageIcon: buildImageIcon(onTap: onImageTap),
      formTypeIcon: buildFormTypeIcon(
        icon: formTypeIcon,
        backgroundColor: formTypeIconBackgroundColor,
        iconColor: formTypeIconColor,
        onTap: onFormTypeTap,
        tooltip: formTypeLabel,
      ),
      formTypeLabel: formTypeLabel,
      questionInput: questionInput,
    );
  }
}
