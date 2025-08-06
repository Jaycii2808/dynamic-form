import 'package:flutter/foundation.dart';
import 'package:dynamic_form_bi/presentation/screens/form_builder/component_widgets/dropdown_form/dropdown_navigation_service.dart';

class DropdownNavigationUtils {
  static final DropdownNavigationService _navigationService =
      DropdownNavigationService();

  /// Handle next button press with dropdown navigation logic
  static DropdownNavigationResult handleNextButtonPress(
    String currentPageId,
    List<String> pageIds,
  ) {
    debugPrint(
      '🚀 [DropdownNavigationUtils] Handling next button press for page: $currentPageId',
    );

    // Get target page based on dropdown selections
    final targetPage = _navigationService.getTargetPageOnNext(
      currentPageId,
      pageIds,
    );

    debugPrint(
      '🎯 [DropdownNavigationUtils] Target page determined: $targetPage',
    );

    if (targetPage == 'submit') {
      // Form should be submitted
      debugPrint(
        '📤 [DropdownNavigationUtils] Form submission triggered by dropdown action',
      );
      return DropdownNavigationResult(
        shouldSubmitForm: true,
        targetPageId: null,
        navigationActions: _navigationService.getPageNavigationActions(
          currentPageId,
        ),
      );
    } else if (targetPage != null) {
      // Navigate to specific page
      debugPrint(
        '➡️ [DropdownNavigationUtils] Navigating to page: $targetPage',
      );
      return DropdownNavigationResult(
        shouldSubmitForm: false,
        targetPageId: targetPage,
        navigationActions: _navigationService.getPageNavigationActions(
          currentPageId,
        ),
      );
    } else {
      // No next page available
      debugPrint('🏁 [DropdownNavigationUtils] No next page available');
      return DropdownNavigationResult(
        shouldSubmitForm: false,
        targetPageId: null,
        navigationActions: _navigationService.getPageNavigationActions(
          currentPageId,
        ),
      );
    }
  }

  /// Check if current page has dropdown navigation actions
  static bool hasDropdownNavigationActions(String currentPageId) {
    final actions = _navigationService.getPageNavigationActions(currentPageId);
    return actions.isNotEmpty;
  }

  /// Get navigation actions for current page
  static List<DropdownNavigationAction> getNavigationActions(
    String currentPageId,
  ) {
    return _navigationService.getPageNavigationActions(currentPageId);
  }

  /// Clear dropdown selections for a page
  static void clearPageSelections(String pageId) {
    _navigationService.clearPageSelections(pageId);
  }

  /// Debug: Print all stored selections
  static void debugPrintSelections() {
    _navigationService.debugPrintSelections();
  }

  /// Get navigation service instance
  static DropdownNavigationService get navigationService => _navigationService;
}

class DropdownNavigationResult {
  final bool shouldSubmitForm;
  final String? targetPageId;
  final List<DropdownNavigationAction> navigationActions;

  DropdownNavigationResult({
    required this.shouldSubmitForm,
    this.targetPageId,
    required this.navigationActions,
  });

  @override
  String toString() {
    return 'DropdownNavigationResult(shouldSubmitForm: $shouldSubmitForm, targetPageId: $targetPageId, navigationActions: $navigationActions)';
  }
}
