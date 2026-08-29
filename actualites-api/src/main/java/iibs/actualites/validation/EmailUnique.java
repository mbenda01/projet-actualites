package iibs.actualites.validation;

import jakarta.validation.*;

import java.lang.annotation.*;

@Documented
@Constraint(validatedBy = EmailUniqueValidator.class)
@Target({ElementType.FIELD, ElementType.PARAMETER, ElementType.RECORD_COMPONENT})
@Retention(RetentionPolicy.RUNTIME)
public @interface EmailUnique {

    String message() default "Cet email est deja utilise";

    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};
}