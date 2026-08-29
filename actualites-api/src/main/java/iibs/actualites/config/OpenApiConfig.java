package iibs.actualites.config;

import io.swagger.v3.oas.models.*;
import io.swagger.v3.oas.models.info.*;
import io.swagger.v3.oas.models.security.*;
import io.swagger.v3.oas.models.servers.*;
import org.springframework.beans.factory.annotation.*;
import org.springframework.context.annotation.*;

import java.util.*;

@Configuration
public class OpenApiConfig {

    private static final String SCHEMA_JWT = "bearerAuth";

    @Bean
    public OpenAPI documentationApi() {
        return new OpenAPI()
                .info(new Info()
                        .title("API Actualites")
                        .version("1.0.0")
                        .description("""
                                API de gestion d'articles d'actualites.

                                Authentification par jeton JWT : appelez
                                /api/auth/connexion, puis renseignez le jeton
                                via le bouton Authorize.
                                """)
                        .contact(new Contact()
                                .name("IIBS")
                                .email("contact@iibs.sn"))
                        .license(new License()
                                .name("Usage pedagogique")))

                .addSecurityItem(new SecurityRequirement().addList(SCHEMA_JWT))

                .components(new Components()
                        .addSecuritySchemes(SCHEMA_JWT, new SecurityScheme()
                                .name(SCHEMA_JWT)
                                .type(SecurityScheme.Type.HTTP)
                                .scheme("bearer")
                                .bearerFormat("JWT")
                                .description("Jeton obtenu via /api/auth/connexion")));
    }
}