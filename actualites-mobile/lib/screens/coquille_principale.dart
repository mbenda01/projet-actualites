import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/articles/articles_bloc.dart';
import '../blocs/articles/articles_event.dart';
import '../widgets/menu_lateral.dart';
import '../widgets/barre_accueil.dart';
import '../widgets/barre_navigation.dart';
import 'page_actualites.dart';
import 'page_exploration.dart';
import 'page_enregistres.dart';

class CoquillePrincipale extends StatefulWidget {
  const CoquillePrincipale({super.key});

  @override
  State<CoquillePrincipale> createState() => _CoquillePrincipaleState();
}

class _CoquillePrincipaleState extends State<CoquillePrincipale> {
  int _indexActif = 0;

  static const List<String> _titres = [
    'Actualités',
    'Explorer',
    'Enregistrés',
  ];

  void _changerOnglet(int index) {
    if (index < 0 || index >= _titres.length) return;
    if (index == _indexActif) return;

    setState(() {
      _indexActif = index;
    });
  }

  void _surRecherche(String terme) {
    context.read<ArticlesBloc>().add(ArticlesRechercheChangee(terme));
  }

  void _surFermetureRecherche() {
    context.read<ArticlesBloc>().add(const ArticlesRechercheChangee(''));
  }

  Widget _construirePage(int index) {
    switch (index) {
      case 1:
        return const PageExploration();
      case 2:
        return const PageEnregistres();
      default:
        return const PageActualites();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _indexActif == 0,
      onPopInvokedWithResult: (bool aQuitte, Object? resultat) {
        if (aQuitte) return;
        _changerOnglet(0);
      },
      child: Scaffold(
        appBar: BarreAccueil(
          titre: _titres[_indexActif],
          onRecherche: _indexActif == 0 ? _surRecherche : null,
          onFermetureRecherche: _surFermetureRecherche,
        ),
        drawer: MenuLateral(
          entreeActive: _titres[_indexActif],
          onSelectionOnglet: _changerOnglet,
        ),
        body: _construirePage(_indexActif),
        bottomNavigationBar: BarreNavigation(
          indexActif: _indexActif,
          onChangement: _changerOnglet,
        ),
      ),
    );
  }
}
