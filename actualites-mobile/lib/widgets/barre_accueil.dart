import 'package:flutter/material.dart';

class BarreAccueil extends StatefulWidget implements PreferredSizeWidget {
  final String titre;

  final ValueChanged<String>? onRecherche;

  final VoidCallback? onFermetureRecherche;

  const BarreAccueil({
    super.key,
    required this.titre,
    this.onRecherche,
    this.onFermetureRecherche,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<BarreAccueil> createState() => _BarreAccueilState();
}

class _BarreAccueilState extends State<BarreAccueil> {
  final TextEditingController _controleur = TextEditingController();
  final FocusNode _focus = FocusNode();

  bool _modeRecherche = false;

  @override
  void dispose() {
    _controleur.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _ouvrirRecherche() {
    setState(() => _modeRecherche = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focus.requestFocus();
    });
  }

  void _fermerRecherche() {
    setState(() => _modeRecherche = false);
    _controleur.clear();
    _focus.unfocus();
    widget.onFermetureRecherche?.call();
  }

  void _effacerTexte() {
    _controleur.clear();
    widget.onRecherche?.call('');
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    if (_modeRecherche) {
      return _construireBarreRecherche();
    }
    return _construireBarreNormale(context);
  }

  Widget _construireBarreNormale(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        tooltip: 'Menu',
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      title: Text(
        widget.titre,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      actions: [
        if (widget.onRecherche != null)
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Rechercher',
            onPressed: _ouvrirRecherche,
          ),
        IconButton(
          icon: const Icon(Icons.account_circle, size: 30),
          tooltip: 'Profil',
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _construireBarreRecherche() {
    return AppBar(
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Quitter la recherche',
        onPressed: _fermerRecherche,
      ),
      title: TextField(
        controller: _controleur,
        focusNode: _focus,
        onChanged: (valeur) => widget.onRecherche?.call(valeur),
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(
          hintText: 'Rechercher un article...',
          border: InputBorder.none,
        ),
        style: const TextStyle(fontSize: 18),
      ),
      actions: [
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controleur,
          builder: (context, valeur, enfant) {
            if (valeur.text.isEmpty) return const SizedBox.shrink();

            return IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Effacer',
              onPressed: _effacerTexte,
            );
          },
        ),
      ],
    );
  }
}