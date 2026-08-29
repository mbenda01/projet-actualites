package iibs.actualites.repository;

import iibs.actualites.entity.*;
import iibs.actualites.entity.enums.*;
import org.springframework.data.domain.*;
import org.springframework.data.mongodb.repository.*;
import org.springframework.stereotype.*;

import java.util.*;

@Repository
public interface ArticleRepository
        extends MongoRepository<Article, Long>, ArticleRepositoryPersonnalise {

    Page<Article> findByStatut(StatutArticle statut, Pageable pageable);

    Page<Article> findByStatutAndCategorie(
            StatutArticle statut,
            Categorie categorie,
            Pageable pageable
    );

    long countByStatut(StatutArticle statut);

    default Optional<Article> chargerComplet(Long id) {
        return findById(id);
    }
}
