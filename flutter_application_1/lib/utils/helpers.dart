import 'package:flutter/material.dart';

String formatCalories(double? calories) {
  if (calories == null) {
    return 'kcal: —';
  }
  return '${calories.toStringAsFixed(0)} kcal/100g';
}

String formatNutrientValue(double? value, String unit) {
  if (value == null) {
    return '— $unit';
  }
  return '${value.toStringAsFixed(1)} $unit';
}

Color getCalorieColor(double? calories) {
  if (calories == null) {
    return Colors.grey;
  } else if (calories < 100) {
    return Colors.green.shade700;
  } else if (calories < 300) {
    return Colors.orange.shade700;
  } else {
    return Colors.red.shade700;
  }
}

String truncateText(String text, int maxLength) {
  if (text.length <= maxLength) {
    return text;
  }
  return '${text.substring(0, maxLength)}...';
}

bool matchesQuery(String text, String query) {
  if (query.isEmpty) return true;
  final lowerText = text.toLowerCase();
  final lowerQuery = query.toLowerCase();
  return lowerText.contains(lowerQuery);
}

extension ListExtensions<T> on List<T> {
  List<T> safeSublist(int start, [int? end]) {
    if (start >= length) return [];
    final actualEnd = end != null ? (end > length ? length : end) : length;
    if (start >= actualEnd) return [];
    return sublist(start, actualEnd);
  }
}