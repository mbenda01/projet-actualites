import '../models/article.dart';
import '../models/enums.dart';
import '../models/page_resultat.dart';

abstract class ArticleRepository {
  Future<PageResultat<Article>> listerPublies({
    Categorie? categorie,
    String? recherche,
    int page = 0,
    int taille = 20,
  });

  Future<PageResultat<Article>> listerTous({
    int page = 0,
    int taille = 20,
  });

  Future<Article> obtenirPublie(int id);
  Future<Article> obtenirParId(int id);
  Future<Article> creer(Article article);
  Future<Article> modifier(int id, Article article);
  Future<Article> changerStatut(int id, StatutArticle statut);
  Future<void> archiver(int id);
}