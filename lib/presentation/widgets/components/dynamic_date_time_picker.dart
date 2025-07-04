import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/core/enums/style_color_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:dynamic_form_bi/core/enums/date_picker_enum.dart';

// Helper functions for parsing style data
Color _parseColor(dynamic value, {Color defaultColor = Colors.white}) {
  if (value is int) return Color(value);
  if (value is String) {
    if (value.startsWith('#')) {
      final hex = value.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    }
  }
  return defaultColor;
}

EdgeInsets _parsePadding(dynamic value) {
  if (value is String) {
    final parts = value.split(' ');
    if (parts.length == 2) {
      final horizontal = double.tryParse(parts[0].replaceAll('px', '')) ?? 0;
      final vertical = double.tryParse(parts[1].replaceAll('px', '')) ?? 0;
      return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
    } else if (parts.length == 4) {
      final top = double.tryParse(parts[0].replaceAll('px', '')) ?? 0;
      final right = double.tryParse(parts[1].replaceAll('px', '')) ?? 0;
      final bottom = double.tryParse(parts[2].replaceAll('px', '')) ?? 0;
      final left = double.tryParse(parts[3].replaceAll('px', '')) ?? 0;
      return EdgeInsets.fromLTRB(left, top, right, bottom);
    } else {
      final valueNum = double.tryParse(parts[0].replaceAll('px', '')) ?? 0;
      return EdgeInsets.all(valueNum);
    }
  }
  return EdgeInsets.zero;
}

class DynamicDateTimePicker extends StatefulWidget {
  final DynamicFormModel component;
  final Function(Map<String, dynamic>)? onComplete;

  const DynamicDateTimePicker({
    super.key,
    required this.component,
    this.onComplete,
  });

  @override
  State<DynamicDateTimePicker> createState() => _DynamicDateTimePickerState();
}

