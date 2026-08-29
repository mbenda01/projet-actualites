package iibs.actualites.service;

import iibs.actualites.entity.*;
import iibs.actualites.exception.*;
import iibs.actualites.faux.*;
import iibs.actualites.repository.*;
import iibs.actualites.service.impl.*;
import iibs.actualites.service.mapper.*;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.extension.*;
import org.mockito.*;
import org.mockito.junit.jupiter.*;
import org.springframework.dao.*;
import org.springframework.data.domain.*;

import java.util.*;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

// ============================================================
// Tests de FavorisServiceImpl.
//
// Deux dependances simulees : le depot des favoris et
// ArticleService.
//
// Simuler ArticleService plutot qu'ArticleRepository est
// exactement ce que la refonte a permis : le service des
// favoris ne connait plus la persistance des articles, il
// depend d'un contrat. Les tests le reflatent.
//
// CE QUE CES TESTS VERIFIENT
// L'idempotence, le rattachement a l'utilisateur courant, et le
// rattrapage des ajouts concurrents.
// ============================================================

@ExtendWith(MockitoExtension.class)
class FavorisServiceImplTest {

    @Mock
    private FavoriRepository favoriRepository;

    @Mock
    private ArticleService articleService;

    private ArticleMapper articleMapper;
    private FauxContexteSecurite contexte;
    private FavorisServiceImpl service;

    private Utilisateur lecteur;
    private Article article;

    @BeforeEach
    void preparer() {
        articleMapper = new ArticleMapperImpl();
        contexte = new FauxContexteSecurite();

        service = new FavorisServiceImpl(
                favoriRepository, articleService, articleMapper, contexte);

        lecteur = DonneesDeTest.lecteur(1L, "Sam", "sam@test.sn");
        article = DonneesDeTest.publie(10L, "Un article", DonneesDeTest.administrateur());

        contexte.connecter(lecteur);
    }

    @Nested
    class Lecture {

        @Test
        void listeLesIdentifiantsDeLUtilisateurCourant() {
            when(favoriRepository.listerIdentifiantsArticles(1L))
                    .thenReturn(Set.of(10L, 11L));

            Set<Long> resultat = service.listerIdentifiants();

            assertThat(resultat).containsExactlyInAnyOrder(10L, 11L);

            // L'identifiant vient du contexte, jamais d'un
            // parametre : personne ne peut lire les favoris
            // d'autrui.
            verify(favoriRepository).listerIdentifiantsArticles(1L);
        }

        @Test
        void retourneUnEnsembleNonModifiable() {
            when(favoriRepository.listerIdentifiantsArticles(any()))
                    .thenReturn(new HashSet<>(Set.of(10L)));

            Set<Long> resultat = service.listerIdentifiants();

            assertThatThrownBy(() -> resultat.add(99L))
                    .isInstanceOf(UnsupportedOperationException.class);
        }

        @Test
        void refuseSansAuthentification() {
            contexte.deconnecter();

            assertThatThrownBy(() -> service.listerIdentifiants())
                    .isInstanceOf(AccesRefuseException.class);

            verify(favoriRepository, never()).listerIdentifiantsArticles(any());
        }

        @Test
        void compteLesFavorisDeLUtilisateurCourant() {
            when(favoriRepository.countByUtilisateurId(1L)).thenReturn(3L);

            assertThat(service.compter()).isEqualTo(3L);
        }

        @Test
        void listeLesArticlesPagines() {
            when(favoriRepository.listerArticles(eq(1L), any()))
                    .thenReturn(new PageImpl<>(List.of(article)));

            var resultat = service.listerArticles(PageRequest.of(0, 20));

            assertThat(resultat.getContent()).hasSize(1);
            assertThat(resultat.getContent().get(0).titre()).isEqualTo("Un article");
        }
    }

    @Nested
    class Bascule {

        @Test
        void ajouteUnArticleAbsent() {
            when(favoriRepository.findByUtilisateurIdAndArticleId(1L, 10L))
                    .thenReturn(Optional.empty());
            when(articleService.trouverPublie(10L)).thenReturn(article);

            boolean resultat = service.basculer(10L);

            assertThat(resultat).isTrue();
            verify(favoriRepository).save(any(Favori.class));
        }

