import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/data/models/components/component_values_model.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/data/models/dynamic_form_multi/dynamic_form_multi_model.dart';
import 'package:dynamic_form_bi/data/models/style/style_model.dart';
import 'package:dynamic_form_bi/data/models/validation/validation_factory.dart';
import 'package:dynamic_form_bi/data/models/validation/base_validation.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Model for component values with specific fields instead of generic Map
///
/// Example usage:
/// ```dart
/// final componentValues = ComponentValuesDataModel(
///   textValue: 'John Doe',
///   emailValue: 'john@example.com',
///   phoneValue: '+1234567890',
///   dateValue: '2024-01-15',
///   checkboxValue: true,
///   numberValue: 25.5,
/// );
///
/// // Get value by type
/// final email = componentValues.getValueByType('email'); // Returns 'john@example.com'
///
/// // Set value by type
/// final updatedValues = componentValues.setValueByType('text', 'Jane Doe');
///
/// // Convert to ComponentValuesModel (no more fromJson/toJson!)
/// final componentValuesModel = componentValues.toComponentValuesModel();
///
/// // Create from ComponentValuesModel
/// final newComponentValues = ComponentValuesDataModel.fromComponentValuesModel(componentValuesModel);
///
/// // Check if has values
/// if (componentValues.hasValues) {
///   // Do something with values
/// }
/// ```
///
/// Test method to verify functionality:
/// ```dart
/// void testComponentValuesModel() {
///   final values = ComponentValuesDataModel(
///     textValue: 'Test text',
///     emailValue: 'test@example.com',
///     checkboxValue: true,
///     numberValue: 42.0,
///   );
///
///   // Test getValueByType
///   assert(values.getValueByType('text') == 'Test text');
///   assert(values.getValueByType('email') == 'test@example.com');
///   assert(values.getValueByType('checkbox') == true);
///   assert(values.getValueByType('number') == 42.0);
///
///   // Test setValueByType
///   final updated = values.setValueByType('text', 'Updated text');
///   assert(updated.textValue == 'Updated text');
///
///   // Test conversion methods
///   final componentModel = values.toComponentValuesModel();
///   final backToValues = ComponentValuesDataModel.fromComponentValuesModel(componentModel);
///   assert(backToValues.textValue == values.textValue);
/// }
/// ```
class ComponentValuesDataModel extends Equatable {
  final String? textValue;
  final String? emailValue;
  final String? phoneValue;
  final String? dateValue;
  final String? timeValue;
  final List<String>? tagsValue;
  final bool? checkboxValue;
  final String? radioValue;
  final List<String>? multiSelectValue;
  final double? numberValue;
  final String? fileValue;
  final String? textareaValue;
  final String? dropdownValue;
  final String? sliderValue;
  final String? ratingValue;
  final String? colorValue;
  final String? passwordValue;
  final String? urlValue;
  final String? searchValue;
  final String? autocompleteValue;

  const ComponentValuesDataModel({
    this.textValue,
    this.emailValue,
    this.phoneValue,
    this.dateValue,
    this.timeValue,
    this.tagsValue,
    this.checkboxValue,
    this.radioValue,
    this.multiSelectValue,
    this.numberValue,
    this.fileValue,
    this.textareaValue,
    this.dropdownValue,
    this.sliderValue,
    this.ratingValue,
    this.colorValue,
    this.passwordValue,
    this.urlValue,
    this.searchValue,
    this.autocompleteValue,
  });

  factory ComponentValuesDataModel.fromJson(Map<String, dynamic> json) {
    return ComponentValuesDataModel(
      textValue: json['text_value'] as String?,
      emailValue: json['email_value'] as String?,
      phoneValue: json['phone_value'] as String?,
      dateValue: json['date_value'] as String?,
      timeValue: json['time_value'] as String?,
      tagsValue: (json['tags_value'] as List<dynamic>?)?.cast<String>(),
      checkboxValue: json['checkbox_value'] as bool?,
      radioValue: json['radio_value'] as String?,
      multiSelectValue: (json['multi_select_value'] as List<dynamic>?)
          ?.cast<String>(),
      numberValue: (json['number_value'] as num?)?.toDouble(),
      fileValue: json['file_value'] as String?,
      textareaValue: json['textarea_value'] as String?,
      dropdownValue: json['dropdown_value'] as String?,
      sliderValue: json['slider_value'] as String?,
      ratingValue: json['rating_value'] as String?,
      colorValue: json['color_value'] as String?,
      passwordValue: json['password_value'] as String?,
      urlValue: json['url_value'] as String?,
      searchValue: json['search_value'] as String?,
      autocompleteValue: json['autocomplete_value'] as String?,
    );
  }


