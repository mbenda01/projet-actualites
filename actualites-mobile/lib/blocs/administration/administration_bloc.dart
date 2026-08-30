import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/erreur_api.dart';
import '../../core/journal.dart';
import '../../repositories/article_repository.dart';
import 'administration_event.dart';
import 'administration_state.dart';

class AdministrationBloc extends Bloc<AdministrationEvent, AdministrationState> {
  static const String _origine = 'AdministrationBloc';
  static const int _taillePage = 50;

  final ArticleRepository _depot;
  final Journal _journal;

  AdministrationBloc({
    required ArticleRepository depot,
    required Journal journal,
  })  : _depot = depot,
        _journal = journal,
        super(const AdministrationInitial()) {
    on<AdministrationChargementDemande>(_surChargement);
    on<AdministrationRafraichissementDemande>(_surChargement);
    on<AdministrationArticleCree>(_surCreation);
    on<AdministrationArticleModifie>(_surModification);
    on<AdministrationStatutChange>(_surChangementStatut);
    on<AdministrationArticleArchive>(_surArchivage);
  }

  Future<void> _surChargement(
    AdministrationEvent evenement,
    Emitter<AdministrationState> emit,
  ) async {
    final etatPrecedent = state;
    if (etatPrecedent is! AdministrationChargee) {
      emit(const AdministrationEnChargement());
    }

    try {
      final resultat = await _depot.listerTous(taille: _taillePage);

      _journal.debug(
        _origine,
        '${resultat.contenu.length} articles chargés sur ${resultat.totalElements}',
      );

      emit(AdministrationChargee(
        articles: resultat.contenu,
        totalElements: resultat.totalElements,
      ));
    } catch (erreur) {
      emit(_traduireEchec(erreur));
    }
  }

  Future<void> _surCreation(
    AdministrationArticleCree evenement,
    Emitter<AdministrationState> emit,
  ) async {
    try {
      final cree = await _depot.creer(evenement.article);

      _journal.info(_origine, 'Article créé : id=${cree.id}');

      add(const AdministrationRafraichissementDemande());
    } catch (erreur) {
      _journal.erreur(_origine, 'Échec de la création', erreur);
      emit(_traduireEchec(erreur));
    }
  }

  Future<void> _surModification(
    AdministrationArticleModifie evenement,
    Emitter<AdministrationState> emit,
  ) async {
    try {
      await _depot.modifier(evenement.id, evenement.article);

      _journal.info(_origine, 'Article modifié : id=${evenement.id}');

      add(const AdministrationRafraichissementDemande());
    } catch (erreur) {
      _journal.erreur(_origine, 'Échec de la modification', erreur);
      emit(_traduireEchec(erreur));
    }
  }

  Future<void> _surChangementStatut(
    AdministrationStatutChange evenement,
    Emitter<AdministrationState> emit,
  ) async {
    final etat = state;
    if (etat is! AdministrationChargee) return;

    emit(etat.copierAvec(actionEnCoursSurId: evenement.id));

    try {
      final modifie = await _depot.changerStatut(evenement.id, evenement.statut);

      _journal.info(
        _origine,
        'Statut changé : id=${evenement.id} -> ${evenement.statut.code}',
      );

      final nouvelleListe = etat.articles
          .map((article) => article.id == modifie.id ? modifie : article)
          .toList();

      emit(etat.copierAvec(
        articles: nouvelleListe,
        effacerActionEnCours: true,
      ));
    } catch (erreur) {
      _journal.erreur(_origine, 'Échec du changement de statut', erreur);
      emit(_traduireEchecConserveListe(erreur, etat));
    }
  }

  Future<void> _surArchivage(
    AdministrationArticleArchive evenement,
    Emitter<AdministrationState> emit,
  ) async {
    final etat = state;
    if (etat is! AdministrationChargee) return;

    emit(etat.copierAvec(actionEnCoursSurId: evenement.id));

    try {
      await _depot.archiver(evenement.id);

      _journal.info(_origine, 'Article archivé : id=${evenement.id}');

      add(const AdministrationRafraichissementDemande());
    } catch (erreur) {
      _journal.erreur(_origine, "Échec de l'archivage", erreur);
      emit(_traduireEchecConserveListe(erreur, etat));
    }
  }

  AdministrationState _traduireEchecConserveListe(
    Object erreur,
    AdministrationChargee etat,
  ) {
    _journal.avertissement(_origine, 'Action échouée, liste conservée');
    return etat.copierAvec(effacerActionEnCours: true);
  }

  AdministrationState _traduireEchec(Object erreur) {
    if (erreur is ErreurAccesRefuse) {
      return const AdministrationEchec('Réservé aux administrateurs');
    }
    if (erreur is ErreurApi) {
      return AdministrationEchec(erreur.message);
    }

    _journal.erreur(_origine, 'Erreur inattendue', erreur);
    return const AdministrationEchec('Une erreur est survenue');
  }
}