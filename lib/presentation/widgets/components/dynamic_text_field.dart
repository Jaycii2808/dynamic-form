// ignore_for_file: non_constant_identifier_names

import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/data/models/states/style_states_model.dart';
import 'package:dynamic_form_bi/data/models/input_types/input_validation_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_field/dynamic_text_field_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_field/dynamic_text_field_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_text_field/dynamic_text_field_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class DynamicTextField extends StatefulWidget {
  final DynamicFormModel component;
  final Function(dynamic)? onComplete;

  const DynamicTextField({
    super.key,
    required this.component,
    this.onComplete,
  });

  @override
  State<DynamicTextField> createState() => _DynamicTextFieldState();
}

class _DynamicTextFieldState extends State<DynamicTextField> {
  @override
  void initState() {
    super.initState();
    context.read<DynamicTextFieldBloc>().add(const InitializeTextFieldEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DynamicTextFieldBloc, DynamicTextFieldState>(
      listener: (context, state) {
        if (state is DynamicTextFieldSuccess) {
          final simpleValue = state.component?.config?.value?.toString() ?? '';
          widget.onComplete?.call(simpleValue);

          final textController = state.textController;
          if (textController != null && textController.text != simpleValue) {
            textController.text = simpleValue;
          }
        } else if (state is DynamicTextFieldError) {
          final simpleValue = state.component?.config?.value?.toString() ?? '';
          widget.onComplete?.call(simpleValue);
          DialogUtils.showErrorDialog(context, state.errorMessage!);
        } else if (state is DynamicTextFieldInitial ||
            state is DynamicTextFieldLoading) {
          debugPrint(
            'Listener: Handling ${state.runtimeType} state for id: ${state.component?.id}, value: ${state.component?.config!.value}',
          );
        } else {
          final simpleValue = state.component?.config?.value?.toString() ?? '';
          widget.onComplete?.call(simpleValue);
          DialogUtils.showErrorDialog(context, "Another Error");
        }
      },
      builder: (context, state) {
        if (state is DynamicTextFieldSuccess) {
          return _buildBody(
            styleModel: state.styleModel!,
            inputConfig: state.inputConfig!,
            component: state.component!,
            currentState: state.formState!,
            errorText: state.errorText,
            textController: state.textController!,
            focusNode: state.focusNode!,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBody({
    required StyleModel styleModel,
    required InputValidationModel inputConfig,
    required DynamicFormModel component,
    required StatesEnum currentState,
    String? errorText,
    required TextEditingController textController,
    required FocusNode focusNode,
  }) {
    StatesEnum enabledBorderState = StatesEnum.base;
    if (errorText != null && errorText.isNotEmpty) {
      enabledBorderState = StatesEnum.error;
    } else if (currentState == StatesEnum.success) {
      enabledBorderState = StatesEnum.success;
    }
    final stateStyle = ReusedWidget.getStateStyle(
      component.states,
      enabledBorderState,
    );

    return Container(
      key: Key(component.id),
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 12.0,
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 12.0,
      ),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(focusNode);
        },
        behavior: HitTestBehavior.translucent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel(styleModel, inputConfig, stateStyle),
            _buildTextField(
              styleModel,
              inputConfig,
              component,
              currentState,
              errorText,
              textController,
              focusNode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(
      StyleModel styleModel,
      InputValidationModel inputConfig,
      StyleStatesModel? stateStyle,
      ) {
    if (inputConfig.label == null || inputConfig.label!.isEmpty) {
      return const SizedBox.shrink();
    }
    final Color labelColor =
        stateStyle?.iconColor ?? styleModel.labelColor ?? Colors.white;

    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 7),
      child: Text(
        inputConfig.label!,
        style: TextStyle(
          fontSize: styleModel.labelTextSize,
          color: labelColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField(
      StyleModel styleModel,
      InputValidationModel inputConfig,
      DynamicFormModel component,
      StatesEnum currentState,
      String? errorText,
      TextEditingController textController,
      FocusNode focusNode,
      ) {
    StatesEnum enabledBorderState = StatesEnum.base;
    if (errorText != null && errorText.isNotEmpty) {
      enabledBorderState = StatesEnum.error;
    } else if (currentState == StatesEnum.success) {
      enabledBorderState = StatesEnum.success;
    }

    final StyleStatesModel? stateStyle = ReusedWidget.getStateStyle(
      component.states,
      enabledBorderState,
    );

    Color? textColor = stateStyle?.textColor;
    String? helperText = stateStyle?.helperText ?? styleModel.helperText;
    Color? helperTextColor =
        stateStyle?.helperTextColor ?? styleModel.helperTextColor;

    return TextField(
      controller: textController,
      focusNode: focusNode,
      enabled: inputConfig.editable && !inputConfig.disabled,
      readOnly: inputConfig.readOnly,
      obscureText: component.inputTypes?.password != null,
      keyboardType: _getKeyboardType(component),
      onChanged: (value) {
        context.read<DynamicTextFieldBloc>().add(
          TextFieldValueChangedEvent(value: value),
        );
      },
      decoration: InputDecoration(
        isDense: true,
        hintText: inputConfig.placeholder ?? '',
        prefixIcon: _buildPrefixIcon(component, currentState),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 0,
        ),
        border: _buildBorder(styleModel, component, enabledBorderState),
        enabledBorder: _buildBorder(styleModel, component, enabledBorderState),
        focusedBorder: _buildBorder(styleModel, component, StatesEnum.focused),
        errorBorder: _buildBorder(styleModel, component, StatesEnum.error),
        errorText: errorText,
        contentPadding: EdgeInsets.symmetric(
          vertical: styleModel.contentVerticalPadding ?? 12.0,
          horizontal: styleModel.contentHorizontalPadding ?? 12.0,
        ),
        helperText: helperText,
        helperStyle: TextStyle(
          color: helperTextColor ?? Colors.white,
          fontSize: 12,
        ),
        labelStyle: TextStyle(
          color: styleModel.labelColor ?? Colors.white,
        ),
      ),
      style: TextStyle(
        fontSize: styleModel.fontSize,
        color: textColor ?? Colors.white,
      ),
    );
  }

  Widget? _buildPrefixIcon(
      DynamicFormModel component,
      StatesEnum currentState,
      ) {
    final stateStyle = ReusedWidget.getStateStyle(
      component.states,
      currentState,
    );
    final iconName = component.config?.icon?.toString();
    if (iconName != null && iconName.isNotEmpty && stateStyle != null) {
      final iconColor = stateStyle.iconColor;
      final iconSize = stateStyle.iconSize;
      final iconData = IconTypeEnum.fromString(iconName).toIconData();
      if (iconData != null) {
        return Icon(iconData, color: iconColor, size: iconSize);
      }
    }
    return null;
  }

  TextInputType _getKeyboardType(DynamicFormModel component) {
    final inputTypes = component.inputTypes;
    if (inputTypes != null) {
      if (inputTypes.email != null) {
        return TextInputType.emailAddress;
      } else if (inputTypes.tel != null) {
        return TextInputType.phone;
      } else if (inputTypes.password != null) {
        return TextInputType.visiblePassword;
      }
    }
    return TextInputType.text;
  }

  OutlineInputBorder _buildBorder(
      StyleModel styleModel,
      DynamicFormModel component,
      StatesEnum state,
      ) {
    final stateStyle = ReusedWidget.getStateStyle(component.states, state);
    final Color color =
        stateStyle?.iconColor ?? styleModel.borderColor ?? Colors.grey;
    final double width =
        stateStyle?.borderWidth ?? styleModel.borderWidth ?? 1.0;

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(styleModel.borderRadius ?? 8.0),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}