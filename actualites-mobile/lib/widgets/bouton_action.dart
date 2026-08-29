import 'package:flutter/material.dart';

class BoutonAction extends StatelessWidget {
  final IconData icone;
  final String libelle;
  final VoidCallback? onPressed;
  final bool plein;

  const BoutonAction({
    super.key,
    required this.icone,
    required this.libelle,
    this.onPressed,
    this.plein = true,
  });

  const BoutonAction.plein({
    super.key,
    required this.icone,
    required this.libelle,
    this.onPressed,
  }) : plein = true;

  const BoutonAction.contour({
    super.key,
    required this.icone,
    required this.libelle,
    this.onPressed,
  }) : plein = false;

  @override
  Widget build(BuildContext context) {
    final forme = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    );

    const marge = EdgeInsets.symmetric(vertical: 16);

    final contenu = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 20),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            libelle,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );

    if (plein) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(padding: marge, shape: forme),
        child: contenu,
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(padding: marge, shape: forme),
      child: contenu,
    );
  }
}