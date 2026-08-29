import '../models/preference_theme.dart';

abstract class ThemeRepository {
  Future<PreferenceTheme> charger();

  Future<void> enregistrer(PreferenceTheme preference);
}
