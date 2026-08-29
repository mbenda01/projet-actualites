import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/favoris/favoris_bloc.dart';
import '../blocs/favoris/favoris_event.dart';
import '../blocs/favoris/favoris_state.dart';
import '../models/article.dart';
import '../repositories/article_repository.dart';
import '../widgets/barre_retour.dart';
import '../widgets/zone_image.dart';
import '../widgets/titre_article.dart';
import '../widgets/meta_article.dart';
import '../widgets/bouton_action.dart';

class EcranDetailArticle extends StatefulWidget {
  final Article article;

  const EcranDetailArticle({super.key, required this.article});

  @override
  State<EcranDetailArticle> createState() => _EcranDetailArticleState();
}

class _EcranDetailArticleState extends State<EcranDetailArticle> {
  late Article _article;
  bool _enChargement = false;

  @override
  void initState() {
    super.initState();
    _article = widget.article;

    if (!_article.estComplet) {
      _chargerDetailComplet();
    }
  }

  Future<void> _chargerDetailComplet() async {
    setState(() => _enChargement = true);

    try {
      final depot = context.read<ArticleRepository>();
      final complet = await depot.obtenirPublie(_article.id);

      if (!mounted) return;

      setState(() {
        _article = complet;
        _enChargement = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _enChargement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarreRetour(titre: "Détail de l'article"),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ZoneImage.banniere(
                    libelle: _article.libelleImage,
                    urlImage: _article.urlImage,
                  ),
                  const SizedBox(height: 20),
                  TitreArticle.large(texte: _article.titre),
                  const SizedBox(height: 8),
                  MetaArticle(
                    datePublication: _article.datePublicationFormatee,
                    dureeLecture: _article.dureeLectureFormatee,
                    auteur: _article.auteurNom,
                  ),
                  const SizedBox(height: 20),
                  ..._construireParagraphes(),
                ],
              ),
            ),
          ),
          _construireBarreActions(context),
        ],
      ),
    );
  }

  List<Widget> _construireParagraphes() {
    if (_enChargement) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (!_article.aDuContenu) return const [];

    return _article.paragraphes
        .map(
          (paragraphe) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              paragraphe,
              style: const TextStyle(fontSize: 17, height: 1.5),
            ),
          ),
        )
        .toList();
  }

  Widget _construireBarreActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Row(
        children: [
          Expanded(
            child: BoutonAction.plein(
              icone: Icons.ios_share,
              libelle: 'Partager',
              onPressed: () => _afficherMessage(context, 'Partage'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: _construireBoutonFavori(context)),
        ],
      ),
    );
  }

  Widget _construireBoutonFavori(BuildContext context) {
    return BlocBuilder<FavorisBloc, FavorisState>(
      builder: (context, etat) {
        final estEnregistre = etat.contient(_article.id);

        return BoutonAction.contour(
          icone: estEnregistre ? Icons.bookmark : Icons.bookmark_border,
          libelle: estEnregistre ? 'Enregistré' : 'Enregistrer',
          onPressed: () => _basculerFavori(context),
        );
      },
    );
  }

  void _basculerFavori(BuildContext context) {
    final bloc = context.read<FavorisBloc>();
    final etaitFavori = bloc.state.contient(_article.id);

    bloc.add(FavorisBascule(_article.id));

    _afficherMessage(
      context,
      etaitFavori ? 'Article retiré des favoris' : 'Article enregistré',
    );
  }

  void _afficherMessage(BuildContext context, String texte) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texte), duration: const Duration(seconds: 2)),
    );
  }
}