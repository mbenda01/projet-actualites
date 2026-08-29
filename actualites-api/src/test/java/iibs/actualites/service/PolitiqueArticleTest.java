package iibs.actualites.service;

import iibs.actualites.entity.*;
import iibs.actualites.exception.*;
import iibs.actualites.faux.*;
import org.junit.jupiter.api.*;

import static org.assertj.core.api.Assertions.*;

// ============================================================
// Tests de PolitiqueArticle.
//
// La classe est instanciee directement avec un faux contexte :
// aucun contexte Spring, aucun SecurityContextHolder a peupler
// ni a nettoyer.
//
// C'est le benefice concret de l'injection : avec l'ancienne
// version statique, chaque test devait manipuler l'etat global
// de Spring Security, et un oubli de nettoyage faisait fuir
// l'utilisateur vers le test suivant.
// ============================================================

class PolitiqueArticleTest {

    private FauxContexteSecurite contexte;
    private PolitiqueArticle politique;

    private Utilisateur admin;
    private Utilisateur lecteur;

    @BeforeEach
    void preparer() {
        contexte = new FauxContexteSecurite();
        politique = new PolitiqueArticle(contexte);

        admin = DonneesDeTest.administrateur(1L, "Alex", "alex@test.sn");
        lecteur = DonneesDeTest.lecteur(2L, "Sam", "sam@test.sn");
    }

    @Nested
    class DroitEcriture {

        @Test
        void unAdministrateurModifieToutArticle() {
            Article article = DonneesDeTest.brouillon(10L, "Un titre", lecteur);
            contexte.connecter(admin);

            // Ne leve pas : un administrateur modifie meme les
            // articles dont il n'est pas l'auteur.
            assertThatCode(() -> politique.verifierDroitEcriture(article))
                    .doesNotThrowAnyException();
        }

        @Test
        void unAuteurModifieSonArticle() {
            Article article = DonneesDeTest.brouillon(10L, "Un titre", lecteur);
            contexte.connecter(lecteur);

            assertThatCode(() -> politique.verifierDroitEcriture(article))
                    .doesNotThrowAnyException();
        }

        @Test
        void unLecteurNeModifiePasLArticleDUnAutre() {
            Utilisateur autreAuteur =
                    DonneesDeTest.lecteur(3L, "Marie", "marie@test.sn");
            Article article = DonneesDeTest.brouillon(10L, "Un titre", autreAuteur);

            contexte.connecter(lecteur);

            assertThatThrownBy(() -> politique.verifierDroitEcriture(article))
                    .isInstanceOf(AccesRefuseException.class)
                    .hasMessageContaining("vos propres articles");
        }

        @Test
        void refuseSansAuthentification() {
            Article article = DonneesDeTest.brouillon(10L, "Un titre", lecteur);
            contexte.deconnecter();

            assertThatThrownBy(() -> politique.verifierDroitEcriture(article))
                    .isInstanceOf(AccesRefuseException.class)
                    .hasMessageContaining("Authentification requise");
        }
    }

    @Nested
    class DroitLectureComplete {

        @Test
        void autoriseUnAdministrateur() {
            contexte.connecter(admin);

            assertThatCode(() -> politique.verifierDroitLectureComplete())
                    .doesNotThrowAnyException();
        }

        @Test
        void refuseUnLecteur() {
            contexte.connecter(lecteur);

            assertThatThrownBy(() -> politique.verifierDroitLectureComplete())
                    .isInstanceOf(AccesRefuseException.class)
                    .hasMessageContaining("administrateurs");
        }

        @Test
        void refuseSansAuthentification() {
            contexte.deconnecter();

            assertThatThrownBy(() -> politique.verifierDroitLectureComplete())
                    .isInstanceOf(AccesRefuseException.class);
        }
    }

    @Nested
    class AuteurCourant {

        @Test
        void retourneLUtilisateurConnecte() {
            contexte.connecter(admin);

            assertThat(politique.auteurCourant()).isEqualTo(admin);
        }

        @Test
        void leveSansAuthentification() {
            contexte.deconnecter();

            assertThatThrownBy(() -> politique.auteurCourant())
                    .isInstanceOf(AccesRefuseException.class);
        }
    }
}