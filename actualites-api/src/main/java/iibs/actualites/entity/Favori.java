package iibs.actualites.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.*;
import java.util.*;

@Entity
@Table(
        name = "favoris",
        uniqueConstraints = @UniqueConstraint(
                name = "uk_favori_utilisateur_article",
                columnNames = {"utilisateur_id", "article_id"}
        ),
        indexes = @Index(
                name = "idx_favori_utilisateur",
                columnList = "utilisateur_id"
        )
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Favori {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "utilisateur_id", nullable = false)
    private Utilisateur utilisateur;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "article_id", nullable = false)
    private Article article;

    @Column(name = "date_enregistrement", nullable = false, updatable = false)
    private LocalDateTime dateEnregistrement;

    private Favori(Utilisateur utilisateur, Article article) {
        this.utilisateur = utilisateur;
        this.article = article;
        this.dateEnregistrement = LocalDateTime.now();
    }

    public static Favori enregistrer(Utilisateur utilisateur, Article article) {
        Objects.requireNonNull(utilisateur, "L'utilisateur est obligatoire");
        Objects.requireNonNull(article, "L'article est obligatoire");

        return new Favori(utilisateur, article);
    }

    @PrePersist
    protected void avantInsertion() {
        if (dateEnregistrement == null) {
            dateEnregistrement = LocalDateTime.now();
        }
    }

    @Override
    public String toString() {
        return "Favori(%d)".formatted(id);
    }
}

