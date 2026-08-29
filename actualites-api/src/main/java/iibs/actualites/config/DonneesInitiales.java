package iibs.actualites.config;

import iibs.actualites.entity.*;
import iibs.actualites.entity.enums.*;
import iibs.actualites.repository.*;
import lombok.*;
import lombok.extern.slf4j.*;
import org.springframework.boot.*;
import org.springframework.context.annotation.*;
import org.springframework.security.crypto.password.*;
import org.springframework.stereotype.*;

import java.util.*;

@Slf4j
@Component
@RequiredArgsConstructor
public class DonneesInitiales implements CommandLineRunner {

    private final UtilisateurRepository utilisateurRepository;
    private final ArticleRepository articleRepository;
    private final PasswordEncoder encodeurMotDePasse;

    @Override
    public void run(String... args) {
        if (utilisateurRepository.count() > 0) {
            log.debug("Donnees de demarrage deja presentes, initialisation ignoree");
            return;
        }

        Utilisateur alex = utilisateurRepository.save(
                Utilisateur.creerAdministrateur(
                        "Alex Rivera", "alex@actualites.sn",
                        encodeurMotDePasse.encode("motdepasse123")));

        Utilisateur marie = utilisateurRepository.save(
                Utilisateur.creerAdministrateur(
                        "Marie Diallo", "marie@actualites.sn",
                        encodeurMotDePasse.encode("motdepasse123")));

        utilisateurRepository.save(
                Utilisateur.inscrire(
                        "Sam Ndiaye", "sam@actualites.sn",
                        encodeurMotDePasse.encode("motdepasse123")));

        publierArticle(
                alex, "Apple devoile la gamme iPhone 16",
                "Quatre modeles, un nouveau capteur photo et une puce gravee en 2 nanometres.",
                Categorie.TECHNOLOGIE,
                "https://picsum.photos/seed/iphone/600/400", "iPhone 16", 8,
                List.of(
                        "La creativite n'est pas un trait fige : elle se cultive au quotidien. "
                                + "Beaucoup attendent le moment d'inspiration, alors que la "
                                + "regularite dans de petites routines produit les vraies avancees.",
                        "Amenager un espace de travail dedie, menager des temps de reflexion "
                                + "et rester curieux sont les composantes essentielles de ce processus."
                ));

        publierArticle(
                marie, "Ouverture du sommet climat a Londres",
                "Chercheurs, investisseurs et responsables publics se reunissent trois jours.",
                Categorie.ENVIRONNEMENT,
                "https://picsum.photos/seed/london/600/400", "Vue de Londres", 5,
                List.of(
                        "Le sommet reunit chercheurs, investisseurs et responsables publics "
                                + "autour d'une seule question : comment deployer les technologies "
                                + "climatiques assez vite pour peser.",
                        "Les tables rondes portent cette annee sur le stockage reseau, la "
                                + "chaleur industrielle et le deficit de financement dans les "
                                + "pays emergents."
                ));

        publierArticle(
                marie, "Le bitcoin atteint son plus haut niveau annuel",
                "Les marches progressent, les analystes restent partages sur les causes.",
                Categorie.ECONOMIE,
                "https://picsum.photos/seed/bitcoin/600/400", "Graphique de marche", 4,
                List.of(
                        "Les marches ont progresse toute la semaine, portant l'actif a des "
                                + "niveaux inedits depuis le debut de l'annee.",
                        "Les analystes restent partages : renouveau de la demande pour les "
                                + "uns, simple effet de volumes reduits pour les autres."
                ));

        publierArticle(
                alex, "L'IA s'installe dans les usages quotidiens",
                "Des modeles issus de la recherche equipent desormais les logiciels grand public.",
                Categorie.TECHNOLOGIE,
                "https://picsum.photos/seed/ai/600/400", "Puce IA", 10,
                List.of(
                        "Assistants, traduction, retouche photo : des modeles qui relevaient "
                                + "de la recherche il y a trois ans sont aujourd'hui integres "
                                + "aux logiciels grand public.",
                        "La prochaine bascule est moins visible : des modeles plus compacts, "
                                + "executes directement sur l'appareil, sans aller-retour avec "
                                + "un serveur."
                ));

        Article brouillon = Article.redigerBrouillon(
                "Enquete en cours sur les transports urbains", alex);

        brouillon.modifierContenu(
                brouillon.getTitre(), "Article en cours de redaction.",
                List.of(), Categorie.GENERAL, null, null, 6);

        articleRepository.save(brouillon);

        log.info("Donnees de demarrage inserees : {} utilisateurs, {} articles",
                utilisateurRepository.count(), articleRepository.count());
    }

    private void publierArticle(
            Utilisateur auteur,
            String titre,
            String chapeau,
            Categorie categorie,
            String urlImage,
            String libelleImage,
            int dureeLectureMinutes,
            List<String> paragraphes
    ) {
        Article article = Article.redigerBrouillon(titre, auteur);

        article.modifierContenu(
                titre, chapeau, paragraphes, categorie,
                urlImage, libelleImage, dureeLectureMinutes);

        article.publier();

        articleRepository.save(article);
    }
}
