package iibs.actualites.entity.enums;

public enum StatutArticle {

    BROUILLON("Brouillon"),
    PUBLIE("Publié"),
    ARCHIVE("Archivé");

    private final String libelle;

    StatutArticle(String libelle) {
        this.libelle = libelle;
    }

    public String getLibelle() {
        return libelle;
    }

    public boolean estPublic() {
        return this == PUBLIE;
    }
}