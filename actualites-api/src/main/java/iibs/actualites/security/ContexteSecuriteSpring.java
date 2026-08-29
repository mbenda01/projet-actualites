package iibs.actualites.security;

import iibs.actualites.entity.*;
import iibs.actualites.exception.*;
import org.springframework.security.core.*;
import org.springframework.security.core.context.*;
import org.springframework.stereotype.*;

import java.util.*;

@Component
public class ContexteSecuriteSpring implements ContexteSecurite {

    @Override
    public Optional<Utilisateur> utilisateurCourant() {
        Authentication authentification =
                SecurityContextHolder.getContext().getAuthentication();

        if (authentification == null || !authentification.isAuthenticated()) {
            return Optional.empty();
        }

        if (!(authentification.getPrincipal() instanceof UtilisateurDetails details)) {
            return Optional.empty();
        }

        return Optional.of(details.utilisateur());
    }

    @Override
    public Utilisateur utilisateurCourantRequis() {
        return utilisateurCourant()
                .orElseThrow(() -> new AccesRefuseException("Authentification requise"));
    }

    @Override
    public Optional<Long> identifiantCourant() {
        return utilisateurCourant().map(Utilisateur::getId);
    }

    @Override
    public Optional<String> emailCourant() {
        return utilisateurCourant().map(Utilisateur::getEmail);
    }

    @Override
    public boolean estAdmin() {
        return utilisateurCourant()
                .map(Utilisateur::estAdmin)
                .orElse(false);
    }
}