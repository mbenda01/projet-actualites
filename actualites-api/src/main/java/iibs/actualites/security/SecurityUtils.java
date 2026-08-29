package iibs.actualites.security;

import iibs.actualites.entity.*;
import iibs.actualites.exception.*;
import org.springframework.security.core.*;
import org.springframework.security.core.context.*;

import java.util.*;

public final class SecurityUtils {

    private SecurityUtils() {
    }

    public static Optional<Utilisateur> utilisateurCourant() {
        Authentication authentification = SecurityContextHolder.getContext().getAuthentication();

        if (authentification == null || !authentification.isAuthenticated()) {
            return Optional.empty();
        }

        if (!(authentification.getPrincipal() instanceof UtilisateurDetails details)) {
            return Optional.empty();
        }

        return Optional.of(details.utilisateur());
    }

    public static Utilisateur utilisateurCourantOuLeve() {
        return utilisateurCourant()
                .orElseThrow(() -> new AccesRefuseException("Authentification requise"));
    }

    public static Optional<Long> identifiantCourant() {
        return utilisateurCourant().map(Utilisateur::getId);
    }

    public static Optional<String> emailCourant() {
        return utilisateurCourant().map(Utilisateur::getEmail);
    }

    public static boolean estAdmin() {
        return utilisateurCourant()
                .map(Utilisateur::estAdmin)
                .orElse(false);
    }
}