import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesModel extends ChangeNotifier {
  final SharedPreferences prefs;
  static const _key = 'favorite_barcodes';
  Set<String> _favorites = {};

  FavoritesModel(this.prefs) {
    _favorites = prefs.getStringList(_key)?.toSet() ?? {};
  }

  Set<String> get favorites => _favorites;

  bool isFavorite(String id) => _favorites.contains(id);

  void toggle(String id) {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    prefs.setStringList(_key, _favorites.toList());
    notifyListeners();
  }
}