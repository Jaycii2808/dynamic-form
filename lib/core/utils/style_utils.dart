import 'package:flutter/material.dart';

class StyleUtils {
  static EdgeInsetsGeometry parsePadding(String? padding) {
    if (padding == null || padding.isEmpty) {
      return const EdgeInsets.all(0);
    }

    final parts = padding.split(' ');
    if (parts.length == 2) {
      // "10px 12px" -> horizontal: 10, vertical: 12
      final horizontal = double.tryParse(parts[0].replaceAll('px', '')) ?? 0;
      final vertical = double.tryParse(parts[1].replaceAll('px', '')) ?? 0;
      return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
    } else if (parts.length == 4) {
      // "10px 12px 8px 6px" -> top, right, bottom, left
      final top = double.tryParse(parts[0].replaceAll('px', '')) ?? 0;
      final right = double.tryParse(parts[1].replaceAll('px', '')) ?? 0;
      final bottom = double.tryParse(parts[2].replaceAll('px', '')) ?? 0;
      final left = double.tryParse(parts[3].replaceAll('px', '')) ?? 0;
      return EdgeInsets.fromLTRB(left, top, right, bottom);
    } else {
      // Single value
      final value = double.tryParse(parts[0].replaceAll('px', '')) ?? 0;
      return EdgeInsets.all(value);
    }
  }

  static Color parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return Colors.transparent;
    }

    if (colorString.startsWith('#')) {
      // Hex color
      final hex = colorString.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    }

    // RGBA color: rgba(r, g, b, a)
    if (colorString.toLowerCase().startsWith('rgba(')) {
      final rgba = colorString
          .toLowerCase()
          .replaceAll('rgba(', '')
          .replaceAll(')', '')
          .replaceAll(' ', '');
      final values = rgba.split(',');
      if (values.length == 4) {
        final r = int.tryParse(values[0]) ?? 0;
        final g = int.tryParse(values[1]) ?? 0;
        final b = int.tryParse(values[2]) ?? 0;
        final a = double.tryParse(values[3]) ?? 1.0;
        return Color.fromRGBO(r, g, b, a);
      }
    }

    // RGB color: rgb(r, g, b)
    if (colorString.toLowerCase().startsWith('rgb(')) {
      final rgb = colorString
          .toLowerCase()
          .replaceAll('rgb(', '')
          .replaceAll(')', '')
          .replaceAll(' ', '');
      final values = rgb.split(',');
      if (values.length == 3) {
        final r = int.tryParse(values[0]) ?? 0;
        final g = int.tryParse(values[1]) ?? 0;
        final b = int.tryParse(values[2]) ?? 0;
        return Color.fromRGBO(r, g, b, 1.0);
      }
    }

    // Named colors
    switch (colorString.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'brown':
        return Colors.brown;
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      default:
        return Colors.transparent;
    }
  }

  static BorderRadius parseBorderRadius(int? radius) {
    if (radius == null) {
      return BorderRadius.zero;
    }
    return BorderRadius.circular(radius.toDouble());
  }

  static double parseFontSize(int? fontSize) {
    return fontSize?.toDouble() ?? 14.0;
  }

  static BoxDecoration buildBoxDecoration(Map<String, dynamic> style) {
    return BoxDecoration(
      color: parseColor(style['backgroundColor']),
      border: style['borderColor'] != null
          ? Border.all(color: parseColor(style['borderColor']))
          : null,
      borderRadius: parseBorderRadius(style['borderRadius']),
    );
  }

  static TextStyle buildTextStyle(Map<String, dynamic> style) {
    return TextStyle(
      fontSize: parseFontSize(style['fontSize']),
      color: parseColor(style['color']),
      fontWeight: _parseFontWeight(style['fontWeight']),
    );
  }

  static FontWeight _parseFontWeight(String? weight) {
    switch (weight?.toLowerCase()) {
      case 'bold':
        return FontWeight.bold;
      case 'normal':
        return FontWeight.normal;
      case 'light':
        return FontWeight.w300;
      default:
        return FontWeight.normal;
    }
  }
}
