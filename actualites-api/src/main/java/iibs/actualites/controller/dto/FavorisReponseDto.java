package iibs.actualites.controller.dto;

import java.util.*;

public record FavorisReponseDto(
        Set<Long> identifiants,
        int nombre
) {
    public static FavorisReponseDto de(Set<Long> identifiants) {
        return new FavorisReponseDto(identifiants, identifiants.size());
    }
}