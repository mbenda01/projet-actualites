package iibs.actualites.service;

import iibs.actualites.controller.dto.*;
import iibs.actualites.entity.*;
import iibs.actualites.entity.enums.*;
import org.springframework.data.domain.*;

public interface ArticleService {

    Page<ArticleResumeDto> listerPublies(Categorie categorie, String terme, Pageable pageable);

    Page<ArticleResumeDto> listerTous(Pageable pageable);

    ArticleDetailDto obtenirPublie(Long id);

    ArticleDetailDto obtenirParId(Long id);

    Article trouverPublie(Long id);

    ArticleDetailDto creer(ArticleCreationDto dto);

    ArticleDetailDto modifier(Long id, ArticleModificationDto dto);

    ArticleDetailDto changerStatut(Long id, StatutArticle statut);

    void archiver(Long id);
}