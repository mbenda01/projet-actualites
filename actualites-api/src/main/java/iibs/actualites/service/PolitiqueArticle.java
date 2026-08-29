package iibs.actualites.service;

import iibs.actualites.entity.*;
import iibs.actualites.exception.*;
import iibs.actualites.security.*;
import lombok.*;
import lombok.extern.slf4j.*;
import org.springframework.stereotype.*;

@Slf4j
@Component
@RequiredArgsConstructor
public class PolitiqueArticle {

    private final ContexteSecurite contexte;

    public void verifierDroitEcriture(Article article) {
        Utilisateur courant = contexte.utilisateurCourantRequis();

        if (courant.estAdmin()) {
            return;
        }

        if (!article.estRedigePar(courant)) {
            log.warn("Modification refusee : article={}, utilisateur={}",
                    article.getId(), courant.getId());
            throw new AccesRefuseException(
                    "Vous ne pouvez modifier que vos propres articles");
        }
    }

    public void verifierDroitLectureComplete() {
        Utilisateur courant = contexte.utilisateurCourantRequis();

        if (!courant.estAdmin()) {
            log.warn("Lecture complete refusee : utilisateur={}", courant.getId());
            throw new AccesRefuseException("Reserve aux administrateurs");
        }
    }

    public Utilisateur auteurCourant() {
        return contexte.utilisateurCourantRequis();
    }
}