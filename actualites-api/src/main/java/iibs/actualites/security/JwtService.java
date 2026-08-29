package iibs.actualites.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.*;
import lombok.extern.slf4j.*;
import org.springframework.beans.factory.annotation.*;
import org.springframework.stereotype.*;

import javax.crypto.*;
import java.nio.charset.*;
import java.util.*;

@Slf4j
@Service
public class JwtService {

    private static final String CLE_TYPE = "type";
    private static final String CLE_ROLE = "role";
    private static final String CLE_IDENTIFIANT = "uid";

    private static final String TYPE_ACCES = "acces";
    private static final String TYPE_RAFRAICHISSEMENT = "rafraichissement";

    private final SecretKey cle;
    private final long accesValiditeMs;
    private final long rafraichissementValiditeMs;

    public JwtService(
            @Value("${application.securite.jwt.secret}") String secret,
            @Value("${application.securite.jwt.acces-validite-ms}") long accesValiditeMs,
            @Value("${application.securite.jwt.rafraichissement-validite-ms}") long rafraichissementValiditeMs
    ) {

        this.cle = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.accesValiditeMs = accesValiditeMs;
        this.rafraichissementValiditeMs = rafraichissementValiditeMs;
    }

    public long accesValiditeSecondes() {
        return accesValiditeMs / 1000;
    }

    public String genererJetonAcces(String email, String role, Long identifiant) {
        return construire(email, TYPE_ACCES, role, identifiant, accesValiditeMs);
    }

    public String genererJetonRafraichissement(String email) {
        return construire(email, TYPE_RAFRAICHISSEMENT, null, null,
                rafraichissementValiditeMs);
    }

    private String construire(
            String email,
            String type,
            String role,
            Long identifiant,
            long dureeMs
    ) {
        Date maintenant = new Date();
        Date expiration = new Date(maintenant.getTime() + dureeMs);

        JwtBuilder constructeur = Jwts.builder()
                .subject(email)
                .claim(CLE_TYPE, type)
                .issuedAt(maintenant)
                .expiration(expiration);

        if (role != null) {
            constructeur.claim(CLE_ROLE, role);
        }
        if (identifiant != null) {
            constructeur.claim(CLE_IDENTIFIANT, identifiant);
        }

        return constructeur.signWith(cle).compact();
    }

    public String extraireEmail(String jeton) {
        return lireRevendications(jeton).getSubject();
    }

    public String extraireRole(String jeton) {
        return lireRevendications(jeton).get(CLE_ROLE, String.class);
    }

    public Long extraireIdentifiant(String jeton) {
        Number valeur = lireRevendications(jeton).get(CLE_IDENTIFIANT, Number.class);
        return valeur == null ? null : valeur.longValue();
    }

    public boolean estJetonAccesValide(String jeton) {
        return estValide(jeton) && TYPE_ACCES.equals(extraireType(jeton));
    }

    public boolean estJetonRafraichissementValide(String jeton) {
        return estValide(jeton) && TYPE_RAFRAICHISSEMENT.equals(extraireType(jeton));
    }

    public boolean estValide(String jeton) {
        try {
            lireRevendications(jeton);
            return true;
        } catch (ExpiredJwtException exception) {
            log.debug("Jeton expire");
            return false;
        } catch (JwtException | IllegalArgumentException exception) {
            log.debug("Jeton invalide : {}", exception.getClass().getSimpleName());
            return false;
        }
    }

    private String extraireType(String jeton) {
        try {
            return lireRevendications(jeton).get(CLE_TYPE, String.class);
        } catch (JwtException | IllegalArgumentException exception) {
            return null;
        }
    }

    private Claims lireRevendications(String jeton) {
        return Jwts.parser()
                .verifyWith(cle)
                .build()
                .parseSignedClaims(jeton)
                .getPayload();
    }
}

