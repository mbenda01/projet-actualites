package iibs.actualites.service.impl;

import iibs.actualites.controller.dto.*;
import iibs.actualites.entity.*;
import iibs.actualites.exception.*;
import iibs.actualites.repository.*;
import iibs.actualites.security.*;
import iibs.actualites.service.*;
import iibs.actualites.service.mapper.*;
import lombok.*;
import lombok.extern.slf4j.*;
import org.springframework.dao.*;
import org.springframework.data.domain.*;
import org.springframework.stereotype.*;
import org.springframework.transaction.annotation.*;

import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class FavorisServiceImpl implements FavorisService {

    private final FavoriRepository favoriRepository;
    private final ArticleService articleService;
    private final ArticleMapper articleMapper;
    private final ContexteSecurite contexte;

    @Override
    @Transactional(readOnly = true)
    public Set<Long> listerIdentifiants() {
        Long utilisateurId = identifiantCourant();

        Set<Long> identifiants =
                favoriRepository.listerIdentifiantsArticles(utilisateurId);

        log.debug("{} favoris lus pour l'utilisateur id={}",
                identifiants.size(), utilisateurId);

        return Set.copyOf(identifiants);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ArticleResumeDto> listerArticles(Pageable pageable) {
        Long utilisateurId = identifiantCourant();

        log.debug("Liste des articles favoris de l'utilisateur id={}",
                utilisateurId);

        return favoriRepository
                .listerArticles(utilisateurId, pageable)
                .map(articleMapper::versResume);
    }

    @Override
    @Transactional(readOnly = true)
    public long compter() {
        return favoriRepository.countByUtilisateurId(identifiantCourant());
    }

    @Override
    @Transactional
    public boolean basculer(Long articleId) {
        Utilisateur utilisateur = contexte.utilisateurCourantRequis();

        Optional<Favori> existant = favoriRepository
                .findByUtilisateurIdAndArticleId(utilisateur.getId(), articleId);

        if (existant.isPresent()) {
            favoriRepository.delete(existant.get());
            log.debug("Favori retire : article={}, utilisateur={}",
                    articleId, utilisateur.getId());
            return false;
        }

        enregistrer(utilisateur, articleId);
        log.debug("Favori ajoute : article={}, utilisateur={}",
                articleId, utilisateur.getId());
        return true;
    }

    @Override
    @Transactional
    public void ajouter(Long articleId) {
        Utilisateur utilisateur = contexte.utilisateurCourantRequis();

        if (favoriRepository.existsByUtilisateurIdAndArticleId(
                utilisateur.getId(), articleId)) {
            log.debug("Article {} deja en favori pour l'utilisateur {}",
                    articleId, utilisateur.getId());
            return;
        }

        enregistrer(utilisateur, articleId);

        log.debug("Favori ajoute : article={}, utilisateur={}",
                articleId, utilisateur.getId());
    }

    @Override
    @Transactional
    public void retirer(Long articleId) {
        Long utilisateurId = identifiantCourant();

        int supprimes = favoriRepository.supprimer(utilisateurId, articleId);

        if (supprimes == 0) {
            log.debug("Aucun favori a retirer : article={}, utilisateur={}",
                    articleId, utilisateurId);
            return;
        }

        log.debug("Favori retire : article={}, utilisateur={}",
                articleId, utilisateurId);
    }

    @Override
    @Transactional
    public void toutRetirer() {
        Long utilisateurId = identifiantCourant();

        int supprimes = favoriRepository.supprimerTout(utilisateurId);

        log.info("{} favoris supprimes pour l'utilisateur id={}",
                supprimes, utilisateurId);
    }

    private void enregistrer(Utilisateur utilisateur, Long articleId) {
        Article article = articleService.trouverPublie(articleId);

        Favori favori = Favori.enregistrer(utilisateur, article);

        try {
            favoriRepository.save(favori);
        } catch (DataIntegrityViolationException exception) {
            log.debug("Ajout concurrent detecte : article={}, utilisateur={}",
                    articleId, utilisateur.getId());
        }
    }

    private Long identifiantCourant() {
        return contexte.utilisateurCourantRequis().getId();
    }
}