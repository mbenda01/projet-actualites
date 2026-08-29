sealed class ErreurApi implements Exception {
  final String message;

  const ErreurApi(this.message);
}

class ErreurReseau extends ErreurApi {
  const ErreurReseau([super.message = 'Connexion impossible']);
}

class ErreurAuthentification extends ErreurApi {
  const ErreurAuthentification([super.message = 'Authentification requise']);
}

class ErreurAccesRefuse extends ErreurApi {
  const ErreurAccesRefuse([super.message = 'Accès refusé']);
}

class ErreurRessourceIntrouvable extends ErreurApi {
  const ErreurRessourceIntrouvable([super.message = 'Ressource introuvable']);
}

class ErreurValidation extends ErreurApi {
  final Map<String, String> champs;

  const ErreurValidation(this.champs, [super.message = 'Validation échouée']);
}

class ErreurConflit extends ErreurApi {
  const ErreurConflit([super.message = 'Conflit']);
}

class ErreurServeur extends ErreurApi {
  const ErreurServeur([super.message = 'Erreur serveur']);
}

class ErreurInconnue extends ErreurApi {
  const ErreurInconnue([super.message = 'Erreur inattendue']);
}