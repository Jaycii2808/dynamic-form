// ignore_for_file: non_constant_identifier_names

import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/core/utils/validation_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

String? validateForm(DynamicFormModel component, String? value) {
  try {
    return ValidationUtils.validateForm(component, value);
  } catch (e) {
    debugPrint('Validation error for ${component.id}: $e');
    return 'Validation error occurred';
  }
}

class DynamicSelect extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicSelect({super.key, required this.component});

  @override
  State<DynamicSelect> createState() => _DynamicSelectState();
}

class _DynamicSelectState extends State<DynamicSelect> {
  bool isDropdownOpen = false;
  final GlobalKey selectKey = GlobalKey();
  OverlayEntry? overlayEntry;
  final FocusNode focusNode = FocusNode();

  // State variables for computed values
  late DynamicFormModel _currentComponent;
  String _currentState = 'base';
  Map<String, dynamic> _style = {};
  List<String> _selectedValues = [];
  String? _selectedValue;
  bool _isMultiple = false;
  bool _searchable = false;
  bool _isDisabled = false;
  List<dynamic> _options = [];
  String? _validationError;
  Widget? _prefixIcon;
  Widget? _suffixIcon;
  Widget? _displayContent;
  String? _helperText;

  // Pre-computed UI elements
  VoidCallback? _onTapHandler;
  Widget? _labelWidget;
  Widget? _helperTextWidget;
  Widget? _selectFieldWidget;

  @override
  void initState() {
    super.initState();

    // Initialize with widget component
    _currentComponent = widget.component;
    _computeValues();
  }

  @override
  void dispose() {
    closeDropdown();
    focusNode.dispose();
    super.dispose();
  }

  void _computeValues() {
    final value = _currentComponent.config['value'];

    // Basic config values
    _isMultiple = _currentComponent.config['multiple'] ?? false;
    _searchable = _currentComponent.config['searchable'] ?? false;
    _isDisabled = _currentComponent.config['disabled'] == true;
    _options = _currentComponent.config['options'] as List<dynamic>? ?? [];

    // Parse selected values
    if (value is List) {
      _selectedValues = value.cast<String>();
      _selectedValue = value.isNotEmpty ? value.first.toString() : null;
    } else {
      _selectedValue = value?.toString();
      _selectedValues = _selectedValue != null ? [_selectedValue!] : [];
    }

    // IMPORTANT: Compute current state FIRST, then styles that depend on it
    _computeCurrentState();
    _computeStyles();
    _computeIcons();
    _computeDisplayContent();
    _computeHelperText();
    _computeUIElements();

    debugPrint(
      '[Select][_computeValues] id=${_currentComponent.id} value=${_isMultiple ? _selectedValues : _selectedValue} state=$_currentState',
    );
    debugPrint('[Select][_computeValues] style=${_style.toString()}');
  }

  void _computeStyles() {
    _style = Map<String, dynamic>.from(_currentComponent.style);

    // Apply variant styles
    if (_currentComponent.variants != null) {
      if (_currentComponent.config['label'] != null &&
          _currentComponent.variants!.containsKey('with_label')) {
        final variantStyle =
            _currentComponent.variants!['with_label']['style']
                as Map<String, dynamic>?;
        if (variantStyle != null) _style.addAll(variantStyle);
      }
      if (_currentComponent.config['icon'] != null &&
          _currentComponent.variants!.containsKey('with_icon')) {
        final variantStyle =
            _currentComponent.variants!['with_icon']['style']
                as Map<String, dynamic>?;
        if (variantStyle != null) _style.addAll(variantStyle);
      }
      if (_isMultiple && _currentComponent.variants!.containsKey('multiple')) {
        final variantStyle =
            _currentComponent.variants!['multiple']['style']
                as Map<String, dynamic>?;
        if (variantStyle != null) _style.addAll(variantStyle);
      }
      if (_searchable &&
          _currentComponent.variants!.containsKey('searchable')) {
        final variantStyle =
            _currentComponent.variants!['searchable']['style']
                as Map<String, dynamic>?;
        if (variantStyle != null) _style.addAll(variantStyle);
      }
    }

    // Apply state styles
    if (_currentComponent.states != null &&
        _currentComponent.states!.containsKey(_currentState)) {
      final stateStyle =
          _currentComponent.states![_currentState]['style']
              as Map<String, dynamic>?;
      if (stateStyle != null) _style.addAll(stateStyle);
    }
  }

