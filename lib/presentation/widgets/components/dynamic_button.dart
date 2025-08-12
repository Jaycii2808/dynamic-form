import 'package:dynamic_form_bi/core/enums/button_action_enum.dart';
import 'package:dynamic_form_bi/data/models/components/form_action_data_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_button/dynamic_button_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_button/dynamic_button_event.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_button/dynamic_button_state.dart';
import 'package:dynamic_form_bi/presentation/blocs/multi_page_form/multi_page_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/multi_page_form/multi_page_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicButton extends StatefulWidget {
  final DynamicFormModel component;
  final Function(String action, FormActionDataModel? data)? onAction;

  const DynamicButton({super.key, required this.component, this.onAction});

  @override
  State<DynamicButton> createState() => _DynamicButtonState();
}

class _DynamicButtonState extends State<DynamicButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DynamicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.component != widget.component) {
      // Push latest component into the local bloc
      try {
        context.read<DynamicButtonBloc>().add(
          SetButtonComponentEvent(widget.component),
        );
      } catch (_) {
        // No-op; bloc is created in build
      }
    }
  }

  void _handleButtonPress(
    BuildContext context,
    DynamicButtonState state,
  ) async {
    context.read<DynamicButtonBloc>().add(const ButtonPressedEvent());
    // Business callback remains in UI as per requirement
    final actionEnum = state.action;
    if (actionEnum == ButtonAction.nextPage ||
        actionEnum == ButtonAction.previousPage) {
      final validate = state.component?.validation?.toJson();
      final targetPage =
          validate?[actionEnum == ButtonAction.nextPage
                  ? 'next_page'
                  : 'previous_page']
              as String?;
      widget.onAction?.call(
        actionEnum.value,
        FormActionDataModel.navigation(
          action: actionEnum.value,
          targetPage: targetPage ?? '',
          formId: state.component?.id ?? '',
          configKey: state.component?.id ?? '',
        ),
      );
    } else {
      widget.onAction?.call(
        actionEnum.value,
        FormActionDataModel.create(
          action: actionEnum.value,
          formId: state.component?.id ?? '',
          customData: state.config.toJson()['customData'],
          configKey: state.component?.id ?? '',
        ),
      );
    }
  }

  VoidCallback? _buildOnPressed(DynamicButtonState state) {
    if (state.isDisabled || !state.isVisible) return null;
    return () => _handleButtonPress(context, state);
  }

  Widget _buildButtonContent(DynamicButtonState btnState) {
    final fontSize = btnState.style.fontSize ?? 10.0;
    final fontWeight = FontWeight.bold;

    if (btnState.isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                btnState.style.textColor ?? Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Loading...',
            style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
          ),
        ],
      );
    }

    // Check icon position from config
    final isIconRightPosition =
        btnState.config.toJson()['is_icon_right_position'] == true ||
        btnState.config.toJson()['is_icon_right_position'] == 'true';

    if (btnState.iconData != null) {
      if (isIconRightPosition) {
        // right
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              btnState.buttonText,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
              ),
            ),
            const SizedBox(width: 8),
            Icon(btnState.iconData, size: fontSize + 4),
          ],
        );
      }
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(btnState.iconData, size: fontSize + 4),
          const SizedBox(width: 8),
          Text(
            btnState.buttonText,
            style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
          ),
        ],
      );
    }

    return Text(
      btnState.buttonText,
      style: TextStyle(color: Colors.black,fontSize: fontSize, fontWeight: fontWeight),
    );
  }

  Widget _buildButtonWidget(DynamicButtonState btnState, Widget content) {
    final backgroundColor = btnState.style.backgroundColor ?? Colors.blue;
    //final textColor = _style.textColor ?? Colors.white;
    final borderColor = btnState.style.borderColor ?? Colors.black;
    final borderWidth = btnState.style.borderWidth ?? 1.0;
    final elevation = btnState.style.elevation ?? 2.0;

    return Container(
      key: Key(widget.component.id),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: GestureDetector(
        onTap: _buildOnPressed(btnState),
        child: Container(
          width: btnState.style.width,
          height: btnState.style.height ?? 48.0,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: borderWidth > 0
                ? Border.all(color: borderColor, width: borderWidth)
                : null,
            borderRadius: BorderRadius.circular(8),
            boxShadow: elevation > 0
                ? [
                    BoxShadow(
                      color: btnState.style.shadowColor ?? Colors.blue,
                      blurRadius: elevation.toDouble(),
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(child: content),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          DynamicButtonBloc()..add(SetButtonComponentEvent(widget.component)),
      child: Builder(
        builder: (context) {
          MultiPageFormBloc? multiPageBloc;
          try {
            multiPageBloc = context.read<MultiPageFormBloc>();
          } catch (_) {
            multiPageBloc = null;
          }
          final buttonView = BlocBuilder<DynamicButtonBloc, DynamicButtonState>(
            builder: (context, btnState) {
              final content = _buildButtonContent(btnState);
              return btnState.isVisible
                  ? _buildButtonWidget(btnState, content)
                  : const SizedBox.shrink();
            },
          );

          if (multiPageBloc == null) {
            return buttonView;
          }

          return BlocListener<MultiPageFormBloc, MultiPageFormState>(
            listener: (context, formState) {
              final external = <String, dynamic>{};
              if (formState is MultiPageFormSuccess) {
                external.addAll(formState.componentValues.toJson());
              }
              context.read<DynamicButtonBloc>().add(
                RecomputeButtonUiEvent(external),
              );
            },
            child: buttonView,
          );
        },
      ),
    );
  }
}
