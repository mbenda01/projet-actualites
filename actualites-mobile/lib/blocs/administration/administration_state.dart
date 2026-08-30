import 'package:equatable/equatable.dart';

import '../../models/article.dart';

sealed class AdministrationState extends Equatable {
  const AdministrationState();

  @override
  List<Object?> get props => [];
}

class AdministrationInitial extends AdministrationState {
  const AdministrationInitial();
}

class AdministrationEnChargement extends AdministrationState {
  const AdministrationEnChargement();
}

class AdministrationChargee extends AdministrationState {
  final List<Article> articles;
  final int totalElements;

  final int? actionEnCoursSurId;

  const AdministrationChargee({
    required this.articles,
    required this.totalElements,
    this.actionEnCoursSurId,
  });

  AdministrationChargee copierAvec({
    List<Article>? articles,
    int? totalElements,
    int? actionEnCoursSurId,
    bool effacerActionEnCours = false,
  }) {
    return AdministrationChargee(
      articles: articles ?? this.articles,
      totalElements: totalElements ?? this.totalElements,
      actionEnCoursSurId: effacerActionEnCours
          ? null
          : (actionEnCoursSurId ?? this.actionEnCoursSurId),
    );
  }

  @override
  List<Object?> get props => [articles, totalElements, actionEnCoursSurId];
}

class AdministrationEchec extends AdministrationState {
  final String message;

  const AdministrationEchec(this.message);

  @override
  List<Object?> get props => [message];
}