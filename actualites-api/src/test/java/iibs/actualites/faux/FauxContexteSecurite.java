package iibs.actualites.faux;

import iibs.actualites.entity.*;
import iibs.actualites.exception.*;
import iibs.actualites.security.*;

import java.util.*;

// ============================================================
// Contexte de securite pour les tests.
//
// C'est ici que l'injection de ContexteSecurite porte ses
// fruits : trois lignes suffisent a simuler un utilisateur
// authentifie.
//
// Avec l'ancienne version statique, chaque test devait peupler
// SecurityContextHolder puis le nettoyer — et un oubli de
// nettoyage faisait fuir l'utilisateur vers le test suivant.
// ============================================================

public class FauxContexteSecurite implements ContexteSecurite {

    private Utilisateur utilisateur;

    /// Contexte sans utilisateur authentifie.
    public FauxContexteSecurite() {
        this.utilisateur = null;
    }

    public FauxContexteSecurite(Utilisateur utilisateur) {
        this.utilisateur = utilisateur;
    }

    /// Change l'utilisateur courant en cours de test.
    public void connecter(Utilisateur utilisateur) {
        this.utilisateur = utilisateur;
    }

    /// Simule une absence d'authentification.
    public void deconnecter() {
        this.utilisateur = null;
    }

    @Override
    public Optional<Utilisateur> utilisateurCourant() {
        return Optional.ofNullable(utilisateur);
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
        return utilisateurCourant().map(Utilisateur::estAdmin).orElse(false);
    }
}