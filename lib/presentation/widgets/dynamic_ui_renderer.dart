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
    // Variant (nếu có)
    if (component.variants != null &&
        component.variants!.containsKey('withLabel')) {
      final variantStyle =
          component.variants!['withLabel']['style'] as Map<String, dynamic>?;
      if (variantStyle != null) {
        style.addAll(variantStyle);
      }
    }
    // State (focus)
    if (_isFocused &&
        component.states != null &&
        component.states!.containsKey('focus')) {
      final focusStyle =
          component.states!['focus']['style'] as Map<String, dynamic>?;
      if (focusStyle != null) {
        style.addAll(focusStyle);
      }
    }

    return Container(
      key: Key(component.id),
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
                    StyleUtils.parseColor(style['labelColor']) ?? Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 4),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
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
                  color:
                      StyleUtils.parseColor(style['borderColor']) ??
                      Colors.blue,
                  width: 2,
                ),
              ),
              errorText: _errorText,
              contentPadding: StyleUtils.parsePadding(style['padding']),
            ),
            style: TextStyle(
              fontSize: style['fontSize']?.toDouble() ?? 16,
              color: StyleUtils.parseColor(style['color']) ?? Colors.black,
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

  String? _validate(UIComponentModel component, String value) {
    // Lấy inputTypes đầu tiên (nếu có)
    final inputTypes = component.inputTypes;
    if (inputTypes != null && inputTypes.isNotEmpty) {
      final firstType = inputTypes.entries.first.value;
      final validation = firstType['validation'] as Map<String, dynamic>?;
      if (validation != null) {
        final minLength = validation['min_length'] ?? 0;
        final maxLength = validation['max_length'] ?? 9999;
        final regexStr = validation['regex'] ?? '';
        final errorMsg = validation['error_message'] ?? 'Invalid input';
        if (value.length < minLength || value.length > maxLength) {
          return errorMsg;
        }
        if (regexStr.isNotEmpty) {
          final regex = RegExp(regexStr);
          if (!regex.hasMatch(value)) {
            return errorMsg;
          }
        }
      }
    }
    if ((component.config['isRequired'] ?? false) && value.trim().isEmpty) {
      return 'Trường này là bắt buộc';
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
