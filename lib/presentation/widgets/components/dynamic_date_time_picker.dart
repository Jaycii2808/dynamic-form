import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/core/enums/style_color_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/data/models/border_config.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_form/dynamic_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:dynamic_form_bi/core/enums/date_picker_enum.dart';

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
    final inputConfig = InputConfig.fromJson(widget.component.config);
    _pickerMode = _determinePickerMode(widget.component.config);
    _selectedFormat = _pickerMode.dateFormat;
    _initializeValue(inputConfig);
  }

  void _initializeValue(InputConfig inputConfig) {
    final value = inputConfig.value;
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
        config['picker_mode']  ?? 'fullDateTime';
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
        final inputConfig = InputConfig.fromJson(component.config);
        final currentState =
            FormStateEnum.fromString(inputConfig.currentState) ??
            FormStateEnum.base;
        final styleConfig = StyleConfig.fromJson(component.style);

        _errorText = inputConfig.errorText;
        _syncControllerWithState(inputConfig.value);

        return _buildBody(styleConfig, inputConfig, component, currentState);
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
    StyleConfig styleConfig,
    InputConfig inputConfig,
    DynamicFormModel component,
    FormStateEnum currentState,
  ) {
    return Container(
      key: Key(component.id),
      padding: styleConfig.padding,
      margin: styleConfig.margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(styleConfig, inputConfig, currentState),
          _buildDateTimeField(
            styleConfig,
            inputConfig,
            component,
            currentState,
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(
    StyleConfig styleConfig,
    InputConfig inputConfig,
    FormStateEnum currentState,
  ) {
    if (inputConfig.label == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 7),
      child: Text(
        inputConfig.label!,
        style: TextStyle(
          fontSize: styleConfig.labelTextSize,
          color: styleConfig.labelColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDateTimeField(
    StyleConfig styleConfig,
    InputConfig inputConfig,
    DynamicFormModel component,
    FormStateEnum currentState,
  ) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      readOnly: true,
      onTapOutside: (_) => _focusNode.unfocus(),
      decoration: InputDecoration(
        isDense: true,
        hintText: inputConfig.placeholder,
        border: _buildBorder(styleConfig.borderConfig, FormStateEnum.base),
        enabledBorder: _buildBorder(
          styleConfig.borderConfig,
          FormStateEnum.base,
        ),
        focusedBorder: _buildBorder(
          styleConfig.borderConfig,
          FormStateEnum.focused,
        ),
        errorBorder: _buildBorder(
          styleConfig.borderConfig,
          FormStateEnum.error,
        ),
        errorText: _errorText,
        contentPadding: EdgeInsets.symmetric(
          vertical: styleConfig.contentVerticalPadding,
          horizontal: styleConfig.contentHorizontalPadding,
        ),
        filled: styleConfig.fillColor != Colors.transparent,
        fillColor: styleConfig.fillColor,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset(
            'assets/svg/SelectDate.svg',
            colorFilter: ColorFilter.mode(
              styleConfig.textColor,
              BlendMode.srcIn,
            ),
            width: styleConfig.fontSize,
            height: styleConfig.fontSize,
          ),
        ),
      ),
      style: TextStyle(
        fontSize: styleConfig.fontSize,
        color: styleConfig.textColor,
        fontStyle: styleConfig.fontStyle,
      ),
      onTap: (inputConfig.disabled || inputConfig.readOnly)
          ? null
          : () => _pickDateTime(context, component, styleConfig),
    );
  }

  OutlineInputBorder _buildBorder(
    BorderConfig borderConfig,
    FormStateEnum? state,
  ) {
    double width = borderConfig.borderWidth;
    Color color = borderConfig.borderColor.withValues(
      alpha: borderConfig.borderOpacity,
    );
    if (state == FormStateEnum.focused) {
      width += 1;
    } else if (state == FormStateEnum.error) {
      color = const Color(0xFFFF4D4F);
      width = 2;
    }
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderConfig.borderRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Future<void> _pickDateTime(
    BuildContext context,
    DynamicFormModel component,
    StyleConfig styleConfig,
  ) async {
    final config = component.config;
    _pickerMode = _determinePickerMode(config);
    _selectedFormat = _pickerMode.dateFormat;
    // debugPrint(
    //   'pickDateTime: componentId=$[38;5;246m${component.id}[0m, pickerMode=$_pickerMode, selectedFormat=$_selectedFormat',
    // );

    final style = _buildPickerStyle(component);
    final pickedDate = await _showDatePicker(context, style, styleConfig);
    if (pickedDate == null || !context.mounted) return;

    TimeOfDay? pickedTime;
    if (_pickerMode != PickerModeEnum.dateOnly) {
      pickedTime = await _showTimePicker(context, style, styleConfig);
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
    debugPrint(
      'pickDateTime: componentId=${component.id}, formattedDateTime=$formattedDateTime',
    );
  }

  Map<String, dynamic> _buildPickerStyle(DynamicFormModel component) {
    final style = Map<String, dynamic>.from(component.style);
    final currentState = InputConfig.fromJson(component.config).currentState;
    final variantStyle =
        component.variants?['single']?['style'] as Map<String, dynamic>?;
    if (variantStyle != null) style.addAll(variantStyle);
    final stateStyle =
        component.states?[currentState]?['style'] as Map<String, dynamic>?;
    if (stateStyle != null) style.addAll(stateStyle);
    return style;
  }

  Future<DateTime?> _showDatePicker(
    BuildContext context,
    Map<String, dynamic> style,
    StyleConfig styleConfig,
  ) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: StyleColorEnum.fromString(
              style['icon_color'],
            ).toColor(customHexValue: style['icon_color']),
            onPrimary: Colors.white,
            surface: styleConfig.fillColor,
            onSurface: StyleColorEnum.fromString(
              style['color'],
            ).toColor(customHexValue: style['color']),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: StyleColorEnum.fromString(
                style['icon_color'],
              ).toColor(customHexValue: style['icon_color']),
            ),
          ),
        ),
        child: child!,
      ),
    );
    debugPrint(
      'pickDateTime: componentId=${widget.component.id}, pickedDate=$pickedDate',
    );
    return pickedDate;
  }

  Future<TimeOfDay?> _showTimePicker(
    BuildContext context,
    Map<String, dynamic> style,
    StyleConfig styleConfig,
  ) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: StyleColorEnum.fromString(
              style['icon_color'],
            ).toColor(customHexValue: style['icon_color']),
            onPrimary: Colors.white,
            surface: styleConfig.fillColor,
            onSurface: StyleColorEnum.fromString(
              style['color'],
            ).toColor(customHexValue: style['color']),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: StyleColorEnum.fromString(
                style['icon_color'],
              ).toColor(customHexValue: style['icon_color']),
            ),
          ),
        ),
        child: child!,
      ),
    );
    debugPrint(
      'pickDateTime: componentId=${widget.component.id}, pickedTime=$pickedTime',
    );
    return pickedTime;
  }
}
