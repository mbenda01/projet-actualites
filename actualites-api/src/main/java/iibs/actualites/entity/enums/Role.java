package iibs.actualites.entity.enums;

public enum Role {

    ADMIN("Administrateur"),
    LECTEUR("Lecteur");

    private final String libelle;

    Role(String libelle) {
        this.libelle = libelle;
    }

    public String getLibelle() {
        return libelle;
    }

    public String autorite() {
        return "ROLE_" + name();
    }
}