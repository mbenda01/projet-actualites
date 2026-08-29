import 'package:hive_flutter/hive_flutter.dart';

import '../../core/hive_boxes.dart';
import '../../models/article.dart';
import '../../models/enums.dart';
import '../../models/page_resultat.dart';

class ArticlesCacheHive {
  const ArticlesCacheHive();

  Box get _boite => Hive.box(HiveBoites.articles);

  String _clePage({Categorie? categorie, String? recherche, required int page}) {
    return 'page:${categorie?.code ?? '_'}:${recherche ?? '_'}:$page';
  }

  Future<void> enregistrerPage(
    PageResultat<Article> page, {
    Categorie? categorie,
    String? recherche,
  }) async {
    final cle = _clePage(categorie: categorie, recherche: recherche, page: page.numeroPage);

    await _boite.put(cle, {
      'contenu': page.contenu.map((article) => article.versJsonCache()).toList(),
      'numeroPage': page.numeroPage,
      'taillePage': page.taillePage,
      'totalElements': page.totalElements,
      'totalPages': page.totalPages,
    });

    for (final article in page.contenu) {
      await enregistrerArticle(article);
    }
  }

  PageResultat<Article>? lirePage({
    Categorie? categorie,
    String? recherche,
    required int page,
  }) {
    final brut = _boite.get(_clePage(categorie: categorie, recherche: recherche, page: page));
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

  Future<void> enregistrerArticle(Article article) {
    return _boite.put('article:${article.id}', article.versJsonCache());
  }

  Article? lireArticle(int id) {
    final brut = _boite.get('article:$id');
    if (brut == null) return null;
    return Article.depuisJson(Map<String, dynamic>.from(brut as Map));
  }
}
