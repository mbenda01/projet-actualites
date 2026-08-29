package iibs.actualites.repository;

import iibs.actualites.entity.*;
import iibs.actualites.entity.enums.*;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.*;
import org.springframework.stereotype.*;

import java.util.*;

@Repository
public interface ArticleRepository extends JpaRepository<Article, Long> {

    @Query(
            value = """
                    SELECT a FROM Article a
                    LEFT JOIN FETCH a.auteur
                    WHERE a.statut = :statut
                    """,
            countQuery = "SELECT COUNT(a) FROM Article a WHERE a.statut = :statut"
    )
    Page<Article> rechercherParStatut(
            @Param("statut") StatutArticle statut,
            Pageable pageable
    );

    @Query(
            value = """
                    SELECT a FROM Article a
                    LEFT JOIN FETCH a.auteur
                    WHERE a.statut = :statut
                      AND a.categorie = :categorie
                    """,
            countQuery = """
                    SELECT COUNT(a) FROM Article a
                    WHERE a.statut = :statut AND a.categorie = :categorie
                    """
    )
    Page<Article> rechercherParStatutEtCategorie(
            @Param("statut") StatutArticle statut,
            @Param("categorie") Categorie categorie,
            Pageable pageable
    );

    @Query(
            value = """
                    SELECT a FROM Article a
                    LEFT JOIN FETCH a.auteur au
                    WHERE a.statut = :statut
                      AND (
                        LOWER(a.titre) LIKE LOWER(CONCAT('%', :terme, '%'))
                        OR LOWER(a.chapeau) LIKE LOWER(CONCAT('%', :terme, '%'))
                        OR LOWER(au.nom) LIKE LOWER(CONCAT('%', :terme, '%'))
                      )
                    """,
            countQuery = """
                    SELECT COUNT(a) FROM Article a
                    LEFT JOIN a.auteur au
                    WHERE a.statut = :statut
                      AND (
                        LOWER(a.titre) LIKE LOWER(CONCAT('%', :terme, '%'))
                        OR LOWER(a.chapeau) LIKE LOWER(CONCAT('%', :terme, '%'))
                        OR LOWER(au.nom) LIKE LOWER(CONCAT('%', :terme, '%'))
                      )
                    """
    )
    Page<Article> rechercherParTerme(
            @Param("statut") StatutArticle statut,
            @Param("terme") String terme,
            Pageable pageable
    );

    @Query("""
            SELECT a FROM Article a
            LEFT JOIN FETCH a.auteur
            LEFT JOIN FETCH a.paragraphes
            WHERE a.id = :id
            """)
    Optional<Article> chargerComplet(@Param("id") Long id);

    Page<Article> findByAuteurId(Long auteurId, Pageable pageable);

    long countByStatut(StatutArticle statut);
}