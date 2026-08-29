package iibs.actualites.service;

import iibs.actualites.controller.dto.*;
import iibs.actualites.entity.*;
import iibs.actualites.entity.enums.*;
import iibs.actualites.exception.*;
import iibs.actualites.faux.*;
import iibs.actualites.repository.*;
import iibs.actualites.service.impl.*;
import iibs.actualites.service.mapper.*;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.extension.*;
import org.mockito.*;
import org.mockito.junit.jupiter.*;
import org.springframework.data.domain.*;

import java.util.*;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

// ============================================================
// Tests d'ArticleServiceImpl.
//
// Le depot est simule par Mockito : les tests s'executent sans
// base de donnees, en quelques millisecondes.
//
// Le mapper est le vrai : c'est du code genere par MapStruct,
// sans dependance ni effet de bord. Le simuler obligerait a
// decrire chaque conversion, sans rien verifier de plus.
//
// La politique est construite avec un faux contexte, comme dans
// son propre test.
//
// CE QUE CES TESTS VERIFIENT
// L'orchestration : le service appelle-t-il la bonne requete
// selon les filtres, applique-t-il la regle de visibilite,
// traduit-il les exceptions de l'entite ?
//
// Les regles de transition elles-memes sont testees dans
// ArticleTest : on ne les reverifie pas ici.
// ============================================================

@ExtendWith(MockitoExtension.class)
class ArticleServiceImplTest {

    @Mock
    private ArticleRepository articleRepository;

    private ArticleMapper articleMapper;
    private FauxContexteSecurite contexte;
    private ArticleServiceImpl service;

    private Utilisateur admin;
    private Utilisateur lecteur;

    @BeforeEach
    void preparer() {
        // Implementation generee par MapStruct : le nom suit la
        // convention <Interface>Impl.
        articleMapper = new ArticleMapperImpl();

        contexte = new FauxContexteSecurite();
        PolitiqueArticle politique = new PolitiqueArticle(contexte);

        service = new ArticleServiceImpl(articleRepository, articleMapper, politique);

        admin = DonneesDeTest.administrateur(1L, "Alex", "alex@test.sn");
        lecteur = DonneesDeTest.lecteur(2L, "Sam", "sam@test.sn");
    }

    @Nested
    class ListeDesArticlesPublies {

        @Test
        void utiliseLaRechercheTextuelleQuandUnTermeEstFourni() {
            Pageable page = PageRequest.of(0, 20);
            when(articleRepository.rechercherParTerme(any(), anyString(), any()))
                    .thenReturn(Page.empty());

            service.listerPublies(null, "climat", page);

            // Verifie que la BONNE requete est appelee : trois
            // methodes existent, une seule doit servir.
            verify(articleRepository).rechercherParTerme(
                    eq(StatutArticle.PUBLIE), eq("climat"), eq(page));
            verify(articleRepository, never()).rechercherParStatut(any(), any());
        }

        @Test
        void utiliseLeFiltreParCategorieQuandAucunTermeNEstFourni() {
            Pageable page = PageRequest.of(0, 20);
            when(articleRepository.rechercherParStatutEtCategorie(any(), any(), any()))
                    .thenReturn(Page.empty());

            service.listerPublies(Categorie.TECHNOLOGIE, null, page);

            verify(articleRepository).rechercherParStatutEtCategorie(
                    eq(StatutArticle.PUBLIE), eq(Categorie.TECHNOLOGIE), eq(page));
        }

        @Test
        void listeSimpleSansFiltre() {
            Pageable page = PageRequest.of(0, 20);
            when(articleRepository.rechercherParStatut(any(), any()))
                    .thenReturn(Page.empty());

            service.listerPublies(null, null, page);

            verify(articleRepository).rechercherParStatut(
                    eq(StatutArticle.PUBLIE), eq(page));
        }

        @Test
        void ignoreUnTermeVide() {
            Pageable page = PageRequest.of(0, 20);
            when(articleRepository.rechercherParStatut(any(), any()))
                    .thenReturn(Page.empty());

            service.listerPublies(null, "   ", page);

            // Un terme fait d'espaces n'est pas une recherche.
            verify(articleRepository).rechercherParStatut(any(), any());
            verify(articleRepository, never())
                    .rechercherParTerme(any(), anyString(), any());
        }

        @Test
        void neDemandeQueLesArticlesPublies() {
            Pageable page = PageRequest.of(0, 20);
            when(articleRepository.rechercherParStatut(any(), any()))
                    .thenReturn(Page.empty());

            service.listerPublies(null, null, page);

            // Le statut est impose par le service, pas par le
            // client : un brouillon ne peut pas apparaitre dans
            // la liste publique.
            verify(articleRepository).rechercherParStatut(
                    eq(StatutArticle.PUBLIE), any());
        }
    }

    @Nested
    class LectureDUnArticlePublie {

