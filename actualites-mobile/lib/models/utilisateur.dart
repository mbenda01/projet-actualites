import 'enums.dart';

class Utilisateur {
  final int id;
  final String nom;
  final String email;
  final Role role;
  final bool actif;
  final DateTime? dateCreation;

  const Utilisateur({
    required this.id,
    required this.nom,
    required this.email,
    this.role = Role.lecteur,
    this.actif = true,
    this.dateCreation,
  });

  bool get estAdmin => role.estAdmin;

  String get initiale => nom.isEmpty ? '?' : nom[0].toUpperCase();

  factory Utilisateur.depuisJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: _lireEntier(json['id']) ?? 0,
      nom: _lireTexte(json['nom']) ?? 'Utilisateur',
      email: _lireTexte(json['email']) ?? '',
      role: Role.depuisJson(json['role']),
      actif: json['actif'] is bool ? json['actif'] as bool : true,
      dateCreation: _lireDate(json['dateCreation']),
    );
  }

  static int? _lireEntier(Object? valeur) {
    if (valeur is int) return valeur;
    if (valeur is num) return valeur.toInt();
    if (valeur is String) return int.tryParse(valeur);
    return null;
  }

  static String? _lireTexte(Object? valeur) {
    if (valeur is! String) return null;
    final nettoye = valeur.trim();
    return nettoye.isEmpty ? null : nettoye;
  }

  static DateTime? _lireDate(Object? valeur) {
    if (valeur is! String) return null;
    return DateTime.tryParse(valeur);
  }

  @override
  String toString() => 'Utilisateur($id, ${role.code})';
}