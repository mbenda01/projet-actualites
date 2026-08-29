package iibs.actualites.validation;

import iibs.actualites.repository.*;
import jakarta.validation.*;
import lombok.*;

@RequiredArgsConstructor
public class ArticleExisteValidator implements ConstraintValidator<ArticleExiste, Long> {

    private final ArticleRepository articleRepository;

    @Override
    public boolean isValid(Long articleId, ConstraintValidatorContext context) {
        if (articleId == null) {
            return true;
        }

        return articleRepository.existsById(articleId);
    }
}