  void _computeCurrentState() {
    final List<String> currentValues = _isMultiple
        ? _selectedValues
        : (_selectedValue != null ? [_selectedValue!] : []);

    final oldState = _currentState;
    _validationError = validateSelect(_currentComponent, currentValues);

    if (_validationError != null) {
      _currentState = 'error';
    } else if (currentValues.isNotEmpty && _validationError == null) {
      _currentState = 'success';
    } else {
      _currentState = 'base';
    }

    // Debug timing of state changes
    if (oldState != _currentState) {
      debugPrint(
        '[Select][StateChange] id=${_currentComponent.id} $oldState → $_currentState (values: $currentValues)',
      );
    }
  }

  void _computeIcons() {
    // Prefix icon
    if ((_currentComponent.config['icon'] != null || _style['icon'] != null) &&
        _style['icon_position'] != 'right') {
      final iconName =
          (_style['icon'] ?? _currentComponent.config['icon'] ?? '').toString();
      final iconColor = StyleUtils.parseColor(_style['icon_color']);
      final iconSize = (_style['icon_size'] is num)
          ? (_style['icon_size'] as num).toDouble()
          : 20.0;
      final iconData = mapIconNameToIconData(iconName);
      if (iconData != null) {
        _prefixIcon = Icon(iconData, color: iconColor, size: iconSize);
      }
    } else {
      _prefixIcon = null;
    }

    // Suffix icon
    if ((_currentComponent.config['icon'] != null || _style['icon'] != null) &&
        _style['icon_position'] == 'right') {
      final iconName =
          (_style['icon'] ?? _currentComponent.config['icon'] ?? '').toString();
      final iconColor = StyleUtils.parseColor(_style['icon_color']);
      final iconSize = (_style['icon_size'] is num)
          ? (_style['icon_size'] as num).toDouble()
          : 20.0;
      final iconData = mapIconNameToIconData(iconName);
      if (iconData != null) {
        _suffixIcon = Icon(iconData, color: iconColor, size: iconSize);
      }
    } else {
      _suffixIcon = null;
    }
  }

