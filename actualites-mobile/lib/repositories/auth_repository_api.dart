import '../core/client_http.dart';
import '../models/jetons.dart';
import '../models/utilisateur.dart';
import 'auth_repository.dart';
import 'jeton_repository.dart';

class AuthRepositoryApi implements AuthRepository {
  final ClientHttp _client;
  final JetonRepository _depotJetons;

  const AuthRepositoryApi({
    required ClientHttp client,
    required JetonRepository depotJetons,
  })  : _client = client,
        _depotJetons = depotJetons;

  @override
  Future<Jetons> inscrire(String nom, String email, String motDePasse) async {
    try {
      final reponse = await _client.dio.post(
        '/api/auth/inscription',
        data: {'nom': nom, 'email': email, 'motDePasse': motDePasse},
        options: dioOptionsPubliques,
      );

      final jetons = Jetons.depuisJson(
        reponse.data['data'] as Map<String, dynamic>,
      );

      await _depotJetons.enregistrerJetons(jetons);
      return jetons;
    } catch (erreur) {
      throw _client.traduireErreur(erreur);
    }
  }

  @override
  Future<Jetons> connecter(String email, String motDePasse) async {
    try {
      final reponse = await _client.dio.post(
        '/api/auth/connexion',
        data: {'email': email, 'motDePasse': motDePasse},
        options: dioOptionsPubliques,
      );

      final jetons = Jetons.depuisJson(
        reponse.data['data'] as Map<String, dynamic>,
      );

      await _depotJetons.enregistrerJetons(jetons);
      return jetons;
    } catch (erreur) {
      throw _client.traduireErreur(erreur);
    }
  }

  @override
  Future<Utilisateur> profilCourant() async {
    try {
      final reponse = await _client.dio.get('/api/auth/profil');

      return Utilisateur.depuisJson(
        reponse.data['data'] as Map<String, dynamic>,
      );
    } catch (erreur) {
      throw _client.traduireErreur(erreur);
    }
  }

  @override
  Future<void> deconnecter() async {
    await _depotJetons.effacerJetons();
  }
}