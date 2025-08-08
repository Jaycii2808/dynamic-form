import 'package:flutter/material.dart';

// Enum for form types
enum FormType {
  dropdown,
  textField,
  switchType,
  datePicker,
  textArea,
  button,
  radio,
  checkbox,
}

// More options dialog option model
class MoreOptionsDialogOption {
  final String label;
  final VoidCallback onPressed;
  final Color? textColor;
  final IconData? icon;
  final bool isToggleable;
  final bool isChecked;
  final VoidCallback? onToggle;

  const MoreOptionsDialogOption({
    required this.label,
    required this.onPressed,
    this.textColor,
    this.icon,
    this.isToggleable = false,
    this.isChecked = false,
    this.onToggle,
  });

  // Factory constructor for toggleable options
  factory MoreOptionsDialogOption.toggleable({
    required String label,
    required bool isChecked,
    required VoidCallback onToggle,
    Color? textColor,
    IconData? icon,
  }) {
    return MoreOptionsDialogOption(
      label: label,
      onPressed: onToggle,
      textColor: textColor,
      icon: icon,
      isToggleable: true,
      isChecked: isChecked,
      onToggle: onToggle,
    );
  }
}

class SharedFormBuilderWidgets {
  // Question header widget - reusable across different form types
  static Widget buildTitleHeader({
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
            fontSize: 20, // Larger font size for question
            fontWeight: FontWeight.w600, // Bolder font weight
            color: Colors.white,
            height: 1.3, // Better line height
          ),
      decoration: InputDecoration(
        hintText: hintText ?? 'Question',
        hintStyle:
            hintStyle ??
            const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 20, // Larger hint text
              fontWeight: FontWeight.w600,
              height: 1.3,
              fontStyle: FontStyle.italic,
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
    VoidCallback? onDescriptionTap,
  }) {
    debugPrint('Building CommonBottomControls with isRequired: $isRequired');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFF374151),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Action buttons group
          Row(
            children: [
              _buildActionButton(
                icon: Icons.content_copy,
                color: const Color(0xFF9CA3AF),
                onTap: onDuplicate,
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.delete_outline,
                color: Colors.red,
                onTap: onDelete,
              ),
            ],
          ),

          const Spacer(),

