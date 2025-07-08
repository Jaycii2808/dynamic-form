import 'package:dynamic_form_bi/core/enums/value_key_enum.dart';
import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/core/utils/style_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_config.dart';
import 'package:dynamic_form_bi/data/models/style_config.dart';
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
          ValueKeyEnum.value.key: state.component!.config[ValueKeyEnum.value.key],
          'selected': state.component!.config['selected'],
          ValueKeyEnum.currentState.key: state.component!.config[ValueKeyEnum.currentState.key],
        };
        if (state is DynamicSwitchSuccess) {
          onComplete(valueMap);
        } else if (state is DynamicSwitchError) {
          DialogUtils.showErrorDialog(context, state.errorMessage!);
        }else if (state is DynamicSwitchLoading || state is DynamicSwitchInitial) {
          debugPrint('Listener: Handling ${state.runtimeType} state');
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
            state.styleConfig!,
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
    StyleConfig styleConfig,
    InputConfig inputConfig,
    DynamicFormModel component,
  ) {
    final style = Map<String, dynamic>.from(component.style);
    final config = component.config;

    final hasLabel = config['label'] != null && config['label'].isNotEmpty;
    final isSelected = config['selected'] == true || config['value'] == true;
    final isDisabled = config['disabled'] == true;

    if (component.states?.containsKey(inputConfig.currentState) == true) {
      style.addAll(component.states![inputConfig.currentState]!['style']);
    }

    final activeColor = StyleUtils.parseColor(
      style['active_color'] ?? style['activeColor'] ?? '#6979F8',
    );
    final inactiveThumbColor = StyleUtils.parseColor(
      style['inactive_color'] ?? style['inactiveColor'] ?? '#CCCCCC',
    );
    final inactiveTrackColor = StyleUtils.parseColor(
      style['inactive_track_color'] ?? style['inactiveTrackColor'] ?? '#E5E5E5',
    );

    return Container(
      key: ValueKey(component.id),
      padding: StyleUtils.parsePadding(style['padding']),
      margin: StyleUtils.parsePadding(style['margin'] ?? '0 0 10 0'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: isSelected,
            onChanged: isDisabled
                ? null
                : (bool value) {
                    context.read<DynamicSwitchBloc>().add(SwitchToggledEvent(value: value));
                  },
            activeColor: activeColor,
            inactiveThumbColor: inactiveThumbColor,
            inactiveTrackColor: inactiveTrackColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          if (hasLabel)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                config['label'],
                style: TextStyle(
                  fontSize: (style['label_text_size'] as num?)?.toDouble() ?? 16,
                 // color: StyleUtils.parseColor(style['label_color'] ?? style['color']),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
