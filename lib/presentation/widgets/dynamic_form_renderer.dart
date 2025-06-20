import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:flutter/material.dart';

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

  // Select input variables
  String? _selectedValue;
  List<String> _selectedValues = []; // For multiple selection
  bool _isDropdownOpen = false;
  bool _isTouched = false; // To track if the field has been interacted with

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
    _controller.text = widget.component.config['value'] ?? '';
    _currentDropdownLabel = widget.component.config['label'];
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
    switch (component.type.toLowerCase()) {
      case 'textfield':
        return _buildTextField(component);
      case 'select':
        return _buildSelect(component);
      case 'datepicker':
        return _buildDatePicker(component);
      case 'textarea':
        return _buildTextArea(component);
      case 'datetime_picker':
        return _buildDateTimePickerForm(component);
      case 'dropdown':
        return _buildDropdown(component);
      default:
        return _buildContainer();
    }
  }

  Widget _buildDateTimePickerForm(DynamicFormModel component) {
    final style = Map<String, dynamic>.from(component.style);
    final value =
        component.config['value'] ??
        DateTime.now()
            .toString(); // Lấy giá trị mặc định từ config hoặc ngày hiện tại
    String dateDisplay = value.contains('dd/mm/yyyy')
        ? 'dd/mm/yyyy'
        : value.split(' ')[0]; // Hiển thị định dạng hoặc giá trị hiện tại

    Future<void> selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
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
          dateDisplay = "${picked.day}/${picked.month}/${picked.year}";
          component.config['value'] = dateDisplay;
        });
      }
    }

    return Container(
      key: Key(component.id),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
          GestureDetector(
            onTap: () => selectDate(context),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: StyleUtils.parseColor(style['borderColor']),
                ),
                borderRadius: StyleUtils.parseBorderRadius(
                  style['borderRadius'],
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateDisplay,
                    style: TextStyle(
                      color: StyleUtils.parseColor(style['color']),
                      fontStyle: style['fontStyle'] == 'italic'
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF6979F8),
                  ), // Sử dụng màu theo giao diện mẫu
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextArea(DynamicFormModel component) {
    final style = Map<String, dynamic>.from(component.style);

    if (component.variants != null) {
      if (component.config['label'] != null &&
          component.variants!.containsKey('withLabel')) {
        final variantStyle =
            component.variants!['withLabel']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (component.config['value'] != null &&
          component.variants!.containsKey('withLabelValue')) {
        final variantStyle =
            component.variants!['withLabelValue']['style']
                as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (component.config['value'] != null &&
          component.variants!.containsKey('withValue')) {
        final variantStyle =
            component.variants!['withValue']['style'] as Map<String, dynamic>?;
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

    if (component.states != null &&
        component.states!.containsKey(currentState)) {
      final stateStyle =
          component.states![currentState]['style'] as Map<String, dynamic>?;
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
                obscureText:
                    component.inputTypes?.containsKey('password') ?? false,
                keyboardType: _getKeyboardType(component),
                maxLines: (style['maxLines'] is num)
                    ? (style['maxLines'] as num).toInt()
                    : 10,
                minLines: (style['minLines'] is num)
                    ? (style['minLines'] as num).toInt()
                    : 6,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: component.config['placeholder'] ?? '',
                  border: OutlineInputBorder(
                    borderRadius: StyleUtils.parseBorderRadius(
                      style['borderRadius'],
                    ),
                    borderSide: BorderSide(
                      color: StyleUtils.parseColor(style['borderColor']),
                      width: style['borderWidth']?.toDouble() ?? 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: StyleUtils.parseBorderRadius(
                      style['borderRadius'],
                    ),
                    borderSide: BorderSide(
                      color: StyleUtils.parseColor(style['borderColor']),
                      width: style['borderWidth']?.toDouble() ?? 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: StyleUtils.parseBorderRadius(
                      style['borderRadius'],
                    ),
                    borderSide: BorderSide(
                      color: StyleUtils.parseColor(style['borderColor']),
                      width: style['borderWidth']?.toDouble() ?? 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: StyleUtils.parseBorderRadius(
                      style['borderRadius'],
                    ),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  errorText: null,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                  filled: style['backgroundColor'] != null,
                  fillColor: StyleUtils.parseColor(style['backgroundColor']),
                  helperText:
                      _errorText, // Đảm bảo helperText hiển thị _errorText
                  helperStyle: TextStyle(
                    color: helperTextColor,
                    fontStyle: style['fontStyle'] == 'italic'
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
                style: TextStyle(
                  fontSize: style['fontSize']?.toDouble() ?? 16,
                  color: StyleUtils.parseColor(style['color']),
                  fontStyle: style['fontStyle'] == 'italic'
                      ? FontStyle.italic
                      : FontStyle.normal,
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
      if (component.config['label'] != null &&
          component.variants!.containsKey('withLabel')) {
        final variantStyle =
            component.variants!['withLabel']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (component.config['icon'] != null &&
          component.variants!.containsKey('withIcon')) {
        final variantStyle =
            component.variants!['withIcon']['style'] as Map<String, dynamic>?;
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
    if (component.states != null &&
        component.states!.containsKey(currentState)) {
      final stateStyle =
          component.states![currentState]['style'] as Map<String, dynamic>?;
      if (stateStyle != null) style.addAll(stateStyle);
    }

    // Icon rendering (dynamic)
    Widget? prefixIcon;
    if (component.config['icon'] != null || style['icon'] != null) {
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
                borderRadius: StyleUtils.parseBorderRadius(
                  style['borderRadius'],
                ),
                borderSide: BorderSide(
                  color: StyleUtils.parseColor(style['borderColor']),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: StyleUtils.parseBorderRadius(
                  style['borderRadius'],
                ),
                borderSide: BorderSide(
                  color: StyleUtils.parseColor(style['borderColor']),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: StyleUtils.parseBorderRadius(
                  style['borderRadius'],
                ),
                borderSide: BorderSide(
                  color: StyleUtils.parseColor(style['borderColor']),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: StyleUtils.parseBorderRadius(
                  style['borderRadius'],
                ),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              errorText: _errorText,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
              filled: style['backgroundColor'] != null,
              fillColor: StyleUtils.parseColor(style['backgroundColor']),
              helperText: helperText,
              helperStyle: TextStyle(
                color: helperTextColor,
                fontStyle: style['fontStyle'] == 'italic'
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
            style: TextStyle(
              fontSize: style['fontSize']?.toDouble() ?? 16,
              color: StyleUtils.parseColor(style['color']),
              fontStyle: style['fontStyle'] == 'italic'
                  ? FontStyle.italic
                  : FontStyle.normal,
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
        } else if (inputTypes.containsKey('tel') &&
            RegExp(r'^[0-9+\-\s()]+$').hasMatch(value)) {
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

  Widget _buildContainer() {
    final component = widget.component;
    return Container(
      key: Key(component.id),
      padding: StyleUtils.parsePadding(component.style['padding']),
      margin: StyleUtils.parsePadding(component.style['margin']),
      decoration: StyleUtils.buildBoxDecoration(component.style),
      child: component.children != null
          ? Column(
              children: component.children!
                  .map((child) => DynamicFormRenderer(component: child))
                  .toList(),
            )
          : null,
    );
  }

  Widget _buildSelect(DynamicFormModel component) {
    final style = Map<String, dynamic>.from(component.style);
    final options = component.config['options'] as List<dynamic>? ?? [];
    final isMultiple = component.config['multiple'] ?? false;
    final searchable = component.config['searchable'] ?? false;

    // Apply variant styles
    if (component.variants != null) {
      if (component.config['label'] != null &&
          component.variants!.containsKey('withLabel')) {
        final variantStyle =
            component.variants!['withLabel']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (component.config['icon'] != null &&
          component.variants!.containsKey('withIcon')) {
        final variantStyle =
            component.variants!['withIcon']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (isMultiple && component.variants!.containsKey('multiple')) {
        final variantStyle =
            component.variants!['multiple']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (searchable && component.variants!.containsKey('searchable')) {
        final variantStyle =
            component.variants!['searchable']['style'] as Map<String, dynamic>?;
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
    if (component.states != null &&
        component.states!.containsKey(currentState)) {
      final stateStyle =
          component.states![currentState]['style'] as Map<String, dynamic>?;
      if (stateStyle != null) style.addAll(stateStyle);
    }

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
          component.config['placeholder'] ?? 'Chọn một tùy chọn',
          style: textStyle,
        );
      }
    }

    final hasLabel =
        component.config['label'] != null &&
        component.config['label'].isNotEmpty;

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
                _showMultiSelectDialog(
                  context,
                  component,
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

  String? _validateDatePicker(
    DynamicFormModel component,
    DateTimeRange? range,
  ) {
    final validationConfig = component.validation;
    if (validationConfig == null) return null;

    final requiredValidation =
        validationConfig['required'] as Map<String, dynamic>?;
    if (requiredValidation?['isRequired'] == true && range == null) {
      return requiredValidation?['error_message'] as String? ??
          'Trường này là bắt buộc';
    }
    return null;
  }

  Widget _buildDatePicker(DynamicFormModel component) {
    final style = Map<String, dynamic>.from(component.style);
    final config = component.config;
    final hasLabel = config['label'] != null && config['label'].isNotEmpty;

    // Determine current state
    final validationError = _validateDatePicker(component, _selectedDateRange);
    String currentState = 'base';

    if (_isTouched && validationError != null) {
      currentState = 'error';
    } else if (_selectedDateRange != null && validationError == null) {
      currentState = 'success';
    }

    // Apply state styles
    if (component.states != null &&
        component.states!.containsKey(currentState)) {
      final stateStyle =
          component.states![currentState]['style'] as Map<String, dynamic>?;
      if (stateStyle != null) style.addAll(stateStyle);
    }

    // Helper text
    final helperText = style['helperText']?.toString();
    final helperTextColor = StyleUtils.parseColor(style['helperTextColor']);

    String displayText = config['placeholder'] ?? 'Select a date range';
    if (_selectedDateRange != null) {
      final start = _selectedDateRange!.start;
      final end = _selectedDateRange!.end;
      final startDate = '${start.toLocal()}'.split(' ')[0];
      final endDate = '${end.toLocal()}'.split(' ')[0];
      displayText = '$startDate - $endDate';
    }

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
                config['label'],
                style: TextStyle(
                  fontSize: style['labelTextSize']?.toDouble() ?? 16,
                  color: StyleUtils.parseColor(style['labelColor']),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          InkWell(
            onTap: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
                initialDateRange: _selectedDateRange,
              );
              setState(() {
                _isTouched = true;
                if (picked != null) {
                  _selectedDateRange = picked;
                }
              });
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
                  Icon(
                    Icons.calendar_today,
                    color: StyleUtils.parseColor(style['iconColor']),
                    size: (style['iconSize'] as num? ?? 20.0).toDouble(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      displayText,
                      style: TextStyle(
                        fontSize: style['fontSize']?.toDouble() ?? 16,
                        color: StyleUtils.parseColor(style['color']),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: StyleUtils.parseColor(style['color']),
                  ),
                ],
              ),
            ),
          ),
          if (_isTouched && validationError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 12),
              child: Text(
                validationError,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          if (helperText != null && !(_isTouched && validationError != null))
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

  Widget _buildDropdown(DynamicFormModel component) {
    final style = Map<String, dynamic>.from(component.style);
    final config = component.config;
    final triggerAvatar = config['avatar'] as String?;
    final triggerIcon = config['icon'] as String?;
    final isSearchable = config['searchable'] as bool? ?? false;
    final placeholder = config['placeholder'] as String? ?? 'Search';

    // Apply variant styles
    if (component.variants != null) {
      if (triggerAvatar != null &&
          component.variants!.containsKey('withAvatar')) {
        final variantStyle =
            component.variants!['withAvatar']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (triggerIcon != null &&
          _currentDropdownLabel == null &&
          component.variants!.containsKey('iconOnly')) {
        final variantStyle =
            component.variants!['iconOnly']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (triggerIcon != null &&
          _currentDropdownLabel != null &&
          component.variants!.containsKey('withIcon')) {
        final variantStyle =
            component.variants!['withIcon']['style'] as Map<String, dynamic>?;
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
    } else if (_selectedActionId != null &&
        component.states!.containsKey('success')) {
      currentState = 'success';
    } else if (_isHovering) {
      currentState = 'hover';
    }

    // Apply state styles
    if (component.states != null &&
        component.states!.containsKey(currentState)) {
      final stateStyle =
          component.states![currentState]['style'] as Map<String, dynamic>?;
      if (stateStyle != null) style.addAll(stateStyle);
    }

    final String? helperText =
        _dropdownErrorText ?? style['helperText'] as String?;
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
        _mapIconNameToIconData(triggerIcon),
        color: StyleUtils.parseColor(style['iconColor']),
        size: (style['iconSize'] as num?)?.toDouble() ?? 24.0,
      );
    } else {
      triggerContent = Row(
        children: [
          if (triggerIcon != null) ...[
            Icon(
              _mapIconNameToIconData(triggerIcon),
              color: StyleUtils.parseColor(style['iconColor']),
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
              final renderBox =
                  dropdownKey.currentContext!.findRenderObject() as RenderBox;
              final size = renderBox.size;
              final offset = renderBox.localToGlobal(Offset.zero);

              // Show the dropdown panel as an overlay.
              showDropdownPanel(
                context,
                component,
                Rect.fromLTWH(
                  offset.dx,
                  offset.dy + size.height,
                  size.width,
                  0,
                ),
              );
            },
            child: Container(
              padding:
                  StyleUtils.parsePadding(style['padding']) ??
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              margin: StyleUtils.parsePadding(style['margin']),
              decoration: BoxDecoration(
                color: StyleUtils.parseColor(style['backgroundColor']),
                border: Border.all(
                  color: StyleUtils.parseColor(style['borderColor']),
                  width: (style['borderWidth'] as num? ?? 1.0).toDouble(),
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
  }

  void showDropdownPanel(
    BuildContext context,
    DynamicFormModel component,
    Rect rect,
  ) {
    final items = component.config['items'] as List<dynamic>? ?? [];
    final style = component.style;
    final isSearchable = component.config['searchable'] as bool? ?? false;
    final dropdownWidth =
        (style['dropdownWidth'] as num?)?.toDouble() ?? rect.width;

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
                    color: StyleUtils.parseColor(
                      style['dropdownBackgroundColor'],
                    ),
                    borderRadius: StyleUtils.parseBorderRadius(
                      style['borderRadius'],
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shrinkWrap: true,
                      itemCount: filteredItems.length + (isSearchable ? 1 : 0),
                      separatorBuilder: (context, index) {
                        // This logic handles separators for both searchable and non-searchable lists.
                        final itemIndex = isSearchable ? index - 1 : index;
                        if (itemIndex < 0 ||
                            itemIndex >= filteredItems.length) {
                          return const SizedBox.shrink();
                        }
                        final item = filteredItems[itemIndex];
                        final nextItem = (itemIndex + 1 < filteredItems.length)
                            ? filteredItems[itemIndex + 1]
                            : null;
                        if (item['type'] == 'divider' ||
                            nextItem?['type'] == 'divider') {
                          return const SizedBox.shrink();
                        }
                        return const Divider(
                          color: Colors.transparent,
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
                              decoration: InputDecoration(
                                hintText: component.config['placeholder'],
                                isDense: true,
                                suffixIcon: const Icon(Icons.search),
                              ),
                              onChanged: (value) {
                                setPanelState(() {
                                  searchQuery = value.toLowerCase();
                                  filteredItems = items.where((item) {
                                    final label =
                                        item['label']
                                            ?.toString()
                                            .toLowerCase() ??
                                        '';
                                    if (item['type'] == 'divider') return true;
                                    return label.contains(searchQuery);
                                  }).toList();
                                });
                              },
                            ),
                          );
                        }

                        final item =
                            filteredItems[isSearchable ? index - 1 : index];
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
                        final itemStyle =
                            item['style'] as Map<String, dynamic>? ?? {};

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _isTouched = true;
                              _selectedActionId = item['id'];
                              _dropdownErrorText = _validateDropdown(
                                component,
                                _selectedActionId,
                              );

                              // Update trigger label unless it's a special display type
                              final bool isIconOnly =
                                  component.config['icon'] != null &&
                                  component.config['label'] == null;
                              final bool hasAvatar =
                                  component.config['avatar'] != null;

                              if (!isIconOnly && !hasAvatar) {
                                _currentDropdownLabel = item['label'];
                              }
                            });
                            overlayEntry?.remove();
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

    final requiredValidation =
        validationConfig['required'] as Map<String, dynamic>?;
    if (requiredValidation?['isRequired'] == true &&
        (selectedId == null || selectedId.isEmpty)) {
      return requiredValidation?['error_message'] as String? ??
          'This field is required.';
    }

    return null;
  }
}