          // Required toggle
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Required',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: isRequired,
                  onChanged: onRequiredChanged,
                  activeColor: Colors.blue,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),

          const SizedBox(width: 8),

          // More options
          _buildActionButton(
            icon: Icons.more_vert,
            color: const Color(0xFF9CA3AF),
            onTap: onMoreOptions,
          ),
        ],
      ),
    );
  }

  // Helper method to build action buttons
  static Widget _buildActionButton({
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Icon(
          icon,
          color: color,
          size: 16,
        ),
      ),
    );
  }

  // Helper method to show description dialog
  static void showDescriptionDialog({
    required BuildContext context,
    required String currentDescription,
    required Function(String) onDescriptionChanged,
    FormType? formType,
  }) {
    debugPrint('Showing description dialog for form type: $formType');

    final TextEditingController descriptionController = TextEditingController(
      text: currentDescription,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F2937),
          title: const Row(
            children: [
              Icon(
                Icons.description,
                color: Color(0xFF9CA3AF),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Add Description',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add a detailed description for this ${formType?.name ?? 'form'} field:',
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 4,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter description here...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF374151),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF374151),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final newDescription = descriptionController.text.trim();
                onDescriptionChanged(newDescription);
                Navigator.of(context).pop();
                debugPrint('Description updated: $newDescription');
              },
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper method to show more options dialog
  static void showMoreOptionsDialog({
    required BuildContext context,
    required List<MoreOptionsDialogOption> options,
    String? title,
    String? content,
    bool showCancelButton = true,
  }) {
    debugPrint('Showing more options dialog with ${options.length} options');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1F2937),
              title: Text(
                title ?? 'More Options',
                style: const TextStyle(color: Colors.white),
              ),
              content: content != null
                  ? Text(
                      content,
                      style: const TextStyle(color: Colors.white),
                    )
                  : null,
              actions: [
                // Custom options
                ...options.map(
                  (option) => TextButton(
                    onPressed: () {
                      if (option.isToggleable) {
                        // For toggleable options, call toggle and rebuild dialog
                        option.onToggle?.call();
                        // Force rebuild of dialog to show updated state
                        setState(() {});
                      } else {
                        // For regular options, close dialog and execute action
                        Navigator.of(context).pop();
                        option.onPressed();
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (option.icon != null) ...[
                          Icon(
                            option.icon!,
                            color: option.textColor ?? Colors.blue,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          option.label,
                          style: TextStyle(
                            color: option.textColor ?? Colors.blue,
                          ),
                        ),
                        if (option.isToggleable) ...[
                          const SizedBox(width: 8),
                          Icon(
                            option.isChecked
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: option.isChecked
                                ? Colors.green
                                : Colors.grey,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Cancel button
                if (showCancelButton)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  // Helper method to show more options dialog with real-time updates
  static void showMoreOptionsDialogWithUpdates({
    required BuildContext context,
    required List<MoreOptionsDialogOption> Function() getOptions,
    String? title,
    String? content,
    bool showCancelButton = true,
  }) {
    debugPrint('Showing more options dialog with real-time updates');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // Get latest options
            final options = getOptions();

            return AlertDialog(
              backgroundColor: const Color(0xFF1F2937),
              title: Text(
                title ?? 'More Options',
                style: const TextStyle(color: Colors.white),
              ),
              content: content != null
                  ? Text(
                      content,
                      style: const TextStyle(color: Colors.white),
                    )
                  : null,
              actions: [
                // Custom options
                ...options.map(
                  (option) => TextButton(
                    onPressed: () {
                      if (option.isToggleable) {
                        // For toggleable options, call toggle and close dialog
                        option.onToggle?.call();
                        Navigator.of(context).pop();
                      } else {
                        // For regular options, close dialog and execute action
                        Navigator.of(context).pop();
                        option.onPressed();
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (option.icon != null) ...[
                          Icon(
                            option.icon!,
                            color: option.textColor ?? Colors.blue,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          option.label,
                          style: TextStyle(
                            color: option.textColor ?? Colors.blue,
                          ),
                        ),
                        if (option.isToggleable) ...[
                          const SizedBox(width: 8),
                          Icon(
                            option.isChecked
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: option.isChecked
                                ? Colors.green
                                : Colors.grey,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Cancel button
                if (showCancelButton)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  // Helper method to show more options as bottom sheet
  static void showMoreOptionsBottomSheet({
    required BuildContext context,
    required List<MoreOptionsDialogOption> Function() getOptions,
    String? title,
    String? content,
    bool showCancelButton = true,
  }) {
    debugPrint('Showing more options bottom sheet');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // Get latest options
            final options = getOptions();

            return Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2D3748), // Dark container color
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with "Options" text
                  // ignore: prefer_const_constructors
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      'Options',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Divider
                  Container(
                    height: 1,
                    color: const Color(0xFF4A5568),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),

                  // Options list
                  ...options.map(
                    (option) => Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            if (option.isToggleable) {
                              // For toggleable options, call toggle and close
                              option.onToggle?.call();
                              Navigator.of(context).pop();
                            } else {
                              // For regular options, close and execute action
                              Navigator.of(context).pop();
                              option.onPressed();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                            child: Row(
                              children: [
                                if (option.icon != null) ...[
                                  Icon(
                                    option.icon!,
                                    color: option.textColor ?? Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Expanded(
                                  child: Text(
                                    option.label,
                                    style: TextStyle(
                                      color: option.textColor ?? Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                if (option.isToggleable) ...[
                                  Icon(
                                    option.isChecked
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: option.isChecked
                                        ? Colors.green
                                        : const Color(0xFF6B7280),
                                    size: 20,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Divider before cancel
                  Container(
                    height: 1,
                    color: const Color(0xFF4A5568),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),

                  // Cancel button
                  if (showCancelButton)
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: const Text(
                              'Cancel',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Bottom padding
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Predefined options for different form types
  static List<MoreOptionsDialogOption> getDropdownMoreOptions({
    required VoidCallback onDescriptionTap,
    required VoidCallback onNavigationFeatureTap,
    bool isNavigationEnabled = false,
    bool isDescriptionEnabled = false,
    VoidCallback? onNavigationToggle,
    VoidCallback? onDescriptionToggle,
  }) {
    final List<MoreOptionsDialogOption> options = [];

    // Add toggleable description option
    if (onDescriptionToggle != null) {
      options.add(
        MoreOptionsDialogOption.toggleable(
          label: 'Description',
          isChecked: isDescriptionEnabled,
          onToggle: onDescriptionToggle,
          textColor: Colors.blue,
          icon: Icons.description,
        ),
      );
    } else {
      // Fallback to regular option
      options.add(
        MoreOptionsDialogOption(
          label: 'Description',
          onPressed: onDescriptionTap,
          textColor: Colors.blue,
          icon: Icons.description,
        ),
      );
    }

    // Add toggleable navigation option
    if (onNavigationToggle != null) {
      options.add(
        MoreOptionsDialogOption.toggleable(
          label: 'Go to page based on answer',
          isChecked: isNavigationEnabled,
          onToggle: onNavigationToggle,
          textColor: Colors.blue,
          icon: Icons.navigation,
        ),
      );
    } else {
      // Fallback to regular option
      options.add(
        MoreOptionsDialogOption(
          label: 'Go to page based on answer',
          onPressed: onNavigationFeatureTap,
          textColor: Colors.blue,
          icon: Icons.navigation,
        ),
      );
    }

    return options;
  }

  static List<MoreOptionsDialogOption> getTextFieldMoreOptions({
    required VoidCallback onDescriptionTap,
    VoidCallback? onValidationTap,
    VoidCallback? onPlaceholderTap,
    bool isValidationEnabled = false,
    bool isPlaceholderEnabled = false,
    VoidCallback? onValidationToggle,
    VoidCallback? onPlaceholderToggle,
  }) {
    final options = [
      MoreOptionsDialogOption(
        label: 'Description',
        onPressed: onDescriptionTap,
        textColor: Colors.blue,
        icon: Icons.description,
      ),
    ];

    if (onValidationToggle != null) {
      options.add(
        MoreOptionsDialogOption.toggleable(
          label: 'Validation Rules',
          isChecked: isValidationEnabled,
          onToggle: onValidationToggle,
          textColor: Colors.blue,
          icon: Icons.rule,
        ),
      );
    } else if (onValidationTap != null) {
      options.add(
        MoreOptionsDialogOption(
          label: 'Validation Rules',
          onPressed: onValidationTap,
          textColor: Colors.blue,
          icon: Icons.rule,
        ),
      );
    }

    if (onPlaceholderToggle != null) {
      options.add(
        MoreOptionsDialogOption.toggleable(
          label: 'Placeholder Text',
          isChecked: isPlaceholderEnabled,
          onToggle: onPlaceholderToggle,
          textColor: Colors.blue,
          icon: Icons.text_fields,
        ),
      );
    } else if (onPlaceholderTap != null) {
      options.add(
        MoreOptionsDialogOption(
          label: 'Placeholder Text',
          onPressed: onPlaceholderTap,
          textColor: Colors.blue,
          icon: Icons.text_fields,
        ),
      );
    }

    return options;
  }

  static List<MoreOptionsDialogOption> getSwitchMoreOptions({
    required VoidCallback onDescriptionTap,
    VoidCallback? onDefaultValueTap,
    bool isDefaultValueEnabled = false,
    VoidCallback? onDefaultValueToggle,
  }) {
    final options = [
      MoreOptionsDialogOption(
        label: 'Description',
        onPressed: onDescriptionTap,
        textColor: Colors.blue,
        icon: Icons.description,
      ),
    ];

    if (onDefaultValueToggle != null) {
      options.add(
        MoreOptionsDialogOption.toggleable(
          label: 'Default Value',
          isChecked: isDefaultValueEnabled,
          onToggle: onDefaultValueToggle,
          textColor: Colors.blue,
          icon: Icons.toggle_on,
        ),
      );
    } else if (onDefaultValueTap != null) {
      options.add(
        MoreOptionsDialogOption(
          label: 'Default Value',
          onPressed: onDefaultValueTap,
          textColor: Colors.blue,
          icon: Icons.toggle_on,
        ),
      );
    }

    return options;
  }

  static List<MoreOptionsDialogOption> getDatePickerMoreOptions({
    required VoidCallback onDescriptionTap,
    VoidCallback? onDateFormatTap,
    VoidCallback? onMinMaxDateTap,
    bool isDateFormatEnabled = false,
    bool isMinMaxDateEnabled = false,
    VoidCallback? onDateFormatToggle,
    VoidCallback? onMinMaxDateToggle,
  }) {
    final options = [
      MoreOptionsDialogOption(
        label: 'Description',
        onPressed: onDescriptionTap,
        textColor: Colors.blue,
        icon: Icons.description,
      ),
    ];

    if (onDateFormatToggle != null) {
      options.add(
        MoreOptionsDialogOption.toggleable(
          label: 'Date Format',
          isChecked: isDateFormatEnabled,
          onToggle: onDateFormatToggle,
          textColor: Colors.blue,
          icon: Icons.date_range,
        ),
      );
    } else if (onDateFormatTap != null) {
      options.add(
        MoreOptionsDialogOption(
          label: 'Date Format',
          onPressed: onDateFormatTap,
          textColor: Colors.blue,
          icon: Icons.date_range,
        ),
      );
    }

    if (onMinMaxDateToggle != null) {
      options.add(
        MoreOptionsDialogOption.toggleable(
          label: 'Min/Max Date',
          isChecked: isMinMaxDateEnabled,
          onToggle: onMinMaxDateToggle,
          textColor: Colors.blue,
          icon: Icons.calendar_today,
        ),
      );
    } else if (onMinMaxDateTap != null) {
      options.add(
        MoreOptionsDialogOption(
          label: 'Min/Max Date',
          onPressed: onMinMaxDateTap,
          textColor: Colors.blue,
          icon: Icons.calendar_today,
        ),
      );
    }

    return options;
  }

  // Helper method for dropdown question header
  static Widget buildDropdownQuestionHeader({
    required Widget questionInput,
    VoidCallback? onImageTap,
    VoidCallback? onDropdownTap,
  }) {
    return buildTitleHeader(
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
    return buildTitleHeader(
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
    return buildTitleHeader(
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
    return buildTitleHeader(
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
    return buildTitleHeader(
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
    return buildTitleHeader(
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
    return buildTitleHeader(
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

  // Description section widget - reusable for all form components
  static Widget buildDescriptionSection({
    required TextEditingController descriptionController,
    required String currentDescription,
    required Function(String) onDescriptionChanged,
    bool showBorder = true,
    bool isEditing = false,
    bool isEnabled = true, // Add enabled state
    VoidCallback? onEditTap,
    VoidCallback? onCancelEdit,
  }) {
    // Hide description section if disabled or empty and not editing
    if (!isEnabled ||
        (currentDescription.isEmpty &&
            descriptionController.text.isEmpty &&
            !isEditing)) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: showBorder
          ? const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color(0xFF374151),
                  width: 1,
                ),
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description header with edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Description',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (!isEditing &&
                  (currentDescription.isNotEmpty ||
                      descriptionController.text.isNotEmpty))
                GestureDetector(
                  onTap: onEditTap,
                  child: const Icon(
                    Icons.edit,
                    color: Color(0xFF9CA3AF),
                    size: 16,
                  ),
                ),
              if (isEditing)
                Row(
                  children: [
                    GestureDetector(
                      onTap: onCancelEdit,
                      child: const Icon(
                        Icons.close,
                        color: Color(0xFF9CA3AF),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        // Save description
                        onDescriptionChanged(descriptionController.text);
                        onCancelEdit?.call();
                      },
                      child: const Icon(
                        Icons.check,
                        color: Colors.green,
                        size: 16,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Description text field
          TextField(
            controller: descriptionController,
            enabled: isEditing,
            style: TextStyle(
              fontSize: 15,
              color: isEditing ? Colors.white : const Color(0xFF9CA3AF),
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: isEditing
                  ? 'Enter description here...'
                  : 'No description added',
              hintStyle: TextStyle(
                color: isEditing
                    ? const Color(0xFF6B7280)
                    : const Color(0xFF9CA3AF),
                fontSize: 15,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
              border: isEditing
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF374151)),
                    )
                  : InputBorder.none,
              enabledBorder: isEditing
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF374151)),
                    )
                  : InputBorder.none,
              focusedBorder: isEditing
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.blue),
                    )
                  : InputBorder.none,
              filled: isEditing,
              fillColor: isEditing
                  ? const Color(0xFF111827)
                  : Colors.transparent,
              contentPadding: isEditing
                  ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                  : EdgeInsets.zero,
            ),
            onChanged: isEditing ? onDescriptionChanged : null,
            maxLines: isEditing ? 4 : 1,
            readOnly: !isEditing,
          ),
        ],
      ),
    );
  }

  /*
   * USAGE EXAMPLES FOR DIFFERENT FORM TYPES:
   *
   * 1. For Dropdown:
   *    SharedFormBuilderWidgets.buildDropdownQuestionHeader(
   *      questionInput: questionInputWidget,
   *      onImageTap: () => showImageDialog(),
   *      onDropdownTap: () => showDropdownInfo(),
   *    );
   *
   * 2. For Text Field:
   *    SharedFormBuilderWidgets.buildTextFieldQuestionHeader(
   *      questionInput: questionInputWidget,
   *      onImageTap: () => showImageDialog(),
   *      onTextFieldTap: () => showTextFieldInfo(),
   *    );
   *
   * 3. For Switch:
   *    SharedFormBuilderWidgets.buildSwitchQuestionHeader(
   *      questionInput: questionInputWidget,
   *      onImageTap: () => showImageDialog(),
   *      onSwitchTap: () => showSwitchInfo(),
   *    );
   *
   * 4. For Custom Form Type:
   *    SharedFormBuilderWidgets.buildFormTypeQuestionHeader(
   *      questionInput: questionInputWidget,
   *      formTypeIcon: Icons.radio_button_checked,
   *      formTypeLabel: 'Radio Button',
   *      formTypeIconColor: Colors.purple,
   *      formTypeIconBackgroundColor: Colors.purple.withValues(alpha: 0.2),
   *      onImageTap: () => showImageDialog(),
   *      onFormTypeTap: () => showRadioInfo(),
   *    );
   *
   * 5. For Generic Usage:
   *    SharedFormBuilderWidgets.buildTitleHeader(
   *      imageIcon: customImageIcon,
   *      formTypeIcon: customFormTypeIcon,
   *      formTypeLabel: 'Custom Type',
   *      questionInput: questionInputWidget,
   *    );
   *
   * 6. For Common Bottom Controls with Description:
   *    SharedFormBuilderWidgets.buildCommonBottomControls(
   *      onDuplicate: () => duplicateForm(),
   *      onDelete: () => deleteForm(),
   *      isRequired: true,
   *      onRequiredChanged: (value) => setRequired(value),
   *      onDescriptionTap: () => showDescriptionDialog(),
   *      onMoreOptions: () => showCustomOptions(),
   *    );
   *
   * 7. For More Options Dialog Usage:
   *    // For Dropdown with toggle state and real-time updates (Bottom Sheet)
   *    SharedFormBuilderWidgets.showMoreOptionsBottomSheet(
   *      context: context,
   *      getOptions: () {
   *        final currentState = context.read<YourBloc>().state;
   *        return SharedFormBuilderWidgets.getDropdownMoreOptions(
   *          onDescriptionTap: () => showDescriptionDialog(),
   *          isNavigationEnabled: currentState.navigationFeatureEnabled,
   *          isDescriptionEnabled: currentState.isDescriptionEditing,
   *          onNavigationToggle: () => toggleNavigationFeature(),
   *          onDescriptionToggle: () => toggleDescriptionEditing(),
   *        );
   *      },
   *    );
   *
   *    // For TextField with toggle state and real-time updates (Dialog)
   *    SharedFormBuilderWidgets.showMoreOptionsDialogWithUpdates(
   *      context: context,
   *      getOptions: () {
   *        final currentState = context.read<YourBloc>().state;
   *        return SharedFormBuilderWidgets.getTextFieldMoreOptions(
   *          onDescriptionTap: () => showDescriptionDialog(),
   *          isValidationEnabled: currentState.validationEnabled,
   *          onValidationToggle: () => toggleValidation(),
   *          isPlaceholderEnabled: currentState.placeholderEnabled,
   *          onPlaceholderToggle: () => togglePlaceholder(),
   *        );
   *      },
   *    );
   *
   *    // For Static Options (no real-time updates needed)
   *    SharedFormBuilderWidgets.showMoreOptionsDialog(
   *      context: context,
   *      options: SharedFormBuilderWidgets.getDropdownMoreOptions(
   *        onDescriptionTap: () => showDescriptionDialog(),
   *        onNavigationFeatureTap: () => enableNavigationFeature(),
   *      ),
   *    );
   *
   * 8. For Description Dialog Usage:
   *    SharedFormBuilderWidgets.showDescriptionDialog(
   *      context: context,
   *      currentDescription: 'Current description text',
   *      onDescriptionChanged: (newDescription) {
   *        // Handle description change
   *        setState(() {
   *          description = newDescription;
   *        });
   *      },
   *      formType: FormType.dropdown,
   *    );
   *
   * 9. For Description Section Usage with Inline Editing:
   *    SharedFormBuilderWidgets.buildDescriptionSection(
   *      descriptionController: _descriptionController,
   *      currentDescription: state.description,
   *      onDescriptionChanged: (value) {
   *        context.read<YourBloc>().add(UpdateDescriptionEvent(value));
   *      },
   *      isEditing: _isEditingDescription,
   *      onEditTap: () {
   *        setState(() {
   *          _isEditingDescription = true;
   *        });
   *      },
   *      onCancelEdit: () {
   *        setState(() {
   *          _isEditingDescription = false;
   *          _descriptionController.text = state.description;
   *        });
   *      },
   *    );
   *
   * 10. Complete Form Builder Example with Shared Description:
   *     class MyFormBuilderWidget extends StatefulWidget {
   *       @override
   *       State<MyFormBuilderWidget> createState() => _MyFormBuilderWidgetState();
   *     }
   *
   *     class _MyFormBuilderWidgetState extends State<MyFormBuilderWidget> {
   *       late TextEditingController _questionController;
   *       late TextEditingController _descriptionController;
   *
   *       @override
   *       void initState() {
   *         super.initState();
   *         _questionController = TextEditingController();
   *         _descriptionController = TextEditingController();
   *       }
   *
   *       @override
   *       Widget build(BuildContext context) {
   *         return BlocBuilder<MyBloc, MyState>(
   *           builder: (context, state) {
   *             if (state is MySuccess) {
   *               return SharedFormBuilderWidgets.buildMainContainer(
   *                 child: Column(
   *                   crossAxisAlignment: CrossAxisAlignment.start,
   *                   children: [
   *                     // Question header
   *                     SharedFormBuilderWidgets.buildTextFieldQuestionHeader(
   *                       questionInput: SharedFormBuilderWidgets.buildQuestionInput(
   *                         controller: _questionController,
   *                         onChanged: (value) {
   *                           context.read<MyBloc>().add(UpdateQuestionEvent(value));
   *                         },
   *                       ),
   *                       onImageTap: () => showImageDialog(),
   *                       onTextFieldTap: () => showTextFieldInfo(),
   *                     ),
   *                     // Shared description section
   *                     SharedFormBuilderWidgets.buildDescriptionSection(
   *                       descriptionController: _descriptionController,
   *                       currentDescription: state.description,
   *                       onDescriptionChanged: (value) {
   *                         context.read<MyBloc>().add(UpdateDescriptionEvent(value));
   *                       },
   *                     ),
   *                     // Your custom form content
   *                     _buildCustomFormContent(state),
   *                     // Bottom controls
   *                     SharedFormBuilderWidgets.buildCommonBottomControls(
   *                       onDuplicate: () => duplicateForm(),
   *                       onDelete: () => deleteForm(),
   *                       isRequired: state.isRequired,
   *                       onRequiredChanged: (value) => setRequired(value),
   *                       onDescriptionTap: () => showDescriptionDialog(),
   *                       onMoreOptions: () => showCustomOptions(),
   *                     ),
   *                   ],
   *                 ),
   *               );
   *             }
   *             return const SizedBox.shrink();
   *           },
   *         );
   *       }
   *     }
   */
}
