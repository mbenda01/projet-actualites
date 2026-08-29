import '../core/client_http_interface.dart';
import '../models/article.dart';
import '../models/enums.dart';
import '../models/page_resultat.dart';
import 'api_repository_base.dart';
import 'article_repository.dart';

class ArticleRepositoryApi extends ApiRepositoryBase
    implements ArticleRepository {
  const ArticleRepositoryApi({required ClientHttpInterface client})
      : super(client: client);

  @override
  Future<PageResultat<Article>> listerPublies({
    Categorie? categorie,
    String? recherche,
    int page = 0,
    int taille = 20,
  }) {
    return executer(
      () => client.get(
        '/api/articles',
        authentifie: false,
        parametres: {
          'page': page,
          'size': taille,
          if (categorie != null) 'categorie': categorie.code,
          if (recherche != null && recherche.isNotEmpty) 'recherche': recherche,
        },
      ),
      (donnees) => PageResultat.depuisJson(
        donnees as Map<String, dynamic>,
        Article.depuisJson,
      ),
    );
  }

  @override
  Future<PageResultat<Article>> listerTous({
    int page = 0,
    int taille = 20,
  }) {
    return executer(
      () => client.get(
        '/api/articles/administration',
        parametres: {'page': page, 'size': taille},
      ),
      (donnees) => PageResultat.depuisJson(
        donnees as Map<String, dynamic>,
        Article.depuisJson,
      ),
    );
  }

  @override
  Future<Article> obtenirPublie(int id) {
    return executer(
      () => client.get('/api/articles/$id', authentifie: false),
      (donnees) => Article.depuisJson(donnees as Map<String, dynamic>),
    );
  }

  @override
  Future<Article> obtenirParId(int id) {
    return executer(
      () => client.get('/api/articles/administration/$id'),
      (donnees) => Article.depuisJson(donnees as Map<String, dynamic>),
    );
  }

  @override
  Future<Article> creer(Article article) {
    return executer(
      () => client.post('/api/articles', donnees: article.versJson()),
      (donnees) => Article.depuisJson(donnees as Map<String, dynamic>),
    );
  }

  @override
  Future<Article> modifier(int id, Article article) {
    return executer(
      () => client.put('/api/articles/$id', donnees: article.versJson()),
      (donnees) => Article.depuisJson(donnees as Map<String, dynamic>),
    );
  }

  @override
  Future<Article> changerStatut(int id, StatutArticle statut) {
    return executer(
      () => client.patch(
        '/api/articles/$id/statut',
        donnees: {'statut': statut.code},
      ),
      (donnees) => Article.depuisJson(donnees as Map<String, dynamic>),
    );
  }

  @override
  Future<void> archiver(int id) {
    return executer(
      () => client.delete('/api/articles/$id'),
      (_) {},
    );
  }
}
