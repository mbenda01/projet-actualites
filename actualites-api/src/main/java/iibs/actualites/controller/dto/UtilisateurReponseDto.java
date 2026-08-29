package iibs.actualites.controller.dto;

import iibs.actualites.entity.enums.*;

import java.time.*;

public record UtilisateurReponseDto(
        Long id,
        String nom,
        String email,
        Role role,
        boolean actif,
        LocalDateTime dateCreation
) {
}