package iibs.actualites.repository;

import iibs.actualites.entity.*;
import org.springframework.data.domain.*;
import org.springframework.data.mongodb.repository.*;
import org.springframework.stereotype.*;

import java.util.*;
import java.util.stream.*;

@Repository
public interface FavoriRepository extends MongoRepository<Favori, Long> {

    @Query("{ 'utilisateur.$id': ?0 }")
    List<Favori> trouverParUtilisateur(Long utilisateurId);

    @Query(value = "{ 'utilisateur.$id': ?0 }", sort = "{ 'dateEnregistrement': -1 }")
    List<Favori> trouverParUtilisateurTriePagine(Long utilisateurId, Pageable pageable);

    @Query("{ 'utilisateur.$id': ?0, 'article.$id': ?1 }")
    Optional<Favori> findByUtilisateurIdAndArticleId(Long utilisateurId, Long articleId);

    @ExistsQuery("{ 'utilisateur.$id': ?0, 'article.$id': ?1 }")
    boolean existsByUtilisateurIdAndArticleId(Long utilisateurId, Long articleId);

    @CountQuery("{ 'utilisateur.$id': ?0 }")
    long countByUtilisateurId(Long utilisateurId);

    default Set<Long> listerIdentifiantsArticles(Long utilisateurId) {
        return trouverParUtilisateur(utilisateurId).stream()
                .map(favori -> favori.getArticle().getId())
                .collect(Collectors.toSet());
    }

    default Page<Article> listerArticles(Long utilisateurId, Pageable pageable) {
        List<Article> articles = trouverParUtilisateurTriePagine(utilisateurId, pageable)
                .stream()
                .map(Favori::getArticle)
                .toList();

        return new PageImpl<>(articles, pageable, countByUtilisateurId(utilisateurId));
    }

    default int supprimer(Long utilisateurId, Long articleId) {
        Optional<Favori> favori = findByUtilisateurIdAndArticleId(utilisateurId, articleId);
        favori.ifPresent(this::delete);
        return favori.isPresent() ? 1 : 0;
    }

    default int supprimerTout(Long utilisateurId) {
        List<Favori> favoris = trouverParUtilisateur(utilisateurId);
        deleteAll(favoris);
        return favoris.size();
    }
}
