package iibs.actualites.service.mapper;

import iibs.actualites.controller.dto.*;
import iibs.actualites.entity.*;
import org.mapstruct.*;


@Mapper(
        componentModel = MappingConstants.ComponentModel.SPRING,
        unmappedTargetPolicy = ReportingPolicy.ERROR
)
public interface UtilisateurMapper {

    UtilisateurReponseDto versReponse(Utilisateur utilisateur);
}

