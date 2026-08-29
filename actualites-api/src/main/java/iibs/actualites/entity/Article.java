package iibs.actualites.entity;

import iibs.actualites.entity.enums.*;
import jakarta.persistence.*;
import lombok.*;

import java.time.*;
import java.util.*;

@Entity
@Table(
        name = "articles",
        indexes = {
                @Index(name = "idx_article_statut", columnList = "statut"),
                @Index(name = "idx_article_categorie", columnList = "categorie"),
                @Index(name = "idx_article_date_publication", columnList = "date_publication")
        }
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Article extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "titre", nullable = false, length = 250)
    private String titre;

    @Column(name = "chapeau", length = 500)
    private String chapeau;

    @ElementCollection(fetch = FetchType.LAZY)
    @CollectionTable(
            name = "article_paragraphes",
            joinColumns = @JoinColumn(name = "article_id")
    )
    @OrderColumn(name = "position")
    @Column(name = "contenu", columnDefinition = "TEXT")
    private List<String> paragraphes = new ArrayList<>();

    @Enumerated(EnumType.STRING)
    @Column(name = "categorie", nullable = false, length = 30)
    private Categorie categorie = Categorie.GENERAL;

    @Enumerated(EnumType.STRING)
    @Column(name = "statut", nullable = false, length = 20)
    private StatutArticle statut = StatutArticle.BROUILLON;

    @Column(name = "url_image", length = 500)
    private String urlImage;

    @Column(name = "libelle_image", length = 150)
    private String libelleImage;

    @Column(name = "duree_lecture_minutes")
    private Integer dureeLectureMinutes;

    @Column(name = "date_publication")
    private LocalDate datePublication;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "auteur_id", nullable = false)
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

