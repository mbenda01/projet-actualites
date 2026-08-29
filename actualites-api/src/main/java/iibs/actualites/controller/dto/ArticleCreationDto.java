package iibs.actualites.controller.dto;

import iibs.actualites.entity.enums.*;
import jakarta.validation.constraints.*;

import java.time.*;
import java.util.*;

public record ArticleCreationDto(

                @NotBlank(message = "Le titre est obligatoire") @Size(min = 5, max = 250, message = "Le titre doit contenir entre 5 et 250 caracteres") String titre,

                @Size(max = 500, message = "Le chapeau ne doit pas depasser 500 caracteres") String chapeau,

                @NotEmpty(message = "L'article doit contenir au moins un paragraphe") List<@NotBlank(message = "Un paragraphe ne peut pas etre vide") String> paragraphes,

                @NotNull(message = "La categorie est obligatoire") Categorie categorie,

                @Size(max = 500, message = "L'URL de l'image ne doit pas depasser 500 caracteres") @Pattern(regexp = "^$|^https?://.+", message = "L'URL de l'image doit commencer par http:// ou https://") String urlImage,

                @Size(max = 150, message = "Le libelle de l'image ne doit pas depasser 150 caracteres") String libelleImage,

                @Min(value = 1, message = "La duree de lecture doit etre d'au moins une minute") @Max(value = 120, message = "La duree de lecture ne peut pas depasser 120 minutes") Integer dureeLectureMinutes,

                LocalDate datePublication) {
}