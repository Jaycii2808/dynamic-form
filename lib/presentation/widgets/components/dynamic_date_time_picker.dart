import 'package:dynamic_form_bi/core/enums/date_picker_enum.dart';
import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/core/utils/form_style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/components/input_config.dart';
import 'package:dynamic_form_bi/data/models/states/style_states_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_date_time_picker/dynamic_date_time_picker_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_date_time_picker/dynamic_date_time_picker_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_date_time_picker/dynamic_date_time_picker_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
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
        if (state is DynamicDateTimePickerSuccess) {
          // Pass simple value instead of valueMap
          final simpleValue = state.component?.config?.value?.toString() ?? '';
          onComplete(simpleValue);

          if (state.focusNode?.hasFocus == false &&
              state.textController!.text !=
                  (state.component?.config?.value ?? '')) {
            state.textController!.text = state.component?.config?.value ?? '';
          }
        } else if (state is DynamicDateTimePickerError) {
          // Pass simple value instead of valueMap
          final simpleValue = state.component?.config?.value?.toString() ?? '';
          onComplete(simpleValue);
          DialogUtils.showErrorDialog(context, state.errorMessage!);
        } else if (state is DynamicDateTimePickerInitial ||
            state is DynamicDateTimePickerLoading) {
          debugPrint(
            'Listener: Handling ${state.runtimeType} state for id: ${state.component?.id}, value: ${state.component?.config?.value}',
          );
        } else {
          // Pass simple value instead of valueMap
          final simpleValue = state.component?.config?.value?.toString() ?? '';
          onComplete(simpleValue);
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
    StatesEnum currentState,
    String? errorText,
    TextEditingController textController,
    FocusNode focusNode,
  ) {
    final StatesEnum? stateKey = component.config?.currentState;
    final StatesEnum effectiveState = stateKey ?? currentState;
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
    StatesEnum currentState,
    String? errorText,
    TextEditingController textController,
    FocusNode focusNode,
  ) {
    final StatesEnum stateKey = currentState;
    final StyleStatesModel? stateStyle = ReusedWidget.getStateStyle(
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
        enabledBorder: _buildBorder(styleModel, StatesEnum.base),
        focusedBorder: _buildBorder(styleModel, StatesEnum.focused),
        errorBorder: _buildBorder(styleModel, StatesEnum.error),
        disabledBorder: _buildBorder(styleModel, StatesEnum.disabled),
        prefixIcon: Padding(
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
        ),
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

  OutlineInputBorder _buildBorder(StyleModel styleModel, StatesEnum state) {
    double width = styleModel.borderWidth ?? 1.0;
    Color color = styleModel.borderColor ?? Colors.grey;

    if (state == StatesEnum.focused) {
      width += 1;
      color = styleModel.focusedBorderColor ?? Colors.blue;
    } else if (state == StatesEnum.error) {
      color = styleModel.errorBorderColor ?? Colors.red;
      width = 2;
    } else if (state == StatesEnum.disabled) {
      color = Colors.grey[400]!;
    }

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(styleModel.borderRadius ?? 4.0),
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
