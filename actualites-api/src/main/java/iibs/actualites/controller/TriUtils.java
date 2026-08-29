package iibs.actualites.controller;

import org.springframework.data.domain.*;
import org.springframework.stereotype.*;

import java.util.*;

@Component
public class TriUtils {

    public static final int TAILLE_MAX_PAGE = 50;

    public Pageable assainir(
            Pageable pageable,
            Set<String> proprietesAutorisees,
            Sort triParDefaut) {
        int taille = Math.min(pageable.getPageSize(), TAILLE_MAX_PAGE);

        List<Sort.Order> ordresValides = pageable.getSort().stream()
                .filter(ordre -> proprietesAutorisees.contains(ordre.getProperty()))
                .toList();

        Sort tri = ordresValides.isEmpty() ? triParDefaut : Sort.by(ordresValides);

        return PageRequest.of(pageable.getPageNumber(), taille, tri);
    }

    public Pageable assainir(Pageable pageable, Set<String> proprietesAutorisees) {
        return assainir(pageable, proprietesAutorisees, Sort.unsorted());
    }
}