package iibs.actualites.controller;

import iibs.actualites.controller.dto.*;
import iibs.actualites.entity.enums.*;
import iibs.actualites.exception.*;
import iibs.actualites.service.*;
import io.swagger.v3.oas.annotations.*;
import io.swagger.v3.oas.annotations.security.*;
import io.swagger.v3.oas.annotations.tags.*;
import jakarta.validation.*;
import lombok.*;
import org.springframework.data.domain.*;
import org.springframework.data.web.*;
import org.springframework.http.*;
import org.springframework.security.access.prepost.*;
import org.springframework.web.bind.annotation.*;

import java.util.*;


@RestController
@RequestMapping("/api/articles")
@RequiredArgsConstructor
@Tag(name = "Articles", description = "Consultation et gestion des articles")
public class ArticleController {

    private static final Set<String> TRIS_AUTORISES = Set.of(
            "id", "titre", "datePublication", "dateCreation", "categorie", "statut"
    );

    private static final Sort TRI_PUBLIC =
            Sort.by(Sort.Direction.DESC, "datePublication");

    private static final Sort TRI_ADMINISTRATION =
            Sort.by(Sort.Direction.DESC, "dateCreation");

    private final ArticleService articleService;
    private final TriUtils triUtils;

    @GetMapping
    @SecurityRequirements
    @Operation(
            summary = "Lister les articles publies",
            description = """
                    Retourne les articles au statut PUBLIE, tries par date
                    de publication decroissante.

                    Filtres optionnels : categorie, recherche textuelle sur
                    le titre, le chapeau et le nom de l'auteur.

                    Tri autorise sur : id, titre, datePublication,
                    dateCreation, categorie, statut.
                    """
    )
    public ResponseEntity<ApiResponse<Page<ArticleResumeDto>>> lister(
            @RequestParam(required = false) Categorie categorie,
            @RequestParam(required = false) String recherche,
            @PageableDefault(size = 20) Pageable pageable
    ) {
        Pageable borne = triUtils.assainir(pageable, TRIS_AUTORISES, TRI_PUBLIC);

        Page<ArticleResumeDto> articles =
                articleService.listerPublies(categorie, recherche, borne);

        return ResponseEntity.ok(
                ApiResponse.succes(articles, "Articles recuperes"));
    }

    @GetMapping("/{id}")
    @SecurityRequirements
    @Operation(
            summary = "Detail d'un article publie",
            description = "Retourne l'article avec ses paragraphes. 404 si non publie."
    )
    public ResponseEntity<ApiResponse<ArticleDetailDto>> obtenir(
            @PathVariable Long id
    ) {
        ArticleDetailDto article = articleService.obtenirPublie(id);

        return ResponseEntity.ok(ApiResponse.succes(article, "Article recupere"));
    }

    @GetMapping("/administration")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
            summary = "Lister tous les articles",
            description = "Tous statuts confondus, brouillons inclus. Reserve aux administrateurs."
    )
    public ResponseEntity<ApiResponse<Page<ArticleResumeDto>>> listerTous(
            @PageableDefault(size = 20) Pageable pageable
    ) {
        Pageable borne =
                triUtils.assainir(pageable, TRIS_AUTORISES, TRI_ADMINISTRATION);

        Page<ArticleResumeDto> articles = articleService.listerTous(borne);

        return ResponseEntity.ok(
                ApiResponse.succes(articles, "Articles recuperes"));
    }

    @GetMapping("/administration/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
            summary = "Detail d'un article",
            description = "Quel que soit son statut. Reserve aux administrateurs."
    )
    public ResponseEntity<ApiResponse<ArticleDetailDto>> obtenirAdministration(
            @PathVariable Long id
    ) {
        ArticleDetailDto article = articleService.obtenirParId(id);

        return ResponseEntity.ok(ApiResponse.succes(article, "Article recupere"));
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
            summary = "Creer un article",
            description = "L'article est cree en BROUILLON. L'auteur est l'utilisateur authentifie."
    )
    public ResponseEntity<ApiResponse<ArticleDetailDto>> creer(
            @Valid @RequestBody ArticleCreationDto dto
    ) {
        ArticleDetailDto article = articleService.creer(dto);

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.succes(article, "Article cree", HttpStatus.CREATED));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Modifier un article")
    public ResponseEntity<ApiResponse<ArticleDetailDto>> modifier(
            @PathVariable Long id,
            @Valid @RequestBody ArticleModificationDto dto
    ) {
        ArticleDetailDto article = articleService.modifier(id, dto);

        return ResponseEntity.ok(ApiResponse.succes(article, "Article modifie"));
    }

    @PatchMapping("/{id}/statut")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
            summary = "Changer le statut",
            description = "BROUILLON, PUBLIE ou ARCHIVE. Le passage en PUBLIE fixe la date de publication."
    )
    public ResponseEntity<ApiResponse<ArticleDetailDto>> changerStatut(
            @PathVariable Long id,
            @Valid @RequestBody ArticleStatutRequestDto dto
    ) {
        ArticleDetailDto article = articleService.changerStatut(id, dto.statut());

        return ResponseEntity.ok(ApiResponse.succes(article, "Statut modifie"));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(
            summary = "Archiver un article",
            description = "Aucune suppression physique : l'article passe en ARCHIVE."
    )
    public ResponseEntity<ApiResponse<Void>> archiver(@PathVariable Long id) {
        articleService.archiver(id);

        return ResponseEntity.ok(ApiResponse.succes(null, "Article archive"));
    }
}