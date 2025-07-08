import 'package:dynamic_form_bi/core/enums/date_picker_enum.dart';
import 'package:dynamic_form_bi/core/enums/form_state_enum.dart';
import 'package:dynamic_form_bi/core/enums/style_color_enum.dart';
import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/data/models/border_config.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_date_time_picker/dynamic_date_time_picker_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_date_time_picker/dynamic_date_time_picker_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_date_time_picker/dynamic_date_time_picker_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class DynamicDateTimePicker extends StatelessWidget {
  final DynamicFormModel component;
  final Function(dynamic) onComplete;

  const DynamicDateTimePicker({
    super.key,
    required this.component,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DynamicDateTimePickerBloc, DynamicDateTimePickerState>(
      listener: (context, state) {
        final valueMap = {
          ValueKeyEnum.value.key: state.component!.config[ValueKeyEnum.value.key],
          ValueKeyEnum.currentState.key: state.component!.config[ValueKeyEnum.currentState.key],
          ValueKeyEnum.errorText.key: state.errorText,
        };
        if (state is DynamicDateTimePickerSuccess) {
          onComplete(valueMap);
          // Sync controller if not focused
          if (state.focusNode?.hasFocus == false &&
              state.textController!.text != state.component!.config[ValueKeyEnum.value.key]) {
            state.textController!.text = state.component!.config[ValueKeyEnum.value.key] ?? '';
          }
        } else if (state is DynamicDateTimePickerError) {
          DialogUtils.showErrorDialog(context, state.errorMessage!);
        } else if (state is DynamicDateTimePickerLoading || state is DynamicDateTimePickerInitial) {
          debugPrint('Listener: Handling ${state.runtimeType} state');
        } else {
          onComplete(valueMap);
          DialogUtils.showErrorDialog(context, "Another Error");
        }
      },
      builder: (context, state) {
        if (state is DynamicDateTimePickerLoading || state is DynamicDateTimePickerInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DynamicDateTimePickerSuccess) {
          return _buildBody(
            state.styleConfig!,
            state.inputConfig!,
            state.component!,
            state.formState!,
            state.errorText,
            state.textController!,
            state.focusNode!,
            context,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBody(
    StyleConfig styleConfig,
    InputConfig inputConfig,
    DynamicFormModel component,
    FormStateEnum currentState,
    String? errorText,
    TextEditingController textController,
    FocusNode focusNode,
    BuildContext context,
  ) {
    return Container(
      key: Key(component.id),
      padding: styleConfig.padding,
      margin: styleConfig.margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(styleConfig, inputConfig),
          _buildDateTimeField(
            styleConfig,
            inputConfig,
            component,
            textController,
            focusNode,
            errorText,
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(StyleConfig styleConfig, InputConfig inputConfig) {
    if (inputConfig.label == null || inputConfig.label!.isEmpty) {
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
    TextEditingController textController,
    FocusNode focusNode,
    String? errorText,
    BuildContext context,
  ) {
    return TextField(
      controller: textController,
      focusNode: focusNode,
      readOnly: true,
      onTapOutside: (_) => focusNode.unfocus(),
      decoration: InputDecoration(
        isDense: true,
        hintText: inputConfig.placeholder,
        border: _buildBorder(styleConfig.borderConfig, FormStateEnum.base),
        enabledBorder: _buildBorder(styleConfig.borderConfig, FormStateEnum.base),
        focusedBorder: _buildBorder(styleConfig.borderConfig, FormStateEnum.focused),
        errorBorder: _buildBorder(styleConfig.borderConfig, FormStateEnum.error),
        errorText: errorText,
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

  OutlineInputBorder _buildBorder(BorderConfig borderConfig, FormStateEnum? state) {
    double width = borderConfig.borderWidth;
    Color color = borderConfig.borderColor.withOpacity(borderConfig.borderOpacity);
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

  PickerModeEnum _determinePickerMode(Map<String, dynamic> config) {
    final pickerModeStr = config['picker_mode'] ?? 'fullDateTime';
    return PickerModeEnum.fromString(pickerModeStr);
  }

  Future<void> _pickDateTime(
    BuildContext context,
    DynamicFormModel component,
    StyleConfig styleConfig,
  ) async {
    final pickerMode = _determinePickerMode(component.config);
    final selectedFormat = pickerMode.dateFormat;

    final style = component.style; // Using simplified style from component
    final pickedDate = await _showDatePicker(
      context,
      style,
      styleConfig,
    );
    if (pickedDate == null || !context.mounted) return;

    TimeOfDay? pickedTime;
    if (pickerMode != PickerModeEnum.dateOnly) {
      pickedTime = await _showTimePicker(context, style, styleConfig);
      if (pickedTime == null || !context.mounted) return;
    }

    final dateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickerMode == PickerModeEnum.dateOnly ? 0 : pickedTime?.hour ?? 0,
      pickerMode == PickerModeEnum.dateOnly || pickerMode == PickerModeEnum.hourDate
          ? 0
          : pickedTime?.minute ?? 0,
    );

    final formattedDateTime = DateFormat(selectedFormat).format(dateTime);
    // Dispatch event to BLoC instead of setState
    context.read<DynamicDateTimePickerBloc>().add(DateTimePickedEvent(value: formattedDateTime));
  }

  Future<DateTime?> _showDatePicker(
    BuildContext context,
    Map<String, dynamic> style,
    StyleConfig styleConfig,
  ) async {
    return showDatePicker(
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
  }

  Future<TimeOfDay?> _showTimePicker(
    BuildContext context,
    Map<String, dynamic> style,
    StyleConfig styleConfig,
  ) async {
    return showTimePicker(
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
  }
}
