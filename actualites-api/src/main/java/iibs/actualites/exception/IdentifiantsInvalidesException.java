package iibs.actualites.exception;

public class IdentifiantsInvalidesException extends RuntimeException {

    public IdentifiantsInvalidesException(String message) {
        super(message);
    }

    public IdentifiantsInvalidesException() {
        super("Identifiants invalides");
    }
}
