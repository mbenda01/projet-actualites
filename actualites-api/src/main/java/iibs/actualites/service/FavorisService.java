package iibs.actualites.service;

import iibs.actualites.controller.dto.*;
import org.springframework.data.domain.*;

import java.util.*;

public interface FavorisService {

    Set<Long> listerIdentifiants();

    Page<ArticleResumeDto> listerArticles(Pageable pageable);

    boolean basculer(Long articleId);

    void ajouter(Long articleId);

    void retirer(Long articleId);

    void toutRetirer();

    long compter();
}