import 'package:equatable/equatable.dart';

import '../../models/article.dart';
import '../../models/enums.dart';

sealed class ArticlesState extends Equatable {
  const ArticlesState();

  @override
  List<Object?> get props => [];
}

class ArticlesInitial extends ArticlesState {
  const ArticlesInitial();
}

class ArticlesEnChargement extends ArticlesState {
  const ArticlesEnChargement();
}

class ArticlesCharges extends ArticlesState {
  final List<Article> articles;
  final int totalElements;
  final bool aUnePageSuivante;
  final bool chargementPageSuivante;
  final Categorie? categorie;
  final String terme;

  const ArticlesCharges({
    required this.articles,
    required this.totalElements,
    required this.aUnePageSuivante,
    this.chargementPageSuivante = false,
    this.categorie,
    this.terme = '',
  });

  bool get estVide => articles.isEmpty;

  ArticlesCharges copierAvec({
    List<Article>? articles,
    int? totalElements,
    bool? aUnePageSuivante,
    bool? chargementPageSuivante,
    Categorie? categorie,
    bool categorieExplicitementNulle = false,
    String? terme,
  }) {
    return ArticlesCharges(
      articles: articles ?? this.articles,
      totalElements: totalElements ?? this.totalElements,
      aUnePageSuivante: aUnePageSuivante ?? this.aUnePageSuivante,
      chargementPageSuivante:
          chargementPageSuivante ?? this.chargementPageSuivante,
      categorie: categorieExplicitementNulle
          ? null
          : (categorie ?? this.categorie),
      terme: terme ?? this.terme,
    );
  }

  @override
  List<Object?> get props => [
        articles,
        totalElements,
        aUnePageSuivante,
        chargementPageSuivante,
        categorie,
        terme,
      ];
}

class ArticlesEchec extends ArticlesState {
  final String message;

  const ArticlesEchec(this.message);

  @override
  List<Object?> get props => [message];
}