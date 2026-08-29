import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/article_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/favoris_repository.dart';
import '../repositories/jeton_repository.dart';
import '../repositories/theme_repository.dart';
import '../core/journal.dart';
import 'injection_depots.dart';
import 'injection_blocs.dart';

class Injection extends StatelessWidget {
  final Widget enfant;

  const Injection({super.key, required this.enfant});

  @override
  Widget build(BuildContext context) {
    final depots = InjectionDepots.construire();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<Journal>.value(value: depots.journal),
        RepositoryProvider<JetonRepository>.value(value: depots.depotJetons),
        RepositoryProvider<AuthRepository>.value(value: depots.depotAuth),
        RepositoryProvider<ArticleRepository>.value(value: depots.depotArticles),
        RepositoryProvider<FavorisRepository>.value(value: depots.depotFavoris),
        RepositoryProvider<ThemeRepository>.value(value: depots.depotTheme),
      ],
      child: MultiBlocProvider(
        providers: InjectionBlocs.fournisseurs,
        child: enfant,
      ),
    );
  }
}