package iibs.actualites.security;

import iibs.actualites.exception.*;
import jakarta.servlet.http.*;
import lombok.*;
import lombok.extern.slf4j.*;
import org.springframework.http.*;
import org.springframework.security.core.*;
import org.springframework.security.web.*;
import org.springframework.stereotype.*;
import tools.jackson.databind.*;

import java.io.*;

@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthenticationEntryPoint implements AuthenticationEntryPoint {

    private final ObjectMapper objectMapper;

    @Override
    public void commence(
            HttpServletRequest requete,
            HttpServletResponse reponse,
            AuthenticationException exception
    ) throws IOException {

        log.debug("Requete non authentifiee sur {}", requete.getRequestURI());

        reponse.setStatus(HttpStatus.UNAUTHORIZED.value());
        reponse.setContentType(MediaType.APPLICATION_JSON_VALUE);
        reponse.setCharacterEncoding("UTF-8");

        objectMapper.writeValue(
                reponse.getOutputStream(),
                ApiResponse.erreur(HttpStatus.UNAUTHORIZED, "Authentification requise")
        );
    }
}