package iibs.actualites.service.mapper;

import iibs.actualites.controller.dto.*;
import iibs.actualites.entity.*;
import org.mapstruct.*;

import java.util.*;

@Mapper(
        componentModel = MappingConstants.ComponentModel.SPRING,
        unmappedTargetPolicy = ReportingPolicy.ERROR
)
public interface ArticleMapper {

    @Mapping(target = "auteurNom", source = "auteur.nom")
    ArticleResumeDto versResume(Article article);

    @Mapping(target = "auteurId", source = "auteur.id")
    @Mapping(target = "auteurNom", source = "auteur.nom")
    ArticleDetailDto versDetail(Article article);

    List<ArticleResumeDto> versResumes(List<Article> articles);
}

