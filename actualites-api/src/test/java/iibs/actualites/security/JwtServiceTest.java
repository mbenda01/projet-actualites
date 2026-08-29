package iibs.actualites.security;

import org.junit.jupiter.api.*;

import static org.assertj.core.api.Assertions.*;

// ============================================================
// Tests de JwtService.
//
// Le service est instancie directement avec ses trois
// parametres : aucun contexte Spring n'est necessaire.
//
// Les durees sont volontairement courtes pour tester
// l'expiration sans attendre : c'est le meme principe que le
// delai injectable de ServiceRecherche cote Flutter.
//
// Le test central est celui du TYPE : sans lui, un jeton
// d'acces pourrait servir a se renouveler indefiniment, ce qui
// annulerait l'interet de sa duree courte.
// ============================================================

class JwtServiceTest {

    /// 32 caracteres minimum : hmacShaKeyFor l'exige.
    private static final String SECRET =
            "secret-de-test-de-32-caracteres-minimum-pour-hmac";

    private static final String EMAIL = "test@exemple.sn";
    private static final String ROLE = "ADMIN";
    private static final Long IDENTIFIANT = 42L;

    /// Durees longues : le jeton reste valide pendant le test.
    private JwtService service;

    @BeforeEach
    void preparer() {
        service = new JwtService(SECRET, 900_000L, 604_800_000L);
    }

    @Nested
    class Emission {

        @Test
        void genereUnJetonDAcces() {
            String jeton = service.genererJetonAcces(EMAIL, ROLE, IDENTIFIANT);

            assertThat(jeton).isNotBlank();
            // Un JWT compte trois segments separes par des points.
            assertThat(jeton.split("\\.")).hasSize(3);
        }

        @Test
        void genereUnJetonDeRafraichissement() {
            String jeton = service.genererJetonRafraichissement(EMAIL);

            assertThat(jeton).isNotBlank();
            assertThat(jeton.split("\\.")).hasSize(3);
        }

        @Test
        void produitDesJetonsDifferents() {
            String acces = service.genererJetonAcces(EMAIL, ROLE, IDENTIFIANT);
            String rafraichissement = service.genererJetonRafraichissement(EMAIL);

            assertThat(acces).isNotEqualTo(rafraichissement);
        }
    }

    @Nested
    class Lecture {

        @Test
        void extraitLEmail() {
            String jeton = service.genererJetonAcces(EMAIL, ROLE, IDENTIFIANT);

            assertThat(service.extraireEmail(jeton)).isEqualTo(EMAIL);
        }

        @Test
        void extraitLeRole() {
            String jeton = service.genererJetonAcces(EMAIL, ROLE, IDENTIFIANT);

            assertThat(service.extraireRole(jeton)).isEqualTo(ROLE);
        }

        @Test
        void extraitLIdentifiant() {
            String jeton = service.genererJetonAcces(EMAIL, ROLE, IDENTIFIANT);

            assertThat(service.extraireIdentifiant(jeton)).isEqualTo(IDENTIFIANT);
        }

        @Test
        void leJetonDeRafraichissementNePortePasDeRole() {
            String jeton = service.genererJetonRafraichissement(EMAIL);

            // Le role est relu en base au rafraichissement : un
            // changement de role prend donc effet sans attendre
            // l'expiration du jeton long.
            assertThat(service.extraireRole(jeton)).isNull();
            assertThat(service.extraireIdentifiant(jeton)).isNull();
        }

        @Test
        void leJetonDeRafraichissementPorteLEmail() {
            String jeton = service.genererJetonRafraichissement(EMAIL);

            assertThat(service.extraireEmail(jeton)).isEqualTo(EMAIL);
        }
    }

    @Nested
    class VerificationDuType {

        @Test
        void accepteUnJetonDAccesCommeAcces() {
            String jeton = service.genererJetonAcces(EMAIL, ROLE, IDENTIFIANT);

            assertThat(service.estJetonAccesValide(jeton)).isTrue();
        }

        @Test
        void refuseUnJetonDeRafraichissementCommeAcces() {
            String jeton = service.genererJetonRafraichissement(EMAIL);

            // Sans cette verification, un jeton de
            // rafraichissement pourrait appeler l'API pendant
            // sept jours.
            assertThat(service.estJetonAccesValide(jeton)).isFalse();
        }

        @Test
        void accepteUnJetonDeRafraichissementCommeRafraichissement() {
            String jeton = service.genererJetonRafraichissement(EMAIL);

            assertThat(service.estJetonRafraichissementValide(jeton)).isTrue();
        }

        @Test
        void refuseUnJetonDAccesCommeRafraichissement() {
            String jeton = service.genererJetonAcces(EMAIL, ROLE, IDENTIFIANT);

            // Le test central : sans lui, un jeton d'acces vole
            // pourrait se prolonger indefiniment, annulant
            // l'interet de sa duree courte.
            assertThat(service.estJetonRafraichissementValide(jeton)).isFalse();
        }
    }

    @Nested
    class Validite {

        @Test
        void refuseUnJetonMalForme() {
            assertThat(service.estValide("pas-un-jeton")).isFalse();
        }

        @Test
        void refuseUneChaineVide() {
            assertThat(service.estValide("")).isFalse();
        }

        @Test
        void refuseUnJetonSigneAvecUnAutreSecret() {
            JwtService autreService = new JwtService(
                    "un-autre-secret-de-32-caracteres-au-moins-ici",
                    900_000L, 604_800_000L);

            String jeton = autreService.genererJetonAcces(EMAIL, ROLE, IDENTIFIANT);

            // C'est la signature qui empeche un client de forger
            // ses propres jetons.
            assertThat(service.estValide(jeton)).isFalse();
        }

        @Test
        void refuseUnJetonExpire() throws InterruptedException {
            // Duree de 1 ms : le jeton expire immediatement.
            JwtService serviceRapide = new JwtService(SECRET, 1L, 1L);

            String jeton = serviceRapide.genererJetonAcces(EMAIL, ROLE, IDENTIFIANT);

            Thread.sleep(50);

            assertThat(serviceRapide.estValide(jeton)).isFalse();
        }
    }

    @Nested
    class Configuration {

        @Test
        void exposeLaDureeEnSecondes() {
            JwtService serviceQuinzeMinutes =
                    new JwtService(SECRET, 900_000L, 604_800_000L);

            assertThat(serviceQuinzeMinutes.accesValiditeSecondes()).isEqualTo(900);
        }

        @Test
        void refuseUnSecretTropCourt() {
            // hmacShaKeyFor exige 256 bits, soit 32 caracteres.
            // Un secret plus court est refuse a la construction
            // plutot qu'a la premiere requete.
            assertThatThrownBy(() -> new JwtService("court", 900_000L, 604_800_000L))
                    .isInstanceOf(Exception.class);
        }
    }
}
