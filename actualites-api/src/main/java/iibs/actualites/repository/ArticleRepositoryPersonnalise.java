package iibs.actualites.repository;

import iibs.actualites.entity.*;
import iibs.actualites.entity.enums.*;
import org.springframework.data.domain.*;

public interface ArticleRepositoryPersonnalise {

    Page<Article> rechercherParTerme(
            StatutArticle statut,
            String terme,
            Pageable pageable
    );
}