class _DynamicDateTimePickerState extends State<DynamicDateTimePicker> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String? _errorText;
  late PickerModeEnum _pickerMode;
  late String _selectedFormat;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode()..addListener(_handleFocusChange);
    final config = widget.component.config;
    _pickerMode = _determinePickerMode(config);
    _selectedFormat = _pickerMode.dateFormat;
    _initializeValue(config);
  }

  void _initializeValue(Map<String, dynamic> config) {
    final value = config['value']?.toString() ?? '';
    debugPrint(
      'initState: componentId=${widget.component.id}, initialValue=$value, selectedFormat=$_selectedFormat',
    );
    if (value.isNotEmpty) {
      try {
        DateFormat(_selectedFormat).parseStrict(value);
        _controller.text = value;
        debugPrint('initState: controllerText=${_controller.text}');
      } catch (e) {
        debugPrint('initState: Error parsing initial value: $e');
        _controller.text = '';
      }
    }
  }

  PickerModeEnum _determinePickerMode(Map<String, dynamic> config) {
    final pickerModeStr =
        config['picker_mode'] ?? config['pickerMode'] ?? 'fullDateTime';
    return PickerModeEnum.fromString(pickerModeStr);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _saveAndValidate();
    }
  }

  void _saveAndValidate() {
    final value = _controller.text;
    final validationError = _validateDateTimePicker(value);
    final newState = validationError != null
        ? FormStateEnum.error
        : value.isNotEmpty
        ? FormStateEnum.success
        : FormStateEnum.base;

    final valueMap = {
      ValueKeyEnum.value.key: value,
      ValueKeyEnum.currentState.key: newState.value,
      ValueKeyEnum.errorText.key: validationError,
    };

    setState(() => _errorText = validationError);
    widget.onComplete?.call(valueMap);
  }

  String? _validateDateTimePicker(String value) {
    final validationConfig = widget.component.validation;
    if (validationConfig == null) return null;

    final requiredValidation =
        validationConfig['required'] as Map<String, dynamic>?;
    if (requiredValidation?['is_required'] == true && value.isEmpty) {
      debugPrint(
        'validate: componentId=${widget.component.id}, error=Required field empty',
      );
      return requiredValidation?['error_message'] as String? ??
          'Please select a date';
    }

    if (value.isNotEmpty) {
      try {
        DateFormat(_selectedFormat).parseStrict(value);
        debugPrint(
          'validate: componentId=${widget.component.id}, value=$value, validation=success',
        );
        return null;
      } catch (e) {
        debugPrint(
          'validate: componentId=${widget.component.id}, value=$value, error=Invalid date format: $e',
        );
        return 'Invalid date format';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DynamicFormBloc, DynamicFormState>(
      builder: (context, state) {
        final component =
            state.page?.components.firstWhere(
              (c) => c.id == widget.component.id,
              orElse: () => widget.component,
            ) ??
            widget.component;

        final config = component.config;
        final currentState =
            FormStateEnum.fromString(config['current_state']) ??
            FormStateEnum.base;
        final componentValue = config['value']?.toString() ?? '';
        final componentError = config['error_text']?.toString();

        _errorText = componentError;
        _syncControllerWithState(componentValue);

        return _buildBody(component, currentState);
      },
    );
  }

  void _syncControllerWithState(String componentValue) {
    if (!_focusNode.hasFocus && _controller.text != componentValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_focusNode.hasFocus) {
          _controller.text = componentValue;
        }
      });
    }
  }

  Widget _buildBody(
    DynamicFormModel component,
    FormStateEnum currentState,
  ) {
    final style = component.style;
    return Container(
      key: Key(component.id),
      padding: _parsePadding(style['padding']),
      margin: _parsePadding(style['margin']),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(component, currentState),
          _buildDateTimeField(component, currentState),
        ],
      ),
    );
  }

  Widget _buildLabel(
    DynamicFormModel component,
    FormStateEnum currentState,
  ) {
    final config = component.config;
    final style = component.style;
    final label = config['label']?.toString();

    if (label == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 7),
      child: Text(
        label,
        style: TextStyle(
          fontSize: (style['label_text_size'] as num?)?.toDouble() ?? 16.0,
          color: _parseColor(style['label_color']),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDateTimeField(
    DynamicFormModel component,
    FormStateEnum currentState,
  ) {
    final config = component.config;
    final style = component.style;

    final isDisabled = config['disabled'] == true;
    final isReadOnly = config['readOnly'] == true;
    final placeholder = config['placeholder']?.toString();
    final fontSize = (style['font_size'] as num?)?.toDouble() ?? 16.0;
    final textColor = _parseColor(style['color']);
    final fillColor = _parseColor(
      style['background_color'],
      defaultColor: Colors.transparent,
    );
    final fontStyle = (style['font_style'] == 'italic')
        ? FontStyle.italic
        : FontStyle.normal;
    final contentVerticalPadding =
        (style['content_vertical_padding'] as num?)?.toDouble() ?? 12.0;
    final contentHorizontalPadding =
        (style['content_horizontal_padding'] as num?)?.toDouble() ?? 12.0;

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      readOnly: true,
      onTapOutside: (_) => _focusNode.unfocus(),
      decoration: InputDecoration(
        isDense: true,
        hintText: placeholder,
        border: _buildBorder(style, FormStateEnum.base),
        enabledBorder: _buildBorder(style, FormStateEnum.base),
        focusedBorder: _buildBorder(style, FormStateEnum.focused),
        errorBorder: _buildBorder(style, FormStateEnum.error),
        errorText: _errorText,
        contentPadding: EdgeInsets.symmetric(
          vertical: contentVerticalPadding,
          horizontal: contentHorizontalPadding,
        ),
        filled: fillColor != Colors.transparent,
        fillColor: fillColor,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset(
            'assets/svg/SelectDate.svg',
            colorFilter: ColorFilter.mode(
              textColor,
              BlendMode.srcIn,
            ),
            width: fontSize,
            height: fontSize,
          ),
        ),
      ),
      style: TextStyle(
        fontSize: fontSize,
        color: textColor,
        fontStyle: fontStyle,
      ),
      onTap: (isDisabled || isReadOnly)
          ? null
          : () => _pickDateTime(context, component),
    );
  }

  OutlineInputBorder _buildBorder(
    Map<String, dynamic> style,
    FormStateEnum? state,
  ) {
    double width = (style['border_width'] as num?)?.toDouble() ?? 1.0;
    Color color = _parseColor(
      style['border_color'],
      defaultColor: const Color(0xFFCCCCCC),
    );
    final borderOpacity = (style['border_opacity'] as num?)?.toDouble() ?? 1.0;
    final borderRadius = (style['border_radius'] as num?)?.toDouble() ?? 4.0;

    color = color.withValues(alpha: borderOpacity);

    if (state == FormStateEnum.focused) {
      width += 1;
    } else if (state == FormStateEnum.error) {
      color = const Color(0xFFFF4D4F);
      width = 2;
    }

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Future<void> _pickDateTime(
    BuildContext context,
    DynamicFormModel component,
  ) async {
    final config = component.config;
    _pickerMode = _determinePickerMode(config);
    _selectedFormat = _pickerMode.dateFormat;
    // debugPrint(
    //   'pickDateTime: componentId=${component.id}, pickerMode=$_pickerMode, selectedFormat=$_selectedFormat',
    // );

    final style = _buildPickerStyle(component);
    final pickedDate = await _showDatePicker(context, style);
    if (pickedDate == null || !context.mounted) return;

    TimeOfDay? pickedTime;
    if (_pickerMode != PickerModeEnum.dateOnly) {
      pickedTime = await _showTimePicker(context, style);
      if (pickedTime == null || !context.mounted) return;
    }

    final dateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      _pickerMode == PickerModeEnum.dateOnly ? 0 : pickedTime?.hour ?? 0,
      _pickerMode == PickerModeEnum.dateOnly ||
              _pickerMode == PickerModeEnum.hourDate
          ? 0
          : pickedTime?.minute ?? 0,
    );

    final formattedDateTime = DateFormat(_selectedFormat).format(dateTime);
    final validationError = _validateDateTimePicker(formattedDateTime);
    final newState = validationError != null
        ? FormStateEnum.error
        : formattedDateTime.isNotEmpty
        ? FormStateEnum.success
        : FormStateEnum.base;

    final valueMap = {
      ValueKeyEnum.value.key: formattedDateTime,
      ValueKeyEnum.currentState.key: newState.value,
      ValueKeyEnum.errorText.key: validationError,
    };

    setState(() {
      _errorText = validationError;
      _controller.text = formattedDateTime;
    });

    widget.onComplete?.call(valueMap);
  }

  Map<String, dynamic> _buildPickerStyle(DynamicFormModel component) {
    final currentState =
        FormStateEnum.fromString(component.config['current_state']) ??
        FormStateEnum.base;
    final style = component.style;
    final fillColor = _parseColor(
      style['background_color'],
      defaultColor: Colors.transparent,
    );

    return {
      'surface': fillColor,
      'primary': _parseColor(style['color']),
      'onSurface': _parseColor(style['color']),
      'onPrimary': Colors.white,
    };
  }

  Future<DateTime?> _showDatePicker(
    BuildContext context,
    Map<String, dynamic> style,
  ) async {
    final now = DateTime.now();
    DateTime? currentDate;

    if (_controller.text.isNotEmpty) {
      try {
        currentDate = DateFormat(_selectedFormat).parse(_controller.text);
      } catch (e) {
        debugPrint('Error parsing current date: $e');
        currentDate = now;
      }
    } else {
      currentDate = now;
    }

    return await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              surface: style['surface'],
              primary: style['primary'],
              onSurface: style['onSurface'],
              onPrimary: style['onPrimary'],
            ),
          ),
          child: child!,
        );
      },
    );
  }

  Future<TimeOfDay?> _showTimePicker(
    BuildContext context,
    Map<String, dynamic> style,
  ) async {
    TimeOfDay? currentTime;

    if (_controller.text.isNotEmpty) {
      try {
        final dateTime = DateFormat(_selectedFormat).parse(_controller.text);
        currentTime = TimeOfDay.fromDateTime(dateTime);
      } catch (e) {
        debugPrint('Error parsing current time: $e');
        currentTime = TimeOfDay.now();
      }
    } else {
      currentTime = TimeOfDay.now();
    }

    return await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              surface: style['surface'],
              primary: style['primary'],
              onSurface: style['onSurface'],
              onPrimary: style['onPrimary'],
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
