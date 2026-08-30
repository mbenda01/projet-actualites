import '../core/client_http_dio.dart';
import '../core/client_http_interface.dart';
import '../core/journal.dart';
import '../repositories/article_repository.dart';
import '../repositories/article_repository_api.dart';
import '../repositories/article_repository_hors_ligne.dart';
import '../repositories/auth_repository.dart';
import '../repositories/auth_repository_api.dart';
import '../repositories/favoris_repository.dart';
import '../repositories/favoris_repository_api.dart';
import '../repositories/favoris_repository_hors_ligne.dart';
import '../repositories/jeton_repository.dart';
import '../repositories/jeton_repository_securise.dart';
import '../repositories/theme_repository.dart';
import '../repositories/theme_repository_local.dart';
import '../services/synchronisation_service.dart';

const String urlBaseApi = 'https://projet-actualites.onrender.com';

class InjectionDepots {
  final Journal journal;
  final JetonRepository depotJetons;
  final AuthRepository depotAuth;
  final ArticleRepository depotArticles;
  final FavorisRepository depotFavoris;
  final ThemeRepository depotTheme;
  final SynchronisationService synchronisation;

  InjectionDepots._({
    required this.journal,
    required this.depotJetons,
    required this.depotAuth,
    required this.depotArticles,
    required this.depotFavoris,
    required this.depotTheme,
    required this.synchronisation,
  });

  factory InjectionDepots.construire() {
    final journal = JournalConsole();
    final depotJetons = JetonRepositorySecurise();

    final ClientHttpInterface client = ClientHttpDio(
      urlBase: urlBaseApi,
      depotJetons: depotJetons,
      journal: journal,
    );

    final depotArticlesDistant = ArticleRepositoryApi(client: client);
    final depotFavorisDistant = FavorisRepositoryApi(client: client);

    final depotArticles = ArticleRepositoryHorsLigne(distant: depotArticlesDistant);
    final depotFavoris = FavorisRepositoryHorsLigne(distant: depotFavorisDistant);

    final synchronisation = SynchronisationService(
      distant: depotFavorisDistant,
      journal: journal,
    )..demarrer();

    return InjectionDepots._(
      journal: journal,
      depotJetons: depotJetons,
      depotAuth: AuthRepositoryApi(client: client, depotJetons: depotJetons),
      depotArticles: depotArticles,
      depotFavoris: depotFavoris,
      depotTheme: const ThemeRepositoryLocal(),
      synchronisation: synchronisation,
    );
  }
}
