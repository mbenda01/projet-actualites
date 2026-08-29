package iibs.actualites.entity;

import iibs.actualites.entity.enums.*;
import iibs.actualites.faux.*;
import org.junit.jupiter.api.*;

import static org.assertj.core.api.Assertions.*;

// ============================================================
// Tests de l'entite Utilisateur.
//
// Comme pour Article, aucune infrastructure n'est necessaire :
// les regles vivent dans l'entite et se testent directement.
//
// Le point le plus surveille est la normalisation de l'email :
// sans elle, Alex@site.sn et alex@site.sn creeraient deux
// comptes distincts, et l'utilisateur ne pourrait pas se
// reconnecter s'il change la casse.
// ============================================================

class UtilisateurTest {

    @Nested
    class Inscription {

        @Test
        void creeUnLecteur() {
            Utilisateur utilisateur = Utilisateur.inscrire(
                    "Sam Ndiaye", "sam@test.sn", DonneesDeTest.EMPREINTE);

            // L'inscription publique ne peut creer que des
            // lecteurs : un endpoint qui accepterait un role
            // serait une faille beante.
            assertThat(utilisateur.getRole()).isEqualTo(Role.LECTEUR);
            assertThat(utilisateur.estAdmin()).isFalse();
        }

        @Test
        void activeLeCompte() {
            Utilisateur utilisateur = Utilisateur.inscrire(
                    "Sam Ndiaye", "sam@test.sn", DonneesDeTest.EMPREINTE);

            assertThat(utilisateur.isActif()).isTrue();
            assertThat(utilisateur.peutSeConnecter()).isTrue();
        }

        @Test
        void normaliseLEmail() {
            Utilisateur utilisateur = Utilisateur.inscrire(
                    "Sam", "  SAM@Test.SN  ", DonneesDeTest.EMPREINTE);

            assertThat(utilisateur.getEmail()).isEqualTo("sam@test.sn");
        }

        @Test
        void supprimeLesEspacesDuNom() {
            Utilisateur utilisateur = Utilisateur.inscrire(
                    "  Sam Ndiaye  ", "sam@test.sn", DonneesDeTest.EMPREINTE);

            assertThat(utilisateur.getNom()).isEqualTo("Sam Ndiaye");
        }

        @Test
        void refuseUnNomNul() {
            assertThatThrownBy(() -> Utilisateur.inscrire(
                    null, "sam@test.sn", DonneesDeTest.EMPREINTE))
                    .isInstanceOf(NullPointerException.class);
        }

        @Test
        void refuseUnEmailNul() {
            assertThatThrownBy(() -> Utilisateur.inscrire(
                    "Sam", null, DonneesDeTest.EMPREINTE))
                    .isInstanceOf(NullPointerException.class);
        }

        @Test
        void refuseUnMotDePasseNul() {
            assertThatThrownBy(() -> Utilisateur.inscrire(
                    "Sam", "sam@test.sn", null))
                    .isInstanceOf(NullPointerException.class);
        }
    }

    @Nested
    class CreationAdministrateur {

        @Test
        void creeUnAdministrateur() {
            Utilisateur utilisateur = Utilisateur.creerAdministrateur(
                    "Alex", "alex@test.sn", DonneesDeTest.EMPREINTE);

            assertThat(utilisateur.getRole()).isEqualTo(Role.ADMIN);
            assertThat(utilisateur.estAdmin()).isTrue();
        }

        @Test
        void normaliseAussiLEmail() {
            Utilisateur utilisateur = Utilisateur.creerAdministrateur(
                    "Alex", "ALEX@Test.SN", DonneesDeTest.EMPREINTE);

            assertThat(utilisateur.getEmail()).isEqualTo("alex@test.sn");
        }
    }

    @Nested
    class NormalisationEmail {

        @Test
        void passeEnMinuscules() {
            assertThat(Utilisateur.normaliserEmail("ALEX@TEST.SN"))
                    .isEqualTo("alex@test.sn");
        }