        @Test
        void retourneUnArticlePublie() {
            Article article = DonneesDeTest.publie(10L, "Un titre", admin);
            when(articleRepository.chargerComplet(10L))
                    .thenReturn(Optional.of(article));

            ArticleDetailDto dto = service.obtenirPublie(10L);

            assertThat(dto.id()).isEqualTo(10L);
            assertThat(dto.titre()).isEqualTo("Un titre");
            assertThat(dto.auteurNom()).isEqualTo("Alex");
        }

        @Test
        void refuseUnBrouillonCommeInexistant() {
            Article article = DonneesDeTest.brouillon(10L, "Un brouillon", admin);
            when(articleRepository.chargerComplet(10L))
                    .thenReturn(Optional.of(article));

            // 404 et non 403 : signaler l'existence d'un article
            // non publie renseignerait sur le contenu a venir.
            assertThatThrownBy(() -> service.obtenirPublie(10L))
                    .isInstanceOf(RessourceNonTrouveeException.class);
        }

        @Test
        void refuseUnArticleArchive() {
            Article article = DonneesDeTest.publie(10L, "Un titre", admin);
            article.archiver();
            when(articleRepository.chargerComplet(10L))
                    .thenReturn(Optional.of(article));

            assertThatThrownBy(() -> service.obtenirPublie(10L))
                    .isInstanceOf(RessourceNonTrouveeException.class);
        }

        @Test
        void refuseUnArticleInexistant() {
            when(articleRepository.chargerComplet(99L))
                    .thenReturn(Optional.empty());

            assertThatThrownBy(() -> service.obtenirPublie(99L))
                    .isInstanceOf(RessourceNonTrouveeException.class)
                    .hasMessageContaining("99");
        }
    }

    @Nested
    class LectureAdministrateur {

        @Test
        void unAdministrateurVoitLesBrouillons() {
            Article article = DonneesDeTest.brouillon(10L, "Un brouillon", admin);
            when(articleRepository.chargerComplet(10L))
                    .thenReturn(Optional.of(article));
            contexte.connecter(admin);

            ArticleDetailDto dto = service.obtenirParId(10L);

            assertThat(dto.statut()).isEqualTo(StatutArticle.BROUILLON);
        }

        @Test
        void unLecteurNAccedePasALaLectureComplete() {
            contexte.connecter(lecteur);

            assertThatThrownBy(() -> service.obtenirParId(10L))
                    .isInstanceOf(AccesRefuseException.class);

            // Le depot n'est meme pas interroge : le droit est
            // verifie avant.
            verify(articleRepository, never()).chargerComplet(any());
        }

        @Test
        void listeCompleteRefuseeAUnLecteur() {
            contexte.connecter(lecteur);

            assertThatThrownBy(() -> service.listerTous(PageRequest.of(0, 20)))
                    .isInstanceOf(AccesRefuseException.class);
        }
    }

    @Nested
    class Creation {

        @Test
        void creeUnBrouillonRattacheALUtilisateurCourant() {
            contexte.connecter(admin);
            when(articleRepository.save(any(Article.class)))
                    .thenAnswer(invocation -> invocation.getArgument(0));

            ArticleCreationDto dto = new ArticleCreationDto(
                    "Nouveau titre",
                    "Un chapeau",
                    List.of("Un paragraphe."),
                    Categorie.TECHNOLOGIE,
                    null, null, 5, null
            );

            ArticleDetailDto resultat = service.creer(dto);

            // Le statut et l'auteur viennent du service, jamais
            // du corps de la requete.
            assertThat(resultat.statut()).isEqualTo(StatutArticle.BROUILLON);
            assertThat(resultat.auteurNom()).isEqualTo("Alex");
        }

        @Test
        void refuseSansAuthentification() {
            contexte.deconnecter();

            ArticleCreationDto dto = new ArticleCreationDto(
                    "Titre", null, List.of("Texte."),
                    Categorie.GENERAL, null, null, null, null
            );

            assertThatThrownBy(() -> service.creer(dto))
                    .isInstanceOf(AccesRefuseException.class);

            verify(articleRepository, never()).save(any());
        }
    }

    @Nested
    class Modification {

        @Test
        void metAJourLeContenu() {
            Article article = DonneesDeTest.publie(10L, "Ancien titre", admin);
            when(articleRepository.chargerComplet(10L))
                    .thenReturn(Optional.of(article));
            contexte.connecter(admin);

            ArticleModificationDto dto = new ArticleModificationDto(
                    "Titre corrige", "Nouveau chapeau",
                    List.of("Texte revise."),
                    Categorie.CULTURE, null, null, 3, null
            );

            ArticleDetailDto resultat = service.modifier(10L, dto);

            assertThat(resultat.titre()).isEqualTo("Titre corrige");
            assertThat(resultat.categorie()).isEqualTo(Categorie.CULTURE);
        }

