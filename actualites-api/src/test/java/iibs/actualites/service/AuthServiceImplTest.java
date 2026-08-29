package iibs.actualites.service;

import iibs.actualites.controller.dto.*;
import iibs.actualites.entity.*;
import iibs.actualites.exception.*;
import iibs.actualites.faux.*;
import iibs.actualites.repository.*;
import iibs.actualites.security.*;
import iibs.actualites.service.impl.*;
import iibs.actualites.service.mapper.*;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.extension.*;
import org.mockito.*;
import org.mockito.junit.jupiter.*;
import org.springframework.security.crypto.password.*;

import java.util.*;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

// ============================================================
// Tests d'AuthServiceImpl.
//
// JwtService est le vrai : il n'a aucune dependance externe et
// ses jetons sont verifiables directement. Le simuler
// obligerait a decrire des valeurs factices sans rien verifier.
//
// PasswordEncoder est simule : BCrypt prend plusieurs centaines
// de millisecondes par appel, volontairement. Sur vingt tests,
// cela ferait plusieurs secondes d'attente pour verifier une
// logique qui n'est pas celle du hachage.
//
// CE QUE CES TESTS VERIFIENT
// La normalisation des emails, l'absence de fuite
// d'information sur les comptes, et les regles du
// rafraichissement.
// ============================================================

@ExtendWith(MockitoExtension.class)
class AuthServiceImplTest {

    private static final String SECRET =
            "secret-de-test-de-32-caracteres-minimum-pour-hmac";

    private static final String MOT_DE_PASSE = "MotDePasse123";

    @Mock
    private UtilisateurRepository utilisateurRepository;

    @Mock
    private PasswordEncoder encodeur;

    private JwtService jwtService;
    private UtilisateurMapper utilisateurMapper;
    private FauxContexteSecurite contexte;
    private AuthServiceImpl service;

    private Utilisateur lecteur;

    @BeforeEach
    void preparer() {
        jwtService = new JwtService(SECRET, 900_000L, 604_800_000L);
        utilisateurMapper = new UtilisateurMapperImpl();
        contexte = new FauxContexteSecurite();

        service = new AuthServiceImpl(
                utilisateurRepository, utilisateurMapper,
                encodeur, jwtService, contexte);

        lecteur = DonneesDeTest.lecteur(1L, "Sam", "sam@test.sn");
    }

    @Nested
    class Inscription {

        @Test
        void creeUnCompteLecteur() {
            when(utilisateurRepository.existsByEmail(anyString())).thenReturn(false);
            when(encodeur.encode(anyString())).thenReturn(DonneesDeTest.EMPREINTE);
            when(utilisateurRepository.save(any(Utilisateur.class)))
                    .thenAnswer(invocation -> invocation.getArgument(0));

            JetonReponseDto reponse = service.inscrire(new InscriptionRequestDto(
                    "Sam Ndiaye", "sam@test.sn", MOT_DE_PASSE));

            assertThat(reponse.utilisateur().nom()).isEqualTo("Sam Ndiaye");
            assertThat(reponse.jetonAcces()).isNotBlank();
            assertThat(reponse.jetonRafraichissement()).isNotBlank();
        }

        @Test
        void hacheLeMotDePasseAvantDeLeStocker() {
            when(utilisateurRepository.existsByEmail(anyString())).thenReturn(false);
            when(encodeur.encode(MOT_DE_PASSE)).thenReturn(DonneesDeTest.EMPREINTE);
            when(utilisateurRepository.save(any(Utilisateur.class)))
                    .thenAnswer(invocation -> invocation.getArgument(0));

            service.inscrire(new InscriptionRequestDto(
                    "Sam", "sam@test.sn", MOT_DE_PASSE));

            // L'entite ne recoit jamais la valeur en clair.
            ArgumentCaptor<Utilisateur> capture =
                    ArgumentCaptor.forClass(Utilisateur.class);
            verify(utilisateurRepository).save(capture.capture());

            assertThat(capture.getValue().getMotDePasse())
                    .isEqualTo(DonneesDeTest.EMPREINTE)
                    .isNotEqualTo(MOT_DE_PASSE);
        }

        @Test
        void normaliseLEmail() {
            when(utilisateurRepository.existsByEmail("sam@test.sn")).thenReturn(false);
            when(encodeur.encode(anyString())).thenReturn(DonneesDeTest.EMPREINTE);
            when(utilisateurRepository.save(any(Utilisateur.class)))
                    .thenAnswer(invocation -> invocation.getArgument(0));

            service.inscrire(new InscriptionRequestDto(
                    "Sam", "  SAM@Test.SN  ", MOT_DE_PASSE));

            // La verification d'unicite porte sur l'email
            // normalise : sinon SAM@Test.SN passerait alors que
            // sam@test.sn existe deja.
            verify(utilisateurRepository).existsByEmail("sam@test.sn");
        }