        @Test
        void retireLesEspaces() {
            assertThat(Utilisateur.normaliserEmail("  alex@test.sn  "))
                    .isEqualTo("alex@test.sn");
        }

        @Test
        void accepteUneValeurNulle() {
            // La methode est appelee sur des saisies utilisateur :
            // elle ne doit pas lever avant que @NotBlank ait pu
            // faire son travail.
            assertThat(Utilisateur.normaliserEmail(null)).isNull();
        }
    }

    @Nested
    class Roles {

        @Test
        void promeutUnLecteur() {
            Utilisateur utilisateur = DonneesDeTest.lecteur();

            utilisateur.promouvoirAdministrateur();

            assertThat(utilisateur.estAdmin()).isTrue();
        }

        @Test
        void refuseDePromouvoirUnAdministrateur() {
            Utilisateur utilisateur = DonneesDeTest.administrateur();

            assertThatThrownBy(utilisateur::promouvoirAdministrateur)
                    .isInstanceOf(IllegalStateException.class)
                    .hasMessageContaining("deja administrateur");
        }

        @Test
        void retrogradeUnAdministrateur() {
            Utilisateur utilisateur = DonneesDeTest.administrateur();

            utilisateur.retrograderLecteur();

            assertThat(utilisateur.estAdmin()).isFalse();
        }

        @Test
        void refuseDeRetrograderUnLecteur() {
            Utilisateur utilisateur = DonneesDeTest.lecteur();

            assertThatThrownBy(utilisateur::retrograderLecteur)
                    .isInstanceOf(IllegalStateException.class)
                    .hasMessageContaining("deja lecteur");
        }
    }

    @Nested
    class Activation {

        @Test
        void desactiveUnCompte() {
            Utilisateur utilisateur = DonneesDeTest.lecteur();

            utilisateur.desactiver();

            assertThat(utilisateur.isActif()).isFalse();
            assertThat(utilisateur.peutSeConnecter()).isFalse();
        }

        @Test
        void refuseDeDesactiverDeuxFois() {
            Utilisateur utilisateur = DonneesDeTest.lecteur();
            utilisateur.desactiver();

            assertThatThrownBy(utilisateur::desactiver)
                    .isInstanceOf(IllegalStateException.class)
                    .hasMessageContaining("deja desactive");
        }

        @Test
        void reactiveUnCompte() {
            Utilisateur utilisateur = DonneesDeTest.lecteur();
            utilisateur.desactiver();

            utilisateur.reactiver();

            assertThat(utilisateur.isActif()).isTrue();
        }

        @Test
        void refuseDeReactiverUnCompteActif() {
            Utilisateur utilisateur = DonneesDeTest.lecteur();

            assertThatThrownBy(utilisateur::reactiver)
                    .isInstanceOf(IllegalStateException.class)
                    .hasMessageContaining("deja actif");
        }
    }

    @Nested
    class MotDePasse {

        @Test
        void remplaceLEmpreinte() {
            Utilisateur utilisateur = DonneesDeTest.lecteur();

            utilisateur.changerMotDePasse("$2a$10$nouvelle.empreinte");

            assertThat(utilisateur.getMotDePasse())
                    .isEqualTo("$2a$10$nouvelle.empreinte");
        }

        @Test
        void refuseUneEmpreinteNulle() {
            Utilisateur utilisateur = DonneesDeTest.lecteur();

            assertThatThrownBy(() -> utilisateur.changerMotDePasse(null))
                    .isInstanceOf(NullPointerException.class);
        }
    }

    @Nested
    class Affichage {

        @Test
        void neDivulguePasLEmail() {
            Utilisateur utilisateur = DonneesDeTest.lecteur(
                    1L, "Sam", "sam@confidentiel.sn");

            // toString est souvent appele dans les journaux : un
            // email y serait une donnee identifiante.
            assertThat(utilisateur.toString()).doesNotContain("sam@confidentiel.sn");
        }
    }
}