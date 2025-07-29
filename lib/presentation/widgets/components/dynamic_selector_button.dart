import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/components/input_config.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_selector_button/dynamic_selector_button_bloc.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_selector_button/dynamic_selector_button_event.dart';
import 'package:dynamic_form_bi/presentation/bloc/dynamic_selector_button/dynamic_selector_button_state.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DynamicSelectorButton extends StatelessWidget {
  final DynamicFormModel component;
  final Function(dynamic) onComplete;

  const DynamicSelectorButton({
    super.key,
    required this.component,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DynamicSelectorButtonBloc, DynamicSelectorButtonState>(
      listener: (context, state) {
        final valueMap = {
          'value': state.component?.config?.value,
          'selected': state.component?.config?.selected,
          'current_state': state.component?.config?.currentState ?? StatesEnum.base,
        };
        if (state is DynamicSelectorButtonSuccess) {
          onComplete(valueMap);
        } else if (state is DynamicSelectorButtonError) {
          DialogUtils.showErrorDialog(context, state.errorMessage!);
        } else if (state is DynamicSelectorButtonLoading ||
            state is DynamicSelectorButtonInitial) {
          debugPrint(
            'Listener: Handling ${state.runtimeType} state for id: ${state.component?.id}, value: ${state.component?.config?.value}',
          );
        } else {
          onComplete(valueMap);
          DialogUtils.showErrorDialog(context, "Another Error");
        }
      },
      builder: (context, state) {
        if (state is DynamicSelectorButtonLoading ||
            state is DynamicSelectorButtonInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DynamicSelectorButtonSuccess) {
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
    InputConfig inputConfig,
    DynamicFormModel component,
  ) {
    final config = component.config;
    final hasLabel = config?.label != null && config!.label!.isNotEmpty;
    final selected = config?.selected == true || config?.value == true;
    final isDisabled = inputConfig.disabled;

    return Container(
      key: Key(component.id),
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      margin: const EdgeInsets.only(bottom: 10.0),
      child: GestureDetector(
        onTap: isDisabled
            ? null
            : () {
                context.read<DynamicSelectorButtonBloc>().add(
                  SelectorButtonToggledEvent(isSelected: !selected),
                );
              },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: styleModel.iconSize ?? 20.0,
              height: styleModel.iconSize ?? 20.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: styleModel.backgroundColor ?? Colors.transparent,
                border: Border.all(
                  color: styleModel.borderColor ?? Colors.grey,
                  width: styleModel.borderWidth ?? 2.0,
                ),
              ),
              child: selected
                  ? Icon(
                      Icons.check,
                      size: (styleModel.iconSize ?? 20.0) * 0.6,
                      color: Colors.white,
                    )
                  : null,
            ),
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
          ],
        ),
      ),
    );
  }
}
