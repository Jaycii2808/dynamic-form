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

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _controller.text = widget.component.config['value'] ?? '';
  }

  @override
  void dispose() {
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
      case 'textarea':
        return _buildTextArea(component);
      case 'datetime_picker':
        return _buildDateTimePickerForm(component);
      default:
        return _buildContainer();
    }
  }
  Widget _buildDateTimePickerForm(DynamicFormModel component) {
    final style = Map<String, dynamic>.from(component.style);
    final value = component.config['value'] ?? DateTime.now().toString(); // Lấy giá trị mặc định từ config hoặc ngày hiện tại
    String dateDisplay = value.contains('dd/mm/yyyy') ? 'dd/mm/yyyy' : value.split(' ')[0]; // Hiển thị định dạng hoặc giá trị hiện tại

    Future<void> selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2016),
        lastDate: DateTime(2030),
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF6979F8),
              ),
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
                border: Border.all(color: StyleUtils.parseColor(style['borderColor'])),
                borderRadius: StyleUtils.parseBorderRadius(style['borderRadius']),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateDisplay,
                    style: TextStyle(
                      color: StyleUtils.parseColor(style['color']),
                      fontStyle: style['fontStyle'] == 'italic' ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                  const Icon(Icons.calendar_today, color: Color(0xFF6979F8)), // Sử dụng màu theo giao diện mẫu
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
      if (component.config['label'] != null && component.variants!.containsKey('withLabel')) {
        final variantStyle = component.variants!['withLabel']['style'] as Map<String, dynamic>?;
        if (variantStyle != null) style.addAll(variantStyle);
      }
      if (component.config['value'] != null && component.variants!.containsKey('withLabelValue')) {
        final variantStyle = component.variants!['withLabelValue']['style'] as Map<String, dynamic>?;
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
                  helperText: _errorText, // Đảm bảo helperText hiển thị _errorText
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
                Positioned( //
                  right: 10,
                  bottom: 0,
                  child: Text(
                    '$_errorText (Now ${value.length - 100})',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
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
}
