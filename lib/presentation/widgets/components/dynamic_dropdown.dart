import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicDropdown extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicDropdown({super.key, required this.component});

  @override
  State<DynamicDropdown> createState() => _DynamicDropdownState();
}

class _DynamicDropdownState extends State<DynamicDropdown> {
  String? _selectedValue; // This stores the value/id, not the label
  String? _currentDisplayLabel; // This stores the label for display purposes
  bool _isHovering = false;
  bool _isTouched = false; // To track if the field has been interacted with
  final FocusNode _focusNode = FocusNode();
  String? _tempSearchValue; // Temporary value while searching

  final GlobalKey _dropdownKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.component.config['value'];
    _updateDisplayLabel();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      // Case 2: User unfocuses (tabs out)
      _saveCurrentValue();
    }
  }

  // Update display label based on selected value
  void _updateDisplayLabel() {
    if (_selectedValue == null) {
      _currentDisplayLabel =
          widget.component.config['label'] ??
          widget.component.config['placeholder'] ??
          'Select an option';
      return;
    }

    final items = widget.component.config['items'] as List<dynamic>? ?? [];
    final selectedItem = items.firstWhere(
      (item) => item['id'] == _selectedValue && item['type'] != 'divider',
      orElse: () => null,
    );

    if (selectedItem != null) {
      _currentDisplayLabel = selectedItem['label'] as String? ?? _selectedValue;
    } else {
      _currentDisplayLabel = _selectedValue;
    }
  }

  // Save the current value (either selected or temporary search value)
  void _saveCurrentValue() {
    String? valueToSave = _tempSearchValue ?? _selectedValue;

    if (valueToSave != widget.component.config['value']) {
      widget.component.config['value'] = valueToSave;
      context.read<DynamicFormBloc>().add(
        UpdateFormField(componentId: widget.component.id, value: valueToSave),
      );
      debugPrint('Dropdown value saved: ${widget.component.id} = $valueToSave');
    }
  }

  // Save value when explicitly selecting an item
  void _saveValue() {
    if (_selectedValue != widget.component.config['value']) {
      widget.component.config['value'] = _selectedValue;
      context.read<DynamicFormBloc>().add(
        UpdateFormField(
          componentId: widget.component.id,
          value: _selectedValue,
        ),
      );
    }
    debugPrint(
      '[Dropdown] Save value: ${widget.component.id} = $_selectedValue',
    );
    // Clear temporary search value when explicitly saving
    _tempSearchValue = null;
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

  String? _validateDropdown(DynamicFormModel component, String? selectedValue) {
    final validationConfig = component.validation;
    if (validationConfig == null) return null;

    final requiredValidation =
        validationConfig['required'] as Map<String, dynamic>?;
    if (requiredValidation?['isRequired'] == true &&
        (selectedValue == null || selectedValue.isEmpty)) {
      return requiredValidation?['error_message'] as String? ??
          'This field is required.';
    }

    return null;
  }

  void _showDropdownPanel(
    BuildContext context,
    DynamicFormModel component,
    Rect rect,
  ) {
    final items = component.config['items'] as List<dynamic>? ?? [];
    final style = component.style;
    final isSearchable = component.config['searchable'] as bool? ?? false;
    final dropdownWidth =
        (style['dropdownWidth'] as num?)?.toDouble() ?? rect.width;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        List<dynamic> filteredItems = List.from(items);
        String searchQuery = '';
        final searchController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setPanelState) {
            if (isSearchable) {
              filteredItems = items.where((item) {
                final label = item['label']?.toString().toLowerCase() ?? '';
                if (item['type'] == 'divider') return true;
                return label.contains(searchQuery.toLowerCase());
              }).toList();
            }

            return Stack(
              children: [
                // Full screen GestureDetector to dismiss the dropdown.
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      // Case 3: User clicks outside component
                      _saveValue();
                      _overlayEntry?.remove();
                      _overlayEntry = null;
                      // Trigger rebuild through BLoC instead of setState
                      context.read<DynamicFormBloc>().add(
                        UpdateFormField(
                          componentId: widget.component.id,
                          value: widget.component.config['value'],
                        ),
                      );
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),
                // The dropdown panel itself.
                Positioned(
                  top: rect.top,
                  left: rect.left,
                  width: dropdownWidth,
                  child: Material(
                    elevation: 4.0,
                    color: StyleUtils.parseColor(
                      style['dropdownBackgroundColor'],
                    ),
                    borderRadius: StyleUtils.parseBorderRadius(
                      style['borderRadius'],
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 300,
                      ), // Max height for dropdown list
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shrinkWrap: true,
                        itemCount:
                            filteredItems.length + (isSearchable ? 1 : 0),
                        separatorBuilder: (context, index) {
                          final itemIndex = isSearchable ? index - 1 : index;
                          if (itemIndex < 0 ||
                              itemIndex >= filteredItems.length) {
                            return const SizedBox.shrink();
                          }
                          final item = filteredItems[itemIndex];
                          final nextItem =
                              (itemIndex + 1 < filteredItems.length)
                              ? filteredItems[itemIndex + 1]
                              : null;
                          if (item['type'] == 'divider' ||
                              nextItem?['type'] == 'divider') {
                            return const SizedBox.shrink();
                          }
                          return Divider(
                            color: StyleUtils.parseColor(style['dividerColor']),
                            height: 1,
                          );
                        },
                        itemBuilder: (context, index) {
                          if (isSearchable && index == 0) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: TextField(
                                controller: searchController,
                                focusNode: _focusNode,
                                decoration: InputDecoration(
                                  hintText: component.config['placeholder'],
                                  isDense: true,
                                  suffixIcon: const Icon(Icons.search),
                                ),
                                onChanged: (value) {
                                  setPanelState(() {
                                    searchQuery = value;
                                  });
                                  // Store temporary search value
                                  _tempSearchValue = value.isNotEmpty
                                      ? value
                                      : null;
                                },
                                onSubmitted: (value) {
                                  // Case 1: User presses Enter
                                  if (filteredItems.isNotEmpty &&
                                      filteredItems.first['type'] !=
                                          'divider') {
                                    final firstItem = filteredItems.first;
                                    _selectedValue = firstItem['id'];
                                    _updateDisplayLabel();
                                    _saveValue();
                                  } else if (value.isNotEmpty) {
                                    // If no filtered items but user entered text, save the text
                                    _tempSearchValue = value;
                                    _saveCurrentValue();
                                  }
                                  _overlayEntry?.remove();
                                  _overlayEntry = null;
                                },
                              ),
                            );
                          }

                          final item =
                              filteredItems[isSearchable ? index - 1 : index];
                          final itemType = item['type'] as String? ?? 'item';

                          if (itemType == 'divider') {
                            return Divider(
                              color: StyleUtils.parseColor(
                                style['dividerColor'],
                              ),
                              height: 1,
                            );
                          }

                          final label = item['label'] as String? ?? '';
                          final value = item['id'] as String? ?? '';
                          final iconName = item['icon'] as String?;
                          final avatarUrl = item['avatar'] as String?;
                          final itemStyle =
                              item['style'] as Map<String, dynamic>? ?? {};

                          return InkWell(
                            onTap: () {
                              debugPrint(
                                "Dropdown Action Tapped: Value='$value', Label='$label'",
                              );

                              _isTouched = true;
                              _selectedValue = value;
                              _updateDisplayLabel();

                              // Save value immediately when item is selected
                              _saveValue();

                              _overlayEntry?.remove();
                              _overlayEntry = null;
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              child: Row(
                                children: [
                                  if (avatarUrl != null) ...[
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(avatarUrl),
                                      radius: 16,
                                    ),
                                    const SizedBox(width: 12),
                                  ] else if (iconName != null) ...[
                                    Icon(
                                      _mapIconNameToIconData(iconName),
                                      color: StyleUtils.parseColor(
                                        itemStyle['color'] ?? style['color'],
                                      ),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                  Expanded(
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        color: StyleUtils.parseColor(
                                          itemStyle['color'] ?? style['color'],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DynamicFormBloc, DynamicFormState>(
      listener: (context, state) {
        // Listen to state changes if needed
      },
      builder: (context, state) {
        final style = Map<String, dynamic>.from(widget.component.style);
        final config = widget.component.config;
        final triggerAvatar = config['avatar'] as String?;
        final triggerIcon = config['icon'] as String?;
        final isSearchable = config['searchable'] as bool? ?? false;
        final placeholder = config['placeholder'] as String? ?? 'Search';

        // Apply variant styles
        if (widget.component.variants != null) {
          if (triggerAvatar != null &&
              widget.component.variants!.containsKey('withAvatar')) {
            final variantStyle =
                widget.component.variants!['withAvatar']['style']
                    as Map<String, dynamic>?;
            if (variantStyle != null) style.addAll(variantStyle);
          }
          if (triggerIcon != null &&
              _currentDisplayLabel == null &&
              widget.component.variants!.containsKey('iconOnly')) {
            final variantStyle =
                widget.component.variants!['iconOnly']['style']
                    as Map<String, dynamic>?;
            if (variantStyle != null) style.addAll(variantStyle);
          }
          if (triggerIcon != null &&
              _currentDisplayLabel != null &&
              widget.component.variants!.containsKey('withIcon')) {
            final variantStyle =
                widget.component.variants!['withIcon']['style']
                    as Map<String, dynamic>?;
            if (variantStyle != null) style.addAll(variantStyle);
          }
        }

        // Determine current state
        final validationError = _validateDropdown(
          widget.component,
          _selectedValue,
        );
        if (_isTouched) {
          // Validation error is handled through BLoC state
        }

        String currentState = 'base';
        if (_isTouched && validationError != null) {
          currentState = 'error';
        } else if (_selectedValue != null &&
            _selectedValue!.isNotEmpty &&
            widget.component.states!.containsKey('success')) {
          currentState = 'success';
        } else if (_isHovering) {
          currentState = 'hover';
        }

        // Apply state styles
        if (widget.component.states != null &&
            widget.component.states!.containsKey(currentState)) {
          final stateStyle =
              widget.component.states![currentState]['style']
                  as Map<String, dynamic>?;
          if (stateStyle != null) style.addAll(stateStyle);
        }

        final String? helperText =
            validationError ?? style['helperText'] as String?;
        final helperTextColor = StyleUtils.parseColor(style['helperTextColor']);

        Widget triggerContent;
        if (isSearchable) {
          triggerContent = Row(
            children: [
              Expanded(
                child: Text(
                  _currentDisplayLabel ?? placeholder,
                  style: TextStyle(
                    color: StyleUtils.parseColor(style['color'] ?? '#000000'),
                  ),
                ),
              ),
              Icon(
                Icons.search,
                color: StyleUtils.parseColor(style['iconColor'] ?? '#000000'),
              ),
            ],
          );
        } else if (triggerIcon != null && _currentDisplayLabel == null) {
          // Icon-only trigger
          triggerContent = Icon(
            _mapIconNameToIconData(triggerIcon),
            color: StyleUtils.parseColor(style['iconColor'] ?? '#000000'),
            size: (style['iconSize'] as num?)?.toDouble() ?? 24.0,
          );
        } else {
          triggerContent = Row(
            children: [
              if (triggerIcon != null) ...[
                Icon(
                  _mapIconNameToIconData(triggerIcon),
                  color: StyleUtils.parseColor(style['iconColor'] ?? '#000000'),
                  size: (style['iconSize'] as num?)?.toDouble() ?? 18.0,
                ),
                const SizedBox(width: 8),
              ],
              if (triggerAvatar != null) ...[
                CircleAvatar(
                  backgroundImage: NetworkImage(triggerAvatar),
                  radius: 16,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  _currentDisplayLabel ??
                      widget.component.config['placeholder'] ??
                      'Select an option',
                  style: TextStyle(
                    color: StyleUtils.parseColor(style['color'] ?? '#000000'),
                  ),
                ),
              ),
              Icon(
                _overlayEntry != null && _overlayEntry!.mounted
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: StyleUtils.parseColor(style['color'] ?? '#000000'),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MouseRegion(
              onEnter: (_) => _isHovering = true,
              onExit: (_) => _isHovering = false,
              child: InkWell(
                key: _dropdownKey,
                focusNode: _focusNode,
                onTap: () {
                  final renderBox =
                      _dropdownKey.currentContext!.findRenderObject()
                          as RenderBox;
                  final size = renderBox.size;
                  final offset = renderBox.localToGlobal(Offset.zero);

                  _showDropdownPanel(
                    context,
                    widget.component,
                    Rect.fromLTWH(
                      offset.dx,
                      offset.dy + size.height,
                      size.width,
                      0,
                    ),
                  );
                },
                child: Container(
                  padding: StyleUtils.parsePadding(style['padding']),
                  margin: StyleUtils.parsePadding(style['margin']),
                  decoration: BoxDecoration(
                    color: StyleUtils.parseColor(style['backgroundColor']),
                    border: Border.all(
                      color: StyleUtils.parseColor(style['borderColor']),
                      width: (style['borderWidth'] as num?)?.toDouble() ?? 1.0,
                    ),
                    borderRadius: StyleUtils.parseBorderRadius(
                      style['borderRadius'],
                    ),
                  ),
                  child: triggerContent,
                ),
              ),
            ),
            if (helperText != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 16),
                child: Text(
                  helperText,
                  style: TextStyle(color: helperTextColor, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}
