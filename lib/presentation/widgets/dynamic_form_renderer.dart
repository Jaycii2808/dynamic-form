import 'dart:async';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:textfield_tags/textfield_tags.dart';

IconData? mapIconNameToIconData(String name) {
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
    // Select input icons
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

class DynamicFormRenderer extends StatefulWidget {
  final DynamicFormModel component;

  const DynamicFormRenderer({super.key, required this.component});

  @override
  State<DynamicFormRenderer> createState() => _DynamicFormRendererState();
}

class _DynamicFormRendererState extends State<DynamicFormRenderer> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;
  late FocusNode _focusNode;
  DateTimeRange? _selectedDateRange;
  RangeValues? _sliderRangeValues;
  double? _sliderValue;

  // Select input variables
  String? _selectedValue;
  List<String> _selectedValues = []; // For multiple selection
  bool _isDropdownOpen = false;
  bool _isTouched = false; // To track if the field has been interacted with
  bool _showSuggestions = false;
  final Set<String> _selectedTags = {};
  late StringTagController<String> tagController;

  // Dropdown-specific states
  bool _isHovering = false;
  String? _selectedActionId;
  String? _dropdownErrorText;
  String? _currentDropdownLabel; // To hold the dynamic label of the trigger

  final GlobalKey _selectKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
    final value = widget.component.config['value'];
    final values = widget.component.config['values'];

    if (value is String) {
      _controller.text = value;
    } else if (value is num) {
      _sliderValue = value.toDouble();
    } else {
      _controller.text = '';
    }

    if (values is List) {
      _sliderRangeValues = RangeValues(values[0].toDouble(), values[1].toDouble());
    }

    _currentDropdownLabel = widget.component.config['label'];
    tagController = StringTagController<String>();
    final initialTags =
        (widget.component.config['initialTags'] as List<dynamic>?)?.cast<String>() ?? [];
    for (var tag in initialTags) {
      tagController.addTag(tag);
    }
    _selectedTags.addAll(initialTags);
  }

  @override
  void dispose() {
    _closeDropdown();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final component = widget.component;
    switch (component.type) {
      case FormTypeEnum.textFieldFormType:
        return _buildTextField(component);
      case FormTypeEnum.selectFormType:
        return _buildSelect(component);
      case FormTypeEnum.textAreaFormType:
        return _buildTextArea(component);
      case FormTypeEnum.dateTimePickerFormType:
        return _buildDateTimePickerForm(component);
      case FormTypeEnum.dropdownFormType:
        return _buildDropdown(component);
      case FormTypeEnum.checkboxGroupFormType:
        return _buildCheckboxGroup(component);
      case FormTypeEnum.checkboxFormType:
        return _buildToggleableRow(component, isRadio: false);
      case FormTypeEnum.radioFormType:
        return _buildToggleableRow(component, isRadio: true);
      case FormTypeEnum.radioGroupFormType:
        return _buildRadioGroup(component);
      case FormTypeEnum.sliderFormType:
        return _buildSlider(component);
      case FormTypeEnum.selectorFormType:
        return _buildSelector(component);
      case FormTypeEnum.switchFormType:
        return _buildSwitch(component);
      case FormTypeEnum.textFieldTagsFormType:
        return _buildTextFieldTags(component);
      case FormTypeEnum.fileUploaderFormType:
        return _FileUploaderWidget(component: component);
      case FormTypeEnum.unknown:
        return _buildDefaultFormType();
      }
  }

  Widget _buildTextFieldTags(DynamicFormModel component) {
    final style = Map<String, dynamic>.from(component.style);
    final config = component.config;
    final initialTags = (config['initialTags'] as List<dynamic>?)?.cast<String>() ?? [];
    final placeholder = config['placeholder'] ?? 'Enter tags...';

    debugPrint('TextFieldTags: Initial tags are $initialTags');
    debugPrint('TextFieldTags: Selected tags are ${_selectedTags.toList()}');

    // Determine current state
    String currentState = 'base';
    if (_selectedTags.isNotEmpty) currentState = 'success';
    if (_errorText != null) currentState = 'error';
    if (component.states != null && component.states!.containsKey(currentState)) {
      final stateStyle = component.states![currentState]['style'] as Map<String, dynamic>?;
      if (stateStyle != null) style.addAll(stateStyle);
    }

    if (_showSuggestions) {
      return Container(
        key: Key(component.id),
        padding: StyleUtils.parsePadding(style['padding']),
        margin: StyleUtils.parsePadding(style['margin'] ?? '0 0 10 0'),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent, width: 1.5),
          borderRadius: BorderRadius.circular(14.0),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedTags.isNotEmpty)
              Container(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _selectedTags.map((tag) {
                    return Container(
                      decoration: BoxDecoration(
                        color: StyleUtils.parseColor('#CDD2FD'),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: StyleUtils.parseColor('#CDD2FD'), width: 10.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 14,
                                color: StyleUtils.parseColor('#6979F8'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTags.remove(tag);
                                debugPrint('Removed: Tag $tag removed from ${component.id}');
                              });
                            },
                            child: SvgPicture.asset(
                              'assets/svg/Close.svg',
                              width: 16,
                              height: 16,
                              colorFilter: const ColorFilter.mode(
                                Colors.redAccent,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                debugPrint('Autocomplete: Filtering options for input ${textEditingValue.text}');
                final availableTags = initialTags
                    .where((tag) => !_selectedTags.contains(tag))
                    .toList();
                if (textEditingValue.text.isEmpty) return availableTags;
                return availableTags.where(
                  (tag) => tag.toLowerCase().contains(textEditingValue.text.toLowerCase()),
                );
              },
              onSelected: (String selection) {
                debugPrint('Autocomplete: Selected tag $selection');
                if (!_selectedTags.contains(selection)) {
                  setState(() {
                    _selectedTags.add(selection);
                    _errorText = null;
                    debugPrint('TagAdded: Successfully added tag $selection via autocomplete');
                  });
                }
              },
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  onSubmitted: (value) {
                    debugPrint('OnSubmitted: Submitted value $value');
                    if (value.isNotEmpty &&
                        initialTags.contains(value.trim()) &&
                        !_selectedTags.contains(value.trim())) {
                      textEditingController.clear();
                      setState(() {
                        _selectedTags.add(value.trim());
                        _errorText = null;
                        debugPrint('TagAdded: Successfully added tag $value');
                      });
                    } else if (_selectedTags.contains(value.trim())) {
                      setState(() {
                        _errorText = 'Tag already selected';
                        debugPrint('TagRejected: $value is already selected');
                      });
                    } else {
                      setState(() {
                        _errorText = 'Tag must match predefined list';
                        debugPrint('TagRejected: $value does not match predefined tags');
                      });
                    }
                  },
                  onChanged: (value) {
                    debugPrint('OnChanged: Input changed to $value');
                    if (_errorText != null) {
                      setState(() => _errorText = null);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: placeholder,
                    border: OutlineInputBorder(
                      borderRadius: StyleUtils.parseBorderRadius(style['borderRadius']),
                      borderSide: BorderSide(
                        color: StyleUtils.parseColor(style['borderColor']),
                        width: style['borderWidth']?.toDouble() ?? 1.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: StyleUtils.parseBorderRadius(style['borderRadius']),
                      borderSide: BorderSide(
                        color: StyleUtils.parseColor(style['borderColor']),
                        width: style['borderWidth']?.toDouble() ?? 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: StyleUtils.parseBorderRadius(style['borderRadius']),
                      borderSide: BorderSide(
                        color: StyleUtils.parseColor(style['borderColor']),
                        width: style['borderWidth']?.toDouble() ?? 2.0,
                      ),
                    ),
                    filled: style['backgroundColor'] != null,
                    fillColor: StyleUtils.parseColor(style['backgroundColor']),
                    errorText: _errorText,
                  ),
                  style: TextStyle(
                    fontSize: style['fontSize']?.toDouble() ?? 16,
                    color: StyleUtils.parseColor(style['color'] ?? '#000000'),
                  ),
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
                          return ListTile(
                            dense: true,
                            title: Text(option),
                            onTap: () => onSelected(option),
                            hoverColor: Colors.grey[100],
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => setState(() => _showSuggestions = false),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          setState(() {
            _showSuggestions = true;
            debugPrint('Tap: Showing suggestions for ${component.id}');
          });
        },
        child: Container(
          key: Key(component.id),
          padding: StyleUtils.parsePadding(style['padding']),
          margin: StyleUtils.parsePadding(style['margin'] ?? '0 0 10 0'),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent, width: 1.5),
            borderRadius: BorderRadius.circular(14.0),
            color: Colors.white,
          ),
          child: _selectedTags.isEmpty
              ? const Center(
                  child: Text(
                    'Click to add tags',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                )
              : Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _selectedTags.map((tag) {
                    return Container(
                      decoration: BoxDecoration(
                        color: StyleUtils.parseColor('#CDD2FD'),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: StyleUtils.parseColor('#CDD2FD'), width: 10.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tag,
                            style: TextStyle(
                              fontSize: 16,
                              color: StyleUtils.parseColor('#6979F8'),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTags.remove(tag);
                                debugPrint('Removed: Tag $tag removed from ${component.id}');
                              });
                            },
                            child: SvgPicture.asset(
                              'assets/svg/Close.svg',
                              width: 16,
                              height: 16,
                              colorFilter: const ColorFilter.mode(
                                Colors.redAccent,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
      );
    }
  }

  Widget _buildSwitch(DynamicFormModel component) {
    final style = Map<String, dynamic>.from(component.style);
    final config = component.config;
    final hasLabel = config['label'] != null && config['label'].isNotEmpty;
    final selected = config['selected'] ?? false;

    // Apply variant styles
    if (component.variants != null) {
      if (hasLabel && component.variants!.containsKey('withLabel')) {
        final variantStyle = component.variants!['withLabel']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (!hasLabel && component.variants!.containsKey('withoutLabel')) {
        final variantStyle = component.variants!['withoutLabel']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
    }

    // Determine current state
    String currentState = 'base';
    if (selected) currentState = 'success';

    if (component.states != null && component.states!.containsKey(currentState)) {
      final stateStyle = component.states![currentState]['style'] as Map<String, dynamic>?;
      if (stateStyle != null) style.addAll(stateStyle);
    }

    return Container(
      key: Key(component.id),
      padding: StyleUtils.parsePadding(style['padding']),
      margin: StyleUtils.parsePadding(style['margin'] ?? '0 0 10 0'),
      child: GestureDetector(
        onTap: () {
          setState(() {
            component.config['selected'] = !selected;
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              selected ? 'assets/svg/On.svg' : 'assets/svg/Off.svg',
              // width: (style['iconSize'] as num?)?.toDouble() ?? 20.0,
              // height: (style['iconSize'] as num?)?.toDouble() ?? 20.0,
            ),
            if (hasLabel)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  config['label'],
                  style: TextStyle(
                    fontSize: style['labelTextSize']?.toDouble() ?? 16,
                    color: StyleUtils.parseColor(style['labelColor'] ?? '#6979F8'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelector(DynamicFormModel component) {
    final style = Map<String, dynamic>.from(component.style);
    final config = component.config;
    final hasLabel = config['label'] != null && config['label'].isNotEmpty;
    final selected = config['selected'] ?? false;

    // Apply variant styles
    if (component.variants != null) {
      if (hasLabel && component.variants!.containsKey('withLabel')) {
        final variantStyle = component.variants!['withLabel']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (!hasLabel && component.variants!.containsKey('withoutLabel')) {
        final variantStyle = component.variants!['withoutLabel']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
    }

    // Determine current state
    String currentState = 'base';
    if (selected) currentState = 'success';

    if (component.states != null && component.states!.containsKey(currentState)) {
      final stateStyle = component.states![currentState]['style'] as Map<String, dynamic>?;
      if (stateStyle != null) style.addAll(stateStyle);
    }

    return Container(
      key: Key(component.id),
      padding: StyleUtils.parsePadding(style['padding']),
      margin: StyleUtils.parsePadding(style['margin'] ?? '0 0 10 0'),
      child: GestureDetector(
        onTap: () {
          setState(() {
            component.config['selected'] = !selected;
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              selected ? 'assets/svg/Active.svg' : 'assets/svg/Inactive.svg',
              width: (style['iconSize'] as num?)?.toDouble() ?? 20.0,
              height: (style['iconSize'] as num?)?.toDouble() ?? 20.0,
            ),
            if (hasLabel)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  config['label'],
                  style: TextStyle(
                    fontSize: style['labelTextSize']?.toDouble() ?? 16,
                    color: StyleUtils.parseColor(style['labelColor']),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimePickerForm(DynamicFormModel component) {
    final style = Map<String, dynamic>.from(component.style);
    final config = component.config;
    final isRange = config['range'] == true;

    if (component.variants != null) {
      final variantKey = isRange ? 'range' : 'single';
      if (component.variants!.containsKey(variantKey)) {
        final variantStyle = component.variants![variantKey]['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
    }

    String currentState = 'base';
    final validationError = _validateDatePicker(component, _selectedDateRange);
    if (_isTouched && validationError != null) {
      currentState = 'error';
    } else if (_selectedDateRange != null && validationError == null) {
      currentState = 'success';
    }

    if (component.states != null && component.states!.containsKey(currentState)) {
      final stateStyle = component.states![currentState]['style'] as Map<String, dynamic>?;
      if (stateStyle != null) style.addAll(stateStyle);
    }

    String dateDisplay = config['value'] ?? (isRange ? 'dd/mm/yyyy - dd/mm/yyyy' : 'dd/mm/yyyy');
    if (_selectedDateRange != null) {
      if (isRange) {
        final start = _selectedDateRange!.start;
        final end = _selectedDateRange!.end;
        dateDisplay =
            "${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year} - "
            "${end.day.toString().padLeft(2, '0')}/${end.month.toString().padLeft(2, '0')}/${end.year}";
      } else {
        final date = _selectedDateRange!.start;
        dateDisplay =
            "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
      }
    }

    Future<void> selectDate(BuildContext context) async {
      if (isRange) {
        final DateTimeRange? picked = await showDateRangePicker(
          context: context,
          initialDateRange: _selectedDateRange,
          firstDate: DateTime(2016),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(primary: Color(0xFF6979F8)),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            _isTouched = true;
            _selectedDateRange = picked;
            _errorText = _validateDatePicker(component, picked);
            component.config['value'] =
                "${picked.start.day.toString().padLeft(2, '0')}/${picked.start.month.toString().padLeft(2, '0')}/${picked.start.year} - "
                "${picked.end.day.toString().padLeft(2, '0')}/${picked.end.month.toString().padLeft(2, '0')}/${picked.end.year}";
          });
        }
      } else {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedDateRange?.start ?? DateTime.now(),
          firstDate: DateTime(2016),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(primary: Color(0xFF6979F8)),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            _isTouched = true;
            _selectedDateRange = DateTimeRange(start: picked, end: picked);
            _errorText = _validateDatePicker(component, _selectedDateRange);
            component.config['value'] =
                "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
          });
        }
      }
    }

    return Container(
      key: Key(component.id),
      padding: StyleUtils.parsePadding(style['padding']),
      margin: StyleUtils.parsePadding(style['margin']),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (config['label'] != null)
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 7),
              child: Text(
                config['label'],
                style: TextStyle(
                  fontSize: style['labelTextSize']?.toDouble() ?? 16,
                  color: StyleUtils.parseColor(style['labelColor']),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          GestureDetector(
            onTap: () => selectDate(context),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: StyleUtils.parseColor(
                    style['borderColor'],
                  ).withValues(alpha: style['borderOpacity']?.toDouble() ?? 1.0),
                  width: style['borderWidth']?.toDouble() ?? 1.0,
                ),
                borderRadius: StyleUtils.parseBorderRadius(style['borderRadius']),
                color: StyleUtils.parseColor(style['backgroundColor']),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateDisplay,
                    style: TextStyle(
                      fontSize: style['fontSize']?.toDouble() ?? 16,
                      color: StyleUtils.parseColor(style['color']),
                      fontStyle: style['fontStyle'] == 'italic'
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    color: StyleUtils.parseColor(style['iconColor']),
                    size: (style['iconSize'] as num?)?.toDouble() ?? 20.0,
                  ),
                ],
              ),
            ),
          ),
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 12),
              child: Text(_errorText!, style: const TextStyle(color: Colors.red, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildTextArea(DynamicFormModel component) {
    final style = Map<String, dynamic>.from(component.style);

    if (component.variants != null) {
      if (component.config['label'] != null && component.variants!.containsKey('withLabel')) {
        final variantStyle = component.variants!['withLabel']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (component.config['value'] != null && component.variants!.containsKey('withLabelValue')) {
        final variantStyle =
            component.variants!['withLabelValue']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (component.config['value'] != null && component.variants!.containsKey('withValue')) {
        final variantStyle = component.variants!['withValue']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
    }

    String currentState = 'base';
    final value = _controller.text;
    if (value.isEmpty) {
      currentState = 'base';
    } else {
      final validationError = _validate(component, value);
      if (validationError != null) {
        currentState = 'error';
      } else {
        currentState = 'success';
      }
    }

    if (component.states != null && component.states!.containsKey(currentState)) {
      final stateStyle = component.states![currentState]['style'] as Map<String, dynamic>?;
      if (stateStyle != null) style.addAll(stateStyle);
    }

    //final helperText = style['helperText']?.toString();
    final helperTextColor = StyleUtils.parseColor(style['helperTextColor']);

    return Container(
      key: Key(component.id),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      margin: StyleUtils.parsePadding(style['margin']),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (component.config['label'] != null)
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
          Stack(
            children: [
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: component.config['editable'] ?? true,
                obscureText: component.inputTypes?.containsKey('password') ?? false,
                keyboardType: _getKeyboardType(component),
                maxLines: (style['maxLines'] is num) ? (style['maxLines'] as num).toInt() : 10,
                minLines: (style['minLines'] is num) ? (style['minLines'] as num).toInt() : 6,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: component.config['placeholder'] ?? '',
                  border: OutlineInputBorder(
                    borderRadius: StyleUtils.parseBorderRadius(style['borderRadius']),
                    borderSide: BorderSide(
                      color: StyleUtils.parseColor(style['borderColor']),
                      width: style['borderWidth']?.toDouble() ?? 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: StyleUtils.parseBorderRadius(style['borderRadius']),
                    borderSide: BorderSide(
                      color: StyleUtils.parseColor(style['borderColor']),
                      width: style['borderWidth']?.toDouble() ?? 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: StyleUtils.parseBorderRadius(style['borderRadius']),
                    borderSide: BorderSide(
                      color: StyleUtils.parseColor(style['borderColor']),
                      width: style['borderWidth']?.toDouble() ?? 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: StyleUtils.parseBorderRadius(style['borderRadius']),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  errorText: null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  filled: style['backgroundColor'] != null,
                  fillColor: StyleUtils.parseColor(style['backgroundColor']),
                  helperText: _errorText,
                  // Đảm bảo helperText hiển thị _errorText
                  helperStyle: TextStyle(
                    color: helperTextColor,
                    fontStyle: style['fontStyle'] == 'italic' ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
                style: TextStyle(
                  fontSize: style['fontSize']?.toDouble() ?? 16,
                  color: StyleUtils.parseColor(style['color']),
                  fontStyle: style['fontStyle'] == 'italic' ? FontStyle.italic : FontStyle.normal,
                ),
                onChanged: (value) {
                  setState(() {
                    _errorText = _validate(component, value);
                  });
                },
              ),
              if (_errorText != null)
                Positioned(
                  //
                  right: 10,
                  bottom: 0,
                  child: Text(
                    '$_errorText (Now ${value.length - 100})',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(DynamicFormModel component) {
    final style = Map<String, dynamic>.from(component.style);

    // Apply variant styles
    if (component.variants != null) {
      if (component.config['label'] != null && component.variants!.containsKey('withLabel')) {
        final variantStyle = component.variants!['withLabel']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (component.config['icon'] != null && component.variants!.containsKey('withIcon')) {
        final variantStyle = component.variants!['withIcon']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
    }

    // Determine current state
    String currentState = 'base';
    final value = _controller.text;
    if (value.isEmpty) {
      currentState = 'base';
    } else {
      final validationError = _validate(component, value);
      if (validationError != null) {
        currentState = 'error';
      } else {
        currentState = 'success';
      }
    }

    // Apply state styles (base, error, success, ...)
    if (component.states != null && component.states!.containsKey(currentState)) {
      final stateStyle = component.states![currentState]['style'] as Map<String, dynamic>?;
      if (stateStyle != null) style.addAll(stateStyle);
    }

    // Icon rendering (dynamic)
    Widget? prefixIcon;
    if (component.config['icon'] != null || style['icon'] != null) {
      final iconName = (style['icon'] ?? component.config['icon'] ?? '').toString();
      final iconColor = StyleUtils.parseColor(style['iconColor']);
      final iconSize = (style['iconSize'] is num) ? (style['iconSize'] as num).toDouble() : 20.0;
      final iconData = mapIconNameToIconData(iconName);
      if (iconData != null) {
        prefixIcon = Icon(iconData, color: iconColor, size: iconSize);
      }
    }

    // Helper text
    final helperText = style['helperText']?.toString();
    final helperTextColor = StyleUtils.parseColor(style['helperTextColor']);

    return Container(
      key: Key(component.id),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      margin: StyleUtils.parsePadding(style['margin']),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (component.config['label'] != null)
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
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: component.config['editable'] ?? true,
            obscureText: component.inputTypes?.containsKey('password') ?? false,
            keyboardType: _getKeyboardType(component),
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: prefixIcon,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
                maxWidth: 36,
                maxHeight: 36,
              ),
              hintText: component.config['placeholder'] ?? '',
              border: OutlineInputBorder(
                borderRadius: StyleUtils.parseBorderRadius(style['borderRadius']),
                borderSide: BorderSide(color: StyleUtils.parseColor(style['borderColor'])),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: StyleUtils.parseBorderRadius(style['borderRadius']),
                borderSide: BorderSide(color: StyleUtils.parseColor(style['borderColor'])),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: StyleUtils.parseBorderRadius(style['borderRadius']),
                borderSide: BorderSide(
                  color: StyleUtils.parseColor(style['borderColor']),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: StyleUtils.parseBorderRadius(style['borderRadius']),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              errorText: _errorText,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              filled: style['backgroundColor'] != null,
              fillColor: StyleUtils.parseColor(style['backgroundColor']),
              helperText: helperText,
              helperStyle: TextStyle(
                color: helperTextColor,
                fontStyle: style['fontStyle'] == 'italic' ? FontStyle.italic : FontStyle.normal,
              ),
            ),
            style: TextStyle(
              fontSize: style['fontSize']?.toDouble() ?? 16,
              color: StyleUtils.parseColor(style['color']),
              fontStyle: style['fontStyle'] == 'italic' ? FontStyle.italic : FontStyle.normal,
            ),
            onChanged: (value) {
              setState(() {
                _errorText = _validate(component, value);
              });
            },
          ),
        ],
      ),
    );
  }

  TextInputType _getKeyboardType(DynamicFormModel component) {
    if (component.inputTypes != null) {
      if (component.inputTypes!.containsKey('email')) {
        return TextInputType.emailAddress;
      } else if (component.inputTypes!.containsKey('tel')) {
        return TextInputType.phone;
      } else if (component.inputTypes!.containsKey('password')) {
        return TextInputType.visiblePassword;
      }
    }
    return TextInputType.text;
  }

  String? _validate(DynamicFormModel component, String value) {
    // Check required field first
    if ((component.config['isRequired'] ?? false) && value.trim().isEmpty) {
      return 'Trường này là bắt buộc';
    }

    // If empty and not required, no validation needed
    if (value.trim().isEmpty) {
      return null;
    }

    // Validate based on inputTypes
    final inputTypes = component.inputTypes;
    if (inputTypes != null && inputTypes.isNotEmpty) {
      // Try to determine which input type to use based on component config or validation
      String? selectedType;

      // Check if there's a specific type mentioned in config
      if (component.config['inputType'] != null) {
        selectedType = component.config['inputType'];
      }

      // If no specific type, try to infer from available types
      if (selectedType == null) {
        if (inputTypes.containsKey('email') && value.contains('@')) {
          selectedType = 'email';
        } else if (inputTypes.containsKey('tel') && RegExp(r'^[0-9+\-\s()]+$').hasMatch(value)) {
          selectedType = 'tel';
        } else if (inputTypes.containsKey('password')) {
          selectedType = 'password';
        } else if (inputTypes.containsKey('text')) {
          selectedType = 'text';
        }
      }

      // If still no type selected, use the first available type
      selectedType ??= inputTypes.keys.first;

      // Validate using the selected type
      if (inputTypes.containsKey(selectedType)) {
        final typeConfig = inputTypes[selectedType];
        final validation = typeConfig['validation'] as Map<String, dynamic>?;

        if (validation != null) {
          final minLength = validation['min_length'] ?? 0;
          final maxLength = validation['max_length'] ?? 9999;
          final regexStr = validation['regex'] ?? '';
          final errorMsg = validation['error_message'] ?? 'Invalid input';

          // Check length
          if (value.length < minLength || value.length > maxLength) {
            return errorMsg;
          }

          // Check regex pattern
          if (regexStr.isNotEmpty) {
            try {
              final regex = RegExp(regexStr);
              if (!regex.hasMatch(value)) {
                return errorMsg;
              }
            } catch (e) {
              // If regex is invalid, skip regex validation
              debugPrint('Invalid regex pattern: $regexStr');
            }
          }
        }
      }
    }

    return null;
  }

  Widget _buildDefaultFormType() {
    final component = widget.component;
    final layout = component.config['layout']?.toString().toLowerCase() ?? 'column';
    final childrenWidgets =
        component.children
            ?.map(
              (child) => Padding(
                padding: StyleUtils.parsePadding(child.style['margin']),
                child: DynamicFormRenderer(component: child),
              ),
            )
            .toList() ??
        [];

    return Container(
      key: Key(component.id),
      padding: StyleUtils.parsePadding(component.style['padding']),
      margin: StyleUtils.parsePadding(component.style['margin']),
      decoration: StyleUtils.buildBoxDecoration(component.style),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (component.config['label'] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 4,
                    height: 28,
                    color: const Color(0xFF6979F8),
                    margin: const EdgeInsets.only(right: 8),
                  ),
                  Text(
                    component.config['label'],
                    style: const TextStyle(
                      color: Color(0xFF6979F8),
                      fontSize: 24,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          if (component.children != null && childrenWidgets.isNotEmpty)
            layout == 'row'
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: childrenWidgets,
                    ),
                  )
                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: childrenWidgets),
        ],
      ),
    );
  }

  Widget _buildSelect(DynamicFormModel component) {
    final style = Map<String, dynamic>.from(component.style);
    final options = component.config['options'] as List<dynamic>? ?? [];
    final isMultiple = component.config['multiple'] ?? false;
    final searchable = component.config['searchable'] ?? false;

    // Apply variant styles
    if (component.variants != null) {
      if (component.config['label'] != null && component.variants!.containsKey('withLabel')) {
        final variantStyle = component.variants!['withLabel']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (component.config['icon'] != null && component.variants!.containsKey('withIcon')) {
        final variantStyle = component.variants!['withIcon']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (isMultiple && component.variants!.containsKey('multiple')) {
        final variantStyle = component.variants!['multiple']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (searchable && component.variants!.containsKey('searchable')) {
        final variantStyle = component.variants!['searchable']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
    }

    // Determine current state
    String currentState = 'base';
    final List<String> currentValues = isMultiple
        ? _selectedValues
        : (_selectedValue != null ? [_selectedValue!] : []);

    final validationError = _validateSelect(component, currentValues);

    if (_isTouched && validationError != null) {
      currentState = 'error';
    } else if (currentValues.isNotEmpty && validationError == null) {
      currentState = 'success';
    } else {
      currentState = 'base';
    }

    // Apply state styles
    if (component.states != null && component.states!.containsKey(currentState)) {
      final stateStyle = component.states![currentState]['style'] as Map<String, dynamic>?;
      if (stateStyle != null) style.addAll(stateStyle);
    }

    // Icon rendering
    Widget? prefixIcon;
    if ((component.config['icon'] != null || style['icon'] != null) &&
        style['iconPosition'] != 'right') {
      final iconName = (style['icon'] ?? component.config['icon'] ?? '').toString();
      final iconColor = StyleUtils.parseColor(style['iconColor']);
      final iconSize = (style['iconSize'] is num) ? (style['iconSize'] as num).toDouble() : 20.0;
      final iconData = mapIconNameToIconData(iconName);
      if (iconData != null) {
        prefixIcon = Icon(iconData, color: iconColor, size: iconSize);
      }
    }

    Widget? suffixIcon;
    if ((component.config['icon'] != null || style['icon'] != null) &&
        style['iconPosition'] == 'right') {
      final iconName = (style['icon'] ?? component.config['icon'] ?? '').toString();
      final iconColor = StyleUtils.parseColor(style['iconColor']);
      final iconSize = (style['iconSize'] is num) ? (style['iconSize'] as num).toDouble() : 20.0;
      final iconData = mapIconNameToIconData(iconName);
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
      fontStyle: style['fontStyle'] == 'italic' ? FontStyle.italic : FontStyle.normal,
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
              CircleAvatar(backgroundImage: NetworkImage(avatarUrl), radius: 16),
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

    final hasLabel = component.config['label'] != null && component.config['label'].isNotEmpty;

    return Container(
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
              if (isMultiple || searchable) {
                _showMultiSelectDialog(context, component, options, isMultiple, searchable);
              } else {
                _toggleDropdown();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: StyleUtils.parseColor(style['borderColor'])),
                borderRadius: StyleUtils.parseBorderRadius(style['borderRadius']),
                color: StyleUtils.parseColor(style['backgroundColor']),
              ),
              child: Row(
                children: [
                  if (prefixIcon != null) ...[prefixIcon, const SizedBox(width: 8)],
                  Expanded(child: displayContent),
                  if (suffixIcon != null) ...[const SizedBox(width: 8), suffixIcon],
                  Icon(
                    _isDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: StyleUtils.parseColor(style['color']),
                  ),
                ],
              ),
            ),
          ),
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 12),
              child: Text(_errorText!, style: const TextStyle(color: Colors.red, fontSize: 12)),
            ),
          if (helperText != null && _errorText == null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 12),
              child: Text(
                helperText,
                style: TextStyle(
                  color: helperTextColor,
                  fontSize: 12,
                  fontStyle: style['fontStyle'] == 'italic' ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
        ],
      ),
    );
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
    final RenderBox renderBox = _selectKey.currentContext!.findRenderObject() as RenderBox;
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
              borderRadius: StyleUtils.parseBorderRadius(component.style['borderRadius']),
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

    Widget listView = ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: height == null || height == 'auto',
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final value = option['value']?.toString() ?? '';
        final label = option['label']?.toString() ?? '';
        final avatarUrl = option['avatar']?.toString();

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
            });
            _closeDropdown();
          },
        );
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

    // For multi-select, use temporary values that are committed on confirmation
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
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                            hintText: style['searchPlaceholder'] ?? 'Tìm kiếm...',
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
                            bool isSelected = tempSelectedValues.contains(value);
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
                                  _errorText = _validateSelect(component, [_selectedValue ?? '']);
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
                          style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
                if (isMultiple)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isTouched = true;
                        _selectedValues = tempSelectedValues;
                        _errorText = _validateSelect(component, _selectedValues);
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

  String? _validateSelect(DynamicFormModel component, List<String> values) {
    final validationConfig = component.validation;
    if (validationConfig == null) return null;

    // Check required field
    final requiredValidation = validationConfig['required'] as Map<String, dynamic>?;
    if (requiredValidation?['isRequired'] == true && values.isEmpty) {
      return requiredValidation?['error_message'] as String? ?? 'Trường này là bắt buộc';
    }

    // If empty and not required, no validation needed
    if (values.isEmpty) {
      return null;
    }

    // Check max selections for multiple select
    if (component.config['multiple'] == true) {
      final maxSelectionsValidation = validationConfig['maxSelections'] as Map<String, dynamic>?;
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

  String? _validateDatePicker(DynamicFormModel component, DateTimeRange? range) {
    final validationConfig = component.validation;
    if (validationConfig == null) return null;

    final requiredValidation = validationConfig['required'] as Map<String, dynamic>?;
    if (requiredValidation?['isRequired'] == true && range == null) {
      return requiredValidation?['error_message'] as String? ?? 'Trường này là bắt buộc';
    }
    return null;
  }

  Widget _buildDropdown(DynamicFormModel component) {
    final style = Map<String, dynamic>.from(component.style);
    final config = component.config;
    final triggerAvatar = config['avatar'] as String?;
    final triggerIcon = config['icon'] as String?;
    final isSearchable = config['searchable'] as bool? ?? false;
    final placeholder = config['placeholder'] as String? ?? 'Search';

    // Apply variant styles
    if (component.variants != null) {
      if (triggerAvatar != null && component.variants!.containsKey('withAvatar')) {
        final variantStyle = component.variants!['withAvatar']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (triggerIcon != null &&
          _currentDropdownLabel == null &&
          component.variants!.containsKey('iconOnly')) {
        final variantStyle = component.variants!['iconOnly']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (triggerIcon != null &&
          _currentDropdownLabel != null &&
          component.variants!.containsKey('withIcon')) {
        final variantStyle = component.variants!['withIcon']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
    }

    // Determine current state
    final validationError = _validateDropdown(component, _selectedActionId);
    if (_isTouched) {
      _dropdownErrorText = validationError;
    }

    String currentState = 'base';
    if (_isTouched && _dropdownErrorText != null) {
      currentState = 'error';
    } else if (_selectedActionId != null && component.states!.containsKey('success')) {
      currentState = 'success';
    } else if (_isHovering) {
      currentState = 'hover';
    }

    // Apply state styles
    if (component.states != null && component.states!.containsKey(currentState)) {
      final stateStyle = component.states![currentState]['style'] as Map<String, dynamic>?;
      if (stateStyle != null) style.addAll(stateStyle);
    }

    final String? helperText = _dropdownErrorText ?? style['helperText'] as String?;
    final helperTextColor = StyleUtils.parseColor(style['helperTextColor']);

    // This key will be used to position the dropdown overlay.
    final GlobalKey dropdownKey = GlobalKey();

    Widget triggerContent;
    if (isSearchable) {
      triggerContent = Row(
        children: [
          Expanded(
            child: Text(
              placeholder,
              style: TextStyle(color: StyleUtils.parseColor(style['color'])),
            ),
          ),
          Icon(Icons.search, color: StyleUtils.parseColor(style['iconColor'])),
        ],
      );
    } else if (triggerIcon != null && _currentDropdownLabel == null) {
      // Icon-only trigger
      triggerContent = Icon(
        mapIconNameToIconData(triggerIcon),
        color: StyleUtils.parseColor(style['iconColor']),
        size: (style['iconSize'] as num?)?.toDouble() ?? 24.0,
      );
    } else {
      triggerContent = Row(
        children: [
          if (triggerIcon != null) ...[
            Icon(
              mapIconNameToIconData(triggerIcon),
              color: StyleUtils.parseColor(style['iconColor']),
              size: (style['iconSize'] as num?)?.toDouble() ?? 18.0,
            ),
            const SizedBox(width: 8),
          ],
          if (triggerAvatar != null) ...[
            CircleAvatar(backgroundImage: NetworkImage(triggerAvatar), radius: 16),
            const SizedBox(width: 8),
          ],
          if (_currentDropdownLabel != null)
            Expanded(
              child: Text(
                _currentDropdownLabel!,
                style: TextStyle(color: StyleUtils.parseColor(style['color'])),
              ),
            ),
          const Icon(Icons.keyboard_arrow_down),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: InkWell(
            key: dropdownKey,
            onTap: () {
              // Find the render box and position of the trigger widget.
              final renderBox = dropdownKey.currentContext!.findRenderObject() as RenderBox;
              final size = renderBox.size;
              final offset = renderBox.localToGlobal(Offset.zero);

              // Show the dropdown panel as an overlay.
              showDropdownPanel(
                context,
                component,
                Rect.fromLTWH(offset.dx, offset.dy + size.height, size.width, 0),
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
                borderRadius: StyleUtils.parseBorderRadius(style['borderRadius']),
              ),
              child: triggerContent,
            ),
          ),
        ),
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 16),
            child: Text(helperText, style: TextStyle(color: helperTextColor, fontSize: 12)),
          ),
      ],
    );
  }

  void showDropdownPanel(BuildContext context, DynamicFormModel component, Rect rect) {
    final items = component.config['items'] as List<dynamic>? ?? [];
    final style = component.style;
    final isSearchable = component.config['searchable'] as bool? ?? false;
    final dropdownWidth = (style['dropdownWidth'] as num?)?.toDouble() ?? rect.width;

    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        List<dynamic> filteredItems = List.from(items);
        String searchQuery = '';
        final searchController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setPanelState) {
            return Stack(
              children: [
                // Full screen GestureDetector to dismiss the dropdown.
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => overlayEntry?.remove(),
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
                    color: StyleUtils.parseColor(style['dropdownBackgroundColor']),
                    borderRadius: StyleUtils.parseBorderRadius(style['borderRadius']),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shrinkWrap: true,
                      itemCount: filteredItems.length + (isSearchable ? 1 : 0),
                      separatorBuilder: (context, index) {
                        // This logic handles separators for both searchable and non-searchable lists.
                        final itemIndex = isSearchable ? index - 1 : index;
                        if (itemIndex < 0 || itemIndex >= filteredItems.length) {
                          return const SizedBox.shrink();
                        }
                        final item = filteredItems[itemIndex];
                        final nextItem = (itemIndex + 1 < filteredItems.length)
                            ? filteredItems[itemIndex + 1]
                            : null;
                        if (item['type'] == 'divider' || nextItem?['type'] == 'divider') {
                          return const SizedBox.shrink();
                        }
                        return const Divider(color: Colors.transparent, height: 1);
                      },
                      itemBuilder: (context, index) {
                        if (isSearchable && index == 0) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: component.config['placeholder'],
                                isDense: true,
                                suffixIcon: const Icon(Icons.search),
                              ),
                              onChanged: (value) {
                                setPanelState(() {
                                  searchQuery = value.toLowerCase();
                                  filteredItems = items.where((item) {
                                    final label = item['label']?.toString().toLowerCase() ?? '';
                                    if (item['type'] == 'divider') return true;
                                    return label.contains(searchQuery);
                                  }).toList();
                                });
                              },
                            ),
                          );
                        }

                        final item = filteredItems[isSearchable ? index - 1 : index];
                        final itemType = item['type'] as String? ?? 'item';

                        if (itemType == 'divider') {
                          return Divider(
                            color: StyleUtils.parseColor(style['dividerColor']),
                            height: 1,
                          );
                        }

                        final label = item['label'] as String? ?? '';
                        final iconName = item['icon'] as String?;
                        final avatarUrl = item['avatar'] as String?;
                        final itemStyle = item['style'] as Map<String, dynamic>? ?? {};

                        return InkWell(
                          onTap: () {
                            // Log the tapped action
                            debugPrint(
                              "Dropdown Action Tapped: ID='${item['id']}', Label='${item['label']}'",
                            );

                            setState(() {
                              _isTouched = true;
                              _selectedActionId = item['id'];
                              _dropdownErrorText = _validateDropdown(component, _selectedActionId);

                              // Update trigger label unless it's a special display type
                              final bool isIconOnly =
                                  component.config['icon'] != null &&
                                  component.config['label'] == null;
                              final bool hasAvatar = component.config['avatar'] != null;
                              final items = component.config['items'] as List<dynamic>? ?? [];
                              final selectedItem = items.firstWhere(
                                (i) => i['id'] == _selectedActionId,
                                orElse: () => null,
                              );

                              if (!isIconOnly && !hasAvatar && selectedItem != null) {
                                _currentDropdownLabel = selectedItem['label'];
                              }
                            });
                            overlayEntry?.remove();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
              ],
            );
          },
        );
      },
    );
    Overlay.of(context).insert(overlayEntry);
  }

  String? _validateDropdown(DynamicFormModel component, String? selectedId) {
    final validationConfig = component.validation;
    if (validationConfig == null) return null;

    final requiredValidation = validationConfig['required'] as Map<String, dynamic>?;
    if (requiredValidation?['isRequired'] == true && (selectedId == null || selectedId.isEmpty)) {
      return requiredValidation?['error_message'] as String? ?? 'This field is required.';
    }

    return null;
  }

  Widget _buildCheckboxGroup(DynamicFormModel component) {
    final layout = component.config['layout']?.toString().toLowerCase() ?? 'row';
    final groupStyle = Map<String, dynamic>.from(component.style);
    final children = component.children ?? [];

    final widgets = children.map((item) {
      final style = {...groupStyle, ...item.style};
      final isSelected = item.config['value'] == true;
      final isEditable = item.config['editable'] != false;
      final label = item.config['label'] as String?;
      final hint = item.config['hint'] as String?;
      final iconName = item.config['icon'] as String?;

      Color bgColor = StyleUtils.parseColor(style['backgroundColor']);
      Color borderColor = StyleUtils.parseColor(style['borderColor']);
      double borderRadius = (style['borderRadius'] as num?)?.toDouble() ?? 8;
      Color iconColor = StyleUtils.parseColor(style['iconColor']);
      double width = (style['width'] as num?)?.toDouble() ?? 40;
      double height = (style['height'] as num?)?.toDouble() ?? 40;
      EdgeInsetsGeometry margin = StyleUtils.parsePadding(style['margin']);

      // Increase border width if selected to give visual feedback
      if (isSelected) {
        borderColor = StyleUtils.parseColor(style['selectedBorderColor']);
      }

      // Disabled style
      if (!isEditable) {
        bgColor = StyleUtils.parseColor('#e0e0e0');
        borderColor = StyleUtils.parseColor('#e0e0e0');
        iconColor = StyleUtils.parseColor('#bdbdbd');
      }

      Widget? iconWidget;
      if (iconName != null) {
        final iconData = mapIconNameToIconData(iconName);
        if (iconData != null) {
          iconWidget = Icon(iconData, color: iconColor, size: width * 0.6);
        }
      }

      return InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: isEditable
            ? () {
                setState(() {
                  item.config['value'] = !isSelected;
                });
              }
            : null,
        child: Container(
          margin: margin,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border.all(color: borderColor, width: 2), // Luôn luôn có border
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (iconWidget != null) iconWidget, // Custom icon always visible
                    if (isSelected)
                      Icon(
                        // Overlay checkmark
                        Icons.check,
                        color: iconColor,
                        size: width * 0.6,
                      ),
                  ],
                ),
              ),
              if (label != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isEditable ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (hint != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    hint,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();

    return Container(
      margin: StyleUtils.parsePadding(groupStyle['margin']),
      padding: StyleUtils.parsePadding(groupStyle['padding']),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (component.config['label'] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 28,
                    color: const Color(0xFF6979F8),
                    margin: const EdgeInsets.only(right: 8),
                  ),
                  Text(
                    component.config['label'],
                    style: const TextStyle(
                      color: Color(0xFF6979F8),
                      fontSize: 24,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          if (component.config['hint'] != null)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                component.config['hint'],
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          layout == 'row'
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: widgets),
                )
              : Column(children: widgets),
        ],
      ),
    );
  }

  Widget _buildRadioGroup(DynamicFormModel component) {
    final layout = component.config['layout']?.toString().toLowerCase() ?? 'row';
    final groupStyle = Map<String, dynamic>.from(component.style);
    final children = component.children ?? [];
    // Tìm group name
    final groupName = component.config['group'] as String? ?? component.id;

    final widgets = children.map((item) {
      final style = {...groupStyle, ...item.style};
      final isSelected = item.config['value'] == true;
      final isEditable = item.config['editable'] != false;
      final label = item.config['label'] as String?;
      final hint = item.config['hint'] as String?;
      final iconName = item.config['icon'] as String?;
      final itemGroup = item.config['group'] as String? ?? groupName;

      Color bgColor = StyleUtils.parseColor(style['backgroundColor']);
      Color borderColor = StyleUtils.parseColor(style['borderColor']);
      double borderRadius = (style['borderRadius'] as num?)?.toDouble() ?? 20;
      double borderWidth = (style['borderWidth'] as num?)?.toDouble() ?? 2;
      Color iconColor = StyleUtils.parseColor(style['iconColor']);
      double width = (style['width'] as num?)?.toDouble() ?? 40;
      double height = (style['height'] as num?)?.toDouble() ?? 40;
      EdgeInsetsGeometry margin = StyleUtils.parsePadding(style['margin']);

      // Increase border width if selected to give visual feedback
      if (isSelected) {
        borderWidth += 2;
      }

      // Disabled style
      if (!isEditable) {
        bgColor = StyleUtils.parseColor('#e0e0e0');
        borderColor = StyleUtils.parseColor('#e0e0e0');
        iconColor = StyleUtils.parseColor('#bdbdbd');
      }

      Widget? iconWidget;
      if (iconName != null) {
        final iconData = mapIconNameToIconData(iconName);
        if (iconData != null) {
          iconWidget = Icon(iconData, color: iconColor, size: width * 0.6);
        }
      }

      return InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: isEditable
            ? () {
                setState(() {
                  // Unselect all in group
                  for (final other in children) {
                    final otherGroup = other.config['group'] as String? ?? groupName;
                    if (otherGroup == itemGroup) {
                      other.config['value'] = other.id == item.id;
                    }
                  }
                });
              }
            : null,
        child: Container(
          margin: margin,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border.all(color: borderColor, width: borderWidth),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child:
                      iconWidget ??
                      (isSelected
                          ? Container(
                              width: width * 0.5,
                              height: height * 0.5,
                              decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
                            )
                          : null),
                ),
              ),
              if (label != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isEditable ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (hint != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    hint,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();

    return Container(
      margin: StyleUtils.parsePadding(groupStyle['margin']),
      padding: StyleUtils.parsePadding(groupStyle['padding']),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (component.config['label'] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 28,
                    color: const Color(0xFF6979F8),
                    margin: const EdgeInsets.only(right: 8),
                  ),
                  Text(
                    component.config['label'],
                    style: const TextStyle(
                      color: Color(0xFF6979F8),
                      fontSize: 24,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          if (component.config['hint'] != null)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                component.config['hint'],
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          layout == 'row'
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: widgets),
                )
              : Column(children: widgets),
        ],
      ),
    );
  }

  Widget _buildToggleableRow(DynamicFormModel component, {required bool isRadio}) {
    // 1. Resolve styles from component's style and states
    Map<String, dynamic> style = Map<String, dynamic>.from(component.style);
    final bool isSelected = component.config['value'] == true;
    final bool isEditable = component.config['editable'] != false;

    // Apply state-specific styles
    String currentState = isSelected ? 'selected' : 'base';
    if (!isEditable) {
      // For disabled items, we don't use states, we just use the styles defined directly on the component.
      // This is based on the new JSON structure.
    } else if (component.states != null && component.states!.containsKey(currentState)) {
      final stateStyle = component.states![currentState]['style'] as Map<String, dynamic>?;
      if (stateStyle != null) {
        style.addAll(stateStyle);
      }
    }

    // 2. Extract configuration
    final String? label = component.config['label'];
    final String? hint = component.config['hint'];
    final String? iconName = component.config['icon'];
    final IconData? leadingIconData = iconName != null ? mapIconNameToIconData(iconName) : null;
    final String? group = component.config['group'];

    // 3. Define visual properties based on style
    final Color backgroundColor = StyleUtils.parseColor(style['backgroundColor']);
    final Color borderColor = StyleUtils.parseColor(style['borderColor']);
    final double borderWidth = (style['borderWidth'] as num?)?.toDouble() ?? 1.0;
    final Color iconColor = StyleUtils.parseColor(style['iconColor']);
    final double controlWidth = (style['width'] as num?)?.toDouble() ?? 28;
    final double controlHeight = (style['height'] as num?)?.toDouble() ?? 28;

    final controlBorderRadius = isRadio
        ? controlWidth / 2
        : (StyleUtils.parseBorderRadius(
            style['borderRadius'],
          ).resolve(TextDirection.ltr).topLeft.x);

    // 4. Build the toggle control (the checkbox or radio button itself)
    Widget toggleControl = Container(
      width: controlWidth,
      height: controlHeight,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: BorderRadius.circular(controlBorderRadius),
      ),
      child: isSelected
          ? (isRadio
                ? Center(
                    child: Container(
                      width: controlWidth * 0.5,
                      height: controlHeight * 0.5,
                      decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
                    ),
                  )
                : Icon(Icons.check, color: iconColor, size: controlWidth * 0.75))
          : null,
    );

    // 5. Build the label and hint text column
    Widget? labelAndHint;
    if (label != null) {
      labelAndHint = Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: style['labelTextSize']?.toDouble() ?? 16,
                color: StyleUtils.parseColor(style['labelColor']),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (hint != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  hint,
                  style: TextStyle(
                    fontSize: 12,
                    color: StyleUtils.parseColor(style['hintColor']),
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      );
    }

    // 6. Handle tap gestures
    void handleTap() {
      if (!isEditable) return;

      if (isRadio) {
        if (group != null) {
          final parent = context.findAncestorWidgetOfExactType<DynamicFormRenderer>()?.component;
          if (parent != null && parent.children != null) {
            setState(() {
              for (final sibling in parent.children!) {
                if (sibling.type == FormTypeEnum.radioFormType && (sibling.config['group'] == group)) {
                  sibling.config['value'] = sibling.id == component.id;
                }
              }
            });
          }
        } else {
          // No group: allow only one selected among siblings of type radioFormType
          final parent = context.findAncestorWidgetOfExactType<DynamicFormRenderer>()?.component;
          if (parent != null && parent.children != null) {
            setState(() {
              for (final sibling in parent.children!) {
                if (sibling.type == FormTypeEnum.radioFormType) {
                  sibling.config['value'] = sibling.id == component.id;
                }
              }
            });
          } else {
            // If no parent, just toggle this radio
            setState(() {
              component.config['value'] = true;
            });
          }
        }
      } else {
        // Checkbox logic
        setState(() {
          component.config['value'] = !isSelected;
        });
      }
    }

    // 7. Assemble the final widget
    return GestureDetector(
      onTap: handleTap,
      child: Container(
        margin: StyleUtils.parsePadding(style['margin']),
        padding: StyleUtils.parsePadding(style['padding']),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            toggleControl,
            const SizedBox(width: 12),
            if (leadingIconData != null) ...[
              Icon(leadingIconData, size: 20, color: StyleUtils.parseColor(style['iconColor'])),
              const SizedBox(width: 8),
            ],
            if (labelAndHint != null) labelAndHint,
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(DynamicFormModel component) {
    final style = Map<String, dynamic>.from(component.style);
    final config = component.config;
    final bool isRange = config['range'] == true;
    final double min = (config['min'] as num?)?.toDouble() ?? 0;
    final double max = (config['max'] as num?)?.toDouble() ?? 100;
    final int? divisions = (config['divisions'] as num?)?.toInt();
    final String prefix = config['prefix']?.toString() ?? '';
    final String? hint = config['hint'] as String?;
    final String? iconName = config['icon'] as String?;
    final String? thumbIconName = config['thumbIcon'] as String?;

    if (component.variants != null) {
      if (hint != null && component.variants!.containsKey('withHint')) {
        final variantStyle = component.variants!['withHint']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (iconName != null && component.variants!.containsKey('withIcon')) {
        final variantStyle = component.variants!['withIcon']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (thumbIconName != null && component.variants!.containsKey('withThumbIcon')) {
        final variantStyle = component.variants!['withThumbIcon']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
    }

    final IconData? thumbIcon = thumbIconName != null ? mapIconNameToIconData(thumbIconName) : null;

    final sliderTheme = SliderTheme.of(context).copyWith(
      activeTrackColor: StyleUtils.parseColor(style['activeColor']),
      inactiveTrackColor: StyleUtils.parseColor(style['inactiveColor']),
      thumbColor: StyleUtils.parseColor(style['thumbColor']),
      overlayColor: StyleUtils.parseColor(style['activeColor']).withValues(alpha:0.2),
      trackHeight: 6.0,
    );

    final currentRangeValues = _sliderRangeValues ?? RangeValues(min, max);

    final sliderWidget = SliderTheme(
      data: sliderTheme.copyWith(
        rangeThumbShape: _CustomRangeSliderThumbShape(
          thumbRadius: 14,
          valuePrefix: prefix,
          values: currentRangeValues,
          iconColor: StyleUtils.parseColor(style['thumbIconColor']),
          labelColor: StyleUtils.parseColor(style['valueLabelColor']),
          thumbIcon: thumbIcon,
        ),
        thumbShape: _CustomSliderThumbShape(
          thumbRadius: 14,
          valuePrefix: prefix,
          displayValue: _sliderValue ?? min,
          iconColor: StyleUtils.parseColor(style['thumbIconColor']),
          labelColor: StyleUtils.parseColor(style['valueLabelColor']),
          thumbIcon: thumbIcon,
        ),
      ),
      child: isRange
          ? RangeSlider(
              values: currentRangeValues,
              min: min,
              max: max,
              divisions: divisions,
              labels: RangeLabels(
                '$prefix${currentRangeValues.start.round()}',
                '$prefix${currentRangeValues.end.round()}',
              ),
              onChanged: (values) {
                setState(() {
                  _sliderRangeValues = values;
                });
              },
            )
          : Slider(
              value: _sliderValue ?? min,
              min: min,
              max: max,
              divisions: divisions,
              label: '$prefix${_sliderValue?.round()}',
              onChanged: (value) {
                setState(() {
                  _sliderValue = value;
                });
              },
            ),
    );

    Widget? iconWidget;
    if (iconName != null) {
      final iconData = mapIconNameToIconData(iconName);
      if (iconData != null) {
        iconWidget = Icon(
          iconData,
          color: StyleUtils.parseColor(style['iconColor']),
          size: (style['iconSize'] as num?)?.toDouble() ?? 24.0,
        );
      }
    }

    return Container(
      margin: StyleUtils.parsePadding(style['margin']),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (iconWidget != null) ...[iconWidget, const SizedBox(width: 8)],
              Expanded(child: sliderWidget),
            ],
          ),
          if (hint != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 4.0),
              child: Text(
                hint,
                style: TextStyle(color: StyleUtils.parseColor(style['hintColor']), fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _CustomSliderThumbShape extends SliderComponentShape {
  final double thumbRadius;
  final String valuePrefix;
  final double displayValue;
  final Color? iconColor;
  final Color? labelColor;
  final IconData? thumbIcon;

  _CustomSliderThumbShape({
    this.thumbRadius = 14.0,
    this.valuePrefix = '',
    required this.displayValue,
    this.iconColor,
    this.labelColor,
    this.thumbIcon,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final paint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, thumbRadius, paint);

    final icon = thumbIcon ?? Icons.check;
    final iconPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: thumbRadius * 1.2,
          fontFamily: icon.fontFamily,
          color: iconColor ?? sliderTheme.activeTrackColor,
        ),
      ),
    );
    iconPainter.layout();
    iconPainter.paint(canvas, center - Offset(iconPainter.width / 2, iconPainter.height / 2));

    final valueLabelPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      text: TextSpan(
        text: '$valuePrefix${displayValue.round()}',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: labelColor ?? Colors.white,
        ),
      ),
    );
    valueLabelPainter.layout();
    valueLabelPainter.paint(canvas, center + Offset(-valueLabelPainter.width / 2, thumbRadius + 4));
  }
}

class _CustomRangeSliderThumbShape extends RangeSliderThumbShape {
  final double thumbRadius;
  final String valuePrefix;
  final RangeValues values;
  final Color? iconColor;
  final Color? labelColor;
  final IconData? thumbIcon;

  _CustomRangeSliderThumbShape({
    this.thumbRadius = 14.0,
    this.valuePrefix = '',
    required this.values,
    this.iconColor,
    this.labelColor,
    this.thumbIcon,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool isPressed = false,
    bool isOnTop = false,
    required SliderThemeData sliderTheme,
    TextDirection? textDirection,
    Thumb? thumb,
  }) {
    if (thumb == null) {
      return;
    }
    final Canvas canvas = context.canvas;

    final paint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, thumbRadius, paint);

    final icon = thumbIcon ?? Icons.check;
    final iconPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: thumbRadius * 1.2,
          fontFamily: icon.fontFamily,
          color: iconColor ?? sliderTheme.activeTrackColor,
        ),
      ),
    );
    iconPainter.layout();
    iconPainter.paint(canvas, center - Offset(iconPainter.width / 2, iconPainter.height / 2));

    final double value = thumb == Thumb.start ? values.start : values.end;
    final valueLabelPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      text: TextSpan(
        text: '$valuePrefix${value.round()}',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: labelColor ?? Colors.white,
        ),
      ),
    );
    valueLabelPainter.layout();
    valueLabelPainter.paint(canvas, center + Offset(-valueLabelPainter.width / 2, thumbRadius + 4));
  }
}

class _FileUploaderWidget extends StatefulWidget {
  final DynamicFormModel component;

  const _FileUploaderWidget({required this.component});

  @override
  __FileUploaderWidgetState createState() => __FileUploaderWidgetState();
}

class __FileUploaderWidgetState extends State<_FileUploaderWidget> {
  String _currentState = 'base'; // base, dragging, loading, success, error
  bool _isDragging = false;
  double _progress = 0.0;
  List<XFile> _pickedFiles = [];
  Timer? _timer;
  bool _isMultipleFiles = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _isMultipleFiles = widget.component.config['multipleFiles'] == true;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startUpload(List<XFile> files) {
    if (_isProcessing) return; // Prevent multiple simultaneous uploads

    _pickedFiles = files;
    _isProcessing = true;

    setState(() {
      _currentState = 'loading';
      _progress = 0;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _progress += 2; // Slower progress for better stability
        if (_progress >= 100) {
          timer.cancel();
          _isProcessing = false;
          // Simulate a random success/error outcome
          if (DateTime.now().second % 2 == 0) {
            _currentState = 'success';
          } else {
            _currentState = 'error';
          }
        }
      });
    });
  }

  void _handleFiles(List<XFile> files) {
    if (files.isEmpty || _isProcessing) return;

    final allowedExtensions =
        (widget.component.config['allowedExtensions'] as List<dynamic>?)?.cast<String>() ?? [];

    // Check if all files have allowed extensions
    if (allowedExtensions.isNotEmpty) {
      for (final file in files) {
        if (!allowedExtensions.any(
          (ext) => file.name.toLowerCase().endsWith('.${ext.toLowerCase()}'),
        )) {
          debugPrint("File type not allowed: ${file.name}. Allowed: $allowedExtensions");
          setState(() {
            _currentState = 'error';
            _isProcessing = false;
          });
          return;
        }
      }
    }

    _startUpload(files);
  }

  void _browseFiles() async {
    if (_isProcessing) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: (widget.component.config['allowedExtensions'] as List<dynamic>?)
            ?.cast<String>(),
        allowMultiple: _isMultipleFiles,
      );

      if (result != null && result.files.isNotEmpty && mounted) {
        final files = result.files.map((f) => XFile(f.path!)).toList();
        _handleFiles(files);
      }
    } catch (e) {
      debugPrint('Error picking files: $e');
      if (mounted) {
        setState(() {
          _currentState = 'error';
          _isProcessing = false;
        });
      }
    }
  }

  void _resetState() {
    if (!mounted) return;

    setState(() {
      _currentState = 'base';
      _pickedFiles.clear();
      _progress = 0;
      _isDragging = false;
      _isProcessing = false;
      _timer?.cancel();
    });
  }

  void _removeFile(int index) {
    if (!mounted || _isProcessing) return;

    setState(() {
      _pickedFiles.removeAt(index);
      if (_pickedFiles.isEmpty) {
        _currentState = 'base';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> baseStyle = Map.from(widget.component.style);
    final Map<String, dynamic> variantStyle = _isDragging
        ? Map.from(widget.component.variants?['dragging']?['style'] ?? {})
        : {};
    final Map<String, dynamic> stateStyle = Map.from(
      widget.component.states?[_currentState]?['style'] ?? {},
    );

    final style = {...baseStyle, ...variantStyle, ...stateStyle};

    final Map<String, dynamic> baseConfig = Map.from(widget.component.config);
    final Map<String, dynamic> variantConfig = _isDragging
        ? Map.from(widget.component.variants?['dragging']?['config'] ?? {})
        : {};
    final Map<String, dynamic> stateConfig = Map.from(
      widget.component.states?[_currentState]?['config'] ?? {},
    );
    final config = {...baseConfig, ...variantConfig, ...stateConfig};

    return DragTarget<List<XFile>>(
      onWillAcceptWithDetails: (data) {
        if (_isProcessing) return false;
        setState(() => _isDragging = true);
        return true;
      },
      onAccept: (data) {
        setState(() => _isDragging = false);
        _handleFiles(data);
      },
      onLeave: (data) {
        setState(() => _isDragging = false);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          margin: StyleUtils.parsePadding(style['margin']),
          child: DottedBorder(
            color: StyleUtils.parseColor(style['borderColor']),
            strokeWidth: (style['borderWidth'] as num?)?.toDouble() ?? 1,
            radius: Radius.circular((style['borderRadius'] as num?)?.toDouble() ?? 0),
            dashPattern: const [6, 6],
            borderType: BorderType.RRect,
            child: Container(
              width: (style['width'] as num?)?.toDouble() ?? 300,
              height: (style['height'] as num?)?.toDouble() ?? 200,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: StyleUtils.parseColor(style['backgroundColor']),
                borderRadius: BorderRadius.circular(
                  (style['borderRadius'] as num?)?.toDouble() ?? 0,
                ),
              ),
              child: _buildChild(style, config),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChild(Map<String, dynamic> style, Map<String, dynamic> config) {
    switch (_currentState) {
      case 'loading':
        return _buildLoadingState(style, config);
      case 'success':
        return _buildSuccessState(style, config);
      case 'error':
        return _buildErrorState(style, config);
      default: // base and dragging
        return _buildBaseState(style, config);
    }
  }

  Widget _buildBaseState(Map<String, dynamic> style, Map<String, dynamic> config) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (style['icon'] != null) ...[
          Icon(
            _mapIconNameToIconData(style['icon']),
            color: StyleUtils.parseColor(style['iconColor']),
            size: (style['iconSize'] as num?)?.toDouble() ?? 48,
          ),
          const SizedBox(height: 8),
        ],
        Text(
          config['title'] ?? '',
          textAlign: TextAlign.center,
          style: TextStyle(color: StyleUtils.parseColor(style['textColor'])),
        ),
        if (config['subtitle'] != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              config['subtitle'] ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(color: StyleUtils.parseColor(style['textColor'])),
            ),
          ),
        if (config['buttonText'] != null && config['buttonText'].isNotEmpty) ...[
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isProcessing ? null : _browseFiles,
            style: ElevatedButton.styleFrom(
              backgroundColor: StyleUtils.parseColor(style['buttonBackgroundColor']),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  (style['buttonBorderRadius'] as num?)?.toDouble() ?? 8,
                ),
              ),
            ),
            child: Text(
              config['buttonText'] ?? 'Browse',
              style: TextStyle(color: StyleUtils.parseColor(style['buttonTextColor'])),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingState(Map<String, dynamic> style, Map<String, dynamic> config) {
    String statusText = config['statusTextFormat'] ?? 'Uploading {fileName} {progress}/{total}%';

    if (_isMultipleFiles && _pickedFiles.length > 1) {
      statusText = statusText
          .replaceAll('{fileName}', '${_pickedFiles.length} files')
          .replaceAll('{progress}', _progress.toInt().toString())
          .replaceAll('{total}', '100');
    } else if (_pickedFiles.isNotEmpty) {
      statusText = statusText
          .replaceAll('{fileName}', _pickedFiles.first.name)
          .replaceAll('{progress}', _progress.toInt().toString())
          .replaceAll('{total}', '100');
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (style['icon'] != null)
          Icon(
            _mapIconNameToIconData(style['icon']),
            color: StyleUtils.parseColor(style['iconColor']),
            size: 48,
          ),
        const SizedBox(height: 16),
        Text(
          statusText,
          textAlign: TextAlign.center,
          style: TextStyle(color: StyleUtils.parseColor(style['textColor'])),
        ),
        if (config['subtitle'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              config['subtitle'],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: StyleUtils.parseColor(style['textColor']).withValues(alpha:0.7),
                fontSize: 12,
              ),
            ),
          ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: null, // Disabled
          style: ElevatedButton.styleFrom(
            backgroundColor: StyleUtils.parseColor(style['buttonBackgroundColor']).withValues(alpha:0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                (style['buttonBorderRadius'] as num?)?.toDouble() ?? 8,
              ),
            ),
          ),
          child: Text(
            config['buttonText'] ?? 'Loading',
            style: TextStyle(color: StyleUtils.parseColor(style['buttonTextColor'])),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState(Map<String, dynamic> style, Map<String, dynamic> config) {
    // Check for the 'withPreview' variant
    final bool hasPreview = widget.component.variants?.containsKey('withPreview') ?? false;

    // Check for the 'multipleFiles' variant
    final bool isMultipleVariant = widget.component.variants?.containsKey('multipleFiles') ?? false;

    if (isMultipleVariant && _pickedFiles.length > 1) {
      return _buildMultipleFilesSuccessState(style, config);
    }

    if (hasPreview && _pickedFiles.isNotEmpty && _isImageFile(_pickedFiles.first.path)) {
      // Build the preview state for single image
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  (style['borderRadius'] as num?)?.toDouble() ?? 8.0,
                ),
                child: Image.file(
                  File(_pickedFiles.first.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _resetState,
            style: ElevatedButton.styleFrom(
              backgroundColor: StyleUtils.parseColor(style['buttonBackgroundColor']),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  (style['buttonBorderRadius'] as num?)?.toDouble() ?? 8,
                ),
              ),
            ),
            child: Text(
              config['buttonText'] ?? 'Remove',
              style: TextStyle(color: StyleUtils.parseColor(style['buttonTextColor'])),
            ),
          ),
        ],
      );
    }

    String statusText = config['statusTextFormat'] ?? '{fileName} uploaded!';
    if (_isMultipleFiles && _pickedFiles.length > 1) {
      statusText = statusText.replaceAll('{fileName}', '${_pickedFiles.length} files');
    } else if (_pickedFiles.isNotEmpty) {
      statusText = statusText.replaceAll('{fileName}', _pickedFiles.first.name);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (style['icon'] != null)
          Icon(
            _mapIconNameToIconData(style['icon']),
            color: StyleUtils.parseColor(style['iconColor']),
            size: 48,
          ),
        const SizedBox(height: 16),
        Text(statusText, style: TextStyle(color: StyleUtils.parseColor(style['textColor']))),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _resetState,
          style: ElevatedButton.styleFrom(
            backgroundColor: StyleUtils.parseColor(style['buttonBackgroundColor']),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                (style['buttonBorderRadius'] as num?)?.toDouble() ?? 8,
              ),
            ),
          ),
          child: Text(
            config['buttonText'] ?? 'Remove',
            style: TextStyle(color: StyleUtils.parseColor(style['buttonTextColor'])),
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleFilesSuccessState(Map<String, dynamic> style, Map<String, dynamic> config) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _pickedFiles.length,
            itemBuilder: (context, index) {
              final file = _pickedFiles[index];
              final isImage = _isImageFile(file.path);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: StyleUtils.parseColor(style['fileItemBackgroundColor']),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    if (isImage) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Image.file(
                            File(file.path),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.broken_image,
                                color: StyleUtils.parseColor(style['iconColor']),
                                size: 40,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ] else ...[
                      Icon(
                        Icons.insert_drive_file,
                        color: StyleUtils.parseColor(style['iconColor']),
                        size: 40,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.name,
                            style: TextStyle(
                              color: StyleUtils.parseColor(style['textColor']),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          FutureBuilder<String>(
                            future: _getFileSize(file.path),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data ?? 'Calculating...',
                                style: TextStyle(
                                  color: StyleUtils.parseColor(style['textColor']).withValues(alpha:0.7),
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _isProcessing ? null : () => _removeFile(index),
                      icon: Icon(
                        Icons.close,
                        color: StyleUtils.parseColor(style['iconColor']),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _browseFiles,
                style: ElevatedButton.styleFrom(
                  backgroundColor: StyleUtils.parseColor(style['buttonBackgroundColor']),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      (style['buttonBorderRadius'] as num?)?.toDouble() ?? 8,
                    ),
                  ),
                ),
                child: Text(
                  config['addMoreButtonText'] ?? 'Add More',
                  style: TextStyle(color: StyleUtils.parseColor(style['buttonTextColor'])),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isProcessing ? null : _resetState,
              style: ElevatedButton.styleFrom(
                backgroundColor: StyleUtils.parseColor(style['removeAllButtonColor']),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    (style['buttonBorderRadius'] as num?)?.toDouble() ?? 8,
                  ),
                ),
              ),
              child: Text(
                config['removeAllButtonText'] ?? 'Remove All',
                style: TextStyle(color: StyleUtils.parseColor(style['buttonTextColor'])),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<String> _getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      final size = await file.length();
      if (size < 1024) {
        return '$size B';
      } else if (size < 1024 * 1024) {
        return '${(size / 1024).toStringAsFixed(1)} KB';
      } else {
        return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    } catch (e) {
      return 'Unknown size';
    }
  }

  Widget _buildErrorState(Map<String, dynamic> style, Map<String, dynamic> config) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (style['icon'] != null)
          Icon(
            _mapIconNameToIconData(style['icon']),
            color: StyleUtils.parseColor(style['iconColor']),
            size: 48,
          ),
        const SizedBox(height: 16),
        Text(
          config['statusText'] ?? 'Error',
          textAlign: TextAlign.center,
          style: TextStyle(color: StyleUtils.parseColor(style['textColor'])),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _resetState,
          style: ElevatedButton.styleFrom(
            backgroundColor: StyleUtils.parseColor(style['buttonBackgroundColor']),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                (style['buttonBorderRadius'] as num?)?.toDouble() ?? 8,
              ),
            ),
          ),
          child: Text(
            config['buttonText'] ?? 'Retry',
            style: TextStyle(color: StyleUtils.parseColor(style['buttonTextColor'])),
          ),
        ),
      ],
    );
  }

  IconData? _mapIconNameToIconData(String name) {
    switch (name) {
      case 'file':
        return Icons.insert_drive_file_outlined;
      case 'check':
        return Icons.check_circle_outline;
      case 'error':
        return Icons.error_outline;
      default:
        return mapIconNameToIconData(name);
    }
  }

  bool _isImageFile(String filePath) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
    final extension = filePath.split('.').last.toLowerCase();
    return imageExtensions.contains(extension);
  }
}
