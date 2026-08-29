package iibs.actualites.controller.dto;

import jakarta.validation.constraints.*;

public record ConnexionRequestDto(

        @NotBlank(message = "L'email est obligatoire")
        @Email(message = "Format d'email invalide")
        String email,

        @NotBlank(message = "Le mot de passe est obligatoire")
        String motDePasse
) {
}