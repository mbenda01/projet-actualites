package iibs.actualites.security;

import iibs.actualites.entity.*;

import java.util.*;

public interface ContexteSecurite {

    Optional<Utilisateur> utilisateurCourant();

    Utilisateur utilisateurCourantRequis();

    Optional<Long> identifiantCourant();

    Optional<String> emailCourant();

    boolean estAdmin();
}