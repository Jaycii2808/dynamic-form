import 'package:dynamic_form_bi/data/models/dynamic_form/dynamic_form_model.dart';
import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
import 'package:dynamic_form_bi/core/enums/button_action_enum.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class FormBuilderModel extends Equatable {
  final String formId;
  final String name;
  final List<FormBuilderPageModel> pages;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FormBuilderModel({
    required this.formId,
    required this.name,
    required this.pages,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FormBuilderModel.empty() {
    final now = DateTime.now();
    return FormBuilderModel(
      formId: 'form_${now.millisecondsSinceEpoch}',
      name: 'Untitled',
      pages: const [
        FormBuilderPageModel(
          pageId: 'page_1',
          title: 'Form Page',
          order: 1,
          showPreviousButton: false,
          showNextButton: false,
          showSubmitButton: true,
          components: [],
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );
  }

  factory FormBuilderModel.fromComponents({
    required String name,
    required List<DynamicFormModel> components,
  }) {
    final now = DateTime.now();
    return FormBuilderModel(
      formId: 'form_${now.millisecondsSinceEpoch}',
      name: name,
      pages: [
        FormBuilderPageModel(
          pageId: 'page_1',
          title: 'Form Page',
          order: 1,
          showPreviousButton: false,
          showNextButton: false,
          showSubmitButton: true,
          components: components,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );
  }

  FormBuilderModel copyWith({
    String? formId,
    String? name,
    List<FormBuilderPageModel>? pages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FormBuilderModel(
      formId: formId ?? this.formId,
      name: name ?? this.name,
      pages: pages ?? this.pages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Convert to JSON format for preview screen
  Map<String, dynamic> toPreviewJson() {
    return {
      'formId': formId,
      'name': name,
      'pages': pages.map((page) => page.toJson()).toList(),
    };
  }

  /// Convert to preview page format
  Map<String, dynamic> toPreviewPage() {
    return {
      'formId': formId,
      'name': name,
      'pages': pages.map((page) => page.toJson()).toList(),
    };
  }

  /// Convert to multi-page JSON format with automatic navigation
  Map<String, dynamic> toExportMultiPageJson() {
    debugPrint('🔄 [FormBuilderModel] Converting form to multi-page JSON');
    debugPrint('🔄 [FormBuilderModel] Original pages count: ${pages.length}');

    // Create a copy of pages and add submit page
    final List<FormBuilderPageModel> pagesWithSubmit = List.from(pages);

    // Add submit page if not already exists
    final submitPageId = 'submit_page_${DateTime.now().millisecondsSinceEpoch}';
    final submitPage = FormBuilderPageModel(
      pageId: submitPageId,
      title: 'Submit Form',
      order: pagesWithSubmit.length + 1,
      showPreviousButton: true,
      showNextButton: false,
      showSubmitButton: true,
      components: const [], // Empty components for submit page
    );

    pagesWithSubmit.add(submitPage);

    debugPrint(
      '🔄 [FormBuilderModel] Added submit page, total pages: ${pagesWithSubmit.length}',
    );

    return {
      'formId': formId,
      'name': name,
      'pages': pagesWithSubmit
          .map((page) => _convertPageToMultiPageFormat(page, pagesWithSubmit))
          .toList(),
    };
  }

  /// Convert page to multi-page format with automatic navigation buttons
  Map<String, dynamic> _convertPageToMultiPageFormat(
    FormBuilderPageModel page,
    List<FormBuilderPageModel> allPages,
  ) {
    debugPrint('🔄 [FormBuilderModel] Converting page: ${page.title}');
    debugPrint(
      '🔄 [FormBuilderModel] Page components count: ${page.components.length}',
    );

    final pageIndex = allPages.indexOf(page);
    final isFirstPage = pageIndex == 0;
    final isLastPage = pageIndex == allPages.length - 1;

    // Convert components and add navigation buttons
    final convertedComponents = <Map<String, dynamic>>[];

    // Add main components (excluding navigation buttons)
    for (final component in page.components) {
      debugPrint(
        '🔄 [FormBuilderModel] Processing component: ${component.id} - ${component.type}',
      );
      if (component.type != FormTypeEnum.buttonFormType ||
          (component.config?.action != ButtonAction.nextPage.value &&
              component.config?.action != ButtonAction.previousPage.value &&
              component.config?.action != ButtonAction.submitForm.value)) {
        debugPrint(
          '🔄 [FormBuilderModel] Converting component: ${component.id}',
        );
        convertedComponents.add(_convertComponentToMultiPageFormat(component));
      } else {
        debugPrint(
          '🔄 [FormBuilderModel] Skipping navigation button: ${component.id}',
        );
      }
    }

    debugPrint(
      '🔄 [FormBuilderModel] Converted ${convertedComponents.length} components',
    );

    // Add navigation buttons based on page position
    if (!isFirstPage) {
      convertedComponents.add(
        _createNavigationButton(
          'previous',
          ButtonAction.previousPage.value,
          'Back',
          pageIndex > 0 ? allPages[pageIndex - 1].pageId : '',
        ),
      );
    }

    if (!isLastPage) {
      convertedComponents.add(
        _createNavigationButton(
          'next',
          ButtonAction.nextPage.value,
          'Next',
          pageIndex < allPages.length - 1 ? allPages[pageIndex + 1].pageId : '',
        ),
      );
    }
    // Remove submit button from last content page since we have dedicated submit page

    final result = {
      'pageId': page.pageId,
      'title': page.title,
      'order': page.order,
      'show_previous_button': !isFirstPage,
      'show_next_button': !isLastPage,
      'show_submit_button': false, // Never show submit button on content pages
      'components': convertedComponents,
    };

    debugPrint('🔄 [FormBuilderModel] Final page JSON: $result');
    return result;
  }

  /// Convert component to multi-page format
  Map<String, dynamic> _convertComponentToMultiPageFormat(
    DynamicFormModel component,
  ) {
    debugPrint(
      '🔄 [FormBuilderModel] Converting component: ${component.id} - ${component.type}',
    );
    debugPrint(
      '🔄 [FormBuilderModel] Component config: ${component.config?.toJson()}',
    );

    final Map<String, dynamic> json = {
      'id': component.id,
      'type': component.type.toJson(),
      'config': component.config?.toJson() ?? {},
      'style': component.style.toJson(),
    };

    if (component.variants != null) {
      json['variants'] = component.variants!.toJson();
    }

    if (component.states != null) {
      json['states'] = component.states!.toJson();
    }

    if (component.validation != null) {
      json['validate'] = component.validation!.toJson();
    }

    debugPrint('🔄 [FormBuilderModel] Converted component JSON: $json');
    return json;
  }

  /// Create navigation button with proper validation
  Map<String, dynamic> _createNavigationButton(
    String icon,
    String action,
    String label,
    String targetPage,
  ) {
    final isNextPage = action == ButtonAction.nextPage.value;
    return {
      'id': '${action}_btn_${DateTime.now().millisecondsSinceEpoch}',
      'type': 'buttonFormType',
      'config': {
        'label': label,
        'value': null,
        'icon': icon,
        'action': action,
        'is_icon_right_position': isNextPage ? 'true' : 'false',
      },
      'validate': {
        'condition': [],
        isNextPage ? 'next_page' : 'previous_page': targetPage,
      },
      'style': {
        'width': '120px',
        'height': '40px',
        'background_color': isNextPage ? '0xFF3B82F6' : '0xFFE5E7EB',
        'text_color': isNextPage ? '0xFFFFFFFF' : '0xFF111827',
        'border_color': 'transparent',
        'font_size': 15,
        'font_weight': '600',
        'margin': '8px 6px',
        'padding': '8px 12px',
        'icon_size': 14,
        'elevation': 4,
        'shadow_color': isNextPage ? '0xFF3B82F6' : '0xFF3B82F6',
      },
      'variants': {},
      'states': {},
    };
  }

  /// Create submit button for the last page
  // Map<String, dynamic> _createSubmitButton() {
  //   return {
  //     'id': 'submit_btn_${DateTime.now().millisecondsSinceEpoch}',
  //     'type': 'buttonFormType',
  //     'config': {
  //       'label': 'Submit',
  //       'value': null,
  //       'icon': 'check_circle',
  //       'action': ButtonAction.submitForm.value,
  //       'is_icon_right_position': 'true',
  //     },
  //     'validate': {
  //       'condition': [],
  //     },
  //     'style': {
  //       'width': '120px',
  //       'height': '40px',
  //       'background_color': '0xFF059669',
  //       'text_color': '0xFFFFFFFF',
  //       'border_color': 'transparent',
  //       'font_size': 15,
  //       'font_weight': '600',
  //       'margin': '8px 6px',
  //       'padding': '8px 12px',
  //       'icon_size': 14,
  //       'elevation': 4,
  //       'shadow_color': '0xFF059669',
  //     },
  //     'variants': {},
  //     'states': {
  //       'disabled': {
  //         'style': {
  //           'background_color': '0xFFF3F4F6',
  //           'text_color': '0xFF9CA3AF',
  //           'border_color': 'transparent',
  //           'elevation': 0,
  //           'shadow_color': 'transparent',
  //         },
  //       },
  //       'base': {
  //         'style': {
  //           'background_color': '0xFF059669',
  //           'text_color': '0xFFFFFFFF',
  //           'border_color': 'transparent',
  //           'elevation': 4,
  //           'shadow_color': '0xFF059669',
  //         },
  //       },
  //       'loading': {
  //         'style': {
  //           'background_color': '0xFF047857',
  //           'elevation': 2,
  //         },
  //       },
  //     },
  //   };
  // }

  /// Get all components from all pages
  List<DynamicFormModel> getAllComponents() {
    final allComponents = <DynamicFormModel>[];
    for (final page in pages) {
      allComponents.addAll(page.components);
    }
    return allComponents;
  }

  /// Get components from a specific page
  List<DynamicFormModel> getComponentsForPage(String pageId) {
    final page = pages.firstWhere(
      (page) => page.pageId == pageId,
      orElse: () => pages.first,
    );
    return page.components;
  }

  @override
  List<Object?> get props => [
    formId,
    name,
    pages,
    createdAt,
    updatedAt,
  ];
}

class FormBuilderPageModel extends Equatable {
  final String pageId;
  final String title;
  final int order;
  final bool showPreviousButton;
  final bool showNextButton;
  final bool showSubmitButton;
  final List<DynamicFormModel> components;

  const FormBuilderPageModel({
    required this.pageId,
    required this.title,
    required this.order,
    this.showPreviousButton = false,
    this.showNextButton = false,
    this.showSubmitButton = true,
    required this.components,
  });

  factory FormBuilderPageModel.fromJson(Map<String, dynamic> json) {
    List<DynamicFormModel> components = [];
    if (json['components'] != null) {
      components = List<DynamicFormModel>.from(
        json['components'].map((x) => DynamicFormModel.fromJson(x)),
      );
      components.sort((a, b) => a.order.compareTo(b.order));
    }

    return FormBuilderPageModel(
      pageId: json['pageId'] ?? '',
      title: json['title'] ?? '',
      order: json['order'] ?? 1,
      showPreviousButton: json['show_previous_button'] ?? false,
      showNextButton: json['show_next_button'] ?? false,
      showSubmitButton: json['show_submit_button'] ?? true,
      components: components,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pageId': pageId,
      'title': title,
      'order': order,
      'show_previous_button': showPreviousButton,
      'show_next_button': showNextButton,
      'show_submit_button': showSubmitButton,
      'components': components
          .map((component) => _convertComponentToJson(component))
          .toList(),
    };
  }

  /// Convert component to JSON format
  Map<String, dynamic> _convertComponentToJson(DynamicFormModel component) {
    final Map<String, dynamic> json = {
      'id': component.id,
      'type': component.type.toJson(),
      'config': component.config?.toJson() ?? {},
      'style': component.style.toJson(),
    };

    if (component.variants != null) {
      json['variants'] = component.variants!.toJson();
    }

    if (component.states != null) {
      json['states'] = component.states!.toJson();
    }

    if (component.validation != null) {
      json['validate'] = component.validation!.toJson();
    }

    return json;
  }

  FormBuilderPageModel copyWith({
    String? pageId,
    String? title,
    int? order,
    bool? showPreviousButton,
    bool? showNextButton,
    bool? showSubmitButton,
    List<DynamicFormModel>? components,
  }) {
    return FormBuilderPageModel(
      pageId: pageId ?? this.pageId,
      title: title ?? this.title,
      order: order ?? this.order,
      showPreviousButton: showPreviousButton ?? this.showPreviousButton,
      showNextButton: showNextButton ?? this.showNextButton,
      showSubmitButton: showSubmitButton ?? this.showSubmitButton,
      components: components ?? this.components,
    );
  }

  @override
  List<Object?> get props => [
    pageId,
    title,
    order,
    showPreviousButton,
    showNextButton,
    showSubmitButton,
    components,
  ];
}
