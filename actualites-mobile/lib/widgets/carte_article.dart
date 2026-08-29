import 'package:flutter/material.dart';
import '../models/article.dart';
import 'zone_image.dart';
import 'titre_article.dart';
import 'meta_article.dart';

class CarteArticle extends StatelessWidget {
  final Article article;
  final VoidCallback? onTap;

  const CarteArticle({
    super.key,
    required this.article,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ZoneImage.vignette(
                libelle: article.libelleImage,
                urlImage: article.urlImage,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TitreArticle.compact(texte: article.titre),
                    const SizedBox(height: 10),
                    MetaArticle.dateSeule(datePublication: article.datePublicationFormatee),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}