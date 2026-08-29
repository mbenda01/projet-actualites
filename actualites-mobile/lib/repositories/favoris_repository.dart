import '../models/article.dart';
import '../models/page_resultat.dart';

abstract class FavorisRepository {
  Future<Set<int>> listerIdentifiants();
  Future<PageResultat<Article>> listerArticles({int page = 0, int taille = 20});
  Future<bool> basculer(int articleId);
  Future<void> retirer(int articleId);
  Future<void> toutRetirer();
}