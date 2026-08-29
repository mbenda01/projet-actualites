package iibs.actualites.entity;

import iibs.actualites.entity.enums.*;
import iibs.actualites.faux.*;
import org.junit.jupiter.api.*;

import java.time.*;
import java.util.*;

import static org.assertj.core.api.Assertions.*;

// ============================================================
// Tests de l'entite Article.
//
// Ces tests ne demandent ni base de donnees, ni contexte
// Spring, ni Mockito : une entite riche se teste comme un objet
// Java ordinaire.
//
// C'est le premier benefice du modele riche : les regles metier
// sont verifiables sans infrastructure.
// ============================================================

class ArticleTest {

    private Utilisateur auteur;

    @BeforeEach
    void preparer() {
        auteur = DonneesDeTest.administrateur();
    }

    @Nested
    class Creation {

        @Test
        void naitEnBrouillon() {
            Article article = Article.redigerBrouillon("Un titre", auteur);

            // La fabrique impose le statut : un article ne peut
            // pas naitre publie.
            assertThat(article.getStatut()).isEqualTo(StatutArticle.BROUILLON);
            assertThat(article.estPublie()).isFalse();
        }

        @Test
        void rattacheLAuteur() {
            Article article = Article.redigerBrouillon("Un titre", auteur);

            assertThat(article.getAuteur()).isEqualTo(auteur);
            assertThat(article.estRedigePar(auteur)).isTrue();
        }

        @Test
        void supprimeLesEspacesDuTitre() {
            Article article = Article.redigerBrouillon("  Un titre  ", auteur);

            assertThat(article.getTitre()).isEqualTo("Un titre");
        }

        @Test
        void refuseUnTitreNul() {
            assertThatThrownBy(() -> Article.redigerBrouillon(null, auteur))
                    .isInstanceOf(NullPointerException.class);
        }

        @Test
        void refuseUnAuteurNul() {
            assertThatThrownBy(() -> Article.redigerBrouillon("Un titre", null))
                    .isInstanceOf(NullPointerException.class);
        }

        @Test
        void naitSansDateDePublication() {
            Article article = Article.redigerBrouillon("Un titre", auteur);

            assertThat(article.getDatePublication()).isNull();
        }
    }

    @Nested
    class Publication {

        @Test
        void poseLaDateDePublication() {
            Article article = Article.redigerBrouillon("Un titre", auteur);

            article.publier();

            assertThat(article.getStatut()).isEqualTo(StatutArticle.PUBLIE);
            assertThat(article.getDatePublication()).isEqualTo(LocalDate.now());
        }

        @Test
        void neRajeunitPasUnArticleRepublie() {
            Article article = Article.redigerBrouillon("Un titre", auteur);
            article.publier();

            LocalDate premierePublication = article.getDatePublication();

            article.archiver();
            article.publier();

            // C'est l'invariant central de publier() : la date
            // est posee une seule fois. Sans lui, republier un
            // article le remonterait en tete de liste.
            assertThat(article.getDatePublication()).isEqualTo(premierePublication);
        }

        @Test
        void refuseDePublierDeuxFois() {
            Article article = Article.redigerBrouillon("Un titre", auteur);
            article.publier();

            assertThatThrownBy(article::publier)
                    .isInstanceOf(IllegalStateException.class)
                    .hasMessageContaining("deja publie");
        }
    }

    @Nested
    class Archivage {

        @Test
        void changeLeStatut() {
            Article article = Article.redigerBrouillon("Un titre", auteur);

            article.archiver();

            assertThat(article.getStatut()).isEqualTo(StatutArticle.ARCHIVE);
            assertThat(article.estPublie()).isFalse();
        }

        @Test
        void refuseDArchiverDeuxFois() {
            Article article = Article.redigerBrouillon("Un titre", auteur);
            article.archiver();

            assertThatThrownBy(article::archiver)
                    .isInstanceOf(IllegalStateException.class)
                    .hasMessageContaining("deja archive");
        }

        @Test
        void conserveLaDateDePublication() {
            Article article = Article.redigerBrouillon("Un titre", auteur);
            article.publier();
            LocalDate date = article.getDatePublication();

            article.archiver();

            // L'article a bien ete publie a cette date, meme
            // s'il est retire.
            assertThat(article.getDatePublication()).isEqualTo(date);
        }
    }

    @Nested
    class RetourEnBrouillon {

        @Test
        void changeLeStatut() {
            Article article = Article.redigerBrouillon("Un titre", auteur);
            article.publier();

            article.repasserEnBrouillon();

            assertThat(article.getStatut()).isEqualTo(StatutArticle.BROUILLON);
        }

        @Test
        void refuseSiDejaEnBrouillon() {
            Article article = Article.redigerBrouillon("Un titre", auteur);

            assertThatThrownBy(article::repasserEnBrouillon)
                    .isInstanceOf(IllegalStateException.class)
                    .hasMessageContaining("deja en brouillon");
        }
    }

