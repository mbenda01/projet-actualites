import 'package:flutter/material.dart';

class ZoneImage extends StatelessWidget {
  final double? largeur;
  final double hauteur;
  final double rayonBordure;
  final String? libelle;
  final String? urlImage;
  final bool afficherLibelle;

  const ZoneImage({
    super.key,
    this.largeur,
    required this.hauteur,
    this.rayonBordure = 12,
    this.libelle,
    this.urlImage,
    this.afficherLibelle = false,
  });

  const ZoneImage.vignette({
    super.key,
    this.libelle,
    this.urlImage,
  })  : largeur = 80,
        hauteur = 80,
        rayonBordure = 12,
        afficherLibelle = false;

  const ZoneImage.banniere({
    super.key,
    this.libelle,
    this.urlImage,
  })  : largeur = double.infinity,
        hauteur = 200,
        rayonBordure = 16,
        afficherLibelle = true;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(rayonBordure),
      child: SizedBox(
        width: largeur,
        height: hauteur,
        child: urlImage == null
            ? _construireRepli(context)
            : Image.network(
                urlImage!,
                fit: BoxFit.cover,
                loadingBuilder: (context, enfant, progression) {
                  if (progression == null) return enfant;
                  return _construireChargement(context, progression);
                },
                errorBuilder: (context, erreur, trace) {
                  return _construireRepli(context);
                },
              ),
      ),
    );
  }

  Widget _construireChargement(
    BuildContext context,
    ImageChunkEvent progression,
  ) {
    final total = progression.expectedTotalBytes;
    final recu = progression.cumulativeBytesLoaded;

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: SizedBox(
          width: afficherLibelle ? 32 : 20,
          height: afficherLibelle ? 32 : 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value: total != null ? recu / total : null,
          ),
        ),
      ),
    );
  }

  Widget _construireRepli(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;

    return Container(
      color: couleurs.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_outlined,
              size: afficherLibelle ? 40 : 28,
              color: couleurs.onSurfaceVariant,
            ),
            if (afficherLibelle && libelle != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  libelle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: couleurs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}