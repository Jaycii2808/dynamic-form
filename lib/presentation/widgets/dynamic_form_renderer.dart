import 'package:dynamic_form_bi/data/models/components/form_action_data_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/presentation/widgets/reused_widgets/reused_widget.dart';
import 'package:flutter/material.dart';

// IconData? mapIconNameToIconData(String name) {
//   return IconTypeEnum.fromString(name).toIconData();
// }

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
  final bool isSharedForm; // Add parameter to indicate shared form mode
  final String? currentPageId; // Add currentPageId parameter

  const DynamicFormRenderer({
    super.key,
    required this.component,
    this.page,
    this.onCompleted,
    this.onFieldChanged,
    this.onButtonAction,
    this.isSharedForm = false, // Default to false for backward compatibility
    this.currentPageId, // Add currentPageId parameter
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
        // final updateModel = ComponentValueUpdateModel.create(
        //   componentId: component.id,
        //   value: value,
        // );

        // context.read<DynamicFormBloc>().add(
        //   UpdateFormFieldEvent(componentId: component.id, value: updateModel),
        // );
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
      isSharedForm: widget.isSharedForm, // Pass the shared form flag
      currentPageId: widget.currentPageId, // Pass the currentPageId
      // Remove onComponentUpdate to disable config editing in shared forms
    );
  }
}
