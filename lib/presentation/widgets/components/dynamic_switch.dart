import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
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
        final valueMap = {
          ValueKeyEnum.value.key:
              state.component!.config[ValueKeyEnum.value.key],
          'selected': state.component!.config['selected'],
          ValueKeyEnum.currentState.key:
              state.component!.config[ValueKeyEnum.currentState.key],
        };
        if (state is DynamicSwitchSuccess) {
          onComplete(valueMap);
        } else if (state is DynamicSwitchError) {
          DialogUtils.showErrorDialog(context, state.errorMessage!);
        } else if (state is DynamicSwitchLoading ||
            state is DynamicSwitchInitial) {
          debugPrint(
            'Listener: Handling ${state.runtimeType} state for id: ${state.component?.id}, value: ${state.component?.config[ValueKeyEnum.value.key]}',
          );
        } else {
          onComplete(valueMap);
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

  // StyleStatesModel? _getStateStyle(StatesModel? states, String key) {
  //   switch (key) {
  //     case 'base':
  //       return states?.base;
  //     case 'error':
  //       return states?.error;
  //     case 'success':
  //       return states?.success;
  //     case 'focused':
  //       return states?.focused;
  //     default:
  //       return null;
  //   }
  // }

  Widget _buildBody(
    BuildContext context,
    StyleModel styleModel,
    InputConfig inputConfig,
    DynamicFormModel component,
  ) {
    final styleModel = StyleModel.fromJson(component.style.toJson());
    final config = component.config;

    final hasLabel = config['label'] != null && config['label'].isNotEmpty;
    final isSelected = config['selected'] == true || config['value'] == true;
    final isDisabled = config['disabled'] == true;

    // final stateStyle = _getStateStyle(
    //   component.states,
    //   inputConfig.currentState,
    // );
    // If you want to merge stateStyle, you can create a merged StyleModel if needed

    final activeColor = StyleUtils.parseColor(
      styleModel.activeColor ?? '#6979F8',
    );
    final inactiveThumbColor = StyleUtils.parseColor(
      styleModel.inactiveColor ?? '#CCCCCC',
    );
    final inactiveTrackColor = StyleUtils.parseColor(
      styleModel.inactiveTrackColor ?? '#E5E5E5',
    );

    return Container(
      key: ValueKey(component.id),
      padding: StyleUtils.parsePadding(styleModel.padding),
      margin: StyleUtils.parsePadding(styleModel.margin ?? '0 0 10 0'),
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
                    config['label'],
                    style: TextStyle(
                      fontSize: styleModel.labelTextSize ?? 16,
                      // color: StyleUtils.parseColor(styleModel.labelColor),
                    ),
                  ),
                  if (component.config['is_required'] == true)
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
