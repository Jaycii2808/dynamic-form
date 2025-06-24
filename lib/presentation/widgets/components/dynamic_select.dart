import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicSelect extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicSelect({super.key, required this.component});

  @override
  State<DynamicSelect> createState() => _DynamicSelectState();
}

class _DynamicSelectState extends State<DynamicSelect> {
  String? _selectedValue;
  List<String> _selectedValues = []; // For multiple selection
  bool _isDropdownOpen = false;
  bool _isTouched = false; // To track if the field has been interacted with
  String? _errorText;

  final GlobalKey _selectKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    final value = widget.component.config['value'];
    if (widget.component.config['multiple'] == true) {
      _selectedValues = (value as List<dynamic>?)?.cast<String>() ?? [];
    } else {
      _selectedValue = value?.toString();
    }
  }

  @override
  void dispose() {
    _closeDropdown();
    super.dispose();
  }

  // Common utility function for mapping icon names to IconData
  IconData? _mapIconNameToIconData(String name) {
    switch (name) {
      case 'mail':
        return Icons.mail;
      case 'check':
        return Icons.check;
      case 'close':
        return Icons.close;
      case 'error':
        return Icons.error;
      case 'user':
        return Icons.person;
      case 'lock':
        return Icons.lock;
      case 'chevron-down':
        return Icons.keyboard_arrow_down;
      case 'chevron-up':
        return Icons.keyboard_arrow_up;
      case 'globe':
        return Icons.language;
      case 'heart':
        return Icons.favorite;
      case 'search':
        return Icons.search;
      case 'location':
        return Icons.location_on;
      case 'calendar':
        return Icons.calendar_today;
      case 'phone':
        return Icons.phone;
      case 'email':
        return Icons.email;
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      case 'school':
        return Icons.school;
      case 'shopping':
        return Icons.shopping_cart;
      case 'food':
        return Icons.restaurant;
      case 'sports':
        return Icons.sports_soccer;
      case 'movie':
        return Icons.movie;
      case 'book':
        return Icons.book;
      case 'car':
        return Icons.directions_car;
      case 'plane':
        return Icons.flight;
      case 'train':
        return Icons.train;
      case 'bus':
        return Icons.directions_bus;
      case 'bike':
        return Icons.directions_bike;
      case 'walk':
        return Icons.directions_walk;
      case 'settings':
        return Icons.settings;
      case 'logout':
        return Icons.logout;
      case 'bell':
        return Icons.notifications;
      case 'more_horiz':
        return Icons.more_horiz;
      case 'edit':
        return Icons.edit;
      case 'delete':
        return Icons.delete;
      case 'share':
        return Icons.share;
      default:
        return null;
    }
  }

  String? _validateSelect(DynamicFormModel component, List<String> values) {
    final validationConfig = component.validation;
    if (validationConfig == null) return null;

    // Check required field
    final requiredValidation =
        validationConfig['required'] as Map<String, dynamic>?;
    if (requiredValidation?['isRequired'] == true && values.isEmpty) {
      return requiredValidation?['error_message'] as String? ??
          'Trường này là bắt buộc';
    }

    // If empty and not required, no validation needed
    if (values.isEmpty) {
      return null;
    }

    // Check max selections for multiple select
    if (component.config['multiple'] == true) {
      final maxSelectionsValidation =
          validationConfig['maxSelections'] as Map<String, dynamic>?;
      if (maxSelectionsValidation != null) {
        final max = maxSelectionsValidation['max'];
        if (max != null && values.length > max) {
          return maxSelectionsValidation['error_message'] as String? ??
              'Vượt quá số lượng cho phép';
        }
      }
    }

    return null;
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    final component = widget.component;
    final RenderBox renderBox =
        _selectKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeDropdown,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: offset.dx,
            top: offset.dy + size.height,
            width: size.width,
            child: Material(
              elevation: 4.0,
              borderRadius: StyleUtils.parseBorderRadius(
                component.style['borderRadius'],
              ),
              child: _buildDropdownList(component),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isDropdownOpen = true;
    });
  }

  void _closeDropdown() {
    if (!_isDropdownOpen) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isDropdownOpen = false;
    });
  }

  Widget _buildDropdownList(DynamicFormModel component) {
    final options = component.config['options'] as List<dynamic>? ?? [];
    final dynamic height = component.config['height'];
    final style = component.style;
    final isMultiple = component.config['multiple'] ?? false;

    Widget listView = ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: height == null || height == 'auto',
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final value = option['value']?.toString() ?? '';
        final label = option['label']?.toString() ?? '';
        final avatarUrl = option['avatar']?.toString();

        if (isMultiple) {
          bool isSelected = _selectedValues.contains(value);
          return CheckboxListTile(
            title: Text(label),
            value: isSelected,
            onChanged: (bool? newValue) {
              setState(() {
                if (newValue == true) {
                  if (!_selectedValues.contains(value)) {
                    _selectedValues.add(value);
                  }
                } else {
                  _selectedValues.remove(value);
                }
                _errorText = _validateSelect(component, _selectedValues);
                context.read<DynamicFormBloc>().add(
                  UpdateFormField(
                    componentId: component.id,
                    value: _selectedValues,
                  ),
                );
              });
            },
            secondary: avatarUrl != null
                ? CircleAvatar(backgroundImage: NetworkImage(avatarUrl))
                : null,
          );
        } else {
          return ListTile(
            leading: avatarUrl != null
                ? CircleAvatar(backgroundImage: NetworkImage(avatarUrl))
                : null,
            title: Text(label),
            onTap: () {
              setState(() {
                _isTouched = true;
                _selectedValue = value;
                _errorText = _validateSelect(component, [_selectedValue ?? '']);
                context.read<DynamicFormBloc>().add(
                  UpdateFormField(
                    componentId: component.id,
                    value: _selectedValue,
                  ),
                );
              });
              _closeDropdown();
            },
          );
        }
      },
    );

    Widget listContainer;
    if (height is num) {
      listContainer = SizedBox(height: height.toDouble(), child: listView);
    } else {
      listContainer = listView;
    }

    return Container(
      decoration: BoxDecoration(
        color: StyleUtils.parseColor(style['backgroundColor']),
        borderRadius: StyleUtils.parseBorderRadius(style['borderRadius']),
        border: Border.all(color: StyleUtils.parseColor(style['borderColor'])),
      ),
      child: listContainer,
    );
  }

  void _showMultiSelectDialog(
    BuildContext context,
    DynamicFormModel component,
    List<dynamic> options,
    bool isMultiple,
    bool searchable,
  ) {
    final style = Map<String, dynamic>.from(component.style);
    String searchQuery = '';
    List<dynamic> filteredOptions = List.from(options);

    List<String> tempSelectedValues = List.from(_selectedValues);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            if (searchable) {
              filteredOptions = options.where((option) {
                final label = option['label']?.toString().toLowerCase() ?? '';
                return label.contains(searchQuery.toLowerCase());
              }).toList();
            }

            return AlertDialog(
              title: Text(component.config['label'] ?? 'Chọn tùy chọn'),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 8,
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (searchable)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText:
                                style['searchPlaceholder'] ?? 'Tìm kiếm...',
                            prefixIcon: const Icon(Icons.search),
                          ),
                          onChanged: (value) {
                            setStateDialog(() {
                              searchQuery = value;
                            });
                          },
                        ),
                      ),
                    if (searchable) const SizedBox(height: 16),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredOptions.length,
                        itemBuilder: (context, index) {
                          final option = filteredOptions[index];
                          final value = option['value']?.toString() ?? '';
                          final label = option['label']?.toString() ?? '';

                          if (isMultiple) {
                            bool isSelected = tempSelectedValues.contains(
                              value,
                            );
                            return CheckboxListTile(
                              title: Text(label),
                              value: isSelected,
                              onChanged: (bool? newValue) {
                                setStateDialog(() {
                                  if (newValue == true) {
                                    if (!tempSelectedValues.contains(value)) {
                                      tempSelectedValues.add(value);
                                    }
                                  } else {
                                    tempSelectedValues.remove(value);
                                  }
                                });
                              },
                            );
                          } else {
                            // For searchable single-select
                            return ListTile(
                              title: Text(label),
                              onTap: () {
                                setState(() {
                                  _isTouched = true;
                                  _selectedValue = value;
                                  _errorText = _validateSelect(component, [
                                    _selectedValue ?? '',
                                  ]);
                                  context.read<DynamicFormBloc>().add(
                                    UpdateFormField(
                                      componentId: component.id,
                                      value: _selectedValue,
                                    ),
                                  );
                                });
                                Navigator.of(context).pop();
                              },
                            );
                          }
                        },
                      ),
                    ),
                    if (filteredOptions.isEmpty && searchable)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          style['noResultsText'] ?? 'Không tìm thấy kết quả',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                if (isMultiple)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isTouched = true;
                        _selectedValues = tempSelectedValues;
                        _errorText = _validateSelect(
                          component,
                          _selectedValues,
                        );
                        context.read<DynamicFormBloc>().add(
                          UpdateFormField(
                            componentId: component.id,
                            value: _selectedValues,
                          ),
                        );
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text('Xác nhận'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = Map<String, dynamic>.from(widget.component.style);
    final options = widget.component.config['options'] as List<dynamic>? ?? [];
    final isMultiple = widget.component.config['multiple'] ?? false;
    final searchable = widget.component.config['searchable'] ?? false;

    // Apply variant styles
    if (widget.component.variants != null) {
      if (widget.component.config['label'] != null &&
          widget.component.variants!.containsKey('withLabel')) {
        final variantStyle =
            widget.component.variants!['withLabel']['style']
                as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (widget.component.config['icon'] != null &&
          widget.component.variants!.containsKey('withIcon')) {
        final variantStyle =
            widget.component.variants!['withIcon']['style']
                as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (isMultiple && widget.component.variants!.containsKey('multiple')) {
        final variantStyle =
            widget.component.variants!['multiple']['style']
                as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (searchable && widget.component.variants!.containsKey('searchable')) {
        final variantStyle =
            widget.component.variants!['searchable']['style']
                as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
    }

    // Determine current state
    String currentState = 'base';
    final List<String> currentValues = isMultiple
        ? _selectedValues
        : (_selectedValue != null ? [_selectedValue!] : []);

    final validationError = _validateSelect(widget.component, currentValues);

    if (_isTouched && validationError != null) {
      currentState = 'error';
    } else if (currentValues.isNotEmpty && validationError == null) {
      currentState = 'success';
    } else {
      currentState = 'base';
    }

    // Apply state styles
    if (widget.component.states != null &&
        widget.component.states!.containsKey(currentState)) {
      final stateStyle =
          widget.component.states![currentState]['style']
              as Map<String, dynamic>?;
      if (stateStyle != null) style.addAll(stateStyle);
    }

    // Icon rendering
    Widget? prefixIcon;
    if ((widget.component.config['icon'] != null || style['icon'] != null) &&
        style['iconPosition'] != 'right') {
      final iconName = (style['icon'] ?? widget.component.config['icon'] ?? '')
          .toString();
      final iconColor = StyleUtils.parseColor(style['iconColor']);
      final iconSize = (style['iconSize'] is num)
          ? (style['iconSize'] as num).toDouble()
          : 20.0;
      final iconData = _mapIconNameToIconData(iconName);
      if (iconData != null) {
        prefixIcon = Icon(iconData, color: iconColor, size: iconSize);
      }
    }

    Widget? suffixIcon;
    if ((widget.component.config['icon'] != null || style['icon'] != null) &&
        style['iconPosition'] == 'right') {
      final iconName = (style['icon'] ?? widget.component.config['icon'] ?? '')
          .toString();
      final iconColor = StyleUtils.parseColor(style['iconColor']);
      final iconSize = (style['iconSize'] is num)
          ? (style['iconSize'] as num).toDouble()
          : 20.0;
      final iconData = _mapIconNameToIconData(iconName);
      if (iconData != null) {
        suffixIcon = Icon(iconData, color: iconColor, size: iconSize);
      }
    }

    // Helper text
    final helperText = style['helperText']?.toString();
    final helperTextColor = StyleUtils.parseColor(style['helperTextColor']);

    // Get display text
    final textStyle = TextStyle(
      fontSize: style['fontSize']?.toDouble() ?? 16,
      color: StyleUtils.parseColor(style['color']),
      fontStyle: style['fontStyle'] == 'italic'
          ? FontStyle.italic
          : FontStyle.normal,
    );

    Widget displayContent;

    if (isMultiple) {
      String displayText = 'Chọn các tùy chọn';
      if (_selectedValues.isNotEmpty) {
        final selectedLabels = _selectedValues.map((value) {
          final option = options.firstWhere(
            (opt) => opt['value'] == value,
            orElse: () => {'label': value},
          );
          return option['label'] ?? value;
        }).toList();
        displayText = selectedLabels.join(', ');
      }
      displayContent = Text(displayText, style: textStyle);
    } else {
      if (_selectedValue != null && _selectedValue!.isNotEmpty) {
        final option = options.firstWhere(
          (opt) => opt['value'] == _selectedValue,
          orElse: () => {'label': _selectedValue},
        );
        final displayText = option['label'] ?? _selectedValue!;
        final avatarUrl = option['avatar']?.toString();

        if (avatarUrl != null) {
          displayContent = Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(avatarUrl),
                radius: 16,
              ),
              const SizedBox(width: 8),
              Text(displayText, style: textStyle),
            ],
          );
        } else {
          displayContent = Text(displayText, style: textStyle);
        }
      } else {
        displayContent = Text(
          widget.component.config['placeholder'] ?? 'Chọn một tùy chọn',
          style: textStyle,
        );
      }
    }

    final hasLabel =
        widget.component.config['label'] != null &&
        widget.component.config['label'].isNotEmpty;

    return Container(
      key: Key(widget.component.id),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      margin: StyleUtils.parsePadding(style['margin']),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasLabel)
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 7),
              child: Text(
                widget.component.config['label'],
                style: TextStyle(
                  fontSize: style['labelTextSize']?.toDouble() ?? 16,
                  color: StyleUtils.parseColor(style['labelColor']),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          InkWell(
            key: _selectKey,
            onTap: () {
              if (isMultiple || searchable) {
                _showMultiSelectDialog(
                  context,
                  widget.component,
                  options,
                  isMultiple,
                  searchable,
                );
              } else {
                _toggleDropdown();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: StyleUtils.parseColor(style['borderColor']),
                ),
                borderRadius: StyleUtils.parseBorderRadius(
                  style['borderRadius'],
                ),
                color: StyleUtils.parseColor(style['backgroundColor']),
              ),
              child: Row(
                children: [
                  if (prefixIcon != null) ...[
                    prefixIcon,
                    const SizedBox(width: 8),
                  ],
                  Expanded(child: displayContent),
                  if (suffixIcon != null) ...[
                    const SizedBox(width: 8),
                    suffixIcon,
                  ],
                  Icon(
                    _isDropdownOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: StyleUtils.parseColor(style['color']),
                  ),
                ],
              ),
            ),
          ),
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 12),
              child: Text(
                _errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          if (helperText != null && _errorText == null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 12),
              child: Text(
                helperText,
                style: TextStyle(
                  color: helperTextColor,
                  fontSize: 12,
                  fontStyle: style['fontStyle'] == 'italic'
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
