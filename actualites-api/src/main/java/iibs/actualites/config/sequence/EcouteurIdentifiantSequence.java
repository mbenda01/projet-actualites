package iibs.actualites.config.sequence;

import lombok.*;
import org.springframework.data.mongodb.core.mapping.event.*;
import org.springframework.stereotype.*;
import org.springframework.util.*;

import java.lang.reflect.*;

@Component
@RequiredArgsConstructor
public class EcouteurIdentifiantSequence extends AbstractMongoEventListener<Object> {

    private final GenerateurSequence generateurSequence;

    @Override
    public void onBeforeConvert(BeforeConvertEvent<Object> event) {
        Object source = event.getSource();

        Field champId = ReflectionUtils.findField(source.getClass(), "id");

        if (champId == null || !champId.getType().equals(Long.class)) {
            return;
        }

        ReflectionUtils.makeAccessible(champId);

        Object valeurActuelle = ReflectionUtils.getField(champId, source);

        if (valeurActuelle != null) {
            return;
        }

        String nomSequence = source.getClass().getSimpleName().toLowerCase() + "_sequence";
        long nouvelIdentifiant = generateurSequence.prochaineValeur(nomSequence);

        ReflectionUtils.setField(champId, source, nouvelIdentifiant);
    }
}
