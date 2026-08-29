package iibs.actualites.service.impl;

import iibs.actualites.controller.dto.*;
import iibs.actualites.entity.*;
import iibs.actualites.entity.enums.*;
import iibs.actualites.exception.*;
import iibs.actualites.repository.*;
import iibs.actualites.service.*;
import iibs.actualites.service.mapper.*;
import lombok.*;
import lombok.extern.slf4j.*;
import org.springframework.data.domain.*;
import org.springframework.stereotype.*;
import org.springframework.transaction.annotation.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class ArticleServiceImpl implements ArticleService {

    private final ArticleRepository articleRepository;
    private final ArticleMapper articleMapper;
    private final PolitiqueArticle politique;

    @Override
    @Transactional(readOnly = true)
    public Page<ArticleResumeDto> listerPublies(
            Categorie categorie,
            String terme,
            Pageable pageable) {
        Page<Article> articles;

        if (terme != null && !terme.isBlank()) {
            log.debug("Recherche d'articles publies, {} caracteres saisis",
                    terme.trim().length());
            articles = articleRepository.rechercherParTerme(
                    StatutArticle.PUBLIE, terme.trim(), pageable);

        } else if (categorie != null) {
            log.debug("Liste des articles publies, categorie {}", categorie);
            articles = articleRepository.findByStatutAndCategorie(
                    StatutArticle.PUBLIE, categorie, pageable);

        } else {
            log.debug("Liste des articles publies, page {}",
                    pageable.getPageNumber());
            articles = articleRepository.findByStatut(
                    StatutArticle.PUBLIE, pageable);
        }

        log.debug("{} articles retournes sur {} au total",
                articles.getNumberOfElements(), articles.getTotalElements());

        return articles.map(articleMapper::versResume);
    }

    @Override
    @Transactional(readOnly = true)
    public ArticleDetailDto obtenirPublie(Long id) {
        log.debug("Lecture de l'article publie id={}", id);

        return articleMapper.versDetail(trouverPublie(id));
    }

    @Override
    @Transactional(readOnly = true)
    public Article trouverPublie(Long id) {
        Article article = chargerOuLever(id);

        if (!article.estPublie()) {
            log.debug("Article id={} non publie, traite comme absent", id);
            throw RessourceNonTrouveeException.pour("Article", id);
        }

        return article;
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ArticleResumeDto> listerTous(Pageable pageable) {
        politique.verifierDroitLectureComplete();

        log.debug("Liste complete des articles, page {}",
                pageable.getPageNumber());

        return articleRepository.findAll(pageable).map(articleMapper::versResume);
    }

    @Override
    @Transactional(readOnly = true)
    public ArticleDetailDto obtenirParId(Long id) {
        politique.verifierDroitLectureComplete();

        log.debug("Lecture de l'article id={} (tous statuts)", id);

        return articleMapper.versDetail(chargerOuLever(id));
    }

    @Override
    @Transactional
    public ArticleDetailDto creer(ArticleCreationDto dto) {
        Utilisateur auteur = politique.auteurCourant();

        log.debug("Creation d'un article par l'utilisateur id={}",
                auteur.getId());

        Article article = Article.redigerBrouillon(dto.titre(), auteur);

        article.modifierContenu(
                dto.titre(),
                dto.chapeau(),
                dto.paragraphes(),
                dto.categorie(),
                dto.urlImage(),
                dto.libelleImage(),
                dto.dureeLectureMinutes());

        Article enregistre = articleRepository.save(article);

        log.info("Article cree : id={}, auteur={}",
                enregistre.getId(), auteur.getId());

        return articleMapper.versDetail(enregistre);
    }

    @Override
    @Transactional
    public ArticleDetailDto modifier(Long id, ArticleModificationDto dto) {
        Article article = chargerOuLever(id);

        politique.verifierDroitEcriture(article);

        article.modifierContenu(
                dto.titre(),
                dto.chapeau(),
                dto.paragraphes(),
                dto.categorie(),
                dto.urlImage(),
                dto.libelleImage(),
                dto.dureeLectureMinutes());

        Article enregistre = articleRepository.save(article);

        log.info("Article modifie : id={}", id);

        return articleMapper.versDetail(enregistre);
    }

    @Override
    @Transactional
    public ArticleDetailDto changerStatut(Long id, StatutArticle statut) {
        Article article = chargerOuLever(id);

        politique.verifierDroitEcriture(article);

        StatutArticle ancien = article.getStatut();

        try {
            article.changerStatut(statut);
        } catch (IllegalStateException exception) {

            throw new ConflitMetierException(exception.getMessage());
        }

        Article enregistre = articleRepository.save(article);

        log.info("Statut de l'article id={} : {} -> {}", id, ancien, statut);

        return articleMapper.versDetail(enregistre);
    }

    @Override
    @Transactional
    public void archiver(Long id) {
        Article article = chargerOuLever(id);

        politique.verifierDroitEcriture(article);

        try {
            article.archiver();
        } catch (IllegalStateException exception) {
            throw new ConflitMetierException(exception.getMessage());
        }

        articleRepository.save(article);

        log.info("Article archive : id={}", id);
    }

    private Article chargerOuLever(Long id) {
        return articleRepository.chargerComplet(id)
                .orElseThrow(() -> {
                    log.debug("Article introuvable : id={}", id);
                    return RessourceNonTrouveeException.pour("Article", id);
                });
    }
}