  factory ComponentValuesDataModel.empty() {
    return const ComponentValuesDataModel();
  }

  /// Get value by component type
  dynamic getValueByType(String componentType) {
    switch (componentType.toLowerCase()) {
      case 'text':
      case 'textfield':
        return textValue;
      case 'email':
        return emailValue;
      case 'phone':
      case 'tel':
        return phoneValue;
      case 'date':
        return dateValue;
      case 'time':
        return timeValue;
      case 'tags':
        return tagsValue;
      case 'checkbox':
        return checkboxValue;
      case 'radio':
        return radioValue;
      case 'multiselect':
      case 'multi_select':
        return multiSelectValue;
      case 'number':
      case 'numeric':
        return numberValue;
      case 'file':
      case 'fileupload':
        return fileValue;
      case 'textarea':
        return textareaValue;
      case 'dropdown':
      case 'select':
        return dropdownValue;
      case 'slider':
        return sliderValue;
      case 'rating':
        return ratingValue;
      case 'color':
        return colorValue;
      case 'password':
        return passwordValue;
      case 'url':
        return urlValue;
      case 'search':
        return searchValue;
      case 'autocomplete':
        return autocompleteValue;
      default:
        return null;
    }
  }

  /// Set value by component type
  ComponentValuesDataModel setValueByType(String componentType, dynamic value) {
    switch (componentType.toLowerCase()) {
      case 'text':
      case 'textfield':
        return copyWith(textValue: value as String?);
      case 'email':
        return copyWith(emailValue: value as String?);
      case 'phone':
      case 'tel':
        return copyWith(phoneValue: value as String?);
      case 'date':
        return copyWith(dateValue: value as String?);
      case 'time':
        return copyWith(timeValue: value as String?);
      case 'tags':
        return copyWith(tagsValue: value as List<String>?);
      case 'checkbox':
        return copyWith(checkboxValue: value as bool?);
      case 'radio':
        return copyWith(radioValue: value as String?);
      case 'multiselect':
      case 'multi_select':
        return copyWith(multiSelectValue: value as List<String>?);
      case 'number':
      case 'numeric':
        return copyWith(numberValue: value as double?);
      case 'file':
      case 'fileupload':
        return copyWith(fileValue: value as String?);
      case 'textarea':
        return copyWith(textareaValue: value as String?);
      case 'dropdown':
      case 'select':
        return copyWith(dropdownValue: value as String?);
      case 'slider':
        return copyWith(sliderValue: value as String?);
      case 'rating':
        return copyWith(ratingValue: value as String?);
      case 'color':
        return copyWith(colorValue: value as String?);
      case 'password':
        return copyWith(passwordValue: value as String?);
      case 'url':
        return copyWith(urlValue: value as String?);
      case 'search':
        return copyWith(searchValue: value as String?);
      case 'autocomplete':
        return copyWith(autocompleteValue: value as String?);
      default:
        return this;
    }
  }

