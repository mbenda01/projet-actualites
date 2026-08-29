package iibs.actualites.config.sequence;

import lombok.*;
import org.springframework.data.annotation.*;
import org.springframework.data.mongodb.core.mapping.*;

@Getter
@Setter
@Document(collection = "sequences")
public class SequenceDocument {

    @Id
    private String id;

    private long valeur;
}
