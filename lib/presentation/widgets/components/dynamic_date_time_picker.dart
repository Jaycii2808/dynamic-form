import 'package:dynamic_form_bi/core/enums/date_picker_enum.dart';
import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/core/utils/form_style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/states/states_model.dart';
import 'package:dynamic_form_bi/data/models/states/style_states_model.dart';
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
          'value': state.component?.config?.value ?? '',
          'current_state': state.component?.config?.currentState ?? 'base',
          'error_text': state.errorText,
        };
        if (state is DynamicDateTimePickerSuccess) {
          onComplete(valueMap);
          if (state.focusNode?.hasFocus == false &&
              state.textController!.text !=
                  (state.component?.config?.value ?? '')) {
            state.textController!.text = state.component?.config?.value ?? '';
          }
        } else if (state is DynamicDateTimePickerError) {
          onComplete(valueMap);
          DialogUtils.showErrorDialog(context, state.errorMessage!);
        } else if (state is DynamicDateTimePickerInitial ||
            state is DynamicDateTimePickerLoading) {
          debugPrint(
            'Listener: Handling ${state.runtimeType} state for id: ${state.component?.id}, value: ${state.component?.config?.value}',
          );
        } else {
          onComplete(valueMap);
          DialogUtils.showErrorDialog(context, "Another Error");
        }
      },
      builder: (context, state) {
        if (state is DynamicDateTimePickerSuccess) {
          return _buildBody(
            context,
            state.styleModel!,
            state.inputConfig!,
            state.component!,
            state.formState!,
            state.errorText,
            state.textController!,
            state.focusNode!,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    StyleModel styleModel,
    InputConfig inputConfig,
    DynamicFormModel component,
    String currentState,
    String? errorText,
    TextEditingController textController,
    FocusNode focusNode,
  ) {
    final String? stateKey = component.config?.currentState;
    final String effectiveState =
        _getStatesModelFromKey(stateKey) ?? currentState;
    return Container(
      key: Key(component.id),
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(styleModel, inputConfig, component),
          _buildDateTimeField(
            context,
            styleModel,
            inputConfig,
            component,
            effectiveState,
            errorText,
            textController,
            focusNode,
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
    final bool isRequired = component.config?.isRequired == true;
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            inputConfig.label!,
            style: TextStyle(
              fontSize: styleModel.labelTextSize ?? 16,
              color: styleModel.textColor ?? Colors.black,
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
    BuildContext context,
    StyleModel styleModel,
    InputConfig inputConfig,
    DynamicFormModel component,
    String currentState,
    String? errorText,
    TextEditingController textController,
    FocusNode focusNode,
  ) {
    final String stateKey = currentState;
    final StyleStatesModel? stateStyle = _getStateStyle(
      component.states,
      stateKey,
    );
    final String? helperText = stateStyle?.helperText ?? styleModel.helperText;
    final Color? helperTextColor = stateStyle?.helperTextColor;

    return TextField(
      controller: textController,
      focusNode: focusNode,
      readOnly: true,
      onTapOutside: (_) => focusNode.unfocus(),
      decoration: InputDecoration(
        isDense: true,
        hintText: inputConfig.placeholder ?? '',
        hintStyle: FormStyleUtils.hintStyle(context),
        errorText: errorText,
        errorStyle: FormStyleUtils.errorStyle(context),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 12.0,
        ),
        filled: styleModel.backgroundColor != Colors.transparent,
        fillColor: styleModel.backgroundColor,
        border: _buildBorder(styleModel, currentState),
        enabledBorder: _buildBorder(styleModel, 'base'),
        focusedBorder: _buildBorder(styleModel, 'focused'),
        errorBorder: _buildBorder(styleModel, 'error'),
        disabledBorder: _buildBorder(styleModel, 'disabled'),
        prefixIcon: inputConfig != null
            ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset(
            'assets/svg/SelectDate.svg',
            colorFilter: ColorFilter.mode(
              stateStyle?.textColor ?? styleModel.textColor ?? Colors.black,
              BlendMode.srcIn,
            ),
            width: styleModel.fontSize ?? 16,
            height: styleModel.fontSize ?? 16,
          ),
        )
            : null,
        helperText: helperText,
        helperStyle: TextStyle(
          color: helperTextColor,
          fontSize: 12,
        ),
      ),
      style: TextStyle(
        fontSize: styleModel.fontSize ?? 16,
        color: stateStyle?.textColor ?? styleModel.textColor ?? Colors.black,
        //fontStyle: styleModel.fontStyle ?? FontStyle.normal,
      ),
      enabled: !(inputConfig.disabled || inputConfig.readOnly),
      onTap: (inputConfig.disabled || inputConfig.readOnly)
          ? null
          : () => _pickDateTime(context, component, styleModel),
    );
  }

  OutlineInputBorder _buildBorder(StyleModel styleModel, String state) {
    double width = styleModel.borderWidth ?? 1.0;
    Color color = styleModel.borderColor ?? Colors.grey;

    if (state == 'focused') {
      width += 1;
      color = styleModel.focusedBorderColor ?? Colors.blue;
    } else if (state == 'error') {
      color = styleModel.errorBorderColor ?? Colors.red;
      width = 2;
    } else if (state == 'disabled') {
      color = Colors.grey[400]!;
    }

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(styleModel.borderRadius ?? 4.0),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  StyleStatesModel? _getStateStyle(StatesModel? states, String key) {
    switch (key) {
      case 'base':
        return states?.base;
      case 'error':
        return states?.error;
      case 'success':
        return states?.success;
      case 'focused':
        return states?.focused;
      default:
        return null;
    }
  }

  String? _getStatesModelFromKey(String? key) {
    switch (key) {
      case 'base':
        return 'base';
      case 'error':
        return 'error';
      case 'success':
        return 'success';
      case 'focused':
        return 'focused';
      default:
        return null;
    }
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
    final pickerMode = _determinePickerMode(component.config?.toJson() ?? {});
    final selectedFormat = pickerMode.dateFormat;

    final pickedDate = await _showDatePicker(context, styleModel);
    if (pickedDate == null || !context.mounted) return;

    TimeOfDay? pickedTime;
    if (pickerMode != PickerModeEnum.dateOnly) {
      pickedTime = await _showTimePicker(context, styleModel);
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
    context.read<DynamicDateTimePickerBloc>().add(
      DateTimePickedEvent(value: formattedDateTime),
    );
  }

  Future<DateTime?> _showDatePicker(
    BuildContext context,
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
            primary: styleModel.iconColor ?? Colors.blue,
            onPrimary: Colors.white,
            surface: styleModel.backgroundColor ?? Colors.white,
            onSurface: styleModel.textColor ?? Colors.black,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: styleModel.iconColor ?? Colors.blue,
            ),
          ),
        ),
        child: child!,
      ),
    );
  }

  Future<TimeOfDay?> _showTimePicker(
    BuildContext context,
    StyleModel styleModel,
  ) async {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: styleModel.iconColor ?? Colors.blue,
            onPrimary: Colors.white,
            surface: styleModel.backgroundColor ?? Colors.white,
            onSurface: styleModel.textColor ?? Colors.black,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: styleModel.iconColor ?? Colors.blue,
            ),
          ),
        ),
        child: child!,
      ),
    );
  }
}
