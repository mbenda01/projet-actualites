import '../core/client_http_interface.dart';
import '../models/article.dart';
import '../models/page_resultat.dart';
import 'api_repository_base.dart';
import 'favoris_repository.dart';

class FavorisRepositoryApi extends ApiRepositoryBase
    implements FavorisRepository {
  const FavorisRepositoryApi({required ClientHttpInterface client})
      : super(client: client);

  @override
  Future<Set<int>> listerIdentifiants() {
    return executer(
      () => client.get('/api/favoris'),
      (donnees) {
        final identifiants = (donnees as Map<String, dynamic>)['identifiants'] as List;
        return identifiants.map((valeur) => valeur as int).toSet();
      },
    );
  }

  @override
  Future<PageResultat<Article>> listerArticles({
    int page = 0,
    int taille = 20,
  }) {
    return executer(
      () => client.get(
        '/api/favoris/articles',
        parametres: {'page': page, 'size': taille},
      ),
      (donnees) => PageResultat.depuisJson(
        donnees as Map<String, dynamic>,
        Article.depuisJson,
      ),
    );
  }

  @override
  Future<bool> basculer(int articleId) {
    return executer(
      () => client.post('/api/favoris/$articleId'),
      (donnees) => donnees as bool,
    );
  }

  @override
  Future<void> retirer(int articleId) {
    return executer(
      () => client.delete('/api/favoris/$articleId'),
      (_) {},
    );
  }

  @override
  Future<void> toutRetirer() {
    return executer(
      () => client.delete('/api/favoris'),
      (_) {},
    );
  }
}
