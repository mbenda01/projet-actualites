import 'package:flutter/material.dart';

class BarreRetour extends StatelessWidget implements PreferredSizeWidget {
  final String titre;

  const BarreRetour({
    super.key,
    required this.titre,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.5,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Retour',
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        titre,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
      ),
    );
  }
}