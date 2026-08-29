import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/jetons.dart';
import 'jeton_repository.dart';

class JetonRepositorySecurise implements JetonRepository {
  static const String _cle = 'jetons_authentification';

  final FlutterSecureStorage _stockage;

  const JetonRepositorySecurise({
    FlutterSecureStorage? stockage,
  }) : _stockage = stockage ?? const FlutterSecureStorage();

  @override
  Future<Jetons?> lireJetons() async {
    final brut = await _stockage.read(key: _cle);
    if (brut == null) return null;

    try {
      final json = jsonDecode(brut) as Map<String, dynamic>;
      return Jetons.depuisStockage(json);
    } catch (_) {
      await effacerJetons();
      return null;
    }
  }

  @override
  Future<void> enregistrerJetons(Jetons jetons) async {
    final json = jsonEncode(jetons.versJson());
    await _stockage.write(key: _cle, value: json);
  }

  @override
  Future<void> effacerJetons() async {
    await _stockage.delete(key: _cle);
  }
}