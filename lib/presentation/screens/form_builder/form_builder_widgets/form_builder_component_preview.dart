import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:flutter/material.dart';

Widget buildComponentPreview(DynamicFormModel component) {
  switch (component.type) {
    case FormTypeEnum.textFieldFormType:
      return _buildTextFieldPreview(component);
    case FormTypeEnum.textAreaFormType:
      return _buildTextAreaPreview(component);
    case FormTypeEnum.switchFormType:
      return _buildSwitchPreview(component);
    case FormTypeEnum.selectorButtonFormType:
      return _buildSelectorButtonPreview(component);
    case FormTypeEnum.dateTimePickerFormType:
      return _buildDateTimePickerPreview(component);
    case FormTypeEnum.dateTimeRangePickerFormType:
      return _buildDateTimeRangePickerPreview(component);
    case FormTypeEnum.dropdownFormType:
      return _buildDropdownPreview(component);
    case FormTypeEnum.buttonFormType:
      return _buildButtonPreview(component);
    default:
      return _buildDefaultPreview(component);
  }
}

Widget _buildTextFieldPreview(DynamicFormModel component) {
  return Container(
    height: 40,
    decoration: BoxDecoration(
      color: Colors.grey[800],
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: Colors.grey[600]!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (component.config?.label != null)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 2),
            child: Text(
              component.config!.label!,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 8,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        Expanded(
          child: Row(
            children: [
              if (component.config?.icon != null) ...[
                const SizedBox(width: 8),
                Icon(Icons.mail, color: Colors.grey[400], size: 10),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  component.config?.placeholder ?? 'Text Field',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 9,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildTextAreaPreview(DynamicFormModel component) {
  return Container(
    height: 100,
    decoration: BoxDecoration(
      color: Colors.grey[800],
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: Colors.grey[600]!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (component.config?.label != null)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 2),
            child: Text(
              component.config!.label!,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 8,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              component.config?.placeholder ?? 'Text Area',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 9,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildSwitchPreview(DynamicFormModel component) {
  return Container(
    height: 40,
    decoration: BoxDecoration(
      color: Colors.grey[800],
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: Colors.grey[600]!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            children: [
              const SizedBox(width: 8),
              const Icon(Icons.toggle_on, color: Colors.blue, size: 12),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  component.config!.label!,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildSelectorButtonPreview(DynamicFormModel component) {
  return Container(
    height: 40,
    decoration: BoxDecoration(
      color: Colors.grey[800],
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: Colors.grey[600]!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            children: [
              const SizedBox(width: 8),
              const Icon(
                Icons.radio_button_checked,
                color: Colors.blue,
                size: 12,
              ),
              const SizedBox(width: 8),
              if (component.config?.label != null)
                Expanded(
                  child: Text(
                    component.config!.label!,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildDateTimePickerPreview(DynamicFormModel component) {
  return Container(
    height: 40,
    decoration: BoxDecoration(
      color: Colors.grey[800],
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: Colors.grey[600]!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (component.config?.label != null)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 2),
            child: Text(
              component.config!.label!,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 8,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        Expanded(
          child: Row(
            children: [
              const SizedBox(width: 8),
              const Icon(Icons.calendar_today, color: Colors.blue, size: 12),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  component.config?.placeholder ?? 'Select Date',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 9,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildDateTimeRangePickerPreview(DynamicFormModel component) {
  return Container(
    height: 40,
    decoration: BoxDecoration(
      color: Colors.grey[800],
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: Colors.grey[600]!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (component.config?.label != null)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 2),
            child: Text(
              component.config!.label!,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 8,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        Expanded(
          child: Row(
            spacing: 8,
            children: [
              const Icon(Icons.date_range, color: Colors.blue, size: 12),
              Expanded(
                child: Text(
                  component.config?.placeholder ?? 'Select Date Range',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 9,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildDropdownPreview(DynamicFormModel component) {
  return Container(
    height: 40,
    decoration: BoxDecoration(
      color: Colors.grey[800],
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: Colors.grey[600]!),
    ),
    child: Row(
      children: [
        const SizedBox(width: 8),
        const Icon(Icons.arrow_drop_down, color: Colors.blue, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            component.config?.placeholder ?? 'Select an option',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
      ],
    ),
  );
}

Widget _buildButtonPreview(DynamicFormModel component) {
  return Container(
    height: 40,
    decoration: BoxDecoration(
      color: Colors.grey[800],
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: Colors.grey[600]!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            children: [
              const SizedBox(width: 8),
              const Icon(Icons.send, color: Colors.blue, size: 12),
              const SizedBox(width: 8),
              if (component.config?.label != null)
                Expanded(
                  child: Text(
                    component.config!.label!,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildDefaultPreview(DynamicFormModel component) {
  return Container(
    height: 32,
    decoration: BoxDecoration(
      color: Colors.grey[800],
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: Colors.grey[600]!),
    ),
    child: const Center(
      child: Text(
        'Component',
        style: TextStyle(color: Colors.grey, fontSize: 10),
      ),
    ),
  );
}
