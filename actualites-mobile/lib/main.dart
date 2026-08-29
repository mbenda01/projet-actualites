import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_state.dart';
import 'blocs/theme/theme_cubit.dart';
import 'di/injection_widget.dart';
import 'routes/app_routes.dart';
import 'screens/coquille_principale.docker dart';
import 'screens/ecran_connexion.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const Injection(enfant: Application()));
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Actualités',
          theme: ThemeApplication.clair,
          darkTheme: ThemeApplication.sombre,
          themeMode: mode,
          routes: Routes.table,
          onGenerateRoute: Routes.generer,
          onUnknownRoute: Routes.inconnue,
          home: const _EcranDeDemarrage(),
        );
      },
    );
  }
}

class _EcranDeDemarrage extends StatelessWidget {
  const _EcranDeDemarrage();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, etat) {
        return switch (etat) {
          AuthAuthentifie() => const CoquillePrincipale(),
          AuthNonAuthentifie() || AuthEchec() => const EcranConnexion(),
          AuthInitial() || AuthEnChargement() => const _EcranChargement(),
        };
      },
    );
  }
}

class _EcranChargement extends StatelessWidget {
  const _EcranChargement();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
