import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/articles/articles_bloc.dart';
import '../blocs/articles/articles_event.dart';
import '../blocs/articles/articles_state.dart';
import '../models/article.dart';
import '../routes/app_routes.dart';
import '../widgets/carte_article.dart';

class PageActualites extends StatefulWidget {
  const PageActualites({super.key});

  @override
  State<PageActualites> createState() => _PageActualitesState();
}

class _PageActualitesState extends State<PageActualites> {
  late final ScrollController _controleurDefilement;

  @override
  void initState() {
    super.initState();

    context.read<ArticlesBloc>().add(const ArticlesChargementDemande());

    _controleurDefilement = ScrollController()
      ..addListener(_surDefilement);
  }

  @override
  void dispose() {
    _controleurDefilement.removeListener(_surDefilement);
    _controleurDefilement.dispose();
    super.dispose();
  }

  void _surDefilement() {
    final position = _controleurDefilement.position;
    final seuil = position.maxScrollExtent - 200;

    if (position.pixels < seuil) {
      return;
    }

    context.read<ArticlesBloc>().add(const ArticlesPageSuivanteDemandee());
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
          ArticlesInitial() || ArticlesEnChargement() => _construireChargement(),
          ArticlesEchec() => _construireErreur(etat.message),
          ArticlesCharges() => etat.estVide
              ? _construireVide(etat.terme)
              : _construireListe(etat),
        };
      },
    );
  }

  Widget _construireChargement() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Chargement des articles...'),
        ],
      ),
    );
  }

  Widget _construireErreur(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context
                  .read<ArticlesBloc>()
                  .add(const ArticlesRafraichissementDemande()),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireVide(String terme) {
    if (terme.isEmpty) {
      return const Center(child: Text('Aucun article disponible.'));
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 48),
            const SizedBox(height: 16),
            Text(
              'Aucun résultat pour « $terme »',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text('Essayez un autre terme.'),
          ],
        ),
      ),
    );
  }

  Widget _construireListe(ArticlesCharges etat) {
    return Column(
      children: [
        if (etat.terme.isNotEmpty) _construireBandeauResultats(etat),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context
                  .read<ArticlesBloc>()
                  .add(const ArticlesRafraichissementDemande());
            },
            child: ListView.builder(
              controller: _controleurDefilement,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: etat.articles.length + (etat.chargementPageSuivante ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= etat.articles.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final article = etat.articles[index];
                return CarteArticle(
                  article: article,
                  onTap: () => _ouvrirArticle(article),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _construireBandeauResultats(ArticlesCharges etat) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          const Icon(Icons.search, size: 16),
          const SizedBox(width: 8),
          Text(
            etat.totalElements > 1
                ? '${etat.totalElements} résultats'
                : '${etat.totalElements} résultat',
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

