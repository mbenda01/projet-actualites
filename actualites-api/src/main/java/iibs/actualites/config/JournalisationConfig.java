package iibs.actualites.config;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import lombok.extern.slf4j.*;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.*;
import org.springframework.core.*;
import org.jspecify.annotations.NonNull;
import org.springframework.web.filter.*;

import java.io.*;
import java.util.*;

@Configuration
public class JournalisationConfig {

    @Bean
    public FilterRegistrationBean<FiltreJournalisation> filtreJournalisation() {
        FilterRegistrationBean<FiltreJournalisation> enregistrement =
                new FilterRegistrationBean<>(new FiltreJournalisation());

        enregistrement.addUrlPatterns("/api/*");
        enregistrement.setOrder(Ordered.HIGHEST_PRECEDENCE + 10);

        return enregistrement;
    }

    @Slf4j
    public static class FiltreJournalisation extends OncePerRequestFilter {

        private static final long SEUIL_LENTEUR_MS = 1000;

        private static final Set<String> CHEMINS_EXCLUS = Set.of(
                "/actuator/health"
        );

        @Override
        protected void doFilterInternal(
                @NonNull HttpServletRequest requete,
                @NonNull HttpServletResponse reponse,
                @NonNull FilterChain chaine
        ) throws ServletException, IOException {

            if (CHEMINS_EXCLUS.contains(requete.getRequestURI())) {
                chaine.doFilter(requete, reponse);
                return;
            }

            long debut = System.currentTimeMillis();

            try {
                chaine.doFilter(requete, reponse);
            } finally {
                journaliser(requete, reponse, System.currentTimeMillis() - debut);
            }
        }

        private void journaliser(
                HttpServletRequest requete,
                HttpServletResponse reponse,
                long duree
        ) {
            String methode = requete.getMethod();
            String chemin = requete.getRequestURI();
            int statut = reponse.getStatus();

            if (statut >= 500) {
                log.error("{} {} -> {} en {}ms", methode, chemin, statut, duree);
            } else if (duree > SEUIL_LENTEUR_MS) {
                log.warn("{} {} -> {} en {}ms (lent)", methode, chemin, statut, duree);
            } else {
                log.debug("{} {} -> {} en {}ms", methode, chemin, statut, duree);
            }
        }
    }
}