import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:flutter/material.dart';

class DropdownFormBuilderWidget extends StatefulWidget {
  final DynamicFormModel component;
  final Function(DynamicFormModel)? onComponentUpdate;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;
  final List<String>? availablePages; // Add parameter for available pages

  const DropdownFormBuilderWidget({
    super.key,
    required this.component,
    this.onComponentUpdate,
    this.onDuplicate,
    this.onDelete,
    this.availablePages, // Add parameter
  });

  @override
  State<DropdownFormBuilderWidget> createState() =>
      _DropdownFormBuilderWidgetState();
}

class _DropdownFormBuilderWidgetState extends State<DropdownFormBuilderWidget> {
  late TextEditingController _questionController;
  late TextEditingController _placeholderController;
  late List<Option> _options;
  bool _isRequired = false;
  bool _navigationFeatureEnabled =
      false; // Add state to track if navigation is enabled

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(
      text: widget.component.config?.label ?? 'Dropdown Question',
    );
    _placeholderController = TextEditingController(
      text: widget.component.config?.placeholder ?? 'Select an option',
    );
    _options = List.from(widget.component.config?.options ?? []);
    _isRequired = widget.component.config?.isRequired ?? false;

    // Add default options if empty
    if (_options.isEmpty) {
      _options = [
        const Option(value: 'option1', label: 'Option 1', order: 1),
        const Option(value: 'option2', label: 'Option 2', order: 2),
        const Option(value: 'option3', label: 'Option 3', order: 3),
      ];
    }

    // Check if navigation feature is enabled by checking if any option has action
    _navigationFeatureEnabled = _options.any(
      (option) => option.action != null && option.action!.isNotEmpty,
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _placeholderController.dispose();
    super.dispose();
  }

  void _updateComponent() {
    if (widget.onComponentUpdate != null) {
      final updatedComponent = widget.component.copyWith(
        config: widget.component.config?.copyWith(
          label: _questionController.text,
          placeholder: _placeholderController.text,
          isRequired: _isRequired,
          options: _options,
        ),
      );
      widget.onComponentUpdate!(updatedComponent);
    }
  }

  void _addOption() {
    setState(() {
      final newOrder = _options.length + 1;
      final newOption = Option(
        value: 'option$newOrder',
        label: 'Option $newOrder',
        order: newOrder,
        // Add default navigation action if feature is enabled
        action: _navigationFeatureEnabled ? 'continue' : null,
        targetSection: _navigationFeatureEnabled ? null : null,
      );
      _options.add(newOption);
    });
    _updateComponent();
  }

  void _removeOption(int index) {
    setState(() {
      _options.removeAt(index);
      // Reorder remaining options
      for (int i = 0; i < _options.length; i++) {
        _options[i] = _options[i].copyWith(order: i + 1);
      }
    });
    _updateComponent();
  }

  void _updateOptionLabel(int index, String newLabel) {
    setState(() {
      _options[index] = _options[index].copyWith(label: newLabel);
    });
    _updateComponent();
  }

