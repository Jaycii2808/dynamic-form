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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

          // Required toggle - make it flexible and wrap if needed
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

          // More options with popup menu
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => _showMoreOptionsPopup(
                context: context,
                onDescriptionTap: onDescriptionTap,
                onMoreOptions: onMoreOptions,
              ),
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
          ),
        ],
      ),
    );
  }

  // Show more options popup menu with default Description option
  static void _showMoreOptionsPopup({
    required BuildContext context,
    VoidCallback? onDescriptionTap,
    VoidCallback? onMoreOptions,
  }) {
    debugPrint('Showing more options popup menu');

    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + button.size.height,
        offset.dx + button.size.width,
        offset.dy + button.size.height,
      ),
      items: [
        // Default Description option
        const PopupMenuItem<String>(
          value: 'description',
          child: Row(
            children: [
              Icon(
                Icons.description,
                color: Color(0xFF9CA3AF),
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Description',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Divider
        const PopupMenuDivider(),
        // Custom options from onMoreOptions callback
        if (onMoreOptions != null)
          const PopupMenuItem<String>(
            value: 'custom',
            child: Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Color(0xFF9CA3AF),
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'More Options',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    ).then((value) {
      debugPrint('More options popup selected: $value');
      if (value == 'description') {
        onDescriptionTap?.call();
      } else if (value == 'custom') {
        onMoreOptions?.call();
      }
    });
  }

  // Helper method to show more options popup (public API)
  static void showMoreOptionsPopup({
    required BuildContext context,
    VoidCallback? onDescriptionTap,
    VoidCallback? onMoreOptions,
  }) {
    _showMoreOptionsPopup(
      context: context,
      onDescriptionTap: onDescriptionTap,
      onMoreOptions: onMoreOptions,
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
  }) {
    // Only show description section if description exists or is being edited
    if (currentDescription.isEmpty && descriptionController.text.isEmpty) {
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
      child: TextField(
        controller: descriptionController,
        style: const TextStyle(
          fontSize: 15, // Larger font size
          color: Colors.white,
          height: 1.4, // Better line height
        ),
        decoration: const InputDecoration(
          hintText: 'Add a description for this form field (optional)',
          hintStyle: TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 15, // Larger hint text
            fontStyle: FontStyle.italic,
            height: 1.4,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: onDescriptionChanged,
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
   * 7. For Direct Popup Menu Usage:
   *    SharedFormBuilderWidgets.showMoreOptionsPopup(
   *      context: context,
   *      onDescriptionTap: () => showDescriptionDialog(),
   *      onMoreOptions: () => showCustomOptions(),
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
   * 9. For Description Section Usage:
   *    SharedFormBuilderWidgets.buildDescriptionSection(
   *      descriptionController: _descriptionController,
   *      currentDescription: state.description,
   *      onDescriptionChanged: (value) {
   *        // Handle description change
   *        context.read<YourBloc>().add(UpdateDescriptionEvent(value));
   *      },
   *      showBorder: true, // Optional: show top border
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
