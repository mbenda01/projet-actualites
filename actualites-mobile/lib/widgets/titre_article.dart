import 'package:flutter/material.dart';

class TitreArticle extends StatelessWidget {
  final String texte;
  final double taillePolice;
  final int? lignesMax;

  const TitreArticle({
    super.key,
    required this.texte,
    this.taillePolice = 20,
    this.lignesMax,
  });

  const TitreArticle.compact({
    super.key,
    required this.texte,
  })  : taillePolice = 19,
        lignesMax = 3;

  const TitreArticle.large({
    super.key,
    required this.texte,
  })  : taillePolice = 24,
        lignesMax = null;

  @override
  Widget build(BuildContext context) {
    return Text(
      texte,
      maxLines: lignesMax,
      overflow: lignesMax != null ? TextOverflow.ellipsis : null,
      style: TextStyle(
        fontSize: taillePolice,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
    );
  }
}