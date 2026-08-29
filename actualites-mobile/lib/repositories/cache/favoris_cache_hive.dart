import 'package:hive_flutter/hive_flutter.dart';

import '../../core/hive_boxes.dart';
import '../../models/article.dart';
import '../../models/page_resultat.dart';

enum TypeActionFavori { basculer, retirer, toutRetirer }

class ActionFavoriEnAttente {
  final TypeActionFavori type;
  final int? articleId;

  const ActionFavoriEnAttente({required this.type, this.articleId});

  Map<String, dynamic> versJson() => {'type': type.name, 'articleId': articleId};

  factory ActionFavoriEnAttente.depuisJson(Map<String, dynamic> json) {
    return ActionFavoriEnAttente(
      type: TypeActionFavori.values.byName(json['type'] as String),
      articleId: json['articleId'] as int?,
    );
  }
}

class FavorisCacheHive {
  const FavorisCacheHive();

  static const String _cleIdentifiants = 'identifiants';
  static const String _clePage = 'page';

  Box get _boiteIdentifiants => Hive.box(HiveBoites.favorisIdentifiants);
  Box get _boiteArticles => Hive.box(HiveBoites.favorisArticles);
  Box get _boiteFileAttente => Hive.box(HiveBoites.favorisFileAttente);

  Future<void> enregistrerIdentifiants(Set<int> identifiants) {
    return _boiteIdentifiants.put(_cleIdentifiants, identifiants.toList());
  }

  Set<int>? lireIdentifiants() {
    final brut = _boiteIdentifiants.get(_cleIdentifiants);
    if (brut == null) return null;
    return (brut as List).map((valeur) => valeur as int).toSet();
  }

  Future<void> enregistrerPage(PageResultat<Article> page) {
    return _boiteArticles.put(_clePage, {
      'contenu': page.contenu.map((article) => article.versJsonCache()).toList(),
      'numeroPage': page.numeroPage,
      'taillePage': page.taillePage,
      'totalElements': page.totalElements,
      'totalPages': page.totalPages,
    });
  }

  PageResultat<Article>? lirePage() {
    final brut = _boiteArticles.get(_clePage);
    if (brut == null) return null;

    final donnees = Map<String, dynamic>.from(brut as Map);
    final contenuBrut = donnees['contenu'] as List;

    return PageResultat<Article>(
      contenu: contenuBrut
          .map((e) => Article.depuisJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      numeroPage: donnees['numeroPage'] as int,
      taillePage: donnees['taillePage'] as int,
      totalElements: donnees['totalElements'] as int,
      totalPages: donnees['totalPages'] as int,
    );
  }

  Future<void> ajouterActionBasculer(int articleId) {
    return _ajouter(ActionFavoriEnAttente(type: TypeActionFavori.basculer, articleId: articleId));
  }

  Future<void> ajouterActionRetirer(int articleId) {
    return _ajouter(ActionFavoriEnAttente(type: TypeActionFavori.retirer, articleId: articleId));
  }

  Future<void> ajouterActionToutRetirer() {
    return _ajouter(const ActionFavoriEnAttente(type: TypeActionFavori.toutRetirer));
  }

  Future<void> _ajouter(ActionFavoriEnAttente action) {
    return _boiteFileAttente.add(action.versJson());
  }

  List<({dynamic cle, ActionFavoriEnAttente action})> lireActionsEnAttente() {
    return _boiteFileAttente.keys.map((cle) {
      final json = Map<String, dynamic>.from(_boiteFileAttente.get(cle) as Map);
      return (cle: cle, action: ActionFavoriEnAttente.depuisJson(json));
    }).toList();
  }

  Future<void> supprimerActionEnAttente(dynamic cle) {
    return _boiteFileAttente.delete(cle);
  }

  bool get aDesActionsEnAttente => _boiteFileAttente.isNotEmpty;
}