  ComponentValuesDataModel copyWith({
    String? textValue,
    String? emailValue,
    String? phoneValue,
    String? dateValue,
    String? timeValue,
    List<String>? tagsValue,
    bool? checkboxValue,
    String? radioValue,
    List<String>? multiSelectValue,
    double? numberValue,
    String? fileValue,
    String? textareaValue,
    String? dropdownValue,
    String? sliderValue,
    String? ratingValue,
    String? colorValue,
    String? passwordValue,
    String? urlValue,
    String? searchValue,
    String? autocompleteValue,
  }) {
    return ComponentValuesDataModel(
      textValue: textValue ?? this.textValue,
      emailValue: emailValue ?? this.emailValue,
      phoneValue: phoneValue ?? this.phoneValue,
      dateValue: dateValue ?? this.dateValue,
      timeValue: timeValue ?? this.timeValue,
      tagsValue: tagsValue ?? this.tagsValue,
      checkboxValue: checkboxValue ?? this.checkboxValue,
      radioValue: radioValue ?? this.radioValue,
      multiSelectValue: multiSelectValue ?? this.multiSelectValue,
      numberValue: numberValue ?? this.numberValue,
      fileValue: fileValue ?? this.fileValue,
      textareaValue: textareaValue ?? this.textareaValue,
      dropdownValue: dropdownValue ?? this.dropdownValue,
      sliderValue: sliderValue ?? this.sliderValue,
      ratingValue: ratingValue ?? this.ratingValue,
      colorValue: colorValue ?? this.colorValue,
      passwordValue: passwordValue ?? this.passwordValue,
      urlValue: urlValue ?? this.urlValue,
      searchValue: searchValue ?? this.searchValue,
      autocompleteValue: autocompleteValue ?? this.autocompleteValue,
    );
  }

  /// Convert to Map for compatibility with existing code
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    if (textValue != null) map['text_value'] = textValue;
    if (emailValue != null) map['email_value'] = emailValue;
    if (phoneValue != null) map['phone_value'] = phoneValue;
    if (dateValue != null) map['date_value'] = dateValue;
    if (timeValue != null) map['time_value'] = timeValue;
    if (tagsValue != null) map['tags_value'] = tagsValue;
    if (checkboxValue != null) map['checkbox_value'] = checkboxValue;
    if (radioValue != null) map['radio_value'] = radioValue;
    if (multiSelectValue != null) map['multi_select_value'] = multiSelectValue;
    if (numberValue != null) map['number_value'] = numberValue;
    if (fileValue != null) map['file_value'] = fileValue;
    if (textareaValue != null) map['textarea_value'] = textareaValue;
    if (dropdownValue != null) map['dropdown_value'] = dropdownValue;
    if (sliderValue != null) map['slider_value'] = sliderValue;
    if (ratingValue != null) map['rating_value'] = ratingValue;
    if (colorValue != null) map['color_value'] = colorValue;
    if (passwordValue != null) map['password_value'] = passwordValue;
    if (urlValue != null) map['url_value'] = urlValue;
    if (searchValue != null) map['search_value'] = searchValue;
    if (autocompleteValue != null) {
      map['autocomplete_value'] = autocompleteValue;
    }