        @Test
        void retireUnArticlePresent() {
            Favori favori = Favori.enregistrer(lecteur, article);
            when(favoriRepository.findByUtilisateurIdAndArticleId(1L, 10L))
                    .thenReturn(Optional.of(favori));

            boolean resultat = service.basculer(10L);

            assertThat(resultat).isFalse();
            verify(favoriRepository).delete(favori);
            verify(favoriRepository, never()).save(any());
        }

        @Test
        void refuseUnArticleNonPublie() {
            when(favoriRepository.findByUtilisateurIdAndArticleId(any(), any()))
                    .thenReturn(Optional.empty());
            when(articleService.trouverPublie(10L))
                    .thenThrow(RessourceNonTrouveeException.pour("Article", 10L));

            // La regle de visibilite vit dans ArticleService :
            // FavorisServiceImpl ne la duplique pas.
            assertThatThrownBy(() -> service.basculer(10L))
                    .isInstanceOf(RessourceNonTrouveeException.class);
        }
    }

    @Nested
    class Ajout {

        @Test
        void enregistreUnArticlePublie() {
            when(favoriRepository.existsByUtilisateurIdAndArticleId(1L, 10L))
                    .thenReturn(false);
            when(articleService.trouverPublie(10L)).thenReturn(article);

            service.ajouter(10L);

            verify(favoriRepository).save(any(Favori.class));
        }

        @Test
        void estIdempotent() {
            when(favoriRepository.existsByUtilisateurIdAndArticleId(1L, 10L))
                    .thenReturn(true);

            service.ajouter(10L);

            // Ajouter un favori existant ne fait rien : le
            // client peut appeler sans verifier d'abord, ce qui
            // economise un aller-retour reseau.
            verify(favoriRepository, never()).save(any());
            verify(articleService, never()).trouverPublie(any());
        }

        @Test
        void rattrapeUnAjoutConcurrent() {
            when(favoriRepository.existsByUtilisateurIdAndArticleId(any(), any()))
                    .thenReturn(false);
            when(articleService.trouverPublie(10L)).thenReturn(article);
            when(favoriRepository.save(any(Favori.class)))
                    .thenThrow(new DataIntegrityViolationException("doublon"));

            // Deux requetes simultanees : la contrainte
            // d'unicite a rejete la seconde. L'article EST en
            // favori, ce que voulait l'appelant — on ne propage
            // pas l'erreur.
            assertThatCode(() -> service.ajouter(10L))
                    .doesNotThrowAnyException();
        }
    }

    @Nested
    class Retrait {

        @Test
        void supprimeEnUneRequete() {
            when(favoriRepository.supprimer(1L, 10L)).thenReturn(1);

            service.retirer(10L);

            // Une seule requete au lieu d'un findBy suivi d'un
            // delete.
            verify(favoriRepository).supprimer(1L, 10L);
            verify(favoriRepository, never()).findByUtilisateurIdAndArticleId(any(), any());
        }

        @Test
        void estIdempotent() {
            when(favoriRepository.supprimer(1L, 99L)).thenReturn(0);

            // Retirer un favori absent ne leve pas : zero ligne
            // affectee est un resultat normal.
            assertThatCode(() -> service.retirer(99L))
                    .doesNotThrowAnyException();
        }
    }

    @Nested
    class SuppressionTotale {

        @Test
        void videLesFavorisDeLUtilisateurCourant() {
            when(favoriRepository.supprimerTout(1L)).thenReturn(3);

            service.toutRetirer();

            verify(favoriRepository).supprimerTout(1L);
        }

        @Test
        void refuseSansAuthentification() {
            contexte.deconnecter();

            assertThatThrownBy(() -> service.toutRetirer())
                    .isInstanceOf(AccesRefuseException.class);

            verify(favoriRepository, never()).supprimerTout(any());
        }
    }
}