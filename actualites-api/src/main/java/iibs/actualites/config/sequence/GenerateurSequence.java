package iibs.actualites.config.sequence;

import lombok.*;
import org.springframework.data.mongodb.core.*;
import org.springframework.data.mongodb.core.query.*;
import org.springframework.stereotype.*;

@Component
@RequiredArgsConstructor
public class GenerateurSequence {

    private final MongoOperations mongoOperations;

    public long prochaineValeur(String nomSequence) {
        Query requete = Query.query(Criteria.where("_id").is(nomSequence));

        Update increment = new Update().inc("valeur", 1);

        FindAndModifyOptions options = FindAndModifyOptions.options()
                .returnNew(true)
                .upsert(true);

        SequenceDocument document = mongoOperations.findAndModify(
                requete, increment, options, SequenceDocument.class);

        return document != null ? document.getValeur() : 1;
    }
}
