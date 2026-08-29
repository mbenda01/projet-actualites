import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../core/erreur_api.dart';
import '../../core/journal.dart';
import '../../repositories/article_repository.dart';
import 'articles_event.dart';
import 'articles_state.dart';

class ArticlesBloc extends Bloc<ArticlesEvent, ArticlesState> {
  static const String _origine = 'ArticlesBloc';
  static const int _taillePage = 20;
  static const Duration _delaiRecherche = Duration(milliseconds: 350);

  final ArticleRepository _depot;
  final Journal _journal;

  int _pageCourante = 0;

  ArticlesBloc({
    required ArticleRepository depot,
    required Journal journal,
  })  : _depot = depot,
        _journal = journal,
        super(const ArticlesInitial()) {
    on<ArticlesChargementDemande>(_surChargement);
    on<ArticlesRafraichissementDemande>(_surRafraichissement);
    on<ArticlesPageSuivanteDemandee>(
      _surPageSuivante,
      transformer: droppable(),
    );
    on<ArticlesFiltreChange>(_surFiltreChange);

    on<ArticlesRechercheChangee>(
      _surRechercheChangee,
      transformer: (evenements, mapper) =>
          evenements.debounce(_delaiRecherche).switchMap(mapper),
    );
  }

  Future<void> _surChargement(
    ArticlesChargementDemande evenement,
    Emitter<ArticlesState> emit,
  ) async {
    emit(const ArticlesEnChargement());
    await _charger(emit);
  }

  Future<void> _surRafraichissement(
    ArticlesRafraichissementDemande evenement,
    Emitter<ArticlesState> emit,
  ) async {
    await _charger(emit, categorie: _categorieActuelle, terme: _termeActuel);
  }

  Future<void> _surFiltreChange(
    ArticlesFiltreChange evenement,
    Emitter<ArticlesState> emit,
  ) async {
    emit(const ArticlesEnChargement());
    await _charger(emit, categorie: evenement.categorie, terme: _termeActuel);
  }

  Future<void> _surRechercheChangee(
    ArticlesRechercheChangee evenement,
    Emitter<ArticlesState> emit,
  ) async {
    final terme = evenement.terme.trim();

    _journal.debug(
      _origine,
      terme.isEmpty ? 'Recherche vidée' : 'Terme appliqué (${terme.length} caractères)',
    );

    await _charger(emit, categorie: _categorieActuelle, terme: terme);
  }

  Future<void> _surPageSuivante(
    ArticlesPageSuivanteDemandee evenement,
    Emitter<ArticlesState> emit,
  ) async {
    final etat = state;
    if (etat is! ArticlesCharges || !etat.aUnePageSuivante) return;
    if (etat.chargementPageSuivante) return;

    emit(etat.copierAvec(chargementPageSuivante: true));

    try {
      final page = _pageCourante + 1;

      final resultat = await _depot.listerPublies(
        categorie: etat.categorie,
        recherche: etat.terme.isEmpty ? null : etat.terme,
        page: page,
        taille: _taillePage,
      );

      _pageCourante = page;

      emit(etat.copierAvec(
        articles: [...etat.articles, ...resultat.contenu],
        totalElements: resultat.totalElements,
        aUnePageSuivante: resultat.aUnePageSuivante,
        chargementPageSuivante: false,
      ));
    } catch (erreur) {
      _journal.erreur(_origine, 'Échec du chargement de la page suivante', erreur);
      emit(etat.copierAvec(chargementPageSuivante: false));
    }
  }

  Future<void> _charger(
    Emitter<ArticlesState> emit, {
    dynamic categorie,
    String terme = '',
  }) async {
    try {
      _pageCourante = 0;

      final resultat = await _depot.listerPublies(
        categorie: categorie,
        recherche: terme.isEmpty ? null : terme,
        page: 0,
        taille: _taillePage,
      );

      _journal.debug(
        _origine,
        '${resultat.contenu.length} articles chargés sur ${resultat.totalElements}',
      );

      emit(ArticlesCharges(
        articles: resultat.contenu,
        totalElements: resultat.totalElements,
        aUnePageSuivante: resultat.aUnePageSuivante,
        categorie: categorie,
        terme: terme,
      ));
    } catch (erreur) {
      emit(_traduireEchec(erreur));
    }
  }

  dynamic get _categorieActuelle {
    final etat = state;
    return etat is ArticlesCharges ? etat.categorie : null;
  }

  String get _termeActuel {
    final etat = state;
    return etat is ArticlesCharges ? etat.terme : '';
  }

  ArticlesState _traduireEchec(Object erreur) {
    if (erreur is ErreurReseau) {
      _journal.avertissement(_origine, 'Erreur réseau');
      return const ArticlesEchec('Connexion impossible. Vérifiez votre réseau.');
    }

    if (erreur is ErreurApi) {
      _journal.avertissement(_origine, 'Échec : ${erreur.runtimeType}');
      return ArticlesEchec(erreur.message);
    }

    _journal.erreur(_origine, 'Erreur inattendue', erreur);
    return const ArticlesEchec('Une erreur est survenue');
  }
}