    return map;
  }


  @override
  List<Object?> get props => [
    textValue,
    emailValue,
    phoneValue,
    dateValue,
    timeValue,
    tagsValue,
    checkboxValue,
    radioValue,
    multiSelectValue,
    numberValue,
    fileValue,
    textareaValue,
    dropdownValue,
    sliderValue,
    ratingValue,
    colorValue,
    passwordValue,
    urlValue,
    searchValue,
    autocompleteValue,
  ];

  @override
  String toString() {
    return 'ComponentValuesDataModel(textValue: $textValue, emailValue: $emailValue, phoneValue: $phoneValue, dateValue: $dateValue, timeValue: $timeValue, tagsValue: $tagsValue, checkboxValue: $checkboxValue, radioValue: $radioValue, multiSelectValue: $multiSelectValue, numberValue: $numberValue, fileValue: $fileValue, textareaValue: $textareaValue, dropdownValue: $dropdownValue, sliderValue: $sliderValue, ratingValue: $ratingValue, colorValue: $colorValue, passwordValue: $passwordValue, urlValue: $urlValue, searchValue: $searchValue, autocompleteValue: $autocompleteValue)';
  }

  /// Convert to ComponentValuesModel for compatibility with existing code
  ComponentValuesModel toComponentValuesModel() {
    final Map<String, dynamic> values = {};

    if (textValue != null) {
      values['textarea_value_001'] = textValue;
    }
    if (emailValue != null) {
      values['email_value_001'] = emailValue;
    }
    if (phoneValue != null) {
      values['phone_value_001'] = phoneValue;
    }
    if (dateValue != null) {
      values['datetime_picker_date_only_001'] = dateValue;
    }
    if (timeValue != null) {
      values['time_value_001'] = timeValue;
    }
    if (tagsValue != null) {
      values['tags_value_001'] = tagsValue;
    }
    if (checkboxValue != null) {
      values['selector_with_label_001'] = checkboxValue;
    }
    if (radioValue != null) {
      values['radio_value_001'] = radioValue;
    }
    if (multiSelectValue != null) {
      values['multi_select_value_001'] = multiSelectValue;
    }
    if (numberValue != null) {
      values['number_value_001'] = numberValue;
    }
    if (fileValue != null) {
      values['file_value_001'] = fileValue;
    }
    if (textareaValue != null) {
      values['textarea_value_001'] = textareaValue;
    }
    if (dropdownValue != null) {
      values['dropdown_value_001'] = dropdownValue;
    }
    if (sliderValue != null) {
      values['slider_value_001'] = sliderValue;
    }
    if (ratingValue != null) {
      values['rating_value_001'] = ratingValue;
    }
    if (colorValue != null) {
      values['color_value_001'] = colorValue;
    }
    if (passwordValue != null) {
      values['password_value_001'] = passwordValue;
    }
    if (urlValue != null) {
      values['url_value_001'] = urlValue;
    }
    if (searchValue != null) {
      values['search_value_001'] = searchValue;
    }
    if (autocompleteValue != null) {
      values['autocomplete_value_001'] = autocompleteValue;
    }

    return ComponentValuesModel(values: values);
  }

  /// Create from ComponentValuesModel for easy conversion
  factory ComponentValuesDataModel.fromComponentValuesModel(
    ComponentValuesModel model,
  ) {
    return ComponentValuesDataModel(
      textValue: model.getValue('textarea_value_001')?.toString(),
      emailValue: model.getValue('email_value_001')?.toString(),
      phoneValue: model.getValue('phone_value_001')?.toString(),
      dateValue: model.getValue('datetime_picker_date_only_001')?.toString(),
      timeValue: model.getValue('time_value_001')?.toString(),
      tagsValue: model.getValue('tags_value_001') is List
          ? (model.getValue('tags_value_001') as List).cast<String>()
          : null,
      checkboxValue: model.getValue('selector_with_label_001') as bool?,
      radioValue: model.getValue('radio_value_001')?.toString(),
      multiSelectValue: model.getValue('multi_select_value_001') is List
          ? (model.getValue('multi_select_value_001') as List).cast<String>()
          : null,
      numberValue: model.getValue('number_value_001') is num
          ? (model.getValue('number_value_001') as num).toDouble()
          : null,
      fileValue: model.getValue('file_value_001')?.toString(),
      textareaValue: model.getValue('textarea_value_001')?.toString(),
      dropdownValue: model.getValue('dropdown_value_001')?.toString(),
      sliderValue: model.getValue('slider_value_001')?.toString(),
      ratingValue: model.getValue('rating_value_001')?.toString(),
      colorValue: model.getValue('color_value_001')?.toString(),
      passwordValue: model.getValue('password_value_001')?.toString(),
      urlValue: model.getValue('url_value_001')?.toString(),
      searchValue: model.getValue('search_value_001')?.toString(),
      autocompleteValue: model.getValue('autocomplete_value_001')?.toString(),
    );
  }

  /// Check if this model has any values
  bool get hasValues {
    return textValue != null ||
        emailValue != null ||
        phoneValue != null ||
        dateValue != null ||
        timeValue != null ||
        tagsValue != null ||
        checkboxValue != null ||
        radioValue != null ||
        multiSelectValue != null ||
        numberValue != null ||
        fileValue != null ||
        textareaValue != null ||
        dropdownValue != null ||
        sliderValue != null ||
        ratingValue != null ||
        colorValue != null ||
        passwordValue != null ||
        urlValue != null ||
        searchValue != null ||
        autocompleteValue != null;
  }
}

/// Model for saved form data structure
class SavedFormDataModel extends Equatable {
  final String formId;
  final List<SavedFormPageDataModel> pages;
  final ComponentValuesDataModel componentValues;

  const SavedFormDataModel({
    required this.formId,
    required this.pages,
    required this.componentValues,
  });

