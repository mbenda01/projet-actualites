import '../core/erreur_api.dart';
import '../models/article.dart';
import '../models/page_resultat.dart';
import 'cache/favoris_cache_hive.dart';
import 'favoris_repository.dart';

class FavorisRepositoryHorsLigne implements FavorisRepository {
  final FavorisRepository _distant;
  final FavorisCacheHive _cache;

  FavorisRepositoryHorsLigne({
    required FavorisRepository distant,
    FavorisCacheHive cache = const FavorisCacheHive(),
  })  : _distant = distant,
        _cache = cache;

  @override
  Future<Set<int>> listerIdentifiants() async {
    try {
      final identifiants = await _distant.listerIdentifiants();
      await _cache.enregistrerIdentifiants(identifiants);
      return identifiants;
    } on ErreurReseau {
      final local = _cache.lireIdentifiants();
      if (local != null) return local;
      rethrow;
    }
  }

  @override
  Future<PageResultat<Article>> listerArticles({int page = 0, int taille = 20}) async {
    try {
      final resultat = await _distant.listerArticles(page: page, taille: taille);
      if (page == 0) await _cache.enregistrerPage(resultat);
      return resultat;
    } on ErreurReseau {
      if (page == 0) {
        final local = _cache.lirePage();
        if (local != null) return local;
      }
      rethrow;
    }
  }

  @override
  Future<bool> basculer(int articleId) async {
    try {
      final estFavori = await _distant.basculer(articleId);
      await _mettreAJourCache(articleId, favori: estFavori);
      return estFavori;
    } on ErreurReseau {
      final identifiantsLocaux = _cache.lireIdentifiants() ?? <int>{};
      final nouvelEtat = !identifiantsLocaux.contains(articleId);

      await _mettreAJourCache(articleId, favori: nouvelEtat);
      await _cache.ajouterActionBasculer(articleId);

      return nouvelEtat;
    }
  }

  @override
  Future<void> retirer(int articleId) async {
    try {
      await _distant.retirer(articleId);
      await _mettreAJourCache(articleId, favori: false);
    } on ErreurReseau {
      await _mettreAJourCache(articleId, favori: false);
      await _cache.ajouterActionRetirer(articleId);
    }
  }

  @override
  Future<void> toutRetirer() async {
    try {
      await _distant.toutRetirer();
      await _cache.enregistrerIdentifiants(const {});
    } on ErreurReseau {
      await _cache.enregistrerIdentifiants(const {});
      await _cache.ajouterActionToutRetirer();
    }
  }

  Future<void> _mettreAJourCache(int articleId, {required bool favori}) async {
    final identifiants = Set<int>.from(_cache.lireIdentifiants() ?? <int>{});
    if (favori) {
      identifiants.add(articleId);
    } else {
      identifiants.remove(articleId);
    }
    await _cache.enregistrerIdentifiants(identifiants);
  }
}
