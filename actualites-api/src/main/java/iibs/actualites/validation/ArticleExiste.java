package iibs.actualites.validation;

import jakarta.validation.*;

import java.lang.annotation.*;

@Documented
@Constraint(validatedBy = ArticleExisteValidator.class)
@Target({ElementType.FIELD, ElementType.PARAMETER, ElementType.RECORD_COMPONENT})
@Retention(RetentionPolicy.RUNTIME)
public @interface ArticleExiste {

    String message() default "Cet article n'existe pas";

    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};
}