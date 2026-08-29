package iibs.actualites.validation;

import iibs.actualites.entity.*;
import iibs.actualites.repository.*;
import jakarta.validation.*;
import lombok.*;

@RequiredArgsConstructor
public class EmailUniqueValidator implements ConstraintValidator<EmailUnique, String> {

    private final UtilisateurRepository utilisateurRepository;

    @Override
    public boolean isValid(String email, ConstraintValidatorContext context) {

        if (email == null || email.isBlank()) {
            return true;
        }

        return !utilisateurRepository.existsByEmail(
                Utilisateur.normaliserEmail(email));
    }
}