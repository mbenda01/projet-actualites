package iibs.actualites.controller.dto;

import iibs.actualites.entity.enums.*;

import java.time.*;
import java.util.*;

public record ArticleDetailDto(
        Long id,
        String titre,
        String chapeau,
        List<String> paragraphes,
        Categorie categorie,
        StatutArticle statut,
        String urlImage,
        String libelleImage,
        Integer dureeLectureMinutes,
        LocalDate datePublication,
        Long auteurId,
        String auteurNom,
        LocalDateTime dateCreation,
        LocalDateTime dateModification
) {
}