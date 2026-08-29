package iibs.actualites.config;

import iibs.actualites.security.*;
import org.springframework.context.annotation.*;
import org.springframework.data.domain.*;
import org.springframework.data.mongodb.config.*;

import java.util.*;

@Configuration
@EnableMongoAuditing(auditorAwareRef = "fournisseurAuditeur")
public class AuditConfig {

    private static final String AUTEUR_SYSTEME = "systeme";

    @Bean
    public AuditorAware<String> fournisseurAuditeur(ContexteSecurite contexte) {
        return () -> Optional.of(
                contexte.emailCourant().orElse(AUTEUR_SYSTEME)
        );
    }
}
