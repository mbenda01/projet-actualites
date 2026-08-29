package iibs.actualites.entity;

import iibs.actualites.entity.enums.*;
import lombok.*;
import org.springframework.data.annotation.*;
import org.springframework.data.mongodb.core.index.*;
import org.springframework.data.mongodb.core.mapping.*;

import java.time.*;
import java.util.*;

@Document(collection = "articles")
@CompoundIndex(name = "idx_article_statut_date", def = "{'statut': 1, 'datePublication': -1}")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Article extends Auditable {

    @Id
    private Long id;

    private String titre;

    private String chapeau;

    private List<String> paragraphes = new ArrayList<>();

    @Indexed
    private Categorie categorie = Categorie.GENERAL;

    @Indexed
    private StatutArticle statut = StatutArticle.BROUILLON;

    private String urlImage;

    private String libelleImage;

    private Integer dureeLectureMinutes;

    @Indexed
    private LocalDate datePublication;

    @DBRef
    private Utilisateur auteur;

    private Article(String titre, Utilisateur auteur) {
        this.titre = titre;
        this.auteur = auteur;
        this.statut = StatutArticle.BROUILLON;
    }

    public static Article redigerBrouillon(String titre, Utilisateur auteur) {
        Objects.requireNonNull(titre, "Le titre est obligatoire");
        Objects.requireNonNull(auteur, "L'auteur est obligatoire");

        return new Article(titre.trim(), auteur);
    }

    public void modifierContenu(
            String titre,
            String chapeau,
            List<String> paragraphes,
            Categorie categorie,
            String urlImage,
            String libelleImage,
            Integer dureeLectureMinutes
    ) {
        Objects.requireNonNull(titre, "Le titre est obligatoire");

        this.titre = titre.trim();
        this.chapeau = chapeau;
        this.categorie = categorie == null ? Categorie.GENERAL : categorie;
        this.urlImage = urlImage;
        this.libelleImage = libelleImage;
        this.dureeLectureMinutes = dureeLectureMinutes;

        remplacerParagraphes(paragraphes);
    }

    public void remplacerParagraphes(List<String> nouveaux) {
        this.paragraphes.clear();

        if (nouveaux != null) {
            this.paragraphes.addAll(nouveaux);
        }
    }

    public void publier() {
        if (statut == StatutArticle.PUBLIE) {
            throw new IllegalStateException("L'article est deja publie");
        }

        this.statut = StatutArticle.PUBLIE;

        if (datePublication == null) {
            this.datePublication = LocalDate.now();
        }
    }

    public void repasserEnBrouillon() {
        if (statut == StatutArticle.BROUILLON) {
            throw new IllegalStateException("L'article est deja en brouillon");
        }

        this.statut = StatutArticle.BROUILLON;
    }

    public void archiver() {
        if (statut == StatutArticle.ARCHIVE) {
            throw new IllegalStateException("L'article est deja archive");
        }

        this.statut = StatutArticle.ARCHIVE;
    }

    public void changerStatut(StatutArticle nouveau) {
        Objects.requireNonNull(nouveau, "Le statut est obligatoire");

        switch (nouveau) {
            case PUBLIE -> publier();
            case BROUILLON -> repasserEnBrouillon();
            case ARCHIVE -> archiver();
        }
    }

    public boolean estPublie() {
        return statut != null && statut.estPublic();
    }

    public boolean aDuContenu() {
        return paragraphes != null && !paragraphes.isEmpty();
    }

    public boolean estRedigePar(Utilisateur utilisateur) {
        return utilisateur != null
                && auteur != null
                && Objects.equals(auteur.getId(), utilisateur.getId());
    }

    public List<String> getParagraphes() {
        return Collections.unmodifiableList(paragraphes);
    }

    @Override
    public String toString() {
        return "Article(%d, %s)".formatted(id, titre);
    }
}

