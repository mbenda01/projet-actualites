import 'dart:async';

import '../core/erreur_api.dart';
import '../core/journal.dart';
import '../repositories/cache/favoris_cache_hive.dart';
import '../repositories/favoris_repository.dart';

class SynchronisationService {
  static const String _origine = 'SynchronisationService';

  final FavorisRepository _distant;
  final FavorisCacheHive _cache;
  final Journal _journal;

  Timer? _minuteur;
  bool _synchronisationEnCours = false;

  SynchronisationService({
    required FavorisRepository distant,
    required Journal journal,
    FavorisCacheHive cache = const FavorisCacheHive(),
  })  : _distant = distant,
        _cache = cache,
        _journal = journal;

  void demarrer({Duration intervalle = const Duration(seconds: 30)}) {
    synchroniser();
    _minuteur = Timer.periodic(intervalle, (_) => synchroniser());
  }

  Future<void> synchroniser() async {
    if (_synchronisationEnCours || !_cache.aDesActionsEnAttente) return;

    _synchronisationEnCours = true;
    _journal.debug(_origine, 'Synchronisation en cours...');

    try {
      final actions = _cache.lireActionsEnAttente();

      for (final entree in actions) {
        try {
          await _rejouer(entree.action);
          await _cache.supprimerActionEnAttente(entree.cle);
        } on ErreurReseau {
          _journal.debug(_origine, 'Toujours hors-ligne, nouvel essai plus tard');
          break;
        } catch (erreur) {
          _journal.erreur(_origine, 'Action de synchro rejetée par le serveur', erreur);
          await _cache.supprimerActionEnAttente(entree.cle);
        }
      }
    } finally {
      _synchronisationEnCours = false;
    }
  }

  Future<void> _rejouer(ActionFavoriEnAttente action) {
    switch (action.type) {
      case TypeActionFavori.basculer:
        return _distant.basculer(action.articleId!);
      case TypeActionFavori.retirer:
        return _distant.retirer(action.articleId!);
      case TypeActionFavori.toutRetirer:
        return _distant.toutRetirer();
    }
  }

  void arreter() {
    _minuteur?.cancel();
    _minuteur = null;
  }
}
