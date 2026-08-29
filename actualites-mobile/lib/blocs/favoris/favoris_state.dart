import 'package:equatable/equatable.dart';

class FavorisState extends Equatable {
  final Set<int> identifiants;
  final bool enChargement;
  final String? erreur;

  const FavorisState({
    this.identifiants = const {},
    this.enChargement = false,
    this.erreur,
  });

  bool contient(int articleId) => identifiants.contains(articleId);

  int get nombre => identifiants.length;

  FavorisState copierAvec({
    Set<int>? identifiants,
    bool? enChargement,
    String? erreur,
    bool effacerErreur = false,
  }) {
    return FavorisState(
      identifiants: identifiants ?? this.identifiants,
      enChargement: enChargement ?? this.enChargement,
      erreur: effacerErreur ? null : (erreur ?? this.erreur),
    );
  }

  @override
  List<Object?> get props => [identifiants, enChargement, erreur];
}