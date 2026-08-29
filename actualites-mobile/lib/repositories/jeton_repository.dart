import '../models/jetons.dart';

abstract class JetonRepository {
  Future<Jetons?> lireJetons();
  Future<void> enregistrerJetons(Jetons jetons);
  Future<void> effacerJetons();
}