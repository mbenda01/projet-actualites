import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/favoris/favoris_bloc.dart';
import '../blocs/favoris/favoris_event.dart';
import '../blocs/favoris/favoris_state.dart';
import '../models/article.dart';
import '../models/page_resultat.dart';
import '../repositories/favoris_repository.dart';
import '../routes/app_routes.dart';
import '../widgets/carte_article.dart';

class PageEnregistres extends StatefulWidget {
  const PageEnregistres({super.key});

  @override
  State<PageEnregistres> createState() => _PageEnregistresState();
}

class _PageEnregistresState extends State<PageEnregistres> {
  PageResultat<Article> _resultat = const PageResultat.vide();
  bool _enChargement = true;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    context.read<FavorisBloc>().add(const FavorisChargementDemande());
    _chargerArticles();
  }

  Future<void> _chargerArticles() async {
    setState(() {
      _enChargement = true;
      _erreur = null;
    });

    try {
      final depot = context.read<FavorisRepository>();
      final resultat = await depot.listerArticles();

      if (!mounted) return;

      setState(() {
        _resultat = resultat;
        _enChargement = false;
      });
    } catch (erreur) {
      if (!mounted) return;

      setState(() {
        _enChargement = false;
        _erreur = 'Impossible de charger les articles enregistrés';
      });
    }
  }

  void _ouvrirArticle(Article article) {
    Navigator.pushNamed(
      context,
      Routes.detailArticle,
      arguments: article,
    );
  }

  void _retirer(Article article) {
    context.read<FavorisBloc>().add(FavorisBascule(article.id));

    setState(() {
      _resultat = PageResultat(
        contenu: _resultat.contenu.where((a) => a.id != article.id).toList(),
        numeroPage: _resultat.numeroPage,
        taillePage: _resultat.taillePage,
        totalElements: _resultat.totalElements - 1,
        totalPages: _resultat.totalPages,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Article retiré des favoris'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () {
            context.read<FavorisBloc>().add(FavorisBascule(article.id));
            _chargerArticles();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FavorisBloc, FavorisState>(
      listenWhen: (avant, apres) => avant.identifiants != apres.identifiants,
      listener: (context, etat) => _chargerArticles(),
      child: _construireCorps(),
    );
  }

  Widget _construireCorps() {
    if (_enChargement) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erreur != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text(_erreur!, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _chargerArticles,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_resultat.estVide) {
      return _construireVide();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _resultat.contenu.length,
      itemBuilder: (context, index) {
        final article = _resultat.contenu[index];

        return Dismissible(
          key: ValueKey(article.id),
          direction: DismissDirection.endToStart,
          background: _construireFondSuppression(),
          onDismissed: (_) => _retirer(article),
          child: CarteArticle(
            article: article,
            onTap: () => _ouvrirArticle(article),
          ),
        );
      },
    );
  }

  Widget _construireFondSuppression() {
    final couleurs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.only(right: 24),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: couleurs.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.bookmark_remove, color: couleurs.onError, size: 28),
    );
  }

  Widget _construireVide() {
    final couleurs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: couleurs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bookmark_border,
                size: 44,
                color: couleurs.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucun article enregistré',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            const Text(
              "Touchez « Enregistrer » sur un article pour le retrouver ici.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