        @Test
        void refuseUnEmailDejaUtilise() {
            when(utilisateurRepository.existsByEmail(anyString())).thenReturn(true);

            assertThatThrownBy(() -> service.inscrire(new InscriptionRequestDto(
                    "Sam", "sam@test.sn", MOT_DE_PASSE)))
                    .isInstanceOf(ConflitMetierException.class);

            verify(utilisateurRepository, never()).save(any());
        }
    }

    @Nested
    class Connexion {

        @Test
        void retourneLesDeuxJetons() {
            when(utilisateurRepository.findByEmail("sam@test.sn"))
                    .thenReturn(Optional.of(lecteur));
            when(encodeur.matches(anyString(), anyString())).thenReturn(true);

            JetonReponseDto reponse = service.connecter(
                    new ConnexionRequestDto("sam@test.sn", MOT_DE_PASSE));

            assertThat(reponse.jetonAcces()).isNotBlank();
            assertThat(reponse.jetonRafraichissement()).isNotBlank();
            assertThat(reponse.typeJeton()).isEqualTo("Bearer");
            assertThat(reponse.expiresIn()).isEqualTo(900);
        }

        @Test
        void leJetonPorteLeRoleEtLIdentifiant() {
            Utilisateur admin = DonneesDeTest.administrateur(5L, "Alex", "alex@test.sn");
            when(utilisateurRepository.findByEmail(anyString()))
                    .thenReturn(Optional.of(admin));
            when(encodeur.matches(anyString(), anyString())).thenReturn(true);

            JetonReponseDto reponse = service.connecter(
                    new ConnexionRequestDto("alex@test.sn", MOT_DE_PASSE));

            assertThat(jwtService.extraireRole(reponse.jetonAcces())).isEqualTo("ADMIN");
            assertThat(jwtService.extraireIdentifiant(reponse.jetonAcces())).isEqualTo(5L);
        }

        @Test
        void normaliseLEmailAvantRecherche() {
            when(utilisateurRepository.findByEmail("sam@test.sn"))
                    .thenReturn(Optional.of(lecteur));
            when(encodeur.matches(anyString(), anyString())).thenReturn(true);

            service.connecter(new ConnexionRequestDto("  SAM@Test.SN  ", MOT_DE_PASSE));

            // Sans normalisation, un compte cree avec une
            // majuscule serait introuvable a la connexion.
            verify(utilisateurRepository).findByEmail("sam@test.sn");
        }

        @Test
        void refuseUnCompteInexistant() {
            when(utilisateurRepository.findByEmail(anyString()))
                    .thenReturn(Optional.empty());

            assertThatThrownBy(() -> service.connecter(
                    new ConnexionRequestDto("inconnu@test.sn", MOT_DE_PASSE)))
                    .isInstanceOf(IdentifiantsInvalidesException.class);
        }

        @Test
        void refuseUnMauvaisMotDePasse() {
            when(utilisateurRepository.findByEmail(anyString()))
                    .thenReturn(Optional.of(lecteur));
            when(encodeur.matches(anyString(), anyString())).thenReturn(false);

            assertThatThrownBy(() -> service.connecter(
                    new ConnexionRequestDto("sam@test.sn", "MauvaisMotDePasse")))
                    .isInstanceOf(IdentifiantsInvalidesException.class);
        }

        @Test
        void refuseUnCompteDesactive() {
            lecteur.desactiver();
            when(utilisateurRepository.findByEmail(anyString()))
                    .thenReturn(Optional.of(lecteur));

            assertThatThrownBy(() -> service.connecter(
                    new ConnexionRequestDto("sam@test.sn", MOT_DE_PASSE)))
                    .isInstanceOf(IdentifiantsInvalidesException.class);

            // Le mot de passe n'est meme pas verifie : inutile
            // de depenser du temps BCrypt pour un compte
            // desactive.
            verify(encodeur, never()).matches(anyString(), anyString());
        }

