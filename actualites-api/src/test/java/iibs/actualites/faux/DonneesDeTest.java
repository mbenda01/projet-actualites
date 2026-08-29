package iibs.actualites.faux;

import iibs.actualites.entity.*;

import java.lang.reflect.*;
import java.util.*;

// ============================================================
// Fabrique d'entites pour les tests.
//
// Les entites n'ayant plus de setters ni de builder, les tests
// passent par les memes fabriques que le code de production :
// Article.redigerBrouillon, Utilisateur.inscrire.
//
// IDENTIFIANTS
// L'id est genere par la base : une entite non persistee a
// donc un id null. Or les tests comparent souvent des
// identifiants, et estRedigePar les compare aussi.
//
// On les pose par reflexion. C'est un contournement assume,
// limite au code de test : l'alternative serait d'ouvrir un
// setter public sur l'id, ce qui affaiblirait l'entite pour
// tout le monde.
// ============================================================

public final class DonneesDeTest {

    private DonneesDeTest() {
    }

    /// Empreinte BCrypt factice.
    ///
    /// Les tests de service n'encodent pas reellement : ils
    /// simulent le PasswordEncoder.
    public static final String EMPREINTE = "$2a$10$empreinte.factice.pour.les.tests";

    // --- Utilisateurs ---------------------------------------

    public static Utilisateur lecteur(Long id, String nom, String email) {
        Utilisateur utilisateur = Utilisateur.inscrire(nom, email, EMPREINTE);
        poserIdentifiant(utilisateur, id);
        return utilisateur;
    }

    public static Utilisateur administrateur(Long id, String nom, String email) {
        Utilisateur utilisateur = Utilisateur.creerAdministrateur(nom, email, EMPREINTE);
        poserIdentifiant(utilisateur, id);
        return utilisateur;
    }

    /// Lecteur par defaut, identifiant 1.
    public static Utilisateur lecteur() {
        return lecteur(1L, "Sam Ndiaye", "sam@test.sn");
    }

    /// Administrateur par defaut, identifiant 2.
    public static Utilisateur administrateur() {
        return administrateur(2L, "Alex Rivera", "alex@test.sn");
    }

    // --- Articles -------------------------------------------

    /// Brouillon avec un contenu minimal.
    public static Article brouillon(Long id, String titre, Utilisateur auteur) {
        Article article = Article.redigerBrouillon(titre, auteur);

        article.modifierContenu(
                titre,
                "Un chapeau de test",
                List.of("Premier paragraphe.", "Second paragraphe."),
                null,
                "https://exemple.test/image.jpg",
                "Image de test",
                5
        );

        poserIdentifiant(article, id);
        return article;
    }

    /// Article publie, date de publication posee.
    public static Article publie(Long id, String titre, Utilisateur auteur) {
        Article article = brouillon(id, titre, auteur);
        article.publier();
        return article;
    }

    /// Brouillon par defaut, identifiant 10.
    public static Article brouillon() {
        return brouillon(10L, "Un brouillon", administrateur());
    }

    /// Article publie par defaut, identifiant 11.
    public static Article publie() {
        return publie(11L, "Un article publie", administrateur());
    }

    // --- Reflexion ------------------------------------------

    /// Pose l'identifiant d'une entite.
    ///
    /// La reflexion remonte la hierarchie : Article herite
    /// d'Auditable, mais le champ id est declare dans Article
    /// lui-meme. La boucle couvre le cas general.
    private static void poserIdentifiant(Object entite, Long id) {
        if (id == null) return;

        Class<?> classe = entite.getClass();

        while (classe != null) {
            try {
                Field champ = classe.getDeclaredField("id");
                champ.setAccessible(true);
                champ.set(entite, id);
                return;
            } catch (NoSuchFieldException exception) {
                classe = classe.getSuperclass();
            } catch (IllegalAccessException exception) {
                throw new IllegalStateException(
                        "Impossible de poser l'identifiant de test", exception);
            }
        }

        throw new IllegalStateException(
                "Champ id introuvable sur " + entite.getClass().getName());
    }
}