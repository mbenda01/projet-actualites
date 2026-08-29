import 'package:equatable/equatable.dart';

sealed class FavorisEvent extends Equatable {
  const FavorisEvent();

  @override
  List<Object?> get props => [];
}

class FavorisChargementDemande extends FavorisEvent {
  const FavorisChargementDemande();
}

class FavorisBascule extends FavorisEvent {
  final int articleId;

  const FavorisBascule(this.articleId);

  @override
  List<Object?> get props => [articleId];
}

class FavorisToutRetireDemande extends FavorisEvent {
  const FavorisToutRetireDemande();
}