package iibs.actualites.controller.dto;

import iibs.actualites.entity.enums.*;

import java.time.*;

public record ArticleResumeDto(
        Long id,
        String titre,
        String chapeau,
        Categorie categorie,
        StatutArticle statut,
        String urlImage,
        String libelleImage,
        Integer dureeLectureMinutes,
        LocalDate datePublication,
        String auteurNom
) {
}
