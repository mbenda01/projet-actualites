import '../models/jetons.dart';
import '../models/utilisateur.dart';

abstract class AuthRepository {
  Future<Jetons> inscrire(String nom, String email, String motDePasse);
  Future<Jetons> connecter(String email, String motDePasse);
  Future<Utilisateur> profilCourant();
  Future<void> deconnecter();
}