  void _reorderOptions(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _options.removeAt(oldIndex);
      _options.insert(newIndex, item);

      // Update order numbers
      for (int i = 0; i < _options.length; i++) {
        _options[i] = _options[i].copyWith(order: i + 1);
      }
    });
    _updateComponent();
  }

  void _showImageFeatureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F2937),
          title: const Row(
            children: [
              Icon(Icons.image, color: Colors.blue, size: 24),
              SizedBox(width: 8),
              Text(
                'Image Feature Coming Soon',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🚀 This feature is under development',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'You will be able to:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _buildFeatureItem('📷 Add images to dropdown options'),
              _buildFeatureItem('🎨 Customize image sizes and positions'),
              _buildFeatureItem('🔄 Drag and drop image upload'),
              _buildFeatureItem('💾 Save and reuse image templates'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Got it!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8EAED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header with type selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE8EAED), width: 1),
              ),
            ),
            child: Row(
              children: [
                // Image icon with dialog
                GestureDetector(
                  onTap: () => _showImageFeatureDialog(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.image,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Question input
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF202124),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Question',
                      hintStyle: TextStyle(
                        color: Color(0xFF9AA0A6),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) => _updateComponent(),
                  ),
                ),

                const SizedBox(width: 12),

                // Type selector
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey,
                        size: 20,
                      ),
                      Text(
                        'Dropdown',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Options section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Options list
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _options.length,
                  onReorder: _reorderOptions,
                  itemBuilder: (context, index) {
                    final option = _options[index];
                    return Container(
                      key: ValueKey(option.value),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Drag handle
                              Container(
                                width: 24,
                                height: 24,
                                margin: const EdgeInsets.only(right: 8),
                                child: const Icon(
                                  Icons.drag_handle,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              ),

                              // Option number
                              Container(
                                width: 24,
                                height: 24,
                                margin: const EdgeInsets.only(right: 8),
                                child: Text(
                                  '${index + 1}.',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                              // Option input
                              Expanded(
                                child: TextField(
                                  controller: TextEditingController(
                                    text: option.label,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF202124),
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Option',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF9AA0A6),
                                      fontSize: 16,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (value) =>
                                      _updateOptionLabel(index, value),
                                ),
                              ),

                              // Remove button
                              GestureDetector(
                                onTap: () => _removeOption(index),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  margin: const EdgeInsets.only(left: 8),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Navigation action for this option (only show when enabled)
                          if (_navigationFeatureEnabled)
                            GestureDetector(
                              onTap: () =>
                                  _displayPageNavigationOptions(context, index),
                              child: Container(
                                margin: const EdgeInsets.only(top: 8, left: 56),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.blue.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.navigation,
                                      color: Colors.blue,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _getNavigationActionText(option),
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                      size: 12,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),

                // Add option button
                GestureDetector(
                  onTap: _addOption,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.add,
                          color: Colors.blue,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Add option',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFE8EAED), width: 1),
              ),
            ),
            child: Row(
              children: [
                // Duplicate button
                GestureDetector(
                  onTap: widget.onDuplicate,
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 8),
                    child: const Icon(
                      Icons.content_copy,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ),

                // Delete button
                GestureDetector(
                  onTap: widget.onDelete,
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 16),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ),

                // Required toggle
                Row(
                  children: [
                    const Text(
                      'Required',
                      style: TextStyle(
                        color: Color(0xFF202124),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: _isRequired,
                      onChanged: (value) {
                        setState(() {
                          _isRequired = value;
                        });
                        _updateComponent();
                      },
                      activeColor: Colors.blue,
                    ),
                  ],
                ),

                const Spacer(),

                // More options
                GestureDetector(
                  onTap: () => _showMoreOptionsDialog(context),
                  child: const SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(
                      Icons.more_vert,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _displayPageNavigationOptions(BuildContext context, int optionIndex) {
    debugPrint(
      '🔄 [DropdownFormBuilder] Showing navigation options for option $optionIndex',
    );

    final List<Widget> navigationOptions = [
      _buildNavigationOption(
        context,
        'Continue to next section',
        'continue',
        null,
        optionIndex,
      ),
    ];

    // Add available pages if provided
    if (widget.availablePages != null) {
      for (int i = 0; i < widget.availablePages!.length; i++) {
        final pageName = widget.availablePages![i];
        navigationOptions.add(
          _buildNavigationOption(
            context,
            'Go to $pageName',
            'goto',
            'page_${i + 1}',
            optionIndex,
          ),
        );
      }
    } else {
      // Fallback to hardcoded pages if no available pages provided
      navigationOptions.addAll([
        _buildNavigationOption(
          context,
          'Go to page 1',
          'goto',
          'page_1',
          optionIndex,
        ),
        _buildNavigationOption(
          context,
          'Go to page 2',
          'goto',
          'page_2',
          optionIndex,
        ),
      ]);
    }

    navigationOptions.add(
      _buildNavigationOption(
        context,
        'Submit page',
        'submit',
        null,
        optionIndex,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Navigation for: ${_options[optionIndex].label}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              ...navigationOptions,
            ],
          ),
        ),
        backgroundColor: const Color(0xFF1F2937),
        duration: const Duration(seconds: 10),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildNavigationOption(
    BuildContext context,
    String title,
    String action,
    String? targetSection,
    int optionIndex,
  ) {
    return GestureDetector(
      onTap: () {
        debugPrint(
          '🔄 [DropdownFormBuilder] Selected navigation for option $optionIndex: $action -> $targetSection',
        );
        _updateOptionNavigation(optionIndex, action, targetSection);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _updateOptionNavigation(
    int optionIndex,
    String action,
    String? targetSection,
  ) {
    debugPrint(
      '🔄 [DropdownFormBuilder] Updating option $optionIndex navigation: $action -> $targetSection',
    );

    setState(() {
      // Enable navigation feature if not already enabled
      if (!_navigationFeatureEnabled) {
        _navigationFeatureEnabled = true;
      }

      _options[optionIndex] = _options[optionIndex].copyWith(
        action: action,
        targetSection: targetSection,
      );
    });

    _updateComponent();
  }

  String _getNavigationActionText(Option option) {
    final action = option.action;
    final targetSection = option.targetSection;

    if (action == 'goto' && targetSection != null) {
      // Try to show actual page name if available
      if (targetSection.startsWith('page_') && widget.availablePages != null) {
        try {
          final pageNumber = int.parse(targetSection.substring(5));
          if (pageNumber > 0 && pageNumber <= widget.availablePages!.length) {
            return 'Go to ${widget.availablePages![pageNumber - 1]}';
          }
        } catch (e) {
          debugPrint('❌ [DropdownFormBuilder] Error parsing page number: $e');
        }
      }
      return 'Go to $targetSection';
    } else if (action == 'continue') {
      return 'Continue to next section';
    } else if (action == 'submit') {
      return 'Submit page';
    }
    return 'Continue to next section'; // Default
  }

  void _showMoreOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('More Options'),
          content: const Text('Select an option to configure:'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _enableNavigationFeature();
              },
              child: const Text('Go to page based on answer'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _enableNavigationFeature() {
    debugPrint('🔄 [DropdownFormBuilder] Enabling navigation feature');
    setState(() {
      _navigationFeatureEnabled = true;

      // Set default navigation action for all existing options
      for (int i = 0; i < _options.length; i++) {
        if (_options[i].action == null || _options[i].action!.isEmpty) {
          _options[i] = _options[i].copyWith(
            action: 'continue',
            targetSection: null,
          );
        }
      }
    });
    _updateComponent();
  }
}