  factory SavedFormDataModel.fromJson(Map<String, dynamic> json) {
    final List<SavedFormPageDataModel> pages = [];
    if (json['pages'] != null) {
      for (final pageJson in json['pages'] as List<dynamic>) {
        pages.add(
          SavedFormPageDataModel.fromJson(pageJson as Map<String, dynamic>),
        );
      }
    }

    return SavedFormDataModel(
      formId: json['form_id'] ?? '',
      pages: pages,
      componentValues: json['component_values'] != null
          ? ComponentValuesDataModel.fromJson(json['component_values'])
          : ComponentValuesDataModel.empty(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'form_id': formId,
      'pages': pages.map((page) => page.toJson()).toList(),
      'component_values': componentValues.toJson(),
    };
  }

  @override
  List<Object?> get props => [formId, pages, componentValues];
}

/// Model for saved form page data
class SavedFormPageDataModel extends Equatable {
  final String pageId;
  final String title;
  final int order;
  final bool showNextButton;
  final bool showPreviousButton;
  final bool showSubmitButton;
  final List<SavedFormComponentDataModel> components;

  const SavedFormPageDataModel({
    required this.pageId,
    required this.title,
    required this.order,
    this.showNextButton = false,
    this.showPreviousButton = false,
    this.showSubmitButton = false,
    required this.components,
  });

