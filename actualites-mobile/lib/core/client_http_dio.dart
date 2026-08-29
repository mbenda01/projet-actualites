import 'package:dio/dio.dart';

import 'client_http_interface.dart';
import 'erreur_api.dart';
import 'journal.dart';
import '../models/jetons.dart';
import '../repositories/jeton_repository.dart';

final _optionsPubliques = Options(
  extra: {'ignorerAuthentification': true},
);

class ClientHttpDio implements ClientHttpInterface {
  static const String _origine = 'ClientHttpDio';

  final Dio _dio;
  final JetonRepository _depotJetons;
  final Journal _journal;

  Future<Jetons?>? _rafraichissementEnCours;

  ClientHttpDio({
    required String urlBase,
    required JetonRepository depotJetons,
    required Journal journal,
    Dio? dio,
  })  : _depotJetons = depotJetons,
        _journal = journal,
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: urlBase,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            )) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _surRequete,
        onError: _surErreur,
      ),
    );
  }

  @override
  Future<dynamic> requete(
    MethodeHttp methode,
    String chemin, {
    dynamic donnees,
    Map<String, dynamic>? parametres,
    bool authentifie = true,
  }) async {
    final options = authentifie ? null : _optionsPubliques;

    final Response reponse = switch (methode) {
      MethodeHttp.get => await _dio.get(
          chemin,
          queryParameters: parametres,
          options: options,
        ),
      MethodeHttp.post => await _dio.post(
          chemin,
          data: donnees,
          options: options,
        ),
      MethodeHttp.put => await _dio.put(
          chemin,
          data: donnees,
          options: options,
        ),
      MethodeHttp.patch => await _dio.patch(
          chemin,
          data: donnees,
          options: options,
        ),
      MethodeHttp.delete => await _dio.delete(
          chemin,
          data: donnees,
          options: options,
        ),
    };

    return reponse.data;
  }

  Future<void> _surRequete(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['ignorerAuthentification'] == true) {
      handler.next(options);
      return;
    }

    final jetons = await _depotJetons.lireJetons();

    if (jetons != null && !jetons.estExpire) {
      options.headers['Authorization'] = jetons.enTeteAutorisation;
    }

    handler.next(options);
  }

  Future<void> _surErreur(
    DioException erreur,
    ErrorInterceptorHandler handler,
  ) async {
    final requete = erreur.requestOptions;
    final estUne401 = erreur.response?.statusCode == 401;
    final dejaTentee = requete.extra['rafraichissementTente'] == true;
    final ignoreAuthentification =
        requete.extra['ignorerAuthentification'] == true;

    if (!estUne401 || dejaTentee || ignoreAuthentification) {
      handler.next(erreur);
      return;
    }

    _journal.debug(_origine, '401 reçu, tentative de rafraîchissement');

    final nouveauxJetons = await _rafraichir();

    if (nouveauxJetons == null) {
      _journal.avertissement(_origine, 'Rafraîchissement échoué');
      handler.next(erreur);
      return;
    }

    try {
      final nouvelleRequete = await _dio.fetch(requete
        ..headers['Authorization'] = nouveauxJetons.enTeteAutorisation
        ..extra['rafraichissementTente'] = true);

      handler.resolve(nouvelleRequete);
    } on DioException catch (nouvelleErreur) {
      handler.next(nouvelleErreur);
    }
  }

  Future<Jetons?> _rafraichir() {
    return _rafraichissementEnCours ??= _executerRafraichissement();
  }

  Future<Jetons?> _executerRafraichissement() async {
    try {
      final jetonsActuels = await _depotJetons.lireJetons();

      if (jetonsActuels == null) return null;

      final reponse = await _dio.post(
        '/api/auth/rafraichissement',
        data: {'jetonRafraichissement': jetonsActuels.jetonRafraichissement},
        options: _optionsPubliques,
      );

      final donnees = reponse.data['data'] as Map<String, dynamic>;
      final nouveauxJetons = Jetons.depuisJson(donnees);

      await _depotJetons.enregistrerJetons(nouveauxJetons);

      _journal.info(_origine, 'Jetons renouvelés');

      return nouveauxJetons;
    } catch (erreur) {
      _journal.erreur(_origine, 'Échec du rafraîchissement', erreur);
      await _depotJetons.effacerJetons();
      return null;
    } finally {
      _rafraichissementEnCours = null;
    }
  }

  @override
  ErreurApi traduireErreur(Object erreur) {
    if (erreur is! DioException) {
      return ErreurInconnue(erreur.toString());
    }

    if (erreur.type == DioExceptionType.connectionTimeout ||
        erreur.type == DioExceptionType.receiveTimeout ||
        erreur.type == DioExceptionType.connectionError) {
      return const ErreurReseau();
    }

    final statut = erreur.response?.statusCode;
    final corps = erreur.response?.data;

    final message = corps is Map<String, dynamic>
        ? corps['message'] as String? ?? 'Erreur'
        : 'Erreur';

    switch (statut) {
      case 400:
        final donnees = corps is Map<String, dynamic> ? corps['data'] : null;
        if (donnees is Map) {
          final champs = donnees.map(
            (cle, valeur) => MapEntry(cle.toString(), valeur.toString()),
          );
          return ErreurValidation(champs, message);
        }
        return ErreurValidation(const {}, message);
      case 401:
        return ErreurAuthentification(message);
      case 403:
        return ErreurAccesRefuse(message);
      case 404:
        return ErreurRessourceIntrouvable(message);
      case 409:
        return ErreurConflit(message);
      case null:
        return const ErreurReseau();
      default:
        if (statut >= 500) return ErreurServeur(message);
        return ErreurInconnue(message);
    }
  }
}
