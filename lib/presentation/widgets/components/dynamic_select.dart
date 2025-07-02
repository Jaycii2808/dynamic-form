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

String? _validateForm(DynamicFormModel component, String? value) {
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
  bool _is_dropdown_open = false;

  final GlobalKey _select_key = GlobalKey();
  OverlayEntry? _overlay_entry;
  final FocusNode _focus_node = FocusNode();

  @override
  void initState() {
    super.initState();
    // No need to setState for value here anymore, just for temporary UI like dropdown
  }

  @override
  void dispose() {
    _close_dropdown();
    _focus_node.dispose();
    super.dispose();
  }

  // Common utility function for mapping icon names to IconData
  IconData? _map_icon_name_to_icon_data(String name) {
    return IconTypeEnum.fromString(name).toIconData();
  }

  String? _validate_select(DynamicFormModel component, List<String> values) {
    // Use validateForm for basic validation (required field, etc.)
    if (values.isEmpty) {
      return _validateForm(component, '');
    }

    // For multiple values, validate each one
    for (String value in values) {
      final validation_error = _validateForm(component, value);
      if (validation_error != null) {
        return validation_error;
      }
    }

    // Check max selections for multiple select (specific to select widget)
    if (component.config['multiple'] == true) {
      final validation_config = component.validation;
      if (validation_config != null) {
        final max_selections_validation =
            validation_config['max_selections'] as Map<String, dynamic>?;
        if (max_selections_validation != null) {
          final max = max_selections_validation['max'];
          if (max != null && values.length > max) {
            return max_selections_validation['error_message'] as String? ??
                'Vượt quá số lượng cho phép';
          }
        }
      }
    }

    return null;
  }

  void _toggle_dropdown() {
    if (_is_dropdown_open) {
      _close_dropdown();
    } else {
      _open_dropdown();
    }
  }

  void _open_dropdown() {
    // Get component from current state
    final component =
        context.read<DynamicFormBloc>().state.page?.components.firstWhere(
          (c) => c.id == widget.component.id,
          orElse: () => widget.component,
        ) ??
        widget.component;

    final RenderBox render_box =
        _select_key.currentContext!.findRenderObject() as RenderBox;
    final size = render_box.size;
    final offset = render_box.localToGlobal(Offset.zero);

    _overlay_entry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _close_dropdown,
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
                component.style['border_radius'],
              ),
              child: BlocBuilder<DynamicFormBloc, DynamicFormState>(
                builder: (context, state) {
                  // Get updated component from state
                  final updated_component = (state.page?.components != null)
                      ? state.page!.components.firstWhere(
                          (c) => c.id == widget.component.id,
                          orElse: () => widget.component,
                        )
                      : widget.component;
                  return _build_dropdown_list(updated_component);
                },
              ),
            ),
          ),
        ],
      ),
    );
    _is_dropdown_open = true;
    Overlay.of(context).insert(_overlay_entry!);
  }

  void _close_dropdown() {
    if (!_is_dropdown_open) return;
    _overlay_entry?.remove();
    _overlay_entry = null;
    _is_dropdown_open = false;
  }

  Widget _build_dropdown_list(DynamicFormModel component) {
    final options = component.config['options'] as List<dynamic>? ?? [];
    final dynamic height = component.config['height'];
    final style = component.style;
    final is_multiple = component.config['multiple'] ?? false;
    // Get selected_values from BLoC state
    final component_value = component.config['value'];
    List<String> selected_values = [];
    if (is_multiple) {
      if (component_value is List) {
        selected_values = component_value.cast<String>();
      } else {
        selected_values = [];
      }
    }
    Widget list_view = ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: height == null || height == 'auto',
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final option_value = option['value']?.toString() ?? '';
        final label = option['label']?.toString() ?? '';
        final avatar_url = option['avatar']?.toString();

        if (is_multiple) {
          bool is_selected = selected_values.contains(option_value);
          return CheckboxListTile(
            title: Text(label),
            value: is_selected,
            onChanged: (bool? new_value) {
              List<String> new_values = List.from(selected_values);
              if (new_value == true) {
                if (!new_values.contains(option_value)) {
                  new_values.add(option_value);
                }
              } else {
                new_values.remove(option_value);
              }
              context.read<DynamicFormBloc>().add(
                UpdateFormFieldEvent(
                  componentId: component.id,
                  value: new_values,
                ),
              );
              debugPrint(
                '[Select] ${component.id} value updated: $new_values (multiple)',
              );
            },
            secondary: avatar_url != null
                ? CircleAvatar(backgroundImage: NetworkImage(avatar_url))
                : null,
          );
        } else {
          return ListTile(
            leading: avatar_url != null
                ? CircleAvatar(backgroundImage: NetworkImage(avatar_url))
                : null,
            title: Text(label),
            onTap: () {
              context.read<DynamicFormBloc>().add(
                UpdateFormFieldEvent(
                  componentId: component.id,
                  value: option_value,
                ),
              );
              debugPrint(
                '[Select] ${component.id} value updated: $option_value (single)',
              );
              _close_dropdown();
            },
          );
        }
      },
    );

    Widget list_container;
    if (height is num) {
      list_container = SizedBox(height: height.toDouble(), child: list_view);
    } else {
      list_container = list_view;
    }

    return Container(
      decoration: BoxDecoration(
        color: StyleUtils.parseColor(style['background_color']),
        borderRadius: StyleUtils.parseBorderRadius(style['border_radius']),
        border: Border.all(color: StyleUtils.parseColor(style['border_color'])),
      ),
      child: list_container,
    );
  }

  void _show_multi_select_dialog(
    BuildContext context,
    DynamicFormModel component,
    List<dynamic> options,
    bool is_multiple,
    bool searchable, {
    String search_query = '',
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
        searchQuery: search_query,
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
        List<String> selected_values = [];
        String? selected_value;
        if (value is List) {
          selected_values = value.cast<String>();
          selected_value = value.isNotEmpty ? value.first.toString() : null;
        } else {
          selected_value = value?.toString();
        }

        final style = Map<String, dynamic>.from(component.style);
        final options = component.config['options'] as List<dynamic>? ?? [];
        final is_multiple = component.config['multiple'] ?? false;
        final searchable = component.config['searchable'] ?? false;
        final is_disabled = component.config['disabled'] == true;

        // Apply variant styles
        if (component.variants != null) {
          if (component.config['label'] != null &&
              component.variants!.containsKey('with_label')) {
            final variant_style =
                component.variants!['with_label']['style']
                    as Map<String, dynamic>?;
            if (variant_style != null) style.addAll(variant_style);
          }
          if (component.config['icon'] != null &&
              component.variants!.containsKey('with_icon')) {
            final variant_style =
                component.variants!['with_icon']['style']
                    as Map<String, dynamic>?;
            if (variant_style != null) style.addAll(variant_style);
          }
          if (is_multiple && component.variants!.containsKey('multiple')) {
            final variant_style =
                component.variants!['multiple']['style']
                    as Map<String, dynamic>?;
            if (variant_style != null) style.addAll(variant_style);
          }
          if (searchable && component.variants!.containsKey('searchable')) {
            final variant_style =
                component.variants!['searchable']['style']
                    as Map<String, dynamic>?;
            if (variant_style != null) style.addAll(variant_style);
          }
        }

        // Determine current state
        String current_state = 'base';
        final List<String> current_values = is_multiple
            ? selected_values
            : (selected_value != null ? [selected_value] : []);

        final validation_error = _validate_select(component, current_values);

        if (validation_error != null) {
          current_state = 'error';
        } else if (current_values.isNotEmpty && validation_error == null) {
          current_state = 'success';
        } else {
          current_state = 'base';
        }

        // Apply state styles
        if (component.states != null &&
            component.states!.containsKey(current_state)) {
          final state_style =
              component.states![current_state]['style']
                  as Map<String, dynamic>?;
          if (state_style != null) style.addAll(state_style);
        }

        debugPrint(
          '[Select][build] id=${component.id} value=${is_multiple ? selected_values : selected_value} state=$current_state',
        );
        debugPrint('[Select][build] style=${style.toString()}');

        // Icon rendering
        Widget? prefix_icon;
        if ((component.config['icon'] != null || style['icon'] != null) &&
            style['icon_position'] != 'right') {
          final icon_name = (style['icon'] ?? component.config['icon'] ?? '')
              .toString();
          final icon_color = StyleUtils.parseColor(style['icon_color']);
          final icon_size = (style['icon_size'] is num)
              ? (style['icon_size'] as num).toDouble()
              : 20.0;
          final icon_data = _map_icon_name_to_icon_data(icon_name);
          if (icon_data != null) {
            prefix_icon = Icon(icon_data, color: icon_color, size: icon_size);
          }
        }

        Widget? suffix_icon;
        if ((component.config['icon'] != null || style['icon'] != null) &&
            style['icon_position'] == 'right') {
          final icon_name = (style['icon'] ?? component.config['icon'] ?? '')
              .toString();
          final icon_color = StyleUtils.parseColor(style['icon_color']);
          final icon_size = (style['icon_size'] is num)
              ? (style['icon_size'] as num).toDouble()
              : 20.0;
          final icon_data = _map_icon_name_to_icon_data(icon_name);
          if (icon_data != null) {
            suffix_icon = Icon(icon_data, color: icon_color, size: icon_size);
          }
        }

        // Get display text
        final text_style = TextStyle(
          fontSize: style['font_size']?.toDouble() ?? 16,
          color: StyleUtils.parseColor(style['color']),
          fontStyle: style['font_style'] == 'italic'
              ? FontStyle.italic
              : FontStyle.normal,
        );

        Widget display_content;

        if (is_multiple) {
          String display_text = 'Chọn các tùy chọn';
          if (selected_values.isNotEmpty) {
            final selected_labels = selected_values.map((value) {
              final option = options.firstWhere(
                (opt) => opt['value'] == value,
                orElse: () => {'label': value},
              );
              return option['label'] ?? value;
            }).toList();
            display_text = selected_labels.join(', ');
          }
          display_content = Text(display_text, style: text_style);
        } else {
          if (selected_value != null && selected_value.isNotEmpty) {
            final option = options.firstWhere(
              (opt) => opt['value'] == selected_value,
              orElse: () => {'label': selected_value},
            );
            final display_text = option['label'] ?? selected_value;

            if (option['avatar'] != null) {
              display_content = Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(option['avatar']),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(display_text, style: text_style)),
                ],
              );
            } else {
              display_content = Text(display_text, style: text_style);
            }
          } else {
            display_content = Text(
              component.config['placeholder'] ?? 'Chọn tùy chọn',
              style: text_style.copyWith(
                color: StyleUtils.parseColor(style['color']).withOpacity(0.6),
              ),
            );
          }
        }

        final helper_text = style['helper_text']?.toString();

        // Main widget structure
        return Container(
          key: Key(component.id),
          margin: StyleUtils.parsePadding(style['margin']),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label
              if (component.config['label'] != null) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    component.config['label'],
                    style: TextStyle(
                      fontSize: style['label_text_size']?.toDouble() ?? 14,
                      color: StyleUtils.parseColor(style['label_color']),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],

              // Select field
              GestureDetector(
                key: _select_key,
                onTap: is_disabled
                    ? null
                    : () {
                        FocusScope.of(context).requestFocus(_focus_node);
                        _toggle_dropdown();
                      },
                child: Container(
                  padding: StyleUtils.parsePadding(style['padding']),
                  decoration: BoxDecoration(
                    color: StyleUtils.parseColor(style['background_color']),
                    border: Border.all(
                      color: StyleUtils.parseColor(style['border_color']),
                      width: 1.0,
                    ),
                    borderRadius: StyleUtils.parseBorderRadius(
                      style['border_radius'],
                    ),
                  ),
                  child: Row(
                    children: [
                      if (prefix_icon != null) ...[
                        prefix_icon,
                        const SizedBox(width: 8),
                      ],
                      Expanded(child: display_content),
                      if (suffix_icon != null) ...[
                        const SizedBox(width: 8),
                        suffix_icon,
                      ],
                    ],
                  ),
                ),
              ),

              // Helper text
              if (helper_text != null && helper_text.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    helper_text,
                    style: TextStyle(
                      fontSize: 12,
                      color: StyleUtils.parseColor(style['helper_text_color']),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
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
