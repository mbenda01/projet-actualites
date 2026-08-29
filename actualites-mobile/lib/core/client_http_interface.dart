import 'erreur_api.dart';

enum MethodeHttp { get, post, put, patch, delete }

abstract class ClientHttpInterface {
  Future<dynamic> requete(
    MethodeHttp methode,
    String chemin, {
    dynamic donnees,
    Map<String, dynamic>? parametres,
    bool authentifie = true,
  });

  ErreurApi traduireErreur(Object erreur);
}

extension ClientHttpRaccourcis on ClientHttpInterface {
  Future<dynamic> get(
    String chemin, {
    Map<String, dynamic>? parametres,
    bool authentifie = true,
  }) {
    return requete(
      MethodeHttp.get,
      chemin,
      parametres: parametres,
      authentifie: authentifie,
    );
  }

  Future<dynamic> post(
    String chemin, {
    dynamic donnees,
    bool authentifie = true,
  }) {
    return requete(
      MethodeHttp.post,
      chemin,
      donnees: donnees,
      authentifie: authentifie,
    );
  }

  Future<dynamic> put(
    String chemin, {
    dynamic donnees,
    bool authentifie = true,
  }) {
    return requete(
      MethodeHttp.put,
      chemin,
      donnees: donnees,
      authentifie: authentifie,
    );
  }

  Future<dynamic> patch(
    String chemin, {
    dynamic donnees,
    bool authentifie = true,
  }) {
    return requete(
      MethodeHttp.patch,
      chemin,
      donnees: donnees,
      authentifie: authentifie,
    );
  }

  Future<dynamic> delete(
    String chemin, {
    dynamic donnees,
    bool authentifie = true,
  }) {
    return requete(
      MethodeHttp.delete,
      chemin,
      donnees: donnees,
      authentifie: authentifie,
    );
  }
}
