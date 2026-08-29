package iibs.actualites.repository;

import iibs.actualites.entity.*;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.*;
import org.springframework.stereotype.*;
import org.springframework.transaction.annotation.*;

import java.util.*;


@Repository
public interface FavoriRepository extends JpaRepository<Favori, Long> {

    @Query("""
            SELECT f.article.id FROM Favori f
            WHERE f.utilisateur.id = :utilisateurId
            """)
    Set<Long> listerIdentifiantsArticles(
            @Param("utilisateurId") Long utilisateurId
    );

    @Query(
            value = """
                    SELECT f.article FROM Favori f
                    LEFT JOIN FETCH f.article.auteur
                    WHERE f.utilisateur.id = :utilisateurId
                    ORDER BY f.dateEnregistrement DESC
                    """,
            countQuery = """
                    SELECT COUNT(f) FROM Favori f
                    WHERE f.utilisateur.id = :utilisateurId
                    """
    )
    Page<Article> listerArticles(
            @Param("utilisateurId") Long utilisateurId,
            Pageable pageable
    );

    Optional<Favori> findByUtilisateurIdAndArticleId(
            Long utilisateurId,
            Long articleId
    );

    boolean existsByUtilisateurIdAndArticleId(Long utilisateurId, Long articleId);

    @Modifying
    @Transactional
    @Query("""
            DELETE FROM Favori f
            WHERE f.utilisateur.id = :utilisateurId
              AND f.article.id = :articleId
            """)
    int supprimer(
            @Param("utilisateurId") Long utilisateurId,
            @Param("articleId") Long articleId
    );

    @Modifying
    @Transactional
    @Query("DELETE FROM Favori f WHERE f.utilisateur.id = :utilisateurId")
    int supprimerTout(@Param("utilisateurId") Long utilisateurId);

    long countByUtilisateurId(Long utilisateurId);
}