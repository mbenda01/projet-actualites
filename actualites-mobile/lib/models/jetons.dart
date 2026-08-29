class Jetons {
  final String jetonAcces;
  final String jetonRafraichissement;
  final String typeJeton;
  final int expiresIn;
  final DateTime emisLe;

  const Jetons({
    required this.jetonAcces,
    required this.jetonRafraichissement,
    required this.typeJeton,
    required this.expiresIn,
    required this.emisLe,
  });

  String get enTeteAutorisation => '$typeJeton $jetonAcces';

  DateTime get expireLe => emisLe.add(Duration(seconds: expiresIn));

  bool get estExpire => DateTime.now().isAfter(expireLe);

  bool get bientotExpire {
    final marge = DateTime.now().add(const Duration(seconds: 30));
    return marge.isAfter(expireLe);
  }

  factory Jetons.depuisJson(Map<String, dynamic> json) {
    return Jetons(
      jetonAcces: json['jetonAcces'] as String? ?? '',
      jetonRafraichissement: json['jetonRafraichissement'] as String? ?? '',
      typeJeton: json['typeJeton'] as String? ?? 'Bearer',
      expiresIn: _lireEntier(json['expiresIn']) ?? 900,
      emisLe: DateTime.now(),
    );
  }

  Map<String, dynamic> versJson() {
    return {
      'jetonAcces': jetonAcces,
      'jetonRafraichissement': jetonRafraichissement,
      'typeJeton': typeJeton,
      'expiresIn': expiresIn,
      'emisLe': emisLe.toIso8601String(),
    };
  }

  factory Jetons.depuisStockage(Map<String, dynamic> json) {
    return Jetons(
      jetonAcces: json['jetonAcces'] as String? ?? '',
      jetonRafraichissement: json['jetonRafraichissement'] as String? ?? '',
      typeJeton: json['typeJeton'] as String? ?? 'Bearer',
      expiresIn: _lireEntier(json['expiresIn']) ?? 900,
      emisLe: DateTime.tryParse(json['emisLe'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  static int? _lireEntier(Object? valeur) {
    if (valeur is int) return valeur;
    if (valeur is num) return valeur.toInt();
    if (valeur is String) return int.tryParse(valeur);
    return null;
  }

  @override
  String toString() => 'Jetons(expire dans ${expiresIn}s)';
}