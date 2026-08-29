import 'package:flutter/material.dart';

class MetaArticle extends StatelessWidget {
  final String datePublication;
  final String? dureeLecture;
  final String? auteur;
  final double taillePolice;

  const MetaArticle({
    super.key,
    required this.datePublication,
    this.dureeLecture,
    this.auteur,
    this.taillePolice = 15,
  });

  const MetaArticle.dateSeule({
    super.key,
    required this.datePublication,
  })  : dureeLecture = null,
        auteur = null,
        taillePolice = 16;

  String _composer() {
    final fragments = <String>[datePublication];

    if (dureeLecture != null) {
      fragments.add(dureeLecture!);
    }
    if (auteur != null) {
      fragments.add('Par $auteur');
    }

    return fragments.join('  |  ');
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _composer(),
      style: TextStyle(
        fontSize: taillePolice,
        color: Theme.of(context).textTheme.bodySmall?.color,
      ),
    );
  }
}