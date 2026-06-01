import 'package:flutter/material.dart';

abstract final class HanjaStrokeColorPalette {
  static const colors = <Color>[
    Color(0xFFC9252D),
    Color(0xFF2563EB),
    Color(0xFF16A34A),
    Color(0xFFF97316),
    Color(0xFF7C3AED),
    Color(0xFF0891B2),
    Color(0xFFDB2777),
    Color(0xFF65A30D),
  ];

  static Color colorFor(int strokeIndex) {
    return colors[strokeIndex % colors.length];
  }
}