  factory SavedFormPageDataModel.fromJson(Map<String, dynamic> json) {
    final List<SavedFormComponentDataModel> components = [];
    if (json['components'] != null) {
      for (final componentJson in json['components'] as List<dynamic>) {
        components.add(
          SavedFormComponentDataModel.fromJson(
            componentJson as Map<String, dynamic>,
          ),
        );
      }
    }

    return SavedFormPageDataModel(
      pageId: json['pageId'] ?? '',
      title: json['title'] ?? '',
      order: json['order'] ?? 0,
      showNextButton: json['show_next_button'] ?? false,
      showPreviousButton: json['show_previous_button'] ?? false,
      showSubmitButton: json['show_submit_button'] ?? false,
      components: components,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pageId': pageId,
      'title': title,
      'order': order,
      'show_next_button': showNextButton,
      'show_previous_button': showPreviousButton,
      'show_submit_button': showSubmitButton,
      'components': components.map((component) => component.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    pageId,
    title,
    order,
    showNextButton,
    showPreviousButton,
    showSubmitButton,
    components,
  ];
}

/// Model for saved form component data
class SavedFormComponentDataModel extends Equatable {
  final String id;
  final FormTypeEnum type;
  final int order;
  final ConfigModel config;
  final StyleModel style;
  final BaseValidation? validation;
  final List<SavedFormComponentDataModel>? children;

  const SavedFormComponentDataModel({
    required this.id,
    required this.type,
    required this.order,
    required this.config,
    required this.style,
    this.validation,
    this.children,
  });

  factory SavedFormComponentDataModel.fromJson(Map<String, dynamic> json) {
    final List<SavedFormComponentDataModel>? children = json['children'] != null
        ? (json['children'] as List<dynamic>)
              .map(
                (childJson) => SavedFormComponentDataModel.fromJson(
                  childJson as Map<String, dynamic>,
                ),
              )
              .toList()
        : null;

    return SavedFormComponentDataModel(
      id: json['id'] ?? '',
      type: FormTypeEnum.fromJson(json['type']),
      order: json['order'] ?? 0,
      config: ConfigModel.fromJson(json['config'] ?? {}),
      style: StyleModel.fromJson(json['style'] ?? {}),
      validation: json['validation'] != null
          ? ValidationFactory.fromJson(json['validation'])
          : null,
      children: children,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toJson(),
      'order': order,
      'config': config.toJson(),
      'style': style.toJson(),
      'validation': validation?.toJson(),
      if (children != null)
        'children': children!.map((child) => child.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    type,
    order,
    config,
    style,
    validation,
    children,
  ];

  /// Create from DynamicFormModel for easy conversion
  factory SavedFormComponentDataModel.fromDynamicFormModel(
    DynamicFormModel model,
  ) {
    final List<SavedFormComponentDataModel>? children = model.children
        ?.map(
          (child) => SavedFormComponentDataModel.fromDynamicFormModel(child),
        )
        .toList();

    return SavedFormComponentDataModel(
      id: model.id,
      type: model.type,
      order: model.order,
      config: model.config ?? const ConfigModel(),
      style: model.style,
      validation: model.validation,
      children: children,
    );
  }

  /// Convert to DynamicFormModel for easy conversion back
  DynamicFormModel toDynamicFormModel() {
    final List<DynamicFormModel>? children = this.children
        ?.map((child) => child.toDynamicFormModel())
        .toList();

    return DynamicFormModel(
      id: id,
      type: type,
      order: order,
      config: config,
      style: style,
      inputTypes: null,
      variants: null,
      states: null,
      validation: validation,
      children: children,
    );
  }
}

/// Helper class for creating saved form data
class SavedFormDataBuilder {
  static SavedFormDataModel createFromMultiPageForm({
    required String formId,
    required List<FormForMultiPageModel> pages,
    required Map<String, dynamic> componentValues,
  }) {
    debugPrint('🔍 [SavedFormDataBuilder] Creating from multi-page form');
    debugPrint('🔍 [SavedFormDataBuilder] Component values: $componentValues');

    final List<SavedFormPageDataModel> savedPages = [];

    for (final page in pages) {
      final List<SavedFormComponentDataModel> savedComponents = [];

      for (final component in page.components) {
        final List<SavedFormComponentDataModel>? savedChildren = component
            .children
            ?.map(
              (child) => SavedFormComponentDataModel(
                id: child.id,
                type: child.type,
                order: child.order,
                config: child.config,
                style: child.style,
                validation: child.validation,
                children: null,
              ),
            )
            .toList();

        // Update component config with new values if available
        ConfigModel updatedConfig = component.config;
        if (componentValues.containsKey(component.id)) {
          final newValue = componentValues[component.id];
          debugPrint(
            '🔍 [SavedFormDataBuilder] Updating ${component.id}: ${component.config.value} -> $newValue',
          );
          updatedConfig = component.config.copyWith(
            value: newValue,
          );
        } else {
          debugPrint(
            '🔍 [SavedFormDataBuilder] No update for ${component.id}: ${component.config.value}',
          );
        }

        savedComponents.add(
          SavedFormComponentDataModel(
            id: component.id,
            type: component.type,
            order: component.order,
            config: updatedConfig,
            style: component.style,
            validation: component.validation,
            children: savedChildren,
          ),
        );
      }

      savedPages.add(
        SavedFormPageDataModel(
          pageId: page.pageId,
          title: page.title,
          order: page.order,
          showNextButton: page.showNextButton,
          showPreviousButton: page.showPreviousButton,
          showSubmitButton: page.showSubmitButton,
          components: savedComponents,
        ),
      );
    }

    return SavedFormDataModel(
      formId: formId,
      pages: savedPages,
      componentValues: ComponentValuesDataModel.fromJson(componentValues),
    );
  }

  static SavedFormDataModel createFromDynamicFormPages({
    required String formId,
    required List<DynamicFormPageModel> pages,
    required Map<String, dynamic> componentValues,
  }) {
    final List<SavedFormPageDataModel> savedPages = [];

    for (final page in pages) {
      final List<SavedFormComponentDataModel> savedComponents = [];

      for (final component in page.components) {
        savedComponents.add(
          SavedFormComponentDataModel.fromDynamicFormModel(component),
        );
      }

      savedPages.add(
        SavedFormPageDataModel(
          pageId: page.pageId,
          title: page.title,
          order: page.order,
          showNextButton: true, // Default values for dynamic form pages
          showPreviousButton: true,
          showSubmitButton: false,
          components: savedComponents,
        ),
      );
    }

    return SavedFormDataModel(
      formId: formId,
      pages: savedPages,
      componentValues: ComponentValuesDataModel.fromJson(componentValues),
    );
  }
}

/// Model for custom form data -
/// This model handles both single-page and multi-page form data formats
/// and provides easy access to form structure and component counts.
///
/// Example usage:
/// ```dart
/// // Create from JSON (handles both formats automatically)
/// final customData = CustomFormDataModel.fromJson(jsonData);
///
/// // Check if multi-page
/// if (customData.isMultiPage) {
///   print('Multi-page form with ${customData.totalComponentsCount} components');
///   print('Form ID: ${customData.formId}');
///
///   // Access pages
///   for (final page in customData.pages) {
///     print('Page: ${page.title} with ${page.components.length} components');
///   }
///
///   // Access component values
///   final values = customData.componentValues;
///   if (values.hasValues) {
///     final componentModel = values.toComponentValuesModel();
///     // Use componentModel...
///   }
/// } else {
///   print('Single-page form with ${customData.totalComponentsCount} components');
///
///   // Access single page
///   final singlePage = customData.singlePage;
///   if (singlePage != null) {
///     print('Page: ${singlePage.title}');
///   }
/// }
///
/// // Create from existing models
/// final multiPageData = SavedFormDataModel(...);
/// final customData = CustomFormDataModel.fromSavedFormDataModel(multiPageData);
///
/// final singlePageData = DynamicFormPageModel(...);
/// final customData = CustomFormDataModel.fromDynamicFormPageModel(singlePageData);
/// ```
class CustomFormDataModel extends Equatable {
  final SavedFormDataModel? multiPageData;
  final DynamicFormPageModel? singlePageData;
  final bool isMultiPage;

  const CustomFormDataModel({
    this.multiPageData,
    this.singlePageData,
    required this.isMultiPage,
  });

  /// Create from JSON - handles both formats automatically
  factory CustomFormDataModel.fromJson(Map<String, dynamic> json) {
    // Check if it's multi-page format
    if (json.containsKey('pages')) {
      return CustomFormDataModel(
        multiPageData: SavedFormDataModel.fromJson(json),
        singlePageData: null,
        isMultiPage: true,
      );
    } else {
      // Single-page format
      return CustomFormDataModel(
        multiPageData: null,
        singlePageData: DynamicFormPageModel.fromJson(json),
        isMultiPage: false,
      );
    }
  }

  /// Convert to JSON format
  Map<String, dynamic> toJson() {
    if (isMultiPage && multiPageData != null) {
      return multiPageData!.toJson();
    } else if (!isMultiPage && singlePageData != null) {
      return singlePageData!.toJson();
    } else {
      return {};
    }
  }

  /// Get total component count across all pages
  int get totalComponentsCount {
    if (isMultiPage && multiPageData != null) {
      int total = 0;
      for (final page in multiPageData!.pages) {
        total += page.components.length;
      }
      return total;
    } else if (!isMultiPage && singlePageData != null) {
      return singlePageData!.components.length;
    } else {
      return 0;
    }
  }

  /// Get form ID
  String get formId {
    if (isMultiPage && multiPageData != null) {
      return multiPageData!.formId;
    } else {
      return '';
    }
  }

  /// Get component values
  ComponentValuesDataModel get componentValues {
    if (isMultiPage && multiPageData != null) {
      return multiPageData!.componentValues;
    } else {
      return ComponentValuesDataModel.empty();
    }
  }

  /// Check if form has any data
  bool get hasData {
    return (isMultiPage && multiPageData != null) ||
        (!isMultiPage && singlePageData != null);
  }

  /// Get pages for multi-page format
  List<SavedFormPageDataModel> get pages {
    if (isMultiPage && multiPageData != null) {
      return multiPageData!.pages;
    } else {
      return [];
    }
  }

  /// Get single page for single-page format
  DynamicFormPageModel? get singlePage {
    if (!isMultiPage && singlePageData != null) {
      return singlePageData;
    } else {
      return null;
    }
  }

  /// Create empty model
  factory CustomFormDataModel.empty() {
    return const CustomFormDataModel(
      multiPageData: null,
      singlePageData: null,
      isMultiPage: false,
    );
  }

  /// Create from SavedFormDataModel (multi-page)
  factory CustomFormDataModel.fromSavedFormDataModel(SavedFormDataModel data) {
    return CustomFormDataModel(
      multiPageData: data,
      singlePageData: null,
      isMultiPage: true,
    );
  }

  /// Create from DynamicFormPageModel (single-page)
  factory CustomFormDataModel.fromDynamicFormPageModel(
    DynamicFormPageModel data,
  ) {
    return CustomFormDataModel(
      multiPageData: null,
      singlePageData: data,
      isMultiPage: false,
    );
  }

  @override
  List<Object?> get props => [multiPageData, singlePageData, isMultiPage];

  @override
  String toString() {
    return 'CustomFormDataModel(isMultiPage: $isMultiPage, totalComponents: $totalComponentsCount)';
  }
}
