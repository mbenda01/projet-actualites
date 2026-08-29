package iibs.actualites.entity.enums;

public enum Categorie {

    TECHNOLOGIE("Technologie"),
    ECONOMIE("Économie"),
    ENVIRONNEMENT("Environnement"),
    SANTE("Santé"),
    CULTURE("Culture"),
    SPORT("Sport"),
    GENERAL("Général");

    private final String libelle;

    Categorie(String libelle) {
        this.libelle = libelle;
    }

    public String getLibelle() {
        return libelle;
    }
}
