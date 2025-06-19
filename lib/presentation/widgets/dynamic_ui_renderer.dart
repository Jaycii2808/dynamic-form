import 'package:flutter/material.dart';
import '../../core/models/ui_component_model.dart';
import '../../core/utils/style_utils.dart';

class DynamicUIRenderer extends StatefulWidget {
  final UIComponentModel component;

  const DynamicUIRenderer({Key? key, required this.component})
    : super(key: key);

  @override
  State<DynamicUIRenderer> createState() => _DynamicUIRendererState();
}

class _DynamicUIRendererState extends State<DynamicUIRenderer> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final component = widget.component;
    switch (component.type.toLowerCase()) {
      case 'textfield':
        return _buildTextField(component);
      case 'container':
        return _buildContainer();
      case 'text':
        return _buildText();
      case 'button':
        return _buildButton();
      case 'image':
        return _buildImage();
      case 'column':
        return _buildColumn();
      case 'row':
        return _buildRow();
      case 'card':
        return _buildCard();
      case 'listview':
        return _buildListView();
      default:
        return _buildContainer();
    }
  }

  Widget _buildTextField(UIComponentModel component) {
    // Style base
    final style = Map<String, dynamic>.from(component.style);
    String currentState = 'base';

    // Validation logic
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

    // Apply state styles
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
      final iconColor =
          StyleUtils.parseColor(style['iconColor']) ?? Colors.white;
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
    final helperTextColor =
        StyleUtils.parseColor(style['helperTextColor']) ?? Colors.transparent;

    // Unified content padding
    final contentPadding = const EdgeInsets.symmetric(
      vertical: 10,
      horizontal: 12,
    );

    return Container(
      key: Key(component.id),
      width: double.infinity,
      padding: StyleUtils.parsePadding(style['padding']),
      margin: StyleUtils.parsePadding(style['margin']),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (component.config['label'] != null)
            Text(
              component.config['label'],
              style: TextStyle(
                fontSize: style['labelTextSize']?.toDouble() ?? 16,
                color:
                    StyleUtils.parseColor(style['labelColor']) ??
                    Color(0xFF3b82f6),
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 4),
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
                  color:
                      StyleUtils.parseColor(style['borderColor']) ??
                      Colors.grey,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: StyleUtils.parseBorderRadius(
                  style['borderRadius'],
                ),
                borderSide: BorderSide(
                  color:
                      StyleUtils.parseColor(style['borderColor']) ??
                      Colors.grey,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: StyleUtils.parseBorderRadius(
                  style['borderRadius'],
                ),
                borderSide: BorderSide(
                  color:
                      StyleUtils.parseColor(style['borderColor']) ??
                      Colors.blue,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: StyleUtils.parseBorderRadius(
                  style['borderRadius'],
                ),
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
              errorText: null,
              contentPadding: contentPadding,
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
              color: StyleUtils.parseColor(style['color']) ?? Colors.white,
              fontStyle: style['fontStyle'] == 'italic'
                  ? FontStyle.italic
                  : FontStyle.normal,
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ],
      ),
    );
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

  TextInputType _getKeyboardType(UIComponentModel component) {
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

  String? _validate(UIComponentModel component, String value) {
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
      if (selectedType == null) {
        selectedType = inputTypes.keys.first;
      }

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
              print('Invalid regex pattern: $regexStr');
            }
          }
        }
      }
    }

    return null;
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
                  .map((child) => DynamicUIRenderer(component: child))
                  .toList(),
            )
          : null,
    );
  }

  Widget _buildText() {
    final component = widget.component;
    return Container(
      key: Key(component.id),
      padding: StyleUtils.parsePadding(component.style['padding']),
      margin: StyleUtils.parsePadding(component.style['margin']),
      child: Text(
        component.config['text'] ?? '',
        style: StyleUtils.buildTextStyle(component.style),
        textAlign: _parseTextAlign(component.style['textAlign']),
      ),
    );
  }

  Widget _buildButton() {
    final component = widget.component;
    return Container(
      key: Key(component.id),
      padding: StyleUtils.parsePadding(component.style['padding']),
      margin: StyleUtils.parsePadding(component.style['margin']),
      child: ElevatedButton(
        onPressed: () {
          print('Button pressed: ${component.id}');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: StyleUtils.parseColor(
            component.style['backgroundColor'],
          ),
          foregroundColor: StyleUtils.parseColor(component.style['color']),
          shape: RoundedRectangleBorder(
            borderRadius: StyleUtils.parseBorderRadius(
              component.style['borderRadius'],
            ),
          ),
        ),
        child: Text(
          component.config['text'] ?? 'Button',
          style: StyleUtils.buildTextStyle(component.style),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final component = widget.component;
    return Container(
      key: Key(component.id),
      padding: StyleUtils.parsePadding(component.style['padding']),
      margin: StyleUtils.parsePadding(component.style['margin']),
      child: Image.network(
        component.config['url'] ?? '',
        width: component.style['width']?.toDouble(),
        height: component.style['height']?.toDouble(),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: component.style['width']?.toDouble() ?? 100,
            height: component.style['height']?.toDouble() ?? 100,
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported),
          );
        },
      ),
    );
  }

  Widget _buildColumn() {
    final component = widget.component;
    return Container(
      key: Key(component.id),
      padding: StyleUtils.parsePadding(component.style['padding']),
      margin: StyleUtils.parsePadding(component.style['margin']),
      decoration: StyleUtils.buildBoxDecoration(component.style),
      child: Column(
        crossAxisAlignment: _parseCrossAxisAlignment(
          component.style['crossAxisAlignment'],
        ),
        mainAxisAlignment: _parseMainAxisAlignment(
          component.style['mainAxisAlignment'],
        ),
        children: component.children != null
            ? component.children!
                  .map((child) => DynamicUIRenderer(component: child))
                  .toList()
            : [],
      ),
    );
  }

  Widget _buildRow() {
    final component = widget.component;
    return Container(
      key: Key(component.id),
      padding: StyleUtils.parsePadding(component.style['padding']),
      margin: StyleUtils.parsePadding(component.style['margin']),
      decoration: StyleUtils.buildBoxDecoration(component.style),
      child: Row(
        crossAxisAlignment: _parseCrossAxisAlignment(
          component.style['crossAxisAlignment'],
        ),
        mainAxisAlignment: _parseMainAxisAlignment(
          component.style['mainAxisAlignment'],
        ),
        children: component.children != null
            ? component.children!
                  .map((child) => DynamicUIRenderer(component: child))
                  .toList()
            : [],
      ),
    );
  }

  Widget _buildCard() {
    final component = widget.component;
    return Container(
      key: Key(component.id),
      padding: StyleUtils.parsePadding(component.style['padding']),
      margin: StyleUtils.parsePadding(component.style['margin']),
      child: Card(
        elevation: component.style['elevation']?.toDouble() ?? 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: StyleUtils.parseBorderRadius(
            component.style['borderRadius'],
          ),
        ),
        child: Container(
          padding: StyleUtils.parsePadding(component.style['contentPadding']),
          child: component.children != null
              ? Column(
                  children: component.children!
                      .map((child) => DynamicUIRenderer(component: child))
                      .toList(),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildListView() {
    final component = widget.component;
    return Container(
      key: Key(component.id),
      padding: StyleUtils.parsePadding(component.style['padding']),
      margin: StyleUtils.parsePadding(component.style['margin']),
      height: component.style['height']?.toDouble(),
      child: ListView.builder(
        itemCount: component.children?.length ?? 0,
        itemBuilder: (context, index) {
          return DynamicUIRenderer(component: component.children![index]);
        },
      ),
    );
  }

  TextAlign _parseTextAlign(String? align) {
    switch (align?.toLowerCase()) {
      case 'center':
        return TextAlign.center;
      case 'left':
        return TextAlign.left;
      case 'right':
        return TextAlign.right;
      case 'justify':
        return TextAlign.justify;
      default:
        return TextAlign.left;
    }
  }

  CrossAxisAlignment _parseCrossAxisAlignment(String? alignment) {
    switch (alignment?.toLowerCase()) {
      case 'center':
        return CrossAxisAlignment.center;
      case 'start':
        return CrossAxisAlignment.start;
      case 'end':
        return CrossAxisAlignment.end;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      default:
        return CrossAxisAlignment.center;
    }
  }

  MainAxisAlignment _parseMainAxisAlignment(String? alignment) {
    switch (alignment?.toLowerCase()) {
      case 'center':
        return MainAxisAlignment.center;
      case 'start':
        return MainAxisAlignment.start;
      case 'end':
        return MainAxisAlignment.end;
      case 'spacebetween':
        return MainAxisAlignment.spaceBetween;
      case 'spacearound':
        return MainAxisAlignment.spaceAround;
      case 'spaceevenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.start;
    }
  }
}
