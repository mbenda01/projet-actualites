package iibs.actualites.controller;

import iibs.actualites.controller.dto.*;
import iibs.actualites.exception.*;
import iibs.actualites.service.*;
import io.swagger.v3.oas.annotations.*;
import io.swagger.v3.oas.annotations.tags.*;
import lombok.*;
import org.springframework.data.domain.*;
import org.springframework.data.web.*;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/favoris")
@RequiredArgsConstructor
@Tag(name = "Favoris", description = "Articles enregistres par l'utilisateur")
public class FavorisController {

    private static final Set<String> TRIS_AUTORISES = Set.of(
            "id", "titre", "datePublication"
    );

    private final FavorisService favorisService;
    private final TriUtils triUtils;

    @GetMapping
    @Operation(
            summary = "Identifiants des articles enregistres",
            description = """
                    Retourne uniquement les identifiants : le client mobile
                    s'en sert pour cocher les boutons sans charger les
                    articles complets.
                    """
    )
    public ResponseEntity<ApiResponse<FavorisReponseDto>> listerIdentifiants() {
        Set<Long> identifiants = favorisService.listerIdentifiants();

        return ResponseEntity.ok(ApiResponse.succes(
                FavorisReponseDto.de(identifiants),
                "Favoris recuperes"
        ));
    }

    @GetMapping("/articles")
    @Operation(
            summary = "Articles enregistres",
            description = "Liste paginee, du plus recemment enregistre au plus ancien."
    )
    public ResponseEntity<ApiResponse<Page<ArticleResumeDto>>> listerArticles(
            @PageableDefault(size = 20) Pageable pageable
    ) {
        Pageable borne = triUtils.assainir(pageable, TRIS_AUTORISES);

        Page<ArticleResumeDto> articles = favorisService.listerArticles(borne);

        return ResponseEntity.ok(
                ApiResponse.succes(articles, "Articles favoris recuperes"));
    }

    @PostMapping("/{articleId}")
    @Operation(
            summary = "Basculer un favori",
            description = """
                    Ajoute l'article s'il est absent, le retire s'il est
                    present. Retourne l'etat resultant.
                    """
    )
    public ResponseEntity<ApiResponse<Boolean>> basculer(
            @PathVariable Long articleId
    ) {
        boolean enregistre = favorisService.basculer(articleId);

        return ResponseEntity.ok(ApiResponse.succes(
                enregistre,
                enregistre ? "Article enregistre" : "Article retire"
        ));
    }

    @DeleteMapping("/{articleId}")
    @Operation(
            summary = "Retirer un favori",
            description = "Sans effet si l'article n'est pas enregistre."
    )
    public ResponseEntity<ApiResponse<Void>> retirer(
            @PathVariable Long articleId
    ) {
        favorisService.retirer(articleId);

        return ResponseEntity.ok(ApiResponse.succes(null, "Article retire"));
    }

    @DeleteMapping
    @Operation(
            summary = "Vider les favoris",
            description = "Retire tous les articles enregistres. Irreversible."
    )
    public ResponseEntity<ApiResponse<Void>> toutRetirer() {
        favorisService.toutRetirer();

        return ResponseEntity.ok(ApiResponse.succes(null, "Favoris vides"));
    }
}