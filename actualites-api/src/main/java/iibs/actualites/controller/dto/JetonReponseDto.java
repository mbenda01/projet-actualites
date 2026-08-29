package iibs.actualites.controller.dto;

public record JetonReponseDto(
        String jetonAcces,
        String jetonRafraichissement,
        String typeJeton,
        long expiresIn,
        UtilisateurReponseDto utilisateur
) {
    public static JetonReponseDto bearer(
            String jetonAcces,
            String jetonRafraichissement,
            long expiresIn,
            UtilisateurReponseDto utilisateur
    ) {
        return new JetonReponseDto(
                jetonAcces, jetonRafraichissement, "Bearer", expiresIn, utilisateur);
    }
}

