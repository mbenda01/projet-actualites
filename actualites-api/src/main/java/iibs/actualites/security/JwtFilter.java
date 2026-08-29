package iibs.actualites.security;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.*;
import org.jspecify.annotations.NonNull;
import org.springframework.security.authentication.*;
import org.springframework.security.core.context.*;
import org.springframework.security.core.userdetails.*;
import org.springframework.security.web.authentication.*;
import org.springframework.stereotype.*;
import org.springframework.web.filter.*;

import java.io.*;

@Slf4j
@Component
@RequiredArgsConstructor
public class JwtFilter extends OncePerRequestFilter {

    private static final String EN_TETE = "Authorization";
    private static final String PREFIXE = "Bearer ";

    private final JwtService jwtService;
    private final UtilisateurDetailsService utilisateurDetailsService;

    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest requete,
            @NonNull HttpServletResponse reponse,
            @NonNull FilterChain chaine) throws ServletException, IOException {

        String jeton = extraireJeton(requete);

        if (jeton == null || SecurityContextHolder.getContext().getAuthentication() != null) {
            chaine.doFilter(requete, reponse);
            return;
        }

        try {
            if (jwtService.estJetonAccesValide(jeton)) {
                authentifier(requete, jeton);
            }
        } catch (Exception exception) {
            log.debug("Echec du traitement du jeton : {}",
                    exception.getClass().getSimpleName());
            SecurityContextHolder.clearContext();
        }

        chaine.doFilter(requete, reponse);
    }

    private void authentifier(HttpServletRequest requete, String jeton) {
        String email = jwtService.extraireEmail(jeton);
        if (email == null)
            return;

        UserDetails details = utilisateurDetailsService.loadUserByUsername(email);

        UsernamePasswordAuthenticationToken authentification = new UsernamePasswordAuthenticationToken(
                details, null, details.getAuthorities());

        authentification.setDetails(
                new WebAuthenticationDetailsSource().buildDetails(requete));

        SecurityContextHolder.getContext().setAuthentication(authentification);
    }

    private String extraireJeton(HttpServletRequest requete) {
        String enTete = requete.getHeader(EN_TETE);

        if (enTete == null || !enTete.startsWith(PREFIXE)) {
            return null;
        }

        String jeton = enTete.substring(PREFIXE.length()).trim();
        return jeton.isEmpty() ? null : jeton;
    }
}