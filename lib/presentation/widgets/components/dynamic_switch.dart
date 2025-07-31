import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_types/input_validation_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_switch/dynamic_switch_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_switch/dynamic_switch_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_switch/dynamic_switch_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicSwitch extends StatelessWidget {
  final DynamicFormModel component;
  final Function(dynamic) onComplete;

  const DynamicSwitch({
    super.key,
    required this.component,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DynamicSwitchBloc, DynamicSwitchState>(
      listener: (context, state) {
        if (state is DynamicSwitchSuccess) {
          // Pass simple value instead of valueMap
          final simpleValue = state.component?.config?.value ?? false;
          onComplete(simpleValue);
        } else if (state is DynamicSwitchError) {
          DialogUtils.showErrorDialog(context, state.errorMessage!);
        } else if (state is DynamicSwitchLoading ||
            state is DynamicSwitchInitial) {
          debugPrint(
            'Listener: Handling ${state.runtimeType} state for id: ${state.component?.id}, value: ${state.component?.config?.value}',
          );
        } else {
          // Pass simple value instead of valueMap
          final simpleValue = state.component?.config?.value ?? false;
          onComplete(simpleValue);
          DialogUtils.showErrorDialog(context, "Another Error");
        }
      },
      builder: (context, state) {
        if (state is DynamicSwitchLoading || state is DynamicSwitchInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DynamicSwitchSuccess) {
          return _buildBody(
            context,
            state.styleModel!,
            state.inputConfig!,
            state.component!,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    StyleModel styleModel,
    InputValidationModel inputConfig,
    DynamicFormModel component,
  ) {
    final config = component.config;

    final hasLabel = config?.label != null && config!.label!.isNotEmpty;
    final isSelected = config?.selected == true || config?.value == true;
    final isDisabled = inputConfig.disabled;

    final activeColor = styleModel.activeColor ?? Colors.blue;
    final inactiveThumbColor = styleModel.inactiveColor ?? Colors.grey;
    final inactiveTrackColor =
        styleModel.inactiveTrackColor ?? Colors.grey[300]!;

    return Container(
      key: ValueKey(component.id),
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 12.0,
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 12.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (hasLabel)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    config.label ?? '',
                    style: TextStyle(
                      fontSize: styleModel.labelTextSize ?? 16,
                      color: styleModel.labelColor ?? Colors.white,
                    ),
                  ),
                  if (component.config?.isRequired == true)
                    const Text(
                      ' *',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          Switch(
            value: isSelected,
            onChanged: isDisabled
                ? null
                : (bool value) {
                    context.read<DynamicSwitchBloc>().add(
                      SwitchToggledEvent(value: value),
                    );
                  },
            activeColor: activeColor,
            inactiveThumbColor: inactiveThumbColor,
            inactiveTrackColor: inactiveTrackColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
