import 'package:flutter/material.dart';

import '../models/article.dart';
import '../screens/ecran_connexion.dart';
import '../screens/ecran_detail_article.dart';
import '../screens/page_a_propos.dart';
import '../screens/page_reglages.dart';

class Routes {
  const Routes._();

  static const String accueil = '/';
  static const String connexion = '/connexion';
  static const String detailArticle = '/article';
  static const String reglages = '/reglages';
  static const String aPropos = '/a-propos';

  static Map<String, WidgetBuilder> get table => {
        connexion: (context) => const EcranConnexion(),
        reglages: (context) => const PageReglages(),
        aPropos: (context) => const PageAPropos(),
      };

  static Route<dynamic>? generer(RouteSettings parametres) {
    switch (parametres.name) {
      case detailArticle:
        final argument = parametres.arguments;

        if (argument is! Article) return null;

        return MaterialPageRoute(
          builder: (context) => EcranDetailArticle(article: argument),
          settings: parametres,
        );

      default:
        return null;
    }
  }

  static Route<dynamic> inconnue(RouteSettings parametres) {
    return MaterialPageRoute(
      builder: (context) => _EcranIntrouvable(nomRoute: parametres.name),
    );
  }
}

class _EcranIntrouvable extends StatelessWidget {
  final String? nomRoute;

  const _EcranIntrouvable({this.nomRoute});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page introuvable')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.help_outline, size: 48),
              const SizedBox(height: 16),
              Text(
                nomRoute == null
                    ? "Cette page n'existe pas."
                    : "La route « $nomRoute » est introuvable.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.accueil,
                  (route) => false,
                ),
                child: const Text("Retour à l'accueil"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}