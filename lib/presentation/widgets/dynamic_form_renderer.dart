import 'package:dynamic_form_bi/core/enums/icon_type_enum.dart';
import 'package:dynamic_form_bi/data/models/components/component_value_update_model.dart';
import 'package:dynamic_form_bi/data/models/components/form_action_data_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form/dynamic_form_bloc.dart';
import 'package:dynamic_form_bi/presentation/blocs/dynamic_form/dynamic_form_event.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

IconData? mapIconNameToIconData(String name) {
  return IconTypeEnum.fromString(name).toIconData();
}

class FormContainer extends StatelessWidget {
  final List<Widget> children;

  const FormContainer({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: FocusScope(autofocus: false, child: Column(children: children)),
    );
  }
}

class DynamicFormRenderer extends StatefulWidget {
  final DynamicFormModel component;
  final DynamicFormPageModel? page;
  final VoidCallback? onCompleted;
  final Function(String componentId, dynamic value)? onFieldChanged;
  final Function(String action, FormActionDataModel? data)? onButtonAction;

  const DynamicFormRenderer({
    super.key,
    required this.component,
    this.page,
    this.onCompleted,
    this.onFieldChanged,
    this.onButtonAction,
  });

  @override
  State<DynamicFormRenderer> createState() => _DynamicFormRendererState();
}

class _DynamicFormRendererState extends State<DynamicFormRenderer> {
  void handleFormFieldUpdate(
    BuildContext context,
    DynamicFormModel component,
    dynamic value,
  ) {
    if (value != null) {
      if (widget.onFieldChanged != null) {
        widget.onFieldChanged!(component.id, value);
      } else {
        // Create ComponentValueUpdateModel from simple value
        final updateModel = ComponentValueUpdateModel.create(
          componentId: component.id,
          value: value,
        );

        context.read<DynamicFormBloc>().add(
          UpdateFormFieldEvent(componentId: component.id, value: updateModel),
        );
      }
    } else {
      debugPrint("Error: No value received");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReusedWidget.buildFormComponent(
      component: widget.component,
      onComponentValueChange: (componentId, value) =>
          handleFormFieldUpdate(context, widget.component, value),
      onButtonAction: widget.onButtonAction,
    );
  }
}