  void _computeDisplayContent() {
    final textStyle = TextStyle(
      fontSize: _style['font_size']?.toDouble() ?? 16,
      color: StyleUtils.parseColor(_style['color']),
      fontStyle: _style['font_style'] == 'italic'
          ? FontStyle.italic
          : FontStyle.normal,
    );

    if (_isMultiple) {
      String displayText = 'Select options';
      if (_selectedValues.isNotEmpty) {
        final selectedLabels = _selectedValues.map((value) {
          final option = _options.firstWhere(
            (opt) => opt['value'] == value,
            orElse: () => {'label': value},
          );
          return option['label'] ?? value;
        }).toList();
        displayText = selectedLabels.join(', ');
      }
      _displayContent = Text(displayText, style: textStyle);
    } else {
      if (_selectedValue != null && _selectedValue!.isNotEmpty) {
        final option = _options.firstWhere(
          (opt) => opt['value'] == _selectedValue,
          orElse: () => {'label': _selectedValue},
        );
        final displayText = option['label'] ?? _selectedValue;

        if (option['avatar'] != null) {
          _displayContent = Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage(option['avatar']),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(displayText, style: textStyle)),
            ],
          );
        } else {
          _displayContent = Text(displayText, style: textStyle);
        }
      } else {
        _displayContent = Text(
          _currentComponent.config['placeholder'] ?? 'Select option',
          style: textStyle.copyWith(
            color: StyleUtils.parseColor(_style['color']).withOpacity(0.6),
          ),
        );
      }
    }
  }

  void _computeHelperText() {
    _helperText = _style['helper_text']?.toString();
  }

  void _computeUIElements() {
    // Pre-compute label widget
    if (_currentComponent.config['label'] != null) {
      _labelWidget = Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          _currentComponent.config['label'],
          style: TextStyle(
            fontSize: _style['label_text_size']?.toDouble() ?? 14,
            color: StyleUtils.parseColor(_style['label_color']),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    } else {
      _labelWidget = null;
    }

    // Pre-compute helper text widget
    if (_helperText != null && _helperText!.isNotEmpty) {
      _helperTextWidget = Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          _helperText!,
          style: TextStyle(
            fontSize: 12,
            color: StyleUtils.parseColor(
              _style['helper_text_color'],
            ),
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    } else {
      _helperTextWidget = null;
    }

    // Pre-compute onTap handler
    _onTapHandler = _isDisabled ? null : _handleSelectTap;

    // Pre-compute select field widget
    _selectFieldWidget = Container(
      padding: StyleUtils.parsePadding(_style['padding']),
      decoration: BoxDecoration(
        color: StyleUtils.parseColor(_style['background_color']),
        border: Border.all(
          color: StyleUtils.parseColor(_style['border_color']),
          width: 1.0,
        ),
        borderRadius: StyleUtils.parseBorderRadius(
          _style['border_radius'],
        ),
      ),
      child: Row(
        children: [
          if (_prefixIcon != null) ...[
            _prefixIcon!,
            const SizedBox(width: 8),
          ],
          Expanded(child: _displayContent!),
          if (_suffixIcon != null) ...[
            const SizedBox(width: 8),
            _suffixIcon!,
          ],
        ],
      ),
    );
  }

  // Event handlers (business logic)
  void _handleSelectTap() {
    FocusScope.of(context).requestFocus(focusNode);
    toggleDropdown();
  }

  void _handleOptionSelect(String optionValue) {
    context.read<DynamicFormBloc>().add(
      UpdateFormFieldEvent(
        componentId: _currentComponent.id,
        value: optionValue,
      ),
    );
    debugPrint(
      '[Select] ${_currentComponent.id} value updated: $optionValue (single)',
    );
    closeDropdown();
  }

  void _handleMultipleOptionToggle(String optionValue, bool isSelected) {
    List<String> newValues = List.from(_selectedValues);
    if (isSelected) {
      if (!newValues.contains(optionValue)) {
        newValues.add(optionValue);
      }
    } else {
      newValues.remove(optionValue);
    }
    context.read<DynamicFormBloc>().add(
      UpdateFormFieldEvent(
        componentId: _currentComponent.id,
        value: newValues,
      ),
    );
    debugPrint(
      '[Select] ${_currentComponent.id} value updated: $newValues (multiple)',
    );
  }

  // Common utility function for mapping icon names to IconData
  IconData? mapIconNameToIconData(String name) {
    return IconTypeEnum.fromString(name).toIconData();
  }

  String? validateSelect(DynamicFormModel component, List<String> values) {
    // Quick check for empty values (required field validation)
    if (values.isEmpty) {
      return validateForm(component, '');
    }

    // Fast path: Check max selections first (most common case)
    if (component.config['multiple'] == true) {
      final validationConfig = component.validation;
      if (validationConfig != null) {
        final maxSelectionsValidation =
            validationConfig['max_selections'] as Map<String, dynamic>?;
        if (maxSelectionsValidation != null) {
          final max = maxSelectionsValidation['max'];
          if (max != null && values.length > max) {
            return maxSelectionsValidation['error_message'] as String? ??
                'Exceeds maximum allowed quantity';
          }
        }
      }
    }

    // Only validate individual values if there are multiple validation rules
    final hasComplexValidation =
        component.validation != null && component.validation!.length > 1;

    if (hasComplexValidation) {
      for (String value in values) {
        final validationError = validateForm(component, value);
        if (validationError != null) {
          return validationError;
        }
      }
    } else {
      // For simple cases, just validate the first value
      final validationError = validateForm(component, values.first);
      if (validationError != null) {
        return validationError;
      }
    }

    return null;
  }

  void toggleDropdown() {
    if (isDropdownOpen) {
      closeDropdown();
    } else {
      openDropdown();
    }
  }

  void openDropdown() {
    final RenderBox renderBox =
        selectKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: closeDropdown,
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
                _currentComponent.style['border_radius'],
              ),
              child: _buildDropdownList(),
            ),
          ),
        ],
      ),
    );
    isDropdownOpen = true;
    Overlay.of(context).insert(overlayEntry!);
  }

  void closeDropdown() {
    if (!isDropdownOpen) return;
    overlayEntry?.remove();
    overlayEntry = null;
    isDropdownOpen = false;
  }

  Widget _buildDropdownList() {
    final dynamic height = _currentComponent.config['height'];

    Widget listView = ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: height == null || height == 'auto',
      itemCount: _options.length,
      itemBuilder: (context, index) {
        final option = _options[index];
        final optionValue = option['value']?.toString() ?? '';
        final label = option['label']?.toString() ?? '';
        final avatarUrl = option['avatar']?.toString();

        if (_isMultiple) {
          bool isSelected = _selectedValues.contains(optionValue);
          return CheckboxListTile(
            title: Text(label),
            value: isSelected,
            onChanged: (bool? newValue) {
              _handleMultipleOptionToggle(optionValue, newValue == true);
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
            onTap: () => _handleOptionSelect(optionValue),
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
        color: StyleUtils.parseColor(
          _currentComponent.style['background_color'],
        ),
        borderRadius: StyleUtils.parseBorderRadius(
          _currentComponent.style['border_radius'],
        ),
        border: Border.all(
          color: StyleUtils.parseColor(_currentComponent.style['border_color']),
        ),
      ),
      child: listContainer,
    );
  }

  void showMultiSelectDialog(
    BuildContext context,
    DynamicFormModel component,
    List<dynamic> options,
    bool isMultiple,
    bool searchable, {
    String searchQuery = '',
  }) {
    final style = Map<String, dynamic>.from(component.style);
    showDialog(
      context: context,
      builder: (BuildContext context) => MultiSelectDialogBloc(
        componentId: component.id,
        options: options,
        label: component.config['label'] ?? 'Select option',
        style: style,
        searchable: searchable,
        searchQuery: searchQuery,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DynamicFormBloc, DynamicFormState>(
      listener: (context, state) {
        // Update component from state and recompute values only when necessary
        final updatedComponent = (state.page?.components != null)
            ? state.page!.components.firstWhere(
                (c) => c.id == widget.component.id,
                orElse: () => widget.component,
              )
            : widget.component;

        // Only update if component actually changed
        if (updatedComponent != _currentComponent ||
            updatedComponent.config['value'] !=
                _currentComponent.config['value'] ||
            updatedComponent.config['disabled'] !=
                _currentComponent.config['disabled'] ||
            updatedComponent.config['multiple'] !=
                _currentComponent.config['multiple'] ||
            updatedComponent.config['searchable'] !=
                _currentComponent.config['searchable'] ||
            updatedComponent.validation != _currentComponent.validation ||
            updatedComponent.style != _currentComponent.style ||
            updatedComponent.states != _currentComponent.states) {
          setState(() {
            _currentComponent = updatedComponent;
            _computeValues();
          });
        }
      },
      child: BlocBuilder<DynamicFormBloc, DynamicFormState>(
        buildWhen: (previous, current) {
          // Only rebuild when something visual actually changes
          final prevComponent = previous.page?.components.firstWhere(
            (c) => c.id == widget.component.id,
            orElse: () => widget.component,
          );
          final currComponent = current.page?.components.firstWhere(
            (c) => c.id == widget.component.id,
            orElse: () => widget.component,
          );

          // Check all factors that can affect visual appearance and state
          return prevComponent?.config['value'] !=
                  currComponent?.config['value'] ||
              prevComponent?.config['disabled'] !=
                  currComponent?.config['disabled'] ||
              prevComponent?.config['multiple'] !=
                  currComponent?.config['multiple'] ||
              prevComponent?.config['searchable'] !=
                  currComponent?.config['searchable'] ||
              prevComponent?.validation != currComponent?.validation ||
              prevComponent?.style != currComponent?.style ||
              prevComponent?.states != currComponent?.states;
        },
        builder: (context, state) {
          // Pure UI rendering - NO LOGIC HERE
          return Container(
            key: Key(_currentComponent.id),
            margin: StyleUtils.parsePadding(_style['margin']),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label
                if (_labelWidget != null) _labelWidget!,

                // Select field
                GestureDetector(
                  key: selectKey,
                  onTap: _onTapHandler,
                  child: _selectFieldWidget!,
                ),

                // Helper text
                if (_helperTextWidget != null) _helperTextWidget!,
              ],
            ),
          );
        },
      ),
    );
  }
}

// Dialog components remain similar but also follow the same pattern...

class MultiSelectDialogBloc extends StatefulWidget {
  final String componentId;
  final List<dynamic> options;
  final String label;
  final Map<String, dynamic> style;
  final bool searchable;
  final String searchQuery;

  const MultiSelectDialogBloc({
    super.key,
    required this.componentId,
    required this.options,
    required this.label,
    required this.style,
    required this.searchable,
    this.searchQuery = '',
  });

  @override
  State<MultiSelectDialogBloc> createState() => _MultiSelectDialogBlocState();
}

class _MultiSelectDialogBlocState extends State<MultiSelectDialogBloc> {
  // State variables for computed values
  late DynamicFormModel _currentComponent;
  List<String> _selectedValues = [];
  List<dynamic> _filteredOptions = [];
  bool _isValidComponent = false;

  // Pre-computed UI elements
  Widget? _dialogContent;
  List<Widget> _listItems = [];

  @override
  void initState() {
    super.initState();
    _computeInitialValues();
  }

  void _computeInitialValues() {
    _filteredOptions = List.from(widget.options);
    _filterOptions();
    _computeUIElements();
  }

  void _updateComponent(DynamicFormModel component) {
    _currentComponent = component;
    _isValidComponent = component.type != FormTypeEnum.unknown;

    if (_isValidComponent) {
      // Update selected values
      final value = component.config['value'];
      if (component.config['multiple'] == true) {
        if (value is List) {
          _selectedValues = value.cast<String>();
        } else {
          _selectedValues = [];
        }
      }
      _computeUIElements();
    }
  }

  void _filterOptions() {
    if (widget.searchable && widget.searchQuery.isNotEmpty) {
      _filteredOptions = widget.options.where((option) {
        final label = option['label']?.toString().toLowerCase() ?? '';
        return label.contains(widget.searchQuery.toLowerCase());
      }).toList();
    } else {
      _filteredOptions = List.from(widget.options);
    }
  }

  // Event handler - business logic
  void _handleOptionToggle(String value, bool? newValue) {
    List<String> newValues = List.from(_selectedValues);
    if (newValue == true) {
      if (!newValues.contains(value)) {
        newValues.add(value);
      }
    } else {
      newValues.remove(value);
    }
    context.read<DynamicFormBloc>().add(
      UpdateFormFieldEvent(
        componentId: widget.componentId,
        value: newValues,
      ),
    );
    debugPrint(
      '[Select] ${widget.componentId} value updated: $newValues (multiple, dialog)',
    );
  }

  void _computeUIElements() {
    // Pre-compute list items
    _listItems = _filteredOptions.map((option) {
      final value = option['value']?.toString() ?? '';
      final label = option['label']?.toString() ?? '';
      final isSelected = _selectedValues.contains(value);

      return CheckboxListTile(
        title: Text(label),
        value: isSelected,
        onChanged: (bool? newValue) {
          _handleOptionToggle(value, newValue);
        },
      );
    }).toList();

    // Pre-compute dialog content
    final searchField = widget.searchable
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SearchFieldBloc(
              style: widget.style,
              searchQuery: widget.searchQuery,
              onChanged: (value) {
                Navigator.of(context).pop();
                Future.delayed(const Duration(milliseconds: 10), () {
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (ctx) => MultiSelectDialogBloc(
                        componentId: widget.componentId,
                        options: widget.options,
                        label: widget.label,
                        style: widget.style,
                        searchable: widget.searchable,
                        searchQuery: value,
                      ),
                    );
                  }
                });
              },
            ),
          )
        : null;

    final noResultsWidget = (_filteredOptions.isEmpty && widget.searchable)
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.style['noResultsText'] ?? 'No results found',
              style: const TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        : null;

    _dialogContent = SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (searchField != null) searchField,
          if (widget.searchable) const SizedBox(height: 16),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: _listItems,
            ),
          ),
          if (noResultsWidget != null) noResultsWidget,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DynamicFormBloc, DynamicFormState>(
      listener: (context, state) {
        // Update component from state and recompute values only when necessary
        final updatedComponent = (state.page?.components != null)
            ? state.page!.components.firstWhere(
                (c) => c.id == widget.componentId,
                orElse: () => DynamicFormModel(
                  id: widget.componentId,
                  type: FormTypeEnum.unknown,
                  order: 0,
                  config: {},
                  style: {},
                ),
              )
            : DynamicFormModel(
                id: widget.componentId,
                type: FormTypeEnum.unknown,
                order: 0,
                config: {},
                style: {},
              );

        if (updatedComponent.type != FormTypeEnum.unknown) {
          setState(() {
            _updateComponent(updatedComponent);
          });
        }
      },
      child: BlocBuilder<DynamicFormBloc, DynamicFormState>(
        buildWhen: (previous, current) {
          // Only rebuild when selected values change
          final prevComponent = previous.page?.components.firstWhere(
            (c) => c.id == widget.componentId,
            orElse: () => DynamicFormModel(
              id: widget.componentId,
              type: FormTypeEnum.unknown,
              order: 0,
              config: {},
              style: {},
            ),
          );
          final currComponent = current.page?.components.firstWhere(
            (c) => c.id == widget.componentId,
            orElse: () => DynamicFormModel(
              id: widget.componentId,
              type: FormTypeEnum.unknown,
              order: 0,
              config: {},
              style: {},
            ),
          );

          return prevComponent?.config['value'] !=
              currComponent?.config['value'];
        },
        builder: (context, state) {
          // Pure UI rendering - NO LOGIC HERE
          if (!_isValidComponent) {
            return const SizedBox.shrink();
          }

          return AlertDialog(
            title: Text(widget.label),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 8,
            ),
            content: _dialogContent,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SearchFieldBloc extends StatelessWidget {
  final Map<String, dynamic> style;
  final String searchQuery;
  final ValueChanged<String> onChanged;
  const SearchFieldBloc({
    super.key,
    required this.style,
    required this.searchQuery,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: style['searchPlaceholder'] ?? 'Search...',
        prefixIcon: const Icon(Icons.search),
      ),
      controller: TextEditingController(text: searchQuery),
      onChanged: onChanged,
    );
  }
}

class CitySearchDialogBloc extends StatefulWidget {
  final String componentId;
  final List<dynamic> options;
  final String label;
  final Map<String, dynamic> style;
  final String initialSearchQuery;

  const CitySearchDialogBloc({
    super.key,
    required this.componentId,
    required this.options,
    required this.label,
    required this.style,
    this.initialSearchQuery = '',
  });

  @override
  State<CitySearchDialogBloc> createState() => _CitySearchDialogBlocState();
}

class _CitySearchDialogBlocState extends State<CitySearchDialogBloc> {
  late String searchQuery;

  // State variables for computed values
  late DynamicFormModel _currentComponent;
  String? _selectedValue;
  List<dynamic> _filteredOptions = [];
  bool _isValidComponent = false;

  // Pre-computed UI elements
  Widget? _dialogContent;
  List<Widget> _listItems = [];

  @override
  void initState() {
    super.initState();
    searchQuery = widget.initialSearchQuery;
    _computeInitialValues();
  }

  void _computeInitialValues() {
    _filteredOptions = List.from(widget.options);
    _filterOptions();
    _computeUIElements();
  }

  void _updateComponent(DynamicFormModel component) {
    _currentComponent = component;
    _isValidComponent = component.type != FormTypeEnum.unknown;

    if (_isValidComponent) {
      // Update selected value
      final value = component.config['value'];
      if (value is List) {
        _selectedValue = value.isNotEmpty ? value.first.toString() : null;
      } else {
        _selectedValue = value?.toString();
      }
      _computeUIElements();
    }
  }

  void _filterOptions() {
    if (searchQuery.isNotEmpty) {
      _filteredOptions = widget.options.where((option) {
        final label = option['label']?.toString().toLowerCase() ?? '';
        return label.contains(searchQuery.toLowerCase());
      }).toList();
    } else {
      _filteredOptions = List.from(widget.options);
    }
  }

  // Event handler - business logic
  void _handleOptionSelect(String value) {
    context.read<DynamicFormBloc>().add(
      UpdateFormFieldEvent(
        componentId: widget.componentId,
        value: value,
      ),
    );
    debugPrint(
      '[Select] ${widget.componentId} value updated: $value (single, city search dialog)',
    );
  }

  void _computeUIElements() {
    // Pre-compute list items
    _listItems = _filteredOptions.map((option) {
      final value = option['value']?.toString() ?? '';
      final label = option['label']?.toString() ?? '';
      final isSelected = _selectedValue == value;

      return ListTile(
        title: Text(label),
        selected: isSelected,
        onTap: () => _handleOptionSelect(value),
        trailing: isSelected
            ? const Icon(Icons.check, color: Colors.blue)
            : null,
      );
    }).toList();

    final noResultsWidget = _filteredOptions.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.style['noResultsText'] ?? 'No results found',
              style: const TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        : null;

    _dialogContent = SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: widget.style['searchPlaceholder'] ?? 'Search...',
                prefixIcon: const Icon(Icons.search),
              ),
              controller: TextEditingController(text: searchQuery),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _filterOptions();
                  _computeUIElements();
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: _listItems,
            ),
          ),
          if (noResultsWidget != null) noResultsWidget,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DynamicFormBloc, DynamicFormState>(
      listener: (context, state) {
        // Update component from state and recompute values only when necessary
        final updatedComponent = (state.page?.components != null)
            ? state.page!.components.firstWhere(
                (c) => c.id == widget.componentId,
                orElse: () => DynamicFormModel(
                  id: widget.componentId,
                  type: FormTypeEnum.unknown,
                  order: 0,
                  config: {},
                  style: {},
                ),
              )
            : DynamicFormModel(
                id: widget.componentId,
                type: FormTypeEnum.unknown,
                order: 0,
                config: {},
                style: {},
              );

        if (updatedComponent.type != FormTypeEnum.unknown) {
          setState(() {
            _updateComponent(updatedComponent);
          });
        }
      },
      child: BlocBuilder<DynamicFormBloc, DynamicFormState>(
        buildWhen: (previous, current) {
          // Only rebuild when selected value changes
          final prevComponent = previous.page?.components.firstWhere(
            (c) => c.id == widget.componentId,
            orElse: () => DynamicFormModel(
              id: widget.componentId,
              type: FormTypeEnum.unknown,
              order: 0,
              config: {},
              style: {},
            ),
          );
          final currComponent = current.page?.components.firstWhere(
            (c) => c.id == widget.componentId,
            orElse: () => DynamicFormModel(
              id: widget.componentId,
              type: FormTypeEnum.unknown,
              order: 0,
              config: {},
              style: {},
            ),
          );

          return prevComponent?.config['value'] !=
              currComponent?.config['value'];
        },
        builder: (context, state) {
          // Pure UI rendering - NO LOGIC HERE
          if (!_isValidComponent) {
            return const SizedBox.shrink();
          }

          return AlertDialog(
            title: Text(widget.label),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 8,
            ),
            content: _dialogContent,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      ),
    );
  }
}
