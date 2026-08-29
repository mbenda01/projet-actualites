package iibs.actualites.controller.dto;

import iibs.actualites.entity.enums.*;
import jakarta.validation.constraints.*;

public record ArticleStatutRequestDto(

        @NotNull(message = "Le statut est obligatoire")
        StatutArticle statut
) {
}