import 'package:equatable/equatable.dart';

import 'enums.dart';

class Article extends Equatable {
  final int id;
  final String titre;
  final String? chapeau;
  final List<String> paragraphes;
  final Categorie categorie;
  final StatutArticle statut;
  final String? urlImage;
  final String? libelleImage;
  final int? dureeLectureMinutes;
  final DateTime? datePublication;
  final int? auteurId;
  final String? auteurNom;

  const Article({
    required this.id,
    required this.titre,
    this.chapeau,
    this.paragraphes = const [],
    this.categorie = Categorie.general,
    this.statut = StatutArticle.brouillon,
    this.urlImage,
    this.libelleImage,
    this.dureeLectureMinutes,
    this.datePublication,
    this.auteurId,
    this.auteurNom,
  });

  bool get aDuContenu => paragraphes.isNotEmpty;

  bool get aUneImage => urlImage != null && urlImage!.isNotEmpty;

  bool get estPublie => statut.estPublic;

  bool get estComplet => paragraphes.isNotEmpty;

  String get datePublicationFormatee {
    final date = datePublication;
    if (date == null) return '';

    const mois = [
      'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
    ];

    return '${date.day} ${mois[date.month - 1]} ${date.year}';
  }

  String get dureeLectureFormatee {
    final duree = dureeLectureMinutes;
    if (duree == null) return '';
    return '$duree min de lecture';
  }

  factory Article.depuisJson(Map<String, dynamic> json) {
    return Article(
      id: _lireEntier(json['id']) ?? 0,
      titre: _lireTexte(json['titre']) ?? 'Sans titre',
      chapeau: _lireTexte(json['chapeau']),
      paragraphes: _lireListeTexte(json['paragraphes']),
      categorie: Categorie.depuisJson(json['categorie']),
      statut: StatutArticle.depuisJson(json['statut']),
      urlImage: _lireTexte(json['urlImage']),
      libelleImage: _lireTexte(json['libelleImage']),
      dureeLectureMinutes: _lireEntier(json['dureeLectureMinutes']),
      datePublication: _lireDate(json['datePublication']),
      auteurId: _lireEntier(json['auteurId']),
      auteurNom: _lireTexte(json['auteurNom']),
    );
  }

  Map<String, dynamic> versJson() {
    return {
      'titre': titre,
      'chapeau': chapeau,
      'paragraphes': paragraphes,
      'categorie': categorie.code,
      'urlImage': urlImage,
      'libelleImage': libelleImage,
      'dureeLectureMinutes': dureeLectureMinutes,
      'datePublication': datePublication?.toIso8601String().split('T').first,
    };
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

  static List<String> _lireListeTexte(Object? valeur) {
    if (valeur is! List) return const [];

    final resultats = <String>[];
    for (final element in valeur) {
      if (element is String && element.trim().isNotEmpty) {
        resultats.add(element);
      }
    }
    return List.unmodifiable(resultats);
  }

  static DateTime? _lireDate(Object? valeur) {
    if (valeur is! String) return null;
    return DateTime.tryParse(valeur);
  }

  Article copierAvec({
    List<String>? paragraphes,
    StatutArticle? statut,
  }) {
    return Article(
      id: id,
      titre: titre,
      chapeau: chapeau,
      paragraphes: paragraphes ?? this.paragraphes,
      categorie: categorie,
      statut: statut ?? this.statut,
      urlImage: urlImage,
      libelleImage: libelleImage,
      dureeLectureMinutes: dureeLectureMinutes,
      datePublication: datePublication,
      auteurId: auteurId,
      auteurNom: auteurNom,
    );
  }

  @override
  List<Object?> get props => [
        id,
        titre,
        chapeau,
        paragraphes,
        categorie,
        statut,
        urlImage,
        libelleImage,
        dureeLectureMinutes,
        datePublication,
        auteurId,
        auteurNom,
      ];

  @override
  String toString() => 'Article($id, $titre)';
}