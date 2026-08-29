import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/journal.dart';
import '../../models/preference_theme.dart';
import '../../repositories/theme_repository.dart';

class EtatTheme {
  final PreferenceTheme preference;
  final ThemeMode modeApplique;

  const EtatTheme({required this.preference, required this.modeApplique});
}

class ThemeCubit extends Cubit<EtatTheme> {
  static const String _origine = 'ThemeCubit';
  static const int _heureDebutNuit = 22;
  static const int _heureFinNuit = 7;

  final ThemeRepository _depot;
  final Journal _journal;

  Timer? _minuteur;

  ThemeCubit({
    required ThemeRepository depot,
    required Journal journal,
  })  : _depot = depot,
        _journal = journal,
        super(const EtatTheme(
          preference: PreferenceTheme.automatique,
          modeApplique: ThemeMode.light,
        )) {
    // Recalcule le mode toutes les minutes tant que l'utilisateur est en
    // automatique, pour basculer sombre/clair sans redémarrer l'app.
    _minuteur = Timer.periodic(const Duration(minutes: 1), (_) => _reappliquer());
  }

  Future<void> charger() async {
    try {
      final preference = await _depot.charger();
      _journal.info(_origine, 'Thème restauré : ${libelleDe(preference)}');
      _emettre(preference);
    } catch (erreur) {
      _journal.erreur(
        _origine,
        'Stockage illisible, mode automatique conservé',
        erreur,
      );
      _emettre(PreferenceTheme.automatique);
    }
  }

  void changer(PreferenceTheme nouvelle) {
    if (nouvelle == state.preference) {
      _journal.debug(_origine, 'Préférence inchangée, aucune action');
      return;
    }

    _journal.info(
      _origine,
      'Passage de ${libelleDe(state.preference)} à ${libelleDe(nouvelle)}',
    );

    _emettre(nouvelle);
    _persister(nouvelle);
  }

  void basculer() {
    switch (state.preference) {
      case PreferenceTheme.sombre:
        changer(PreferenceTheme.clair);
      case PreferenceTheme.clair:
      case PreferenceTheme.automatique:
        changer(PreferenceTheme.sombre);
    }
  }

  void _reappliquer() {
    if (state.preference != PreferenceTheme.automatique) return;
    _emettre(state.preference);
  }

  void _emettre(PreferenceTheme preference) {
    final mode = _resoudreMode(preference);
    if (mode == state.modeApplique && preference == state.preference) return;
    emit(EtatTheme(preference: preference, modeApplique: mode));
  }

  ThemeMode _resoudreMode(PreferenceTheme preference) {
    switch (preference) {
      case PreferenceTheme.clair:
        return ThemeMode.light;
      case PreferenceTheme.sombre:
        return ThemeMode.dark;
      case PreferenceTheme.automatique:
        final heure = DateTime.now().hour;
        final estNuit = heure >= _heureDebutNuit || heure < _heureFinNuit;
        return estNuit ? ThemeMode.dark : ThemeMode.light;
    }
  }

  void _persister(PreferenceTheme preference) {
    _depot.enregistrer(preference).catchError((Object erreur) {
      _journal.erreur(_origine, 'Échec de la persistance du thème', erreur);
    });
  }

  @override
  Future<void> close() {
    _minuteur?.cancel();
    return super.close();
  }

  static String libelleDe(PreferenceTheme preference) {
    switch (preference) {
      case PreferenceTheme.automatique:
        return 'Automatique (sombre 22h-7h)';
      case PreferenceTheme.clair:
        return 'Clair';
      case PreferenceTheme.sombre:
        return 'Sombre';
    }
  }
}
