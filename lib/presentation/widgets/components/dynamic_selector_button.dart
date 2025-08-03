import 'package:dynamic_form_bi/core/utils/dialog_utils.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/input_types/input_validation_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_selector_button/dynamic_selector_button_bloc.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_selector_button/dynamic_selector_button_event.dart';
import 'package:dynamic_form_bi/presentation/widgets/blocs/dynamic_selector_button/dynamic_selector_button_state.dart';
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
        if (state is DynamicSelectorButtonSuccess) {
          // Pass simple value instead of valueMap
          final simpleValue = state.component?.config?.value ?? false;
          onComplete(simpleValue);
        } else if (state is DynamicSelectorButtonError) {
          DialogUtils.showErrorDialog(context, state.errorMessage!);
        } else if (state is DynamicSelectorButtonLoading ||
            state is DynamicSelectorButtonInitial) {
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
    InputValidationModel inputConfig,
    DynamicFormModel component,
  ) {
    final config = component.config;
    final hasLabel = config?.label != null && config!.label!.isNotEmpty;
    final selected = config?.selected == true || config?.value == true;
    final isDisabled = inputConfig.disabled;

    return Container(
      key: Key(component.id),
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 8.0,
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 8.0,
      ),
      child: GestureDetector(
        onTap: isDisabled
            ? null
            : () {
                context.read<DynamicSelectorButtonBloc>().add(
                  SelectorButtonToggledEvent(isSelected: !selected),
                );
              },
        child: Row(
          children: [
            Container(
              width: (styleModel.iconSize ?? 20.0) * 0.8,
              height: (styleModel.iconSize ?? 20.0) * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: styleModel.backgroundColor ?? Colors.transparent,
                border: Border.all(
                  color: styleModel.borderColor ?? Colors.grey,
                  width: (styleModel.borderWidth ?? 2.0) * 0.8,
                ),
              ),
              child: selected
                  ? Icon(
                      Icons.check,
                      size: (styleModel.iconSize ?? 20.0) * 0.5,
                      color: Colors.white,
                    )
                  : null,
            ),
            if (hasLabel)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          config.label ?? '',
                          style: TextStyle(
                            fontSize: (styleModel.labelTextSize ?? 16) * 0.8,
                            color: styleModel.labelColor ?? Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (component.config?.isRequired == true)
                        const Text(
                          ' *',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
