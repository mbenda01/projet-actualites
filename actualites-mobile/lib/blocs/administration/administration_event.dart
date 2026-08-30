import 'package:equatable/equatable.dart';

import '../../models/article.dart';
import '../../models/enums.dart';

sealed class AdministrationEvent extends Equatable {
  const AdministrationEvent();

  @override
  List<Object?> get props => [];
}

class AdministrationChargementDemande extends AdministrationEvent {
  const AdministrationChargementDemande();
}

class AdministrationRafraichissementDemande extends AdministrationEvent {
  const AdministrationRafraichissementDemande();
}

class AdministrationArticleCree extends AdministrationEvent {
  final Article article;

  const AdministrationArticleCree(this.article);

  @override
  List<Object?> get props => [article];
}

class AdministrationArticleModifie extends AdministrationEvent {
  final int id;
  final Article article;

  const AdministrationArticleModifie(this.id, this.article);

  @override
  List<Object?> get props => [id, article];
}

class AdministrationStatutChange extends AdministrationEvent {
  final int id;
  final StatutArticle statut;

  const AdministrationStatutChange(this.id, this.statut);

  @override
  List<Object?> get props => [id, statut];
}

class AdministrationArticleArchive extends AdministrationEvent {
  final int id;

  const AdministrationArticleArchive(this.id);

  @override
  List<Object?> get props => [id];
}