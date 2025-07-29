import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/core/utils/form_style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/components/input_config.dart';
import 'package:dynamic_form_bi/data/models/states/style_states_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_date_time_range_picker/dynamic_date_time_range_picker_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_date_time_range_picker/dynamic_date_time_range_picker_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_date_time_range_picker/dynamic_date_time_range_picker_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class DynamicDateTimeRangePicker extends StatelessWidget {
  final DynamicFormModel component;
  final Function(dynamic) onComplete;

  const DynamicDateTimeRangePicker({
    super.key,
    required this.component,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      DynamicDateTimeRangePickerBloc,
      DynamicDateTimeRangePickerState
    >(
      listener: (context, state) {
        final valueMap = {
          'value': state.component?.config?.value ?? '',
          'current_state': state.component?.config?.currentState ?? StatesEnum.base,
          'error_text': state.errorText,
        };
        if (state is DynamicDateTimeRangePickerSuccess) {
          onComplete(valueMap);
          if (state.focusNode?.hasFocus == false &&
              state.textController!.text !=
                  _formatRangeValue(state.component?.config?.value)) {
            state.textController!.text = _formatRangeValue(
              state.component?.config?.value,
            );
          }
        } else if (state is DynamicDateTimeRangePickerError) {
          onComplete(valueMap);
          DialogUtils.showErrorDialog(context, state.errorMessage!);
        } else if (state is DynamicDateTimeRangePickerInitial ||
            state is DynamicDateTimeRangePickerLoading) {
          debugPrint(
            'Listener: Handling ${state.runtimeType} state for id: ${state.component?.id}, value: ${state.component?.config?.value}',
          );
        } else {
          onComplete(valueMap);
          DialogUtils.showErrorDialog(context, "Another Error");
        }
      },
      builder: (context, state) {
        if (state is DynamicDateTimeRangePickerSuccess) {
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

  String _formatRangeValue(dynamic value) {
    if (value is Map<String, dynamic> &&
        value.containsKey('start') &&
        value.containsKey('end')) {
      return '${value['start']} - ${value['end']}';
    }
    return '';
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
    final StatesEnum effectiveState =stateKey ?? currentState;
    return Container(
      key: Key(component.id),
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(styleModel, inputConfig, component),
          _buildDateTimeRangeField(
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
              color: styleModel.labelColor ?? Colors.black,
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

  Widget _buildDateTimeRangeField(
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
        hintText: inputConfig.placeholder ?? 'MMM d, yyyy - MMM d, yyyy',
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
              stateStyle?.textColor ?? styleModel.iconColor ?? Colors.black,
              BlendMode.srcIn,
            ),
            width: styleModel.iconSize ?? 20,
            height: styleModel.iconSize ?? 20,
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
      ),
      enabled: !(inputConfig.disabled || inputConfig.readOnly),
      onTap: (inputConfig.disabled || inputConfig.readOnly)
          ? null
          : () => _pickDateTimeRange(context, component, styleModel),
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




  Future<void> _pickDateTimeRange(
    BuildContext context,
    DynamicFormModel component,
    StyleModel styleModel,
  ) async {
    // Parse current value if exists
    DateTimeRange? initialRange;
    final currentValue = component.config?.value;
    if (currentValue is Map<String, dynamic> &&
        currentValue.containsKey('start') &&
        currentValue.containsKey('end')) {
      try {
        final startDate = DateFormat(
          'MMM d, yyyy',
        ).parse(currentValue['start']);
        final endDate = DateFormat('MMM d, yyyy').parse(currentValue['end']);
        initialRange = DateTimeRange(start: startDate, end: endDate);
      } catch (e) {
        debugPrint('Error parsing existing date range: $e');
      }
    }

    // Show date range picker
    final pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
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

    if (pickedRange != null && context.mounted) {
      final formattedRange = {
        'start': DateFormat('MMM d, yyyy').format(pickedRange.start),
        'end': DateFormat('MMM d, yyyy').format(pickedRange.end),
      };

      context.read<DynamicDateTimeRangePickerBloc>().add(
        DateTimeRangePickedEvent(value: formattedRange),
      );
    }
  }
}
