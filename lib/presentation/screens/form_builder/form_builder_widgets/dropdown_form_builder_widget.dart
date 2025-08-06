import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:flutter/material.dart';

class DropdownFormBuilderWidget extends StatefulWidget {
  final DynamicFormModel component;
  final Function(DynamicFormModel)? onComponentUpdate;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;

  const DropdownFormBuilderWidget({
    super.key,
    required this.component,
    this.onComponentUpdate,
    this.onDuplicate,
    this.onDelete,
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
      _options.add(
        Option(
          value: 'option$newOrder',
          label: 'Option $newOrder',
          order: newOrder,
        ),
      );
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
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Row(
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
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
