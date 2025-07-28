// import 'package:flutter/material.dart';
// import 'package:dynamic_form_bi/data/models/style/style_model.dart';
//
// class StyleUtils {
//   static EdgeInsetsGeometry parsePadding(String? padding) {
//     if (padding == null || padding.isEmpty) {
//       return const EdgeInsets.all(0);
//     }
//     final parts = padding.split(' ');
//     if (parts.length == 2) {
//       final horizontal = double.tryParse(parts[0].replaceAll('px', '')) ?? 0;
//       final vertical = double.tryParse(parts[1].replaceAll('px', '')) ?? 0;
//       return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
//     } else if (parts.length == 4) {
//       final top = double.tryParse(parts[0].replaceAll('px', '')) ?? 0;
//       final right = double.tryParse(parts[1].replaceAll('px', '')) ?? 0;
//       final bottom = double.tryParse(parts[2].replaceAll('px', '')) ?? 0;
//       final left = double.tryParse(parts[3].replaceAll('px', '')) ?? 0;
//       return EdgeInsets.fromLTRB(left, top, right, bottom);
//     } else {
//       final value = double.tryParse(parts[0].replaceAll('px', '')) ?? 0;
//       return EdgeInsets.all(value);
//     }
//   }
//
//   static Color parseColor(String? colorString) {
//     if (colorString == null || colorString.isEmpty) {
//       return Colors.transparent;
//     }
//     if (colorString.toLowerCase().startsWith('0xff')) {
//       final hex = colorString.replaceAll('0x', '').replaceAll('0X', '');
//       if (hex.length == 8) {
//         return Color(int.parse(hex, radix: 16));
//       } else if (hex.length == 6) {
//         return Color(int.parse('FF$hex', radix: 16));
//       }
//     }
//     return Colors.transparent;
//   }
//   static BorderRadius parseBorderRadius(double? radius) {
//     if (radius == null) {
//       return BorderRadius.zero;
//     }
//     return BorderRadius.circular(radius);
//   }
//
//   static double parseFontSize(double? fontSize) {
//     return fontSize ?? 14.0;
//   }
//
//   static BoxDecoration buildBoxDecoration(StyleModel style) {
//     return BoxDecoration(
//       color:style.backgroundColor,
//       border: style.borderColor != null
//           ? Border.all(color: style.borderColor!)
//           : null,
//       borderRadius: parseBorderRadius(style.borderRadius),
//     );
//   }
//
//   static TextStyle buildTextStyle(StyleModel style) {
//     return TextStyle(
//       fontSize: parseFontSize(style.fontSize),
//       color: style.textColor,
//       fontWeight: _parseFontWeight(style.fontStyle),
//     );
//   }
//
//   static FontWeight _parseFontWeight(String? weight) {
//     switch (weight?.toLowerCase()) {
//       case 'bold':
//         return FontWeight.bold;
//       case 'normal':
//         return FontWeight.normal;
//       case 'light':
//         return FontWeight.w300;
//       default:
//         return FontWeight.normal;
//     }
//   }
// }
