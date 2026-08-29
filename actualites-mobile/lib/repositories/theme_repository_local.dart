import 'package:shared_preferences/shared_preferences.dart';

import '../models/preference_theme.dart';
import 'theme_repository.dart';

class ThemeRepositoryLocal implements ThemeRepository {
  static const String _cle = 'theme.preference';

  const ThemeRepositoryLocal();

  @override
  Future<PreferenceTheme> charger() async {
    final prefs = await SharedPreferences.getInstance();

    final nom = prefs.getString(_cle);
    if (nom == null) return PreferenceTheme.automatique;

    for (final preference in PreferenceTheme.values) {
      if (preference.name == nom) return preference;
    }

    return PreferenceTheme.automatique;
  }

  @override
  Future<void> enregistrer(PreferenceTheme preference) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cle, preference.name);
  }
}
