import '../core/client_http.dart';
import '../models/article.dart';
import '../models/enums.dart';
import '../models/page_resultat.dart';
import 'article_repository.dart';

class ArticleRepositoryApi implements ArticleRepository {
  final ClientHttp _client;

  const ArticleRepositoryApi({required ClientHttp client}) : _client = client;

  @override
  Future<PageResultat<Article>> listerPublies({
    Categorie? categorie,
    String? recherche,
    int page = 0,
    int taille = 20,
  }) async {
    try {
      final reponse = await _client.dio.get(
        '/api/articles',
        queryParameters: {
          'page': page,
          'size': taille,
          if (categorie != null) 'categorie': categorie.code,
          if (recherche != null && recherche.isNotEmpty) 'recherche': recherche,
        },
        options: dioOptionsPubliques,
      );

      return PageResultat.depuisJson(
        reponse.data['data'] as Map<String, dynamic>,
        Article.depuisJson,
      );
    } catch (erreur) {
      throw _client.traduireErreur(erreur);
    }
  }

  @override
  Future<PageResultat<Article>> listerTous({
    int page = 0,
    int taille = 20,
  }) async {
    try {
      final reponse = await _client.dio.get(
        '/api/articles/administration',
        queryParameters: {'page': page, 'size': taille},
      );

      return PageResultat.depuisJson(
        reponse.data['data'] as Map<String, dynamic>,
        Article.depuisJson,
      );
    } catch (erreur) {
      throw _client.traduireErreur(erreur);
    }
  }

  @override
  Future<Article> obtenirPublie(int id) async {
    try {
      final reponse = await _client.dio.get(
        '/api/articles/$id',
        options: dioOptionsPubliques,
      );

      return Article.depuisJson(reponse.data['data'] as Map<String, dynamic>);
    } catch (erreur) {
      throw _client.traduireErreur(erreur);
    }
  }

  @override
  Future<Article> obtenirParId(int id) async {
    try {
      final reponse = await _client.dio.get('/api/articles/administration/$id');

      return Article.depuisJson(reponse.data['data'] as Map<String, dynamic>);
    } catch (erreur) {
      throw _client.traduireErreur(erreur);
    }
  }

  @override
  Future<Article> creer(Article article) async {
    try {
      final reponse = await _client.dio.post(
        '/api/articles',
        data: article.versJson(),
      );

      return Article.depuisJson(reponse.data['data'] as Map<String, dynamic>);
    } catch (erreur) {
      throw _client.traduireErreur(erreur);
    }
  }

  @override
  Future<Article> modifier(int id, Article article) async {
    try {
      final reponse = await _client.dio.put(
        '/api/articles/$id',
        data: article.versJson(),
      );

      return Article.depuisJson(reponse.data['data'] as Map<String, dynamic>);
    } catch (erreur) {
      throw _client.traduireErreur(erreur);
    }
  }

  @override
  Future<Article> changerStatut(int id, StatutArticle statut) async {
    try {
      final reponse = await _client.dio.patch(
        '/api/articles/$id/statut',
        data: {'statut': statut.code},
      );

      return Article.depuisJson(reponse.data['data'] as Map<String, dynamic>);
    } catch (erreur) {
      throw _client.traduireErreur(erreur);
    }
  }

  @override
  Future<void> archiver(int id) async {
    try {
      await _client.dio.delete('/api/articles/$id');
    } catch (erreur) {
      throw _client.traduireErreur(erreur);
    }
  }
}