        @Test
        void neDepublienPasLArticle() {
            Article article = DonneesDeTest.publie(10L, "Un titre", admin);
            when(articleRepository.chargerComplet(10L))
                    .thenReturn(Optional.of(article));
            contexte.connecter(admin);

            ArticleModificationDto dto = new ArticleModificationDto(
                    "Titre corrige", null, List.of("Texte."),
                    Categorie.GENERAL, null, null, null, null
            );

            ArticleDetailDto resultat = service.modifier(10L, dto);

            // Corriger une faute de frappe ne doit pas retirer
            // l'article de la liste publique.
            assertThat(resultat.statut()).isEqualTo(StatutArticle.PUBLIE);
        }

        @Test
        void nAppellePasSave() {
            Article article = DonneesDeTest.publie(10L, "Un titre", admin);
            when(articleRepository.chargerComplet(10L))
                    .thenReturn(Optional.of(article));
            contexte.connecter(admin);

            service.modifier(10L, new ArticleModificationDto(
                    "Titre", null, List.of("Texte."),
                    Categorie.GENERAL, null, null, null, null));

            // L'entite est geree par Hibernate : le dirty
            // checking suffit, save serait redondant.
            verify(articleRepository, never()).save(any());
        }

        @Test
        void refuseSiLUtilisateurNEstPasLAuteur() {
            Utilisateur autre = DonneesDeTest.lecteur(3L, "Marie", "marie@test.sn");
            Article article = DonneesDeTest.publie(10L, "Un titre", autre);
            when(articleRepository.chargerComplet(10L))
                    .thenReturn(Optional.of(article));
            contexte.connecter(lecteur);

            assertThatThrownBy(() -> service.modifier(10L, new ArticleModificationDto(
                    "Titre", null, List.of("Texte."),
                    Categorie.GENERAL, null, null, null, null)))
                    .isInstanceOf(AccesRefuseException.class);
        }
    }

    @Nested
    class ChangementDeStatut {

        @Test
        void publieUnBrouillon() {
            Article article = DonneesDeTest.brouillon(10L, "Un titre", admin);
            when(articleRepository.chargerComplet(10L))
                    .thenReturn(Optional.of(article));
            contexte.connecter(admin);

            ArticleDetailDto resultat =
                    service.changerStatut(10L, StatutArticle.PUBLIE);

            assertThat(resultat.statut()).isEqualTo(StatutArticle.PUBLIE);
            assertThat(resultat.datePublication()).isNotNull();
        }

        @Test
        void traduitLExceptionDeLEntiteEnConflitMetier() {
            Article article = DonneesDeTest.publie(10L, "Un titre", admin);
            when(articleRepository.chargerComplet(10L))
                    .thenReturn(Optional.of(article));
            contexte.connecter(admin);

            // L'entite leve IllegalStateException ; sans
            // traduction, le gestionnaire global repondrait 500
            // au lieu de 409.
            assertThatThrownBy(() ->
                    service.changerStatut(10L, StatutArticle.PUBLIE))
                    .isInstanceOf(ConflitMetierException.class)
                    .hasMessageContaining("deja publie");
        }
    }

    @Nested
    class Archivage {

        @Test
        void archiveSansSupprimer() {
            Article article = DonneesDeTest.publie(10L, "Un titre", admin);
            when(articleRepository.chargerComplet(10L))
                    .thenReturn(Optional.of(article));
            contexte.connecter(admin);

            service.archiver(10L);

            assertThat(article.getStatut()).isEqualTo(StatutArticle.ARCHIVE);
            // Aucune suppression physique : les favoris qui
            // referencent cet article restent valides.
            verify(articleRepository, never()).delete(any());
            verify(articleRepository, never()).deleteById(any());
        }

        @Test
        void refuseDArchiverDeuxFois() {
            Article article = DonneesDeTest.publie(10L, "Un titre", admin);
            article.archiver();
            when(articleRepository.chargerComplet(10L))
                    .thenReturn(Optional.of(article));
            contexte.connecter(admin);

            assertThatThrownBy(() -> service.archiver(10L))
                    .isInstanceOf(ConflitMetierException.class);
        }
    }

    @Nested
    class TrouverPublie {

        @Test
        void retourneLEntite() {
            Article article = DonneesDeTest.publie(10L, "Un titre", admin);
            when(articleRepository.chargerComplet(10L))
                    .thenReturn(Optional.of(article));

            Article resultat = service.trouverPublie(10L);

            assertThat(resultat).isSameAs(article);
        }

        @Test
        void appliqueLaMemeRegleDeVisibilite() {
            Article article = DonneesDeTest.brouillon(10L, "Un brouillon", admin);
            when(articleRepository.chargerComplet(10L))
                    .thenReturn(Optional.of(article));

            // FavorisServiceImpl s'appuie dessus : la regle ne
            // doit pas etre dupliquee la-bas.
            assertThatThrownBy(() -> service.trouverPublie(10L))
                    .isInstanceOf(RessourceNonTrouveeException.class);
        }
    }
}