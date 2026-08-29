import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/favoris/favoris_bloc.dart';
import '../blocs/favoris/favoris_event.dart';
import '../blocs/favoris/favoris_state.dart';
import '../blocs/theme/theme_cubit.dart';
import '../routes/app_routes.dart';
import '../widgets/barre_retour.dart';

class PageReglages extends StatelessWidget {
  const PageReglages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarreRetour(titre: 'Réglages'),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _construireTitreSection(context, 'Compte'),
          _construireLigneCompte(context),

          const Divider(height: 32),

          _construireTitreSection(context, 'Apparence'),
          _construireSelecteurTheme(context),

          const Divider(height: 32),

          _construireTitreSection(context, 'Données'),
          _construireLigneFavoris(context),

          const Divider(height: 32),

          _construireTitreSection(context, 'Application'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('À propos'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, Routes.aPropos),
          ),

          const SizedBox(height: 16),
          _construireBoutonDeconnexion(context),
        ],
      ),
    );
  }

  Widget _construireTitreSection(BuildContext context, String texte) {
    final couleur = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        texte.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: couleur,
        ),
      ),
    );
  }

  Widget _construireLigneCompte(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, etat) {
        if (etat is! AuthAuthentifie) return const SizedBox.shrink();

        final couleurs = Theme.of(context).colorScheme;
        final utilisateur = etat.utilisateur;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: couleurs.primaryContainer,
            child: Text(
              utilisateur.initiale,
              style: TextStyle(color: couleurs.onPrimaryContainer),
            ),
          ),
          title: Text(utilisateur.nom),
          subtitle: Text(utilisateur.email),
        );
      },
    );
  }

  Widget _construireSelecteurTheme(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, modeActif) {
        return Column(
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              value: mode,
              groupValue: modeActif,
              onChanged: (choisi) {
                if (choisi != null) context.read<ThemeCubit>().changer(choisi);
              },
              title: Text(ThemeCubit.libelleDe(mode)),
              subtitle: mode == ThemeMode.system
                  ? const Text('Suit le réglage du téléphone')
                  : null,
              secondary: Icon(_iconeDe(mode)),
            );
          }).toList(),
        );
      },
    );
  }

  IconData _iconeDe(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  Widget _construireLigneFavoris(BuildContext context) {
    return BlocBuilder<FavorisBloc, FavorisState>(
      builder: (context, etat) {
        final nombre = etat.nombre;

        return ListTile(
          leading: const Icon(Icons.bookmark_border),
          title: const Text('Articles enregistrés'),
          subtitle: Text(nombre > 1 ? '$nombre articles' : '$nombre article'),
          trailing: nombre == 0
              ? null
              : TextButton(
                  onPressed: () => _confirmerSuppression(context),
                  child: const Text('Tout effacer'),
                ),
        );
      },
    );
  }

  Future<void> _confirmerSuppression(BuildContext context) async {
    final bloc = context.read<FavorisBloc>();

    final confirme = await showDialog<bool>(
      context: context,
      builder: (contexteDialogue) => AlertDialog(
        title: const Text('Effacer les favoris ?'),
        content: const Text(
          'Tous les articles enregistrés seront retirés. '
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexteDialogue, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(contexteDialogue, true),
            child: const Text('Effacer'),
          ),
        ],
      ),
    );

    if (confirme == true) {
      bloc.add(const FavorisToutRetireDemande());
    }
  }

  Widget _construireBoutonDeconnexion(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: () => _confirmerDeconnexion(context),
        icon: const Icon(Icons.logout),
        label: const Text('Se déconnecter'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
          side: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }

  Future<void> _confirmerDeconnexion(BuildContext context) async {
    final blocAuth = context.read<AuthBloc>();

    final confirme = await showDialog<bool>(
      context: context,
      builder: (contexteDialogue) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text(
          'Vous devrez vous reconnecter pour accéder à vos favoris.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexteDialogue, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(contexteDialogue, true),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );

    if (confirme == true) {
      blocAuth.add(const AuthDeconnexionDemandee());
    }
  }
}