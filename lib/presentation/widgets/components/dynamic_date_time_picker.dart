import 'package:dynamic_form_bi/core/enums/date_picker_enum.dart';
import 'package:dynamic_form_bi/core/enums/style_color_enum.dart';

import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
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
          'value': state.component!.config['value'],
          'current_state': state.component!.config['current_state'],
          'error_text': state.errorText,
        };
        if (state is DynamicDateTimePickerSuccess) {
          onComplete(valueMap);
          // Sync controller if not focused
          if (state.focusNode?.hasFocus == false &&
              state.textController!.text != state.component!.config['value']) {
            state.textController!.text = state.component!.config['value'] ?? '';
          }
        } else if (state is DynamicDateTimePickerError) {
          DialogUtils.showErrorDialog(context, state.errorMessage!);
        } else if (state is DynamicDateTimePickerLoading ||
            state is DynamicDateTimePickerInitial) {
          debugPrint('Listener: Handling ${state.runtimeType} state');
        } else {
          onComplete(valueMap);
          DialogUtils.showErrorDialog(context, "Another Error");
        }
      },
      builder: (context, state) {
        if (state is DynamicDateTimePickerLoading ||
            state is DynamicDateTimePickerInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DynamicDateTimePickerSuccess) {
          return _buildBody(
            state.styleModel!,
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
    StyleModel styleModel,
    InputConfig inputConfig,
    DynamicFormModel component,
    String currentState,
    String? errorText,
    TextEditingController textController,
    FocusNode focusNode,
    BuildContext context,
  ) {
    return Container(
      key: Key(component.id),
      padding: styleModel.paddingGeometry,
      margin: styleModel.marginGeometry,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(styleModel, inputConfig, component),
          _buildDateTimeField(
            styleModel,
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

  Widget _buildLabel(
    StyleModel styleModel,
    InputConfig inputConfig,
    DynamicFormModel component,
  ) {
    if (inputConfig.label == null || inputConfig.label!.isEmpty) {
      return const SizedBox.shrink();
    }
    final bool isRequired = component.config['is_required'] == true;
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            inputConfig.label!,
            style: TextStyle(
              fontSize: styleModel.labelTextSize,
              color: styleModel.labelTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isRequired)
            const Text(
              ' *',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateTimeField(
    StyleModel styleModel,
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
        border: _buildBorder(styleModel, 'base'),
        enabledBorder: _buildBorder(
          styleModel,
          'base',
        ),
        focusedBorder: _buildBorder(
          styleModel,
          'focused',
        ),
        errorBorder: _buildBorder(
          styleModel,
          'error',
        ),
        errorText: errorText,
        contentPadding: EdgeInsets.symmetric(
          vertical: styleModel.contentVerticalPaddingValue,
          horizontal: styleModel.contentHorizontalPaddingValue,
        ),
        filled: styleModel.fillColor != Colors.transparent,
        fillColor: styleModel.fillColor,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset(
            'assets/svg/SelectDate.svg',
            colorFilter: ColorFilter.mode(
              styleModel.textColorValue,
              BlendMode.srcIn,
            ),
            width: styleModel.fontSizeValue,
            height: styleModel.fontSizeValue,
          ),
        ),
      ),
      style: TextStyle(
        fontSize: styleModel.fontSizeValue,
        color: styleModel.textColorValue,
        fontStyle: styleModel.fontStyleValue,
      ),
      onTap: (inputConfig.disabled || inputConfig.readOnly)
          ? null
          : () => _pickDateTime(context, component, styleModel),
    );
  }

  OutlineInputBorder _buildBorder(
    StyleModel styleModel,
    String? state,
  ) {
    double width = styleModel.borderWidthValue;
    Color color = styleModel.borderColorValue;

    if (state == 'focused') {
      width += 1;
      color = styleModel.focusedBorderColorValue;
    } else if (state == 'error') {
      color = styleModel.errorBorderColorValue;
      width = 2;
    }

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(styleModel.borderRadiusValue),
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
    StyleModel styleModel,
  ) async {
    final pickerMode = _determinePickerMode(component.config);
    final selectedFormat = pickerMode.dateFormat;

    final style = component.style; // Using simplified style from component
    final pickedDate = await _showDatePicker(
      context,
      style.toJson(),
      styleModel,
    );
    if (pickedDate == null || !context.mounted) return;

    TimeOfDay? pickedTime;
    if (pickerMode != PickerModeEnum.dateOnly) {
      pickedTime = await _showTimePicker(context, style.toJson(), styleModel);
      if (pickedTime == null || !context.mounted) return;
    }

    final dateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickerMode == PickerModeEnum.dateOnly ? 0 : pickedTime?.hour ?? 0,
      pickerMode == PickerModeEnum.dateOnly ||
              pickerMode == PickerModeEnum.hourDate
          ? 0
          : pickedTime?.minute ?? 0,
    );

    final formattedDateTime = DateFormat(selectedFormat).format(dateTime);
    // Dispatch event to BLoC instead of setState
    context.read<DynamicDateTimePickerBloc>().add(
      DateTimePickedEvent(value: formattedDateTime),
    );
  }

  Future<DateTime?> _showDatePicker(
    BuildContext context,
    Map<String, dynamic> style,
    StyleModel styleModel,
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
            surface: styleModel.fillColor,
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
    StyleModel styleModel,
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
            surface: styleModel.fillColor,
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
