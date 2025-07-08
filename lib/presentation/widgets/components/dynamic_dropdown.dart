// ignore_for_file: non_constant_identifier_names

import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
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
  final FocusNode focusNode = FocusNode();
  final GlobalKey dropdownKey = GlobalKey();
  OverlayEntry? overlayEntry;

  // State variables for computed values
  late DynamicFormModel _currentComponent;
  String _currentState = 'base';
  Map<String, dynamic> _style = {};
  String? _displayLabel;
  Widget? _triggerContent;
  bool _isDisabled = false;
  bool _isSearchable = false;
  String? _value;
  String? _triggerIcon;
  String? _triggerAvatar;
  String _placeholder = 'Select an option';
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();

    // Initialize with widget component
    _currentComponent = widget.component;
    _computeValues();
  }

  @override
  void dispose() {
    overlayEntry?.remove();
    focusNode.dispose();
    super.dispose();
  }

  void _computeValues() {
    final config = _currentComponent.config;

    // Basic values
    _triggerAvatar = config['avatar'] as String?;
    _triggerIcon = config['icon'] as String?;
    _isSearchable = config['searchable'] as bool? ?? false;
    _placeholder = config['placeholder'] as String? ?? 'Search';
    _value = config['value']?.toString();
    _currentState = config['current_state'] ?? 'base';
    _isDisabled = config['disabled'] == true;
    _items = config['items'] as List<dynamic>? ?? [];

    _computeStyles();
    _computeDisplayLabel();
    _computeTriggerContent();
  }

  void _computeStyles() {
    _style = Map<String, dynamic>.from(_currentComponent.style);

    // Always apply variant with_icon if icon exists
    if ((_triggerIcon != null || _style['icon'] != null) &&
        _currentComponent.variants != null &&
        _currentComponent.variants!.containsKey('with_icon')) {
      final variantStyle =
          _currentComponent.variants!['with_icon']['style']
              as Map<String, dynamic>?;
      if (variantStyle != null) _style.addAll(variantStyle);
    }

    // Apply variant with_avatar if avatar exists
    if (_triggerAvatar != null &&
        _currentComponent.variants != null &&
        _currentComponent.variants!.containsKey('with_avatar')) {
      final variantStyle =
          _currentComponent.variants!['with_avatar']['style']
              as Map<String, dynamic>?;
      if (variantStyle != null) _style.addAll(variantStyle);
    }

    // Apply state style if available
    if (_currentComponent.states != null &&
        _currentComponent.states!.containsKey(_currentState)) {
      final stateStyle =
          _currentComponent.states![_currentState]['style']
              as Map<String, dynamic>?;
      if (stateStyle != null) _style.addAll(stateStyle);
    }
  }

  void _computeDisplayLabel() {
    final config = _currentComponent.config;

    if (_value == null || _value!.isEmpty) {
      _displayLabel =
          config['label'] ?? config['placeholder'] ?? 'Select an option';
    } else {
      final selectedItem = _items.firstWhere(
        (item) => item['id'] == _value && item['type'] != 'divider',
        orElse: () => null,
      );
      if (selectedItem != null) {
        _displayLabel = selectedItem['label'] as String? ?? _value;
      } else {
        _displayLabel = _value;
      }
    }
  }

  void _computeTriggerContent() {
    final config = _currentComponent.config;

    if (_isSearchable) {
      _triggerContent = Row(
        children: [
          Expanded(
            child: Text(
              _displayLabel ?? _placeholder,
              style: TextStyle(
                color: StyleUtils.parseColor(_style['color'] ?? '#000000'),
              ),
            ),
          ),
          Icon(
            Icons.search,
            color: StyleUtils.parseColor(_style['icon_color'] ?? '#000000'),
          ),
        ],
      );
    } else if (_triggerIcon != null &&
        (_displayLabel == null || _displayLabel!.isEmpty)) {
      // Icon-only trigger
      _triggerContent = Icon(
        mapIconNameToIconData(_triggerIcon!),
        color: StyleUtils.parseColor(_style['icon_color'] ?? '#000000'),
        size: (_style['icon_size'] as num?)?.toDouble() ?? 24.0,
      );
    } else {
      _triggerContent = Row(
        children: [
          if (_triggerIcon != null) ...[
            Icon(
              mapIconNameToIconData(_triggerIcon!),
              color: StyleUtils.parseColor(
                _style['icon_color'] ?? '#000000',
              ),
              size: (_style['icon_size'] as num?)?.toDouble() ?? 18.0,
            ),
            const SizedBox(width: 8),
          ],
          if (_triggerAvatar != null) ...[
            CircleAvatar(
              backgroundImage: NetworkImage(_triggerAvatar!),
              radius: 16,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              _displayLabel ?? config['placeholder'] ?? 'Select an option',
              style: TextStyle(
                color: StyleUtils.parseColor(_style['color'] ?? '#000000'),
              ),
            ),
          ),
          Icon(
            overlayEntry != null && overlayEntry!.mounted
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
            color: StyleUtils.parseColor(_style['color'] ?? '#000000'),
          ),
        ],
      );
    }
  }

  IconData? mapIconNameToIconData(String name) {
    return IconTypeEnum.fromString(name).toIconData();
  }

  void showDropdownPanel(
    BuildContext context,
    DynamicFormModel component,
    Rect rect,
    String? selectedValue,
  ) {
    final items = component.config['items'] as List<dynamic>? ?? [];
    final style = component.style;
    final isSearchable = component.config['searchable'] as bool? ?? false;
    final dropdownWidth =
        (style['dropdown_width'] as num?)?.toDouble() ?? rect.width;

    overlayEntry = OverlayEntry(
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
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      overlayEntry?.remove();
                      overlayEntry = null;
                      // Trigger rebuild to update arrow icon
                      setState(() {});
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),
                Positioned(
                  top: rect.bottom + 4,
                  left: rect.left,
                  width: dropdownWidth,
                  child: Material(
                    elevation: 4.0,
                    color: StyleUtils.parseColor(
                      style['dropdown_background_color'],
                    ),
                    borderRadius: StyleUtils.parseBorderRadius(
                      style['border_radius'],
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 300),
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
                            color: StyleUtils.parseColor(
                              style['divider_color'],
                            ),
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
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  hintText: component.config['placeholder'],
                                  isDense: true,
                                  suffixIcon: const Icon(Icons.search),
                                ),
                                onChanged: (value) {
                                  setPanelState(() {
                                    searchQuery = value;
                                  });
                                },
                                onSubmitted: (value) {
                                  if (filteredItems.isNotEmpty &&
                                      filteredItems.first['type'] !=
                                          'divider') {
                                    final firstItem = filteredItems.first;
                                    final newValue = firstItem['id'];
                                    context.read<DynamicFormBloc>().add(
                                      UpdateFormFieldEvent(
                                        componentId: component.id,
                                        value: newValue,
                                      ),
                                    );
                                    debugPrint(
                                      '[Dropdown] ${component.id} value updated: $newValue',
                                    );
                                  } else if (value.isNotEmpty) {
                                    context.read<DynamicFormBloc>().add(
                                      UpdateFormFieldEvent(
                                        componentId: component.id,
                                        value: value,
                                      ),
                                    );
                                    debugPrint(
                                      '[Dropdown] ${component.id} value updated: $value',
                                    );
                                  }
                                  overlayEntry?.remove();
                                  overlayEntry = null;
                                  // Trigger rebuild to update arrow icon
                                  setState(() {});
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
                                style['divider_color'],
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
                              context.read<DynamicFormBloc>().add(
                                UpdateFormFieldEvent(
                                  componentId: component.id,
                                  value: value,
                                ),
                              );
                              debugPrint(
                                '[Dropdown] ${component.id} value updated: $value',
                              );
                              overlayEntry?.remove();
                              overlayEntry = null;
                              // Trigger rebuild to update arrow icon
                              setState(() {});
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
                                      mapIconNameToIconData(iconName),
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
    Overlay.of(context).insert(overlayEntry!);
  }

  void _handleTap() {
    FocusScope.of(context).requestFocus(focusNode);
    final renderBox =
        dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    showDropdownPanel(
      context,
      _currentComponent,
      Rect.fromLTWH(
        offset.dx,
        offset.dy,
        size.width,
        size.height,
      ),
      _value,
    );
    // Trigger rebuild to update arrow icon
    setState(() {});
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
            updatedComponent.config['current_state'] !=
                _currentComponent.config['current_state']) {
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

          return prevComponent?.config['value'] !=
                  currComponent?.config['value'] ||
              prevComponent?.config['disabled'] !=
                  currComponent?.config['disabled'] ||
              prevComponent?.config['current_state'] !=
                  currComponent?.config['current_state'];
        },
        builder: (context, state) {
          return Focus(
            focusNode: focusNode,
            child: MouseRegion(
              child: InkWell(
                key: dropdownKey,
                onTap: _isDisabled ? null : _handleTap,
                child: Container(
                  padding: StyleUtils.parsePadding(_style['padding']),
                  margin: StyleUtils.parsePadding(_style['margin']),
                  decoration: BoxDecoration(
                    color: StyleUtils.parseColor(_style['background_color']),
                    border: Border.all(
                      color: StyleUtils.parseColor(_style['border_color']),
                      width:
                          (_style['border_width'] as num?)?.toDouble() ?? 1.0,
                    ),
                    borderRadius: StyleUtils.parseBorderRadius(
                      _style['border_radius'],
                    ),
                  ),
                  child: _triggerContent,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
