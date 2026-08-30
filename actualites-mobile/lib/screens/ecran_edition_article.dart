import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/administration/administration_bloc.dart';
import '../blocs/administration/administration_event.dart';
import '../models/article.dart';
import '../models/enums.dart';

class EcranEditionArticle extends StatefulWidget {
  final Article? article;

  const EcranEditionArticle({super.key, this.article});

  @override
  State<EcranEditionArticle> createState() => _EcranEditionArticleState();
}

class _EcranEditionArticleState extends State<EcranEditionArticle> {
  final _formulaireCle = GlobalKey<FormState>();

  late final TextEditingController _controleurTitre;
  late final TextEditingController _controleurChapeau;
  late final TextEditingController _controleurParagraphes;
  late final TextEditingController _controleurUrlImage;
  late final TextEditingController _controleurLibelleImage;
  late final TextEditingController _controleurDuree;

  late Categorie _categorie;

  bool get _enModification => widget.article != null;

  @override
  void initState() {
    super.initState();

    final article = widget.article;

    _controleurTitre = TextEditingController(text: article?.titre ?? '');
    _controleurChapeau = TextEditingController(text: article?.chapeau ?? '');
    _controleurParagraphes = TextEditingController(
      text: article?.paragraphes.join('\n\n') ?? '',
    );
    _controleurUrlImage = TextEditingController(text: article?.urlImage ?? '');
    _controleurLibelleImage = TextEditingController(text: article?.libelleImage ?? '');
    _controleurDuree = TextEditingController(
      text: article?.dureeLectureMinutes?.toString() ?? '',
    );
    _categorie = article?.categorie ?? Categorie.general;
  }

  @override
  void dispose() {
    _controleurTitre.dispose();
    _controleurChapeau.dispose();
    _controleurParagraphes.dispose();
    _controleurUrlImage.dispose();
    _controleurLibelleImage.dispose();
    _controleurDuree.dispose();
    super.dispose();
  }

  void _enregistrer() {
    if (!_formulaireCle.currentState!.validate()) return;

    final paragraphes = _controleurParagraphes.text
        .split('\n\n')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    final urlImage = _controleurUrlImage.text.trim();
    final libelleImage = _controleurLibelleImage.text.trim();
    final chapeau = _controleurChapeau.text.trim();
    final duree = int.tryParse(_controleurDuree.text.trim());

    final article = Article(
      id: widget.article?.id ?? 0,
      titre: _controleurTitre.text.trim(),
      chapeau: chapeau.isEmpty ? null : chapeau,
      paragraphes: paragraphes,
      categorie: _categorie,
      urlImage: urlImage.isEmpty ? null : urlImage,
      libelleImage: libelleImage.isEmpty ? null : libelleImage,
      dureeLectureMinutes: duree,
    );

    if (_enModification) {
      context
          .read<AdministrationBloc>()
          .add(AdministrationArticleModifie(widget.article!.id, article));
    } else {
      context.read<AdministrationBloc>().add(AdministrationArticleCree(article));
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_enModification ? "Modifier l'article" : 'Nouvel article'),
      ),
      body: Form(
        key: _formulaireCle,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _controleurTitre,
              decoration: const InputDecoration(labelText: 'Titre'),
              validator: (valeur) {
                if (valeur == null || valeur.trim().length < 5) {
                  return 'Au moins 5 caractères';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controleurChapeau,
              decoration: const InputDecoration(labelText: 'Chapeau'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Categorie>(
              initialValue: _categorie,
              decoration: const InputDecoration(labelText: 'Catégorie'),
              items: Categorie.values
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat.libelle)))
                  .toList(),
              onChanged: (choix) {
                if (choix != null) setState(() => _categorie = choix);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controleurParagraphes,
              decoration: const InputDecoration(
                labelText: 'Contenu',
                helperText: 'Séparez les paragraphes par une ligne vide',
                alignLabelWithHint: true,
              ),
              maxLines: 10,
              validator: (valeur) {
                if (valeur == null || valeur.trim().isEmpty) {
                  return 'Le contenu est obligatoire';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controleurUrlImage,
              decoration: const InputDecoration(labelText: "URL de l'image"),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controleurLibelleImage,
              decoration: const InputDecoration(labelText: "Libellé de l'image"),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controleurDuree,
              decoration: const InputDecoration(labelText: 'Durée de lecture (minutes)'),
              keyboardType: TextInputType.number,
              validator: (valeur) {
                if (valeur == null || valeur.trim().isEmpty) return null;
                final entier = int.tryParse(valeur.trim());
                if (entier == null || entier < 1 || entier > 120) {
                  return 'Entre 1 et 120 minutes';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _enregistrer,
              child: Text(_enModification ? 'Enregistrer' : 'Créer'),
            ),
          ],
        ),
      ),
    );
  }
}