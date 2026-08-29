enum Categorie {
  technologie('TECHNOLOGIE', 'Technologie'),
  economie('ECONOMIE', 'Économie'),
  environnement('ENVIRONNEMENT', 'Environnement'),
  sante('SANTE', 'Santé'),
  culture('CULTURE', 'Culture'),
  sport('SPORT', 'Sport'),
  general('GENERAL', 'Général');

  final String code;

  final String libelle;

  const Categorie(this.code, this.libelle);

  static Categorie depuisJson(Object? valeur) {
    if (valeur is! String) return Categorie.general;

    for (final categorie in Categorie.values) {
      if (categorie.code == valeur) return categorie;
    }

    return Categorie.general;
  }
}

enum StatutArticle {
  brouillon('BROUILLON', 'Brouillon'),
  publie('PUBLIE', 'Publié'),
  archive('ARCHIVE', 'Archivé');

  final String code;
  final String libelle;

  const StatutArticle(this.code, this.libelle);

  bool get estPublic => this == StatutArticle.publie;

  static StatutArticle depuisJson(Object? valeur) {
    if (valeur is! String) return StatutArticle.brouillon;

    for (final statut in StatutArticle.values) {
      if (statut.code == valeur) return statut;
    }

    return StatutArticle.brouillon;
  }
}

enum Role {
  admin('ADMIN', 'Administrateur'),
  lecteur('LECTEUR', 'Lecteur');

  final String code;
  final String libelle;

  const Role(this.code, this.libelle);

  bool get estAdmin => this == Role.admin;

  static Role depuisJson(Object? valeur) {
    if (valeur is! String) return Role.lecteur;

    for (final role in Role.values) {
      if (role.code == valeur) return role;
    }

    return Role.lecteur;
  }
}