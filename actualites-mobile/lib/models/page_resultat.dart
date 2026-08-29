class PageResultat<T> {
  final List<T> contenu;
  final int numeroPage;
  final int taillePage;
  final int totalElements;
  final int totalPages;

  const PageResultat({
    required this.contenu,
    required this.numeroPage,
    required this.taillePage,
    required this.totalElements,
    required this.totalPages,
  });

  const PageResultat.vide()
      : contenu = const [],
        numeroPage = 0,
        taillePage = 0,
        totalElements = 0,
        totalPages = 0;

  bool get estVide => contenu.isEmpty;

  bool get aUnePageSuivante => numeroPage + 1 < totalPages;

  int get pageSuivante => numeroPage + 1;

  factory PageResultat.depuisJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) convertirElement,
  ) {
    final brut = json['content'];
    final elements = <T>[];

    if (brut is List) {
      for (final element in brut) {
        if (element is Map<String, dynamic>) {
          elements.add(convertirElement(element));
        }
      }
    }

    return PageResultat<T>(
      contenu: List.unmodifiable(elements),
      numeroPage: _lireEntier(json['number']) ?? 0,
      taillePage: _lireEntier(json['size']) ?? elements.length,
      totalElements: _lireEntier(json['totalElements']) ?? elements.length,
      totalPages: _lireEntier(json['totalPages']) ?? 1,
    );
  }

  PageResultat<T> concatener(PageResultat<T> suivante) {
    return PageResultat<T>(
      contenu: List.unmodifiable([...contenu, ...suivante.contenu]),
      numeroPage: suivante.numeroPage,
      taillePage: suivante.taillePage,
      totalElements: suivante.totalElements,
      totalPages: suivante.totalPages,
    );
  }

  static int? _lireEntier(Object? valeur) {
    if (valeur is int) return valeur;
    if (valeur is num) return valeur.toInt();
    if (valeur is String) return int.tryParse(valeur);
    return null;
  }

  @override
  String toString() =>
      'PageResultat(${contenu.length}/$totalElements, page $numeroPage/$totalPages)';
}