import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/articles/articles_bloc.dart';
import '../blocs/articles/articles_event.dart';
import '../blocs/articles/articles_state.dart';
import '../blocs/favoris/favoris_bloc.dart';
import '../blocs/favoris/favoris_state.dart';
import '../models/article.dart';
import '../routes/app_routes.dart';

class PageExploration extends StatefulWidget {
  const PageExploration({super.key});

  @override
  State<PageExploration> createState() => _PageExplorationState();
}

class _PageExplorationState extends State<PageExploration> {
  @override
  void initState() {
    super.initState();

    final blocArticles = context.read<ArticlesBloc>();
    if (blocArticles.state is ArticlesInitial) {
      blocArticles.add(const ArticlesChargementDemande());
    }
  }

  Map<String, List<Article>> _grouperParAuteur(List<Article> articles) {
    final groupes = <String, List<Article>>{};

    for (final article in articles) {
      final auteur = article.auteurNom ?? 'Auteur inconnu';
      groupes.putIfAbsent(auteur, () => []).add(article);
    }

    return groupes;
  }

  void _ouvrirArticle(Article article) {
    Navigator.pushNamed(
      context,
      Routes.detailArticle,
      arguments: article,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArticlesBloc, ArticlesState>(
      builder: (context, etat) {
        return switch (etat) {
          ArticlesInitial() || ArticlesEnChargement() =>
            const Center(child: CircularProgressIndicator()),
          ArticlesEchec() => Center(
              child: Text('Impossible de charger les auteurs : ${etat.message}'),
            ),
          ArticlesCharges() => _construireContenu(etat.articles),
        };
      },
    );
  }

  Widget _construireContenu(List<Article> articles) {
    final groupes = _grouperParAuteur(articles);

    if (groupes.isEmpty) {
      return const Center(child: Text('Aucun auteur à explorer.'));
    }

    final entrees = groupes.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: entrees.length,
      itemBuilder: (context, index) {
        final entree = entrees[index];
        return _construireCarteAuteur(entree.key, entree.value);
      },
    );
  }

  Widget _construireCarteAuteur(String auteur, List<Article> articles) {
    final couleurs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: couleurs.primary,
          child: Text(
            auteur.isNotEmpty ? auteur[0].toUpperCase() : '?',
            style: TextStyle(
              color: couleurs.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          auteur,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          articles.length > 1 ? '${articles.length} articles' : '1 article',
          style: const TextStyle(fontSize: 13),
        ),
        children:
            articles.map((article) => _construireLigne(article)).toList(),
      ),
    );
  }

  Widget _construireLigne(Article article) {
    final couleurs = Theme.of(context).colorScheme;

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.only(left: 72, right: 16),
      title: Text(
        article.titre,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Text(
        article.datePublicationFormatee,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: BlocBuilder<FavorisBloc, FavorisState>(
        builder: (context, etatFavoris) {
          final estFavori = etatFavoris.contient(article.id);

          return Icon(
            estFavori ? Icons.bookmark : Icons.chevron_right,
            size: 20,
            color: estFavori ? couleurs.primary : null,
          );
        },
      ),
      onTap: () => _ouvrirArticle(article),
    );
  }
}
