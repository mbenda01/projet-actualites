import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../routes/app_routes.dart';

class _EntreeMenu {
  final IconData icone;
  final String libelle;
  final int? indexOnglet;
  final String? route;

  const _EntreeMenu(
    this.icone,
    this.libelle, {
    this.indexOnglet,
    this.route,
  });

  bool get meneAUnOnglet => indexOnglet != null;
  bool get meneAUneRoute => route != null;
}

class MenuLateral extends StatelessWidget {
  final String? entreeActive;

  final ValueChanged<int>? onSelectionOnglet;

  const MenuLateral({
    super.key,
    this.entreeActive,
    this.onSelectionOnglet,
  });

  static const List<_EntreeMenu> _entrees = [
    _EntreeMenu(Icons.home_outlined, 'Actualités', indexOnglet: 0),
    _EntreeMenu(Icons.explore_outlined, 'Explorer', indexOnglet: 1),
    _EntreeMenu(Icons.bookmark_border, 'Enregistrés', indexOnglet: 2),
    _EntreeMenu(
      Icons.settings_outlined,
      'Réglages',
      route: Routes.reglages,
    ),
    _EntreeMenu(Icons.info_outline, 'À propos', route: Routes.aPropos),
  ];

  static const _EntreeMenu _entreeAdministration = _EntreeMenu(
    Icons.edit_note,
    'Gestion des articles',
    route: Routes.administration,
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, etatAuth) {
        final estAdmin = etatAuth is AuthAuthentifie && etatAuth.utilisateur.estAdmin;

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _construireEntete(context, etatAuth),
              ..._entrees.map((entree) => _construireEntree(context, entree)),
              if (estAdmin) ...[
                const Divider(),
                _construireEntree(context, _entreeAdministration),
              ],
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Déconnexion'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _construireEntete(BuildContext context, AuthState etatAuth) {
    final couleurs = Theme.of(context).colorScheme;
    final email = etatAuth is AuthAuthentifie ? etatAuth.utilisateur.email : '';

    return DrawerHeader(
      decoration: BoxDecoration(color: couleurs.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: couleurs.onPrimary,
            child: Icon(Icons.person, size: 32, color: couleurs.primary),
          ),
          const SizedBox(height: 12),
          Text(
            'Actualités',
            style: TextStyle(
              color: couleurs.onPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            email,
            style: TextStyle(
              color: couleurs.onPrimary.withValues(alpha: 0.75),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireEntree(BuildContext context, _EntreeMenu entree) {
    final couleurs = Theme.of(context).colorScheme;
    final estActive = entree.libelle == entreeActive;

    return ListTile(
      leading: Icon(
        entree.icone,
        color: estActive ? couleurs.primary : null,
      ),
      title: Text(
        entree.libelle,
        style: TextStyle(
          color: estActive ? couleurs.primary : null,
          fontWeight: estActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: estActive,
      selectedTileColor: couleurs.primary.withValues(alpha: 0.08),
      onTap: () => _gererClic(context, entree),
    );
  }

  void _gererClic(BuildContext context, _EntreeMenu entree) {
    Navigator.pop(context);

    if (entree.meneAUnOnglet) {
      onSelectionOnglet?.call(entree.indexOnglet!);
      return;
    }

    if (entree.meneAUneRoute) {
      Navigator.pushNamed(context, entree.route!);
    }
  }
}