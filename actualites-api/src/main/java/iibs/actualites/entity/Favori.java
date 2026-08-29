package iibs.actualites.entity;

import lombok.*;
import org.springframework.data.annotation.*;
import org.springframework.data.mongodb.core.index.*;
import org.springframework.data.mongodb.core.mapping.*;

import java.time.*;
import java.util.*;

@Document(collection = "favoris")
@CompoundIndex(
        name = "uk_favori_utilisateur_article",
        def = "{'utilisateur.$id': 1, 'article.$id': 1}",
        unique = true
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Favori {

    @Id
    private Long id;

    @DBRef
    @Indexed
    private Utilisateur utilisateur;

    @DBRef
    private Article article;

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

    @Override
    public String toString() {
        return "Favori(%d)".formatted(id);
    }
}

