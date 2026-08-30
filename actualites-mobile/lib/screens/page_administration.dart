import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/administration/administration_bloc.dart';
import '../blocs/administration/administration_event.dart';
import '../blocs/administration/administration_state.dart';
import '../models/article.dart';
import '../models/enums.dart';
import '../routes/app_routes.dart';
import '../widgets/barre_retour.dart';

class PageAdministration extends StatefulWidget {
  const PageAdministration({super.key});

  @override
  State<PageAdministration> createState() => _PageAdministrationState();
}

class _PageAdministrationState extends State<PageAdministration> {
  @override
  void initState() {
    super.initState();
    context.read<AdministrationBloc>().add(const AdministrationChargementDemande());
  }

  void _ouvrirCreation() async {
    final cree = await Navigator.pushNamed(context, Routes.editionArticle);
    if (cree == true && mounted) {
      context.read<AdministrationBloc>().add(const AdministrationRafraichissementDemande());
    }
  }

  void _ouvrirEdition(Article article) async {
    final modifie = await Navigator.pushNamed(
      context,
      Routes.editionArticle,
      arguments: article,
    );
    if (modifie == true && mounted) {
      context.read<AdministrationBloc>().add(const AdministrationRafraichissementDemande());
    }
  }

  Future<void> _confirmerArchivage(Article article) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (contexteDialogue) => AlertDialog(
        title: const Text('Archiver cet article ?'),
        content: Text(
          '« ${article.titre} » ne sera plus visible du public. Cette action reste réversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexteDialogue, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(contexteDialogue, true),
            child: const Text('Archiver'),
          ),
        ],
      ),
    );

    if (confirme == true && mounted) {
      context.read<AdministrationBloc>().add(AdministrationArticleArchive(article.id));
    }
  }

  void _publier(Article article) {
    context
        .read<AdministrationBloc>()
        .add(AdministrationStatutChange(article.id, StatutArticle.publie));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarreRetour(titre: 'Gestion des articles'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ouvrirCreation,
        icon: const Icon(Icons.add),
        label: const Text('Nouvel article'),
      ),
      body: BlocBuilder<AdministrationBloc, AdministrationState>(
        builder: (context, etat) {
          return switch (etat) {
            AdministrationInitial() ||
            AdministrationEnChargement() =>
              const Center(child: CircularProgressIndicator()),
            AdministrationEchec() => _construireErreur(etat.message),
            AdministrationChargee() => _construireListe(etat),
          };
        },
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
            const Icon(Icons.lock_outline, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context
                  .read<AdministrationBloc>()
                  .add(const AdministrationChargementDemande()),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireListe(AdministrationChargee etat) {
    if (etat.articles.isEmpty) {
      return const Center(child: Text('Aucun article pour le moment.'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<AdministrationBloc>().add(const AdministrationRafraichissementDemande());
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: etat.articles.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final article = etat.articles[index];
          final enCours = etat.actionEnCoursSurId == article.id;

          return _construireLigne(article, enCours);
        },
      ),
    );
  }

  Widget _construireLigne(Article article, bool enCours) {
    final couleurs = Theme.of(context).colorScheme;

    return ListTile(
      onTap: enCours ? null : () => _ouvrirEdition(article),
      leading: _construirePastilleStatut(article.statut),
      title: Text(
        article.titre,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        article.auteurNom ?? 'Auteur inconnu',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: enCours
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : PopupMenuButton<String>(
              onSelected: (choix) {
                switch (choix) {
                  case 'editer':
                    _ouvrirEdition(article);
                  case 'publier':
                    _publier(article);
                  case 'archiver':
                    _confirmerArchivage(article);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'editer', child: Text('Modifier')),
                if (article.statut != StatutArticle.publie)
                  const PopupMenuItem(value: 'publier', child: Text('Publier')),
                if (article.statut != StatutArticle.archive)
                  PopupMenuItem(
                    value: 'archiver',
                    child: Text('Archiver', style: TextStyle(color: couleurs.error)),
                  ),
              ],
            ),
    );
  }

  Widget _construirePastilleStatut(StatutArticle statut) {
    final Color couleur;
    switch (statut) {
      case StatutArticle.publie:
        couleur = Colors.green;
      case StatutArticle.brouillon:
        couleur = Colors.orange;
      case StatutArticle.archive:
        couleur = Colors.grey;
    }

    return CircleAvatar(
      radius: 6,
      backgroundColor: couleur,
    );
  }
}