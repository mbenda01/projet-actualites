package iibs.actualites.exception;

public class RessourceNonTrouveeException extends RuntimeException {

    public RessourceNonTrouveeException(String message) {
        super(message);
    }

    public static RessourceNonTrouveeException pour(String ressource, Object identifiant) {
        return new RessourceNonTrouveeException(
                "%s introuvable : %s".formatted(ressource, identifiant)
        );
    }
}