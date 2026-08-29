package iibs.actualites.exception;

import lombok.extern.slf4j.*;
import org.springframework.dao.*;
import org.springframework.http.*;
import org.springframework.http.converter.*;
import org.springframework.security.access.*;
import org.springframework.security.core.userdetails.*;
import org.springframework.validation.*;
import org.springframework.web.bind.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.method.annotation.*;

import java.util.*;
import java.util.stream.*;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

        @ExceptionHandler(MethodArgumentNotValidException.class)
        public ResponseEntity<ApiResponse<Map<String, String>>> gererValidation(
                        MethodArgumentNotValidException exception) {
                Map<String, String> erreurs = exception.getBindingResult().getFieldErrors().stream()
                                .collect(Collectors.toMap(
                                                FieldError::getField,
                                                erreur -> Optional.ofNullable(erreur.getDefaultMessage())
                                                                .orElse("Valeur invalide"),
                                                (message1, message2) -> message1));

                exception.getBindingResult().getGlobalErrors()
                                .forEach(erreur -> erreurs.put(erreur.getObjectName(), erreur.getDefaultMessage()));

                log.debug("Validation echouee sur {} champ(s) : {}", erreurs.size(), erreurs.keySet());

                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                                .body(ApiResponse.erreur(HttpStatus.BAD_REQUEST, "Validation echouee", erreurs));
        }

        @ExceptionHandler(RessourceNonTrouveeException.class)
        public ResponseEntity<ApiResponse<Void>> gererRessourceNonTrouvee(
                        RessourceNonTrouveeException exception) {
                log.debug("Ressource non trouvee : {}", exception.getMessage());

                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                                .body(ApiResponse.erreur(HttpStatus.NOT_FOUND, exception.getMessage()));
        }

        @ExceptionHandler(ConflitMetierException.class)
        public ResponseEntity<ApiResponse<Void>> gererConflitMetier(
                        ConflitMetierException exception) {
                log.debug("Conflit metier : {}", exception.getMessage());

                return ResponseEntity.status(HttpStatus.CONFLICT)
                                .body(ApiResponse.erreur(HttpStatus.CONFLICT, exception.getMessage()));
        }

        @ExceptionHandler(AccesRefuseException.class)
        public ResponseEntity<ApiResponse<Void>> gererAccesRefuse(
                        AccesRefuseException exception) {
                log.warn("Acces refuse : {}", exception.getMessage());

                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                                .body(ApiResponse.erreur(HttpStatus.FORBIDDEN, exception.getMessage()));
        }

        @ExceptionHandler(AccessDeniedException.class)
        public ResponseEntity<ApiResponse<Void>> gererAccesRefuseSpring(
                        AccessDeniedException exception) {
                log.warn("Acces refuse par Spring Security");

                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                                .body(ApiResponse.erreur(HttpStatus.FORBIDDEN, "Acces refuse"));
        }

        @ExceptionHandler(IdentifiantsInvalidesException.class)
        public ResponseEntity<ApiResponse<Void>> gererIdentifiantsInvalides(
                        IdentifiantsInvalidesException exception) {
                log.warn("Tentative d'authentification echouee");

                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                                .body(ApiResponse.erreur(HttpStatus.UNAUTHORIZED, exception.getMessage()));
        }

        @ExceptionHandler(UsernameNotFoundException.class)
        public ResponseEntity<ApiResponse<Void>> gererUtilisateurInconnu(
                        UsernameNotFoundException exception) {
                log.warn("Tentative d'authentification echouee");

                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                                .body(ApiResponse.erreur(HttpStatus.UNAUTHORIZED, "Identifiants invalides"));
        }

        @ExceptionHandler(InvalidDataAccessApiUsageException.class)
        public ResponseEntity<ApiResponse<Void>> gererUsageInvalide(
                        InvalidDataAccessApiUsageException exception) {
                log.debug("Parametre de requete invalide : {}", exception.getMessage());

                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                                .body(ApiResponse.erreur(HttpStatus.BAD_REQUEST,
                                                "Parametre de tri ou de filtre invalide"));
        }

        @ExceptionHandler(DataIntegrityViolationException.class)
        public ResponseEntity<ApiResponse<Void>> gererViolationIntegrite(
                        DataIntegrityViolationException exception) {
                log.error("Violation de contrainte en base", exception);

                return ResponseEntity.status(HttpStatus.CONFLICT)
                                .body(ApiResponse.erreur(HttpStatus.CONFLICT,
                                                "Conflit de donnees (contrainte violee)"));
        }

        @ExceptionHandler({
                        HttpMessageNotReadableException.class,
                        MethodArgumentTypeMismatchException.class
        })
        public ResponseEntity<ApiResponse<Void>> gererRequeteIllisible(Exception exception) {
                log.debug("Requete illisible : {}", exception.getClass().getSimpleName());

                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                                .body(ApiResponse.erreur(HttpStatus.BAD_REQUEST, "Requete invalide"));
        }

        @ExceptionHandler(Exception.class)
        public ResponseEntity<ApiResponse<Void>> gererErreurInattendue(Exception exception) {
                log.error("Erreur inattendue", exception);

                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                                .body(ApiResponse.erreur(HttpStatus.INTERNAL_SERVER_ERROR,
                                                "Erreur interne inattendue"));
        }
}
