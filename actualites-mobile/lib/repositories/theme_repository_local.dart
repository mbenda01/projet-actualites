import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_repository.dart';

class ThemeRepositoryLocal implements ThemeRepository {
  static const String _cle = 'theme.mode';

  const ThemeRepositoryLocal();

  @override
  Future<ThemeMode> charger() async {
    final prefs = await SharedPreferences.getInstance();

    final nom = prefs.getString(_cle);
    if (nom == null) return ThemeMode.system;

    for (final mode in ThemeMode.values) {
      if (mode.name == nom) return mode;
    }

    return ThemeMode.system;
  }

  @override
  Future<void> enregistrer(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cle, mode.name);
  }
}