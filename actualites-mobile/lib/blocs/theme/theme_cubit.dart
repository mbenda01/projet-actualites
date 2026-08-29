import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/journal.dart';
import '../../repositories/theme_repository.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _origine = 'ThemeCubit';

  final ThemeRepository _depot;
  final Journal _journal;

  ThemeCubit({
    required ThemeRepository depot,
    required Journal journal,
  })  : _depot = depot,
        _journal = journal,
        super(ThemeMode.system);

  Future<void> charger() async {
    try {
      final mode = await _depot.charger();
      _journal.info(_origine, 'Thème restauré : ${libelleDe(mode)}');
      emit(mode);
    } catch (erreur) {
      _journal.erreur(_origine, 'Stockage illisible, mode automatique conservé', erreur);
    }
  }

  void changer(ThemeMode nouveau) {
    if (nouveau == state) {
      _journal.debug(_origine, 'Mode inchangé, aucune action');
      return;
    }

    _journal.info(_origine, 'Passage de ${libelleDe(state)} à ${libelleDe(nouveau)}');

    emit(nouveau);
    _persister(nouveau);
  }

  void basculer() {
    switch (state) {
      case ThemeMode.dark:
        changer(ThemeMode.light);
      case ThemeMode.light:
      case ThemeMode.system:
        changer(ThemeMode.dark);
    }
  }

  void _persister(ThemeMode mode) {
    _depot.enregistrer(mode).catchError((Object erreur) {
      _journal.erreur(_origine, 'Échec de la persistance du thème', erreur);
    });
  }

  static String libelleDe(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Automatique';
      case ThemeMode.light:
        return 'Clair';
      case ThemeMode.dark:
        return 'Sombre';
    }
  }
}