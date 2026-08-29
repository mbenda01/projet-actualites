import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/article_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/favoris_repository.dart';
import '../repositories/jeton_repository.dart';
import '../repositories/theme_repository.dart';
import '../core/journal.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/articles/articles_bloc.dart';
import '../blocs/favoris/favoris_bloc.dart';
import '../blocs/theme/theme_cubit.dart';

class InjectionBlocs {
  InjectionBlocs._();

    static List<BlocProvider> get fournisseurs => [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            depot: context.read<AuthRepository>(),
            depotJetons: context.read<JetonRepository>(),
            journal: context.read<Journal>(),
          )..add(const AuthDemarrageDemande()),
        ),
        BlocProvider<ArticlesBloc>(
          create: (context) => ArticlesBloc(
            depot: context.read<ArticleRepository>(),
            journal: context.read<Journal>(),
          ),
        ),
        BlocProvider<FavorisBloc>(
          create: (context) => FavorisBloc(
            depot: context.read<FavorisRepository>(),
            journal: context.read<Journal>(),
          ),
        ),
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(
            depot: context.read<ThemeRepository>(),
            journal: context.read<Journal>(),
          )..charger(),
        ),
      ];
}