    @Nested
    class ChangementDeStatut {

        @Test
        void deleguéAPublier() {
            Article article = Article.redigerBrouillon("Un titre", auteur);

            article.changerStatut(StatutArticle.PUBLIE);

            assertThat(article.getStatut()).isEqualTo(StatutArticle.PUBLIE);
            assertThat(article.getDatePublication()).isNotNull();
        }

        @Test
        void deleguéAArchiver() {
            Article article = Article.redigerBrouillon("Un titre", auteur);

            article.changerStatut(StatutArticle.ARCHIVE);

            assertThat(article.getStatut()).isEqualTo(StatutArticle.ARCHIVE);
        }

        @Test
        void refuseUnStatutNul() {
            Article article = Article.redigerBrouillon("Un titre", auteur);

            assertThatThrownBy(() -> article.changerStatut(null))
                    .isInstanceOf(NullPointerException.class);
        }
    }

    @Nested
    class Contenu {

        @Test
        void metAJourLesChampsEditoriaux() {
            Article article = Article.redigerBrouillon("Ancien titre", auteur);

            article.modifierContenu(
                    "Nouveau titre",
                    "Nouveau chapeau",
                    List.of("Paragraphe unique."),
                    Categorie.TECHNOLOGIE,
                    "https://exemple.test/img.jpg",
                    "Une image",
                    7
            );

            assertThat(article.getTitre()).isEqualTo("Nouveau titre");
            assertThat(article.getChapeau()).isEqualTo("Nouveau chapeau");
            assertThat(article.getCategorie()).isEqualTo(Categorie.TECHNOLOGIE);
            assertThat(article.getDureeLectureMinutes()).isEqualTo(7);
        }

        @Test
        void neTouchePasAuStatut() {
            Article article = Article.redigerBrouillon("Un titre", auteur);
            article.publier();
            LocalDate date = article.getDatePublication();

            article.modifierContenu(
                    "Titre corrige", null, List.of("Texte."),
                    Categorie.GENERAL, null, null, null
            );

            // Corriger une faute de frappe ne doit ni depublier
            // l'article, ni modifier sa date.
            assertThat(article.getStatut()).isEqualTo(StatutArticle.PUBLIE);
            assertThat(article.getDatePublication()).isEqualTo(date);
        }

        @Test
        void neTouchePasALAuteur() {
            Article article = Article.redigerBrouillon("Un titre", auteur);

            article.modifierContenu(
                    "Titre", null, List.of("Texte."),
                    Categorie.GENERAL, null, null, null
            );

            assertThat(article.getAuteur()).isEqualTo(auteur);
        }

        @Test
        void utiliseGeneralSiLaCategorieEstNulle() {
            Article article = Article.redigerBrouillon("Un titre", auteur);

            article.modifierContenu(
                    "Titre", null, List.of("Texte."),
                    null, null, null, null
            );

            assertThat(article.getCategorie()).isEqualTo(Categorie.GENERAL);
        }
    }

    @Nested
    class Paragraphes {

        @Test
        void remplaceLesParagraphes() {
            Article article = DonneesDeTest.brouillon();

            article.remplacerParagraphes(List.of("Un seul paragraphe."));

            assertThat(article.getParagraphes()).containsExactly("Un seul paragraphe.");
        }

        @Test
        void accepteUneListeNulle() {
            Article article = DonneesDeTest.brouillon();

            article.remplacerParagraphes(null);

            assertThat(article.getParagraphes()).isEmpty();
            assertThat(article.aDuContenu()).isFalse();
        }

        @Test
        void retourneUneListeNonModifiable() {
            Article article = DonneesDeTest.brouillon();

            List<String> paragraphes = article.getParagraphes();

            // Empeche un appelant de modifier la collection
            // suivie par Hibernate en dehors de l'entite.
            assertThatThrownBy(() -> paragraphes.add("Intrus"))
                    .isInstanceOf(UnsupportedOperationException.class);
        }
    }

    @Nested
    class Auteur {

        @Test
        void reconnaitSonAuteur() {
            Article article = Article.redigerBrouillon("Un titre", auteur);

            assertThat(article.estRedigePar(auteur)).isTrue();
        }

        @Test
        void neReconnaitPasUnAutreUtilisateur() {
            Article article = Article.redigerBrouillon("Un titre", auteur);
            Utilisateur autre = DonneesDeTest.lecteur();

            assertThat(article.estRedigePar(autre)).isFalse();
        }

        @Test
        void refuseUnUtilisateurNul() {
            Article article = Article.redigerBrouillon("Un titre", auteur);

            assertThat(article.estRedigePar(null)).isFalse();
        }
    }
}
