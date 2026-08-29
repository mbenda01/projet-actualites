import 'package:equatable/equatable.dart';

import '../../models/enums.dart';

sealed class ArticlesEvent extends Equatable {
  const ArticlesEvent();

  @override
  List<Object?> get props => [];
}

class ArticlesChargementDemande extends ArticlesEvent {
  const ArticlesChargementDemande();
}

class ArticlesRafraichissementDemande extends ArticlesEvent {
  const ArticlesRafraichissementDemande();
}

class ArticlesPageSuivanteDemandee extends ArticlesEvent {
  const ArticlesPageSuivanteDemandee();
}

class ArticlesFiltreChange extends ArticlesEvent {
  final Categorie? categorie;

  const ArticlesFiltreChange(this.categorie);

  @override
  List<Object?> get props => [categorie];
}

class ArticlesRechercheChangee extends ArticlesEvent {
  final String terme;

  const ArticlesRechercheChangee(this.terme);

  @override
  List<Object?> get props => [terme];
}