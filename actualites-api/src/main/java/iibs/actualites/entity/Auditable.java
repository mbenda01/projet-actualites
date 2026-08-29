package iibs.actualites.entity;

import lombok.*;
import org.springframework.data.annotation.*;

import java.time.*;

@Getter
@Setter
public abstract class Auditable {

    @CreatedDate
    private LocalDateTime dateCreation;

    @LastModifiedDate
    private LocalDateTime dateModification;

    @CreatedBy
    private String creePar;

    @LastModifiedBy
    private String modifiePar;
}
