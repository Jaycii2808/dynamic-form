import 'package:flutter/material.dart';

/// Enum for common style colors used in the app
/// Supports both named colors and custom hex values
enum StyleColorEnum {
  primary,
  secondary,
  error,
  success,
  info,
  warning,
  white,
  black,
  grey,
  transparent,
  customHex;

  static StyleColorEnum fromString(String? value) {
    if (value == null) return StyleColorEnum.transparent;
    switch (value.toLowerCase()) {
      case 'primary':
        return StyleColorEnum.primary;
      case 'secondary':
        return StyleColorEnum.secondary;
      case 'error':
        return StyleColorEnum.error;
      case 'success':
        return StyleColorEnum.success;
      case 'info':
        return StyleColorEnum.info;
      case 'warning':
        return StyleColorEnum.warning;
      case 'white':
        return StyleColorEnum.white;
      case 'black':
        return StyleColorEnum.black;
      case 'grey':
      case 'gray':
        return StyleColorEnum.grey;
      case 'transparent':
        return StyleColorEnum.transparent;
      default:
        return StyleColorEnum.customHex;
    }
  }

  /// Get the Color value for the enum
  /// If [customHex] is used, provide the hex string as [customHexValue]
  Color toColor({String? customHexValue}) {
    switch (this) {
      case StyleColorEnum.primary:
        return const Color(0xFF6979F8);
      case StyleColorEnum.secondary:
        return const Color(0xFF333333);
      case StyleColorEnum.error:
        return const Color(0xFFFF4D4F);
      case StyleColorEnum.success:
        return const Color(0xFF52C41A);
      case StyleColorEnum.info:
        return const Color(0xFF1890FF);
      case StyleColorEnum.warning:
        return const Color(0xFFFFC107);
      case StyleColorEnum.white:
        return Colors.white;
      case StyleColorEnum.black:
        return Colors.black;
      case StyleColorEnum.grey:
        return Colors.grey;
      case StyleColorEnum.transparent:
        return Colors.transparent;
      case StyleColorEnum.customHex:
        if (customHexValue != null && customHexValue.startsWith('#')) {
          final hex = customHexValue.replaceAll('#', '');
          if (hex.length == 6) {
            return Color(int.parse('FF$hex', radix: 16));
          } else if (hex.length == 8) {
            return Color(int.parse(hex, radix: 16));
          }
        }
        return Colors.transparent;
    }
  }
}
