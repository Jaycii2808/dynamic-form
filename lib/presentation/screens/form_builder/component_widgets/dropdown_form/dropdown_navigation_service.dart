import 'package:flutter/foundation.dart';
import 'package:dynamic_form_bi/data/models/config/config_model.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/component_widgets/dropdown_form/dropdown_action_enum.dart';

class DropdownNavigationService {
  static final DropdownNavigationService _instance =
      DropdownNavigationService._internal();
  factory DropdownNavigationService() => _instance;
  DropdownNavigationService._internal();

  // Store dropdown selections for each page
  final Map<String, Map<String, Option>> _pageDropdownSelections = {};

  /// Store dropdown selection for a specific page
  void storeDropdownSelection(
    String pageId,
    String componentId,
    Option selectedOption,
  ) {
    debugPrint(
      '🗂️ [DropdownNavigationService] Storing selection for page $pageId, component $componentId: ${selectedOption.label}',
    );

    if (!_pageDropdownSelections.containsKey(pageId)) {
      _pageDropdownSelections[pageId] = {};
    }
    _pageDropdownSelections[pageId]![componentId] = selectedOption;
  }

  /// Get dropdown selection for a specific page and component
  Option? getDropdownSelection(String pageId, String componentId) {
    return _pageDropdownSelections[pageId]?[componentId];
  }

  /// Get all dropdown selections for a specific page
  Map<String, Option> getPageDropdownSelections(String pageId) {
    return _pageDropdownSelections[pageId] ?? {};
  }

  /// Clear dropdown selections for a specific page
  void clearPageSelections(String pageId) {
    _pageDropdownSelections.remove(pageId);
    debugPrint(
      '🗑️ [DropdownNavigationService] Cleared selections for page $pageId',
    );
  }

  /// Get target page based on dropdown selections when next button is pressed
  String? getTargetPageOnNext(String currentPageId, List<String> pageIds) {
    debugPrint(
      '🎯 [DropdownNavigationService] Checking navigation for page $currentPageId',
    );

    final pageSelections = getPageDropdownSelections(currentPageId);
    if (pageSelections.isEmpty) {
      debugPrint(
        '📄 [DropdownNavigationService] No dropdown selections found, proceeding to next page',
      );
      return _getNextPageId(currentPageId, pageIds);
    }

    // Check for goto actions first
    for (final selection in pageSelections.values) {
      final action = DropdownActionOptionsEnum.fromString(selection.action);
      if (action == DropdownActionOptionsEnum.goto &&
          selection.targetSection != null) {
        debugPrint(
          '🎯 [DropdownNavigationService] Found goto action to: ${selection.targetSection}',
        );
        return selection.targetSection;
      }
    }

    // Check for continue/next actions
    bool hasNextAction = pageSelections.values.any(
      (selection) {
        final action = DropdownActionOptionsEnum.fromString(selection.action);
        return action == DropdownActionOptionsEnum.next;
      },
    );

    if (hasNextAction) {
      debugPrint(
        '➡️ [DropdownNavigationService] Found continue action, proceeding to next page',
      );
      return _getNextPageId(currentPageId, pageIds);
    }

    // Check for submit actions
    bool hasSubmitAction = pageSelections.values.any(
      (selection) {
        final action = DropdownActionOptionsEnum.fromString(selection.action);
        return action == DropdownActionOptionsEnum.submit;
      },
    );

    if (hasSubmitAction) {
      debugPrint(
        '📤 [DropdownNavigationService] Found submit action, form should be submitted',
      );
      return 'submit'; // Special value to indicate form submission
    }

    // Default: proceed to next page
    debugPrint(
      '📄 [DropdownNavigationService] No specific actions found, proceeding to next page',
    );
    return _getNextPageId(currentPageId, pageIds);
  }

  /// Get next page ID in sequence
  String? _getNextPageId(String currentPageId, List<String> pageIds) {
    final currentIndex = pageIds.indexOf(currentPageId);
    if (currentIndex == -1 || currentIndex >= pageIds.length - 1) {
      return null; // No next page
    }
    return pageIds[currentIndex + 1];
  }

  /// Check if form should be submitted based on dropdown selections
  bool shouldSubmitForm(String currentPageId) {
    final pageSelections = getPageDropdownSelections(currentPageId);
    return pageSelections.values.any(
      (selection) {
        final action = DropdownActionOptionsEnum.fromString(selection.action);
        return action == DropdownActionOptionsEnum.submit;
      },
    );
  }

  /// Get all navigation actions for a page
  List<DropdownNavigationAction> getPageNavigationActions(String pageId) {
    final pageSelections = getPageDropdownSelections(pageId);
    final actions = <DropdownNavigationAction>[];

    for (final entry in pageSelections.entries) {
      final componentId = entry.key;
      final selection = entry.value;

      if (selection.action != null) {
        final action = DropdownActionOptionsEnum.fromString(selection.action);
        actions.add(
          DropdownNavigationAction(
            componentId: componentId,
            action: action.value,
            targetSection: selection.targetSection,
            optionLabel: selection.label,
          ),
        );
      }
    }

    return actions;
  }

  /// Debug: Print all stored selections
  void debugPrintSelections() {
    debugPrint('📊 [DropdownNavigationService] Current selections:');
    for (final pageEntry in _pageDropdownSelections.entries) {
      debugPrint('  Page: ${pageEntry.key}');
      for (final componentEntry in pageEntry.value.entries) {
        final action = DropdownActionOptionsEnum.fromString(
          componentEntry.value.action,
        );
        debugPrint(
          '    Component: ${componentEntry.key} -> ${componentEntry.value.label} (${action.value})',
        );
      }
    }
  }
}

class DropdownNavigationAction {
  final String componentId;
  final String action;
  final String? targetSection;
  final String optionLabel;

  DropdownNavigationAction({
    required this.componentId,
    required this.action,
    this.targetSection,
    required this.optionLabel,
  });

  @override
  String toString() {
    return 'DropdownNavigationAction(componentId: $componentId, action: $action, targetSection: $targetSection, optionLabel: $optionLabel)';
  }
}
