import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/journal.dart';
import '../../repositories/favoris_repository.dart';
import 'favoris_event.dart';
import 'favoris_state.dart';

class FavorisBloc extends Bloc<FavorisEvent, FavorisState> {
  static const String _origine = 'FavorisBloc';

  final FavorisRepository _depot;
  final Journal _journal;

  FavorisBloc({
    required FavorisRepository depot,
    required Journal journal,
  })  : _depot = depot,
        _journal = journal,
        super(const FavorisState()) {
    on<FavorisChargementDemande>(_surChargement);
    on<FavorisBascule>(_surBascule);
    on<FavorisToutRetireDemande>(_surToutRetire);
  }

  Future<void> _surChargement(
    FavorisChargementDemande evenement,
    Emitter<FavorisState> emit,
  ) async {
    emit(state.copierAvec(enChargement: true, effacerErreur: true));

    try {
      final identifiants = await _depot.listerIdentifiants();

      _journal.debug(_origine, '${identifiants.length} favoris chargés');

      emit(state.copierAvec(identifiants: identifiants, enChargement: false));
    } catch (erreur) {
      _journal.erreur(_origine, 'Échec du chargement des favoris', erreur);
      emit(state.copierAvec(
        enChargement: false,
        erreur: 'Impossible de charger les favoris',
      ));
    }
  }

  Future<void> _surBascule(
    FavorisBascule evenement,
    Emitter<FavorisState> emit,
  ) async {
    final ancienEtat = state.identifiants;
    final estDejaFavori = ancienEtat.contains(evenement.articleId);

    final nouveauxIdentifiants = Set<int>.from(ancienEtat);
    if (estDejaFavori) {
      nouveauxIdentifiants.remove(evenement.articleId);
    } else {
      nouveauxIdentifiants.add(evenement.articleId);
    }

    emit(state.copierAvec(
      identifiants: nouveauxIdentifiants,
      effacerErreur: true,
    ));

    try {
      await _depot.basculer(evenement.articleId);

      _journal.debug(
        _origine,
        estDejaFavori
            ? 'Article ${evenement.articleId} retiré'
            : 'Article ${evenement.articleId} ajouté',
      );
    } catch (erreur) {
      _journal.erreur(_origine, 'Échec de la bascule, retour en arrière', erreur);

      emit(state.copierAvec(
        identifiants: ancienEtat,
        erreur: 'Impossible de mettre à jour les favoris',
      ));
    }
  }

  Future<void> _surToutRetire(
    FavorisToutRetireDemande evenement,
    Emitter<FavorisState> emit,
  ) async {
    final ancienEtat = state.identifiants;

    emit(state.copierAvec(identifiants: const {}, effacerErreur: true));

    try {
      await _depot.toutRetirer();
      _journal.info(_origine, 'Favoris vidés');
    } catch (erreur) {
      _journal.erreur(_origine, 'Échec de la suppression, retour en arrière', erreur);

      emit(state.copierAvec(
        identifiants: ancienEtat,
        erreur: 'Impossible de vider les favoris',
      ));
    }
  }
}