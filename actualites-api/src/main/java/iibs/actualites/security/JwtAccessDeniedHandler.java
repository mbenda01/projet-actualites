package iibs.actualites.security;

import iibs.actualites.exception.*;
import jakarta.servlet.http.*;
import lombok.*;
import lombok.extern.slf4j.*;
import org.springframework.http.*;
import org.springframework.security.access.*;
import org.springframework.security.web.access.*;
import org.springframework.stereotype.*;
import tools.jackson.databind.*;

import java.io.*;

@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAccessDeniedHandler implements AccessDeniedHandler {

    private final ObjectMapper objectMapper;

    @Override
    public void handle(
            HttpServletRequest requete,
            HttpServletResponse reponse,
            AccessDeniedException exception
    ) throws IOException {

        log.warn("Acces refuse sur {} {}", requete.getMethod(), requete.getRequestURI());

        reponse.setStatus(HttpStatus.FORBIDDEN.value());
        reponse.setContentType(MediaType.APPLICATION_JSON_VALUE);
        reponse.setCharacterEncoding("UTF-8");

        objectMapper.writeValue(
                reponse.getOutputStream(),
                ApiResponse.erreur(HttpStatus.FORBIDDEN, "Acces refuse")
        );
    }
}