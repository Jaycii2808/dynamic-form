import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';

class DynamicSelect extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicSelect({super.key, required this.component});

  @override
  State<DynamicSelect> createState() => _DynamicSelectState();
}

class _DynamicSelectState extends State<DynamicSelect> {
  bool _isDropdownOpen = false;
  String? _errorText;

  final GlobalKey _selectKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    // No need to setState for value here anymore, just for temporary UI like dropdown
  }

  @override
  void dispose() {
    _closeDropdown();
    super.dispose();
  }

  // Common utility function for mapping icon names to IconData
  IconData? _mapIconNameToIconData(String name) {
    return IconTypeEnum.fromString(name).toIconData();
  }

  String? _validateSelect(DynamicFormModel component, List<String> values) {
    // Use validateForm for basic validation (required field, etc.)
    if (values.isEmpty) {
      return validateForm(component, '');
    }

    // For multiple values, validate each one
    for (String value in values) {
      final validationError = validateForm(component, value);
      if (validationError != null) {
        return validationError;
      }
    }

    // Check max selections for multiple select (specific to select widget)
    if (component.config['multiple'] == true) {
      final validationConfig = component.validation;
      if (validationConfig != null) {
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
    // Get component from current state
    final component =
        context.read<DynamicFormBloc>().state.page?.components.firstWhere(
          (c) => c.id == widget.component.id,
          orElse: () => widget.component,
        ) ??
        widget.component;

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
    _isDropdownOpen = true;
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeDropdown() {
    if (!_isDropdownOpen) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isDropdownOpen = false;
  }

  Widget _buildDropdownList(DynamicFormModel component) {
    final options = component.config['options'] as List<dynamic>? ?? [];
    final dynamic height = component.config['height'];
    final style = component.style;
    final isMultiple = component.config['multiple'] ?? false;
    // Get selectedValues from BLoC state
    final value = component.config['value'];
    List<String> selectedValues = [];
    if (component.config['multiple'] == true) {
      if (value is List) {
        selectedValues = value.cast<String>();
      } else {
        selectedValues = [];
      }
    }
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
          bool isSelected = selectedValues.contains(value);
          return CheckboxListTile(
            title: Text(label),
            value: isSelected,
            onChanged: (bool? newValue) {
              List<String> newValues = List.from(selectedValues);
              if (newValue == true) {
                if (!newValues.contains(value)) {
                  newValues.add(value);
                }
              } else {
                newValues.remove(value);
              }
              context.read<DynamicFormBloc>().add(
                UpdateFormFieldEvent(
                  componentId: component.id,
                  value: newValues,
                ),
              );
              debugPrint(
                '[Select] ${component.id} value updated: $newValues (multiple)',
              );
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
              context.read<DynamicFormBloc>().add(
                UpdateFormFieldEvent(componentId: component.id, value: value),
              );
              debugPrint(
                '[Select] ${component.id} value updated: $value (single)',
              );
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
    bool searchable, {
    String searchQuery = '',
  }) {
    final style = Map<String, dynamic>.from(component.style);
    showDialog(
      context: context,
      builder: (BuildContext context) => MultiSelectDialogBloc(
        componentId: component.id,
        options: options,
        label: component.config['label'] ?? 'Chọn tùy chọn',
        style: style,
        searchable: searchable,
        searchQuery: searchQuery,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DynamicFormBloc, DynamicFormState>(
      listener: (context, state) {},
      builder: (context, state) {
        // Lấy component mới nhất từ state (theo id)
        final component = (state.page?.components != null)
            ? state.page!.components.firstWhere(
                (c) => c.id == widget.component.id,
                orElse: () => widget.component,
              )
            : widget.component;

        // Read value from BLoC state, do not use setState
        final value = component.config['value'];
        List<String> selectedValues = [];
        String? selectedValue;
        if (value is List) {
          selectedValues = value.cast<String>();
          selectedValue = value.isNotEmpty ? value.first.toString() : null;
        } else {
          selectedValue = value?.toString();
        }

        final style = Map<String, dynamic>.from(component.style);
        final options = component.config['options'] as List<dynamic>? ?? [];
        final isMultiple = component.config['multiple'] ?? false;
        final searchable = component.config['searchable'] ?? false;

        // Apply variant styles
        if (component.variants != null) {
          if (component.config['label'] != null &&
              component.variants!.containsKey('withLabel')) {
            final variantStyle =
                component.variants!['withLabel']['style']
                    as Map<String, dynamic>?;
            if (variantStyle != null) style.addAll(variantStyle);
          }
          if (component.config['icon'] != null &&
              component.variants!.containsKey('withIcon')) {
            final variantStyle =
                component.variants!['withIcon']['style']
                    as Map<String, dynamic>?;
            if (variantStyle != null) style.addAll(variantStyle);
          }
          if (isMultiple && component.variants!.containsKey('multiple')) {
            final variantStyle =
                component.variants!['multiple']['style']
                    as Map<String, dynamic>?;
            if (variantStyle != null) style.addAll(variantStyle);
          }
          if (searchable && component.variants!.containsKey('searchable')) {
            final variantStyle =
                component.variants!['searchable']['style']
                    as Map<String, dynamic>?;
            if (variantStyle != null) style.addAll(variantStyle);
          }
        }

        // Determine current state
        String currentState = 'base';
        final List<String> currentValues = isMultiple
            ? selectedValues
            : (selectedValue != null ? [selectedValue] : []);

        final validationError = _validateSelect(component, currentValues);

        if (validationError != null) {
          currentState = 'error';
        } else if (currentValues.isNotEmpty && validationError == null) {
          currentState = 'success';
        } else {
          currentState = 'base';
        }

        // Apply state styles
        if (component.states != null &&
            component.states!.containsKey(currentState)) {
          final stateStyle =
              component.states![currentState]['style'] as Map<String, dynamic>?;
          if (stateStyle != null) style.addAll(stateStyle);
        }

        debugPrint(
          '[Select][build] id=${component.id} value=${isMultiple ? selectedValues : selectedValue} state=$currentState',
        );
        debugPrint('[Select][build] style=${style.toString()}');

        // Icon rendering
        Widget? prefixIcon;
        if ((component.config['icon'] != null || style['icon'] != null) &&
            style['iconPosition'] != 'right') {
          final iconName = (style['icon'] ?? component.config['icon'] ?? '')
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
        if ((component.config['icon'] != null || style['icon'] != null) &&
            style['iconPosition'] == 'right') {
          final iconName = (style['icon'] ?? component.config['icon'] ?? '')
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
          if (selectedValues.isNotEmpty) {
            final selectedLabels = selectedValues.map((value) {
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
          if (selectedValue != null && selectedValue.isNotEmpty) {
            final option = options.firstWhere(
              (opt) => opt['value'] == selectedValue,
              orElse: () => {'label': selectedValue},
            );
            final displayText = option['label'] ?? selectedValue;
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
              component.config['placeholder'] ?? 'Chọn một tùy chọn',
              style: textStyle,
            );
          }
        }

        final hasLabel =
            component.config['label'] != null &&
            component.config['label'].isNotEmpty;

        return Container(
          key: Key(component.id),
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          margin: StyleUtils.parsePadding(style['margin']),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasLabel)
                Padding(
                  padding: const EdgeInsets.only(left: 2, bottom: 7),
                  child: Text(
                    component.config['label'],
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
                  if (isMultiple) {
                    _showMultiSelectDialog(
                      context,
                      component,
                      options,
                      isMultiple,
                      searchable,
                    );
                  } else if (searchable) {
                    // Single-select + searchable: city dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => CitySearchDialogBloc(
                        componentId: component.id,
                        options: options,
                        label: component.config['label'] ?? 'Chọn tùy chọn',
                        style: style,
                        initialSearchQuery: '',
                      ),
                    );
                  } else {
                    _toggleDropdown();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
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
      },
    );
  }
}

class MultiSelectDialogBloc extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BlocBuilder<DynamicFormBloc, DynamicFormState>(
      builder: (context, state) {
        final component = (state.page?.components != null)
            ? state.page!.components.firstWhere(
                (c) => c.id == componentId,
                orElse: () => DynamicFormModel(
                  id: componentId,
                  type: FormTypeEnum.unknown,
                  order: 0,
                  config: {},
                  style: {},
                ),
              )
            : DynamicFormModel(
                id: componentId,
                type: FormTypeEnum.unknown,
                order: 0,
                config: {},
                style: {},
              );
        if (component.type == FormTypeEnum.unknown) {
          return const SizedBox.shrink();
        }
        final value = component.config['value'];
        List<String> selectedValues = [];
        if (component.config['multiple'] == true) {
          if (value is List) {
            selectedValues = value.cast<String>();
          }
        }
        List<dynamic> filteredOptions = options;
        if (searchable && searchQuery.isNotEmpty) {
          filteredOptions = options.where((option) {
            final label = option['label']?.toString().toLowerCase() ?? '';
            return label.contains(searchQuery.toLowerCase());
          }).toList();
        }
        return AlertDialog(
          title: Text(label),
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
                    child: _SearchFieldBloc(
                      style: style,
                      searchQuery: searchQuery,
                      onChanged: (value) {
                        Navigator.of(context).pop();
                        Future.delayed(const Duration(milliseconds: 10), () {
                          if (context.mounted) {
                            showDialog(
                              context: context,
                              builder: (ctx) => MultiSelectDialogBloc(
                                componentId: componentId,
                                options: options,
                                label: label,
                                style: style,
                                searchable: searchable,
                                searchQuery: value,
                              ),
                            );
                          }
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
                      bool isSelected = selectedValues.contains(value);
                      return CheckboxListTile(
                        title: Text(label),
                        value: isSelected,
                        onChanged: (bool? newValue) {
                          List<String> newValues = List.from(selectedValues);
                          if (newValue == true) {
                            if (!newValues.contains(value)) {
                              newValues.add(value);
                            }
                          } else {
                            newValues.remove(value);
                          }
                          context.read<DynamicFormBloc>().add(
                            UpdateFormFieldEvent(
                              componentId: componentId,
                              value: newValues,
                            ),
                          );
                          debugPrint(
                            '[Select] $componentId value updated: $newValues (multiple, dialog)',
                          );
                        },
                      );
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
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }
}

class _SearchFieldBloc extends StatelessWidget {
  final Map<String, dynamic> style;
  final String searchQuery;
  final ValueChanged<String> onChanged;
  const _SearchFieldBloc({
    required this.style,
    required this.searchQuery,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: style['searchPlaceholder'] ?? 'Tìm kiếm...',
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

  @override
  void initState() {
    super.initState();
    searchQuery = widget.initialSearchQuery;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DynamicFormBloc, DynamicFormState>(
      builder: (context, state) {
        final component = (state.page?.components != null)
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
        if (component.type == FormTypeEnum.unknown) {
          return const SizedBox.shrink();
        }
        final value = component.config['value'];
        String? selectedValue;
        if (value is List) {
          selectedValue = value.isNotEmpty ? value.first.toString() : null;
        } else {
          selectedValue = value?.toString();
        }
        List<dynamic> filteredOptions = widget.options;
        if (searchQuery.isNotEmpty) {
          filteredOptions = widget.options.where((option) {
            final label = option['label']?.toString().toLowerCase() ?? '';
            return label.contains(searchQuery.toLowerCase());
          }).toList();
        }
        return AlertDialog(
          title: Text(widget.label),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 8,
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText:
                          widget.style['searchPlaceholder'] ?? 'Tìm kiếm...',
                      prefixIcon: const Icon(Icons.search),
                    ),
                    controller: TextEditingController(text: searchQuery),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredOptions.length,
                    itemBuilder: (context, index) {
                      final option = filteredOptions[index];
                      final value = option['value']?.toString() ?? '';
                      final label = option['label']?.toString() ?? '';
                      bool isSelected = selectedValue == value;
                      return ListTile(
                        title: Text(label),
                        selected: isSelected,
                        onTap: () {
                          context.read<DynamicFormBloc>().add(
                            UpdateFormFieldEvent(
                              componentId: widget.componentId,
                              value: value,
                            ),
                          );
                          debugPrint(
                            '[Select] ${widget.componentId} value updated: $value (single, city search dialog)',
                          );
                        },
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Colors.blue)
                            : null,
                      );
                    },
                  ),
                ),
                if (filteredOptions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      widget.style['noResultsText'] ?? 'Không tìm thấy kết quả',
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
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }
}

// void _showCitySearchDialog(
//   BuildContext context,
//   DynamicFormModel component,
//   List<dynamic> options,
//   String label,
//   Map<String, dynamic> style, {
//   String searchQuery = '',
// }) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) => CitySearchDialogBloc(
//       componentId: component.id,
//       options: options,
//       label: label,
//       style: style,
//       initialSearchQuery: searchQuery,
//     ),
//   );
// }