        @Test
        void neDivulguePasSiLeCompteExiste() {
            when(utilisateurRepository.findByEmail("inconnu@test.sn"))
                    .thenReturn(Optional.empty());
            when(utilisateurRepository.findByEmail("sam@test.sn"))
                    .thenReturn(Optional.of(lecteur));
            when(encodeur.matches(anyString(), anyString())).thenReturn(false);

            String messageCompteInconnu = attraperMessage(() -> service.connecter(
                    new ConnexionRequestDto("inconnu@test.sn", MOT_DE_PASSE)));

            String messageMauvaisMotDePasse = attraperMessage(() -> service.connecter(
                    new ConnexionRequestDto("sam@test.sn", "Mauvais")));

            // Messages identiques : distinguer les deux cas
            // permettrait d'enumerer les comptes existants.
            assertThat(messageCompteInconnu).isEqualTo(messageMauvaisMotDePasse);
        }

        private String attraperMessage(Runnable action) {
            try {
                action.run();
                return null;
            } catch (Exception exception) {
                return exception.getMessage();
            }
        }
    }

    @Nested
    class Rafraichissement {

        @Test
        void renouvelleLesJetons() {
            String jetonRafraichissement =
                    jwtService.genererJetonRafraichissement("sam@test.sn");

            when(utilisateurRepository.findByEmail("sam@test.sn"))
                    .thenReturn(Optional.of(lecteur));

            JetonReponseDto reponse = service.rafraichir(
                    new RafraichissementRequestDto(jetonRafraichissement));

            assertThat(reponse.jetonAcces()).isNotBlank();
            assertThat(reponse.jetonRafraichissement()).isNotBlank();
        }

        @Test
        void relitLeRoleEnBase() {
            String jetonRafraichissement =
                    jwtService.genererJetonRafraichissement("sam@test.sn");

            // Le compte est passe ADMIN depuis l'emission du
            // jeton de rafraichissement.
            lecteur.promouvoirAdministrateur();
            when(utilisateurRepository.findByEmail("sam@test.sn"))
                    .thenReturn(Optional.of(lecteur));

            JetonReponseDto reponse = service.rafraichir(
                    new RafraichissementRequestDto(jetonRafraichissement));

            // Le nouveau jeton porte le role a jour : le
            // changement prend effet sans attendre l'expiration
            // du jeton long.
            assertThat(jwtService.extraireRole(reponse.jetonAcces())).isEqualTo("ADMIN");
        }

        @Test
        void refuseUnJetonDAcces() {
            String jetonAcces =
                    jwtService.genererJetonAcces("sam@test.sn", "LECTEUR", 1L);

            // Sans cette verification, un jeton d'acces vole
            // pourrait se prolonger indefiniment.
            assertThatThrownBy(() -> service.rafraichir(
                    new RafraichissementRequestDto(jetonAcces)))
                    .isInstanceOf(IdentifiantsInvalidesException.class);

            verify(utilisateurRepository, never()).findByEmail(anyString());
        }

        @Test
        void refuseUnJetonMalForme() {
            assertThatThrownBy(() -> service.rafraichir(
                    new RafraichissementRequestDto("pas-un-jeton")))
                    .isInstanceOf(IdentifiantsInvalidesException.class);
        }

        @Test
        void refuseSiLeCompteAEteSupprime() {
            String jeton = jwtService.genererJetonRafraichissement("sam@test.sn");
            when(utilisateurRepository.findByEmail(anyString()))
                    .thenReturn(Optional.empty());

            assertThatThrownBy(() -> service.rafraichir(
                    new RafraichissementRequestDto(jeton)))
                    .isInstanceOf(IdentifiantsInvalidesException.class);
        }

        @Test
        void refuseSiLeCompteAEteDesactive() {
            String jeton = jwtService.genererJetonRafraichissement("sam@test.sn");
            lecteur.desactiver();
            when(utilisateurRepository.findByEmail(anyString()))
                    .thenReturn(Optional.of(lecteur));

            // Desactiver un compte le deconnecte dans les quinze
            // minutes, au lieu d'attendre sept jours.
            assertThatThrownBy(() -> service.rafraichir(
                    new RafraichissementRequestDto(jeton)))
                    .isInstanceOf(IdentifiantsInvalidesException.class);
        }
    }

    @Nested
    class ProfilCourant {

        @Test
        void retourneLUtilisateurConnecte() {
            contexte.connecter(lecteur);

            UtilisateurReponseDto profil = service.profilCourant();

            assertThat(profil.email()).isEqualTo("sam@test.sn");
        }

        @Test
        void refuseSansAuthentification() {
            contexte.deconnecter();

            assertThatThrownBy(() -> service.profilCourant())
                    .isInstanceOf(AccesRefuseException.class);
        }
    }
}