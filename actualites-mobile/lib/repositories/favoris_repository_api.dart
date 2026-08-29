import '../core/client_http.dart';
import '../models/article.dart';
import '../models/page_resultat.dart';
import 'favoris_repository.dart';

class FavorisRepositoryApi implements FavorisRepository {
  final ClientHttp _client;

  const FavorisRepositoryApi({required ClientHttp client}) : _client = client;

  @override
  Future<Set<int>> listerIdentifiants() async {
    try {
      final reponse = await _client.dio.get('/api/favoris');

      final donnees = reponse.data['data'] as Map<String, dynamic>;
      final identifiants = donnees['identifiants'] as List;

      return identifiants.map((valeur) => valeur as int).toSet();
    } catch (erreur) {
      throw _client.traduireErreur(erreur);
    }
  }

  @override
  Future<PageResultat<Article>> listerArticles({
    int page = 0,
    int taille = 20,
  }) async {
    try {
      final reponse = await _client.dio.get(
        '/api/favoris/articles',
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
  Future<bool> basculer(int articleId) async {
    try {
      final reponse = await _client.dio.post('/api/favoris/$articleId');

      return reponse.data['data'] as bool;
    } catch (erreur) {
      throw _client.traduireErreur(erreur);
    }
  }

  @override
  Future<void> retirer(int articleId) async {
    try {
      await _client.dio.delete('/api/favoris/$articleId');
    } catch (erreur) {
      throw _client.traduireErreur(erreur);
    }
  }

  @override
  Future<void> toutRetirer() async {
    try {
      await _client.dio.delete('/api/favoris');
    } catch (erreur) {
      throw _client.traduireErreur(erreur);
    }
  }
}