import '../core/erreur_api.dart';
import '../models/article.dart';
import '../models/enums.dart';
import '../models/page_resultat.dart';
import 'article_repository.dart';
import 'cache/articles_cache_hive.dart';

class ArticleRepositoryHorsLigne implements ArticleRepository {
  final ArticleRepository _distant;
  final ArticlesCacheHive _cache;

  ArticleRepositoryHorsLigne({
    required ArticleRepository distant,
    ArticlesCacheHive cache = const ArticlesCacheHive(),
  })  : _distant = distant,
        _cache = cache;

  @override
  Future<PageResultat<Article>> listerPublies({
    Categorie? categorie,
    String? recherche,
    int page = 0,
    int taille = 20,
  }) async {
    try {
      final resultat = await _distant.listerPublies(
        categorie: categorie,
        recherche: recherche,
        page: page,
        taille: taille,
      );
      await _cache.enregistrerPage(resultat, categorie: categorie, recherche: recherche);
      return resultat;
    } on ErreurReseau {
      final local = _cache.lirePage(categorie: categorie, recherche: recherche, page: page);
      if (local != null) return local;
      rethrow;
    }
  }

  @override
  Future<Article> obtenirPublie(int id) async {
    try {
      final article = await _distant.obtenirPublie(id);
      await _cache.enregistrerArticle(article);
      return article;
    } on ErreurReseau {
      final local = _cache.lireArticle(id);
      if (local != null) return local;
      rethrow;
    }
  }

  @override
  Future<PageResultat<Article>> listerTous({int page = 0, int taille = 20}) {
    return _distant.listerTous(page: page, taille: taille);
  }

  @override
  Future<Article> obtenirParId(int id) => _distant.obtenirParId(id);

  @override
  Future<Article> creer(Article article) => _distant.creer(article);

  @override
  Future<Article> modifier(int id, Article article) => _distant.modifier(id, article);

  @override
  Future<Article> changerStatut(int id, StatutArticle statut) {
    return _distant.changerStatut(id, statut);
  }

  @override
  Future<void> archiver(int id) => _distant.archiver(id);
}
