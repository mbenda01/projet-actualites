package iibs.actualites.controller.dto;

import jakarta.validation.constraints.*;

public record RafraichissementRequestDto(

        @NotBlank(message = "Le jeton de rafraichissement est obligatoire")
        String jetonRafraichissement
) {
}

