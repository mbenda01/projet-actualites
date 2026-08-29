import 'package:flutter/material.dart';

abstract class ThemeRepository {
  Future<ThemeMode> charger();

  Future<void> enregistrer(ThemeMode mode);
}