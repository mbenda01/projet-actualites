package iibs.actualites.repository;

import iibs.actualites.entity.*;
import iibs.actualites.entity.enums.*;
import lombok.*;
import org.bson.Document;
import org.springframework.data.domain.*;
import org.springframework.data.mongodb.core.*;
import org.springframework.data.mongodb.core.aggregation.*;
import org.springframework.data.mongodb.core.query.*;
import org.springframework.stereotype.*;

import java.util.*;
import java.util.regex.*;

@Repository
@RequiredArgsConstructor
public class ArticleRepositoryPersonnaliseImpl implements ArticleRepositoryPersonnalise {

    private static final String COLLECTION = "articles";

    private final MongoTemplate mongoTemplate;

    @Override
    public Page<Article> rechercherParTerme(
            StatutArticle statut,
            String terme,
            Pageable pageable
    ) {
        Pattern motif = Pattern.compile(Pattern.quote(terme), Pattern.CASE_INSENSITIVE);

        MatchOperation filtreStatut = Aggregation.match(Criteria.where("statut").is(statut));

        LookupOperation jointureAuteur = LookupOperation.newLookup()
                .from("utilisateurs")
                .localField("auteur.$id")
                .foreignField("_id")
                .as("auteurJointure");

        MatchOperation filtreTerme = Aggregation.match(new Criteria().orOperator(
                Criteria.where("titre").regex(motif),
                Criteria.where("chapeau").regex(motif),
                Criteria.where("auteurJointure.nom").regex(motif)
        ));

        Aggregation aggregationComptage = Aggregation.newAggregation(
                filtreStatut, jointureAuteur, filtreTerme, Aggregation.count().as("total"));

        Document resultatComptage = mongoTemplate
                .aggregate(aggregationComptage, COLLECTION, Document.class)
                .getUniqueMappedResult();

        long total = resultatComptage != null
                ? ((Number) resultatComptage.get("total")).longValue()
                : 0;

        Aggregation aggregationPage = Aggregation.newAggregation(
                filtreStatut,
                jointureAuteur,
                filtreTerme,
                Aggregation.skip(pageable.getOffset()),
                Aggregation.limit(pageable.getPageSize())
        );

        List<Article> articles = mongoTemplate
                .aggregate(aggregationPage, COLLECTION, Article.class)
                .getMappedResults();

        return new PageImpl<>(articles, pageable, total);
    }
}
