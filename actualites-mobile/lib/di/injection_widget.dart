import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/article_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/favoris_repository.dart';
import '../repositories/jeton_repository.dart';
import '../repositories/theme_repository.dart';
import '../core/journal.dart';
import '../services/synchronisation_service.dart';
import 'injection_depots.dart';
import 'injection_blocs.dart';

class Injection extends StatefulWidget {
  final Widget enfant;

  const Injection({super.key, required this.enfant});

  @override
  State<Injection> createState() => _InjectionState();
}

class _InjectionState extends State<Injection> {
  late final InjectionDepots _depots;

  @override
  void initState() {
    super.initState();
    _depots = InjectionDepots.construire();
  }

  @override
  void dispose() {
    _depots.synchronisation.arreter();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<Journal>.value(value: _depots.journal),
        RepositoryProvider<JetonRepository>.value(value: _depots.depotJetons),
        RepositoryProvider<AuthRepository>.value(value: _depots.depotAuth),
        RepositoryProvider<ArticleRepository>.value(value: _depots.depotArticles),
        RepositoryProvider<FavorisRepository>.value(value: _depots.depotFavoris),
        RepositoryProvider<ThemeRepository>.value(value: _depots.depotTheme),
        RepositoryProvider<SynchronisationService>.value(value: _depots.synchronisation),
      ],
      child: MultiBlocProvider(
        providers: InjectionBlocs.fournisseurs,
        child: widget.enfant,
      ),
    );
  }
}
