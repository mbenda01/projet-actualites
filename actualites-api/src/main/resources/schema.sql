
CREATE TABLE IF NOT EXISTS utilisateurs (
    id                 BIGSERIAL PRIMARY KEY,
    nom                VARCHAR(120)  NOT NULL,
    email              VARCHAR(150)  NOT NULL,
    mot_de_passe       VARCHAR(255)  NOT NULL,
    role               VARCHAR(20)   NOT NULL DEFAULT 'LECTEUR',
    actif              BOOLEAN       NOT NULL DEFAULT TRUE,

    -- Colonnes d'audit, remplies par JPA
    date_creation      TIMESTAMP,
    date_modification  TIMESTAMP,
    cree_par           VARCHAR(150),
    modifie_par        VARCHAR(150),

    CONSTRAINT uk_utilisateur_email UNIQUE (email),
    CONSTRAINT ck_utilisateur_role CHECK (role IN ('ADMIN', 'LECTEUR'))
);


CREATE TABLE IF NOT EXISTS articles (
    id                     BIGSERIAL PRIMARY KEY,
    titre                  VARCHAR(250) NOT NULL,
    chapeau                VARCHAR(500),
    categorie              VARCHAR(30)  NOT NULL DEFAULT 'GENERAL',
    statut                 VARCHAR(20)  NOT NULL DEFAULT 'BROUILLON',
    url_image              VARCHAR(500),
    libelle_image          VARCHAR(150),
    duree_lecture_minutes  INTEGER,
    date_publication       DATE,
    auteur_id              BIGINT       NOT NULL,

    date_creation          TIMESTAMP,
    date_modification      TIMESTAMP,
    cree_par               VARCHAR(150),
    modifie_par            VARCHAR(150),

    CONSTRAINT fk_article_auteur
        FOREIGN KEY (auteur_id) REFERENCES utilisateurs (id)
        ON DELETE RESTRICT,

    CONSTRAINT ck_article_statut
        CHECK (statut IN ('BROUILLON', 'PUBLIE', 'ARCHIVE')),

    CONSTRAINT ck_article_categorie
        CHECK (categorie IN (
            'TECHNOLOGIE', 'ECONOMIE', 'ENVIRONNEMENT',
            'SANTE', 'CULTURE', 'SPORT', 'GENERAL'
        )),

    CONSTRAINT ck_article_duree
        CHECK (duree_lecture_minutes IS NULL
               OR duree_lecture_minutes BETWEEN 1 AND 120)
);


CREATE TABLE IF NOT EXISTS article_paragraphes (
    article_id  BIGINT  NOT NULL,
    position    INTEGER NOT NULL,
    contenu     TEXT    NOT NULL,

    PRIMARY KEY (article_id, position),

    CONSTRAINT fk_paragraphe_article
        FOREIGN KEY (article_id) REFERENCES articles (id)
        ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS favoris (
    id                   BIGSERIAL PRIMARY KEY,
    utilisateur_id       BIGINT    NOT NULL,
    article_id           BIGINT    NOT NULL,
    date_enregistrement  TIMESTAMP NOT NULL,

    CONSTRAINT uk_favori_utilisateur_article
        UNIQUE (utilisateur_id, article_id),


    CONSTRAINT fk_favori_utilisateur
        FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs (id)
        ON DELETE CASCADE,

    CONSTRAINT fk_favori_article
        FOREIGN KEY (article_id) REFERENCES articles (id)
        ON DELETE CASCADE
);


CREATE INDEX IF NOT EXISTS idx_article_statut
    ON articles (statut);

CREATE INDEX IF NOT EXISTS idx_article_categorie
    ON articles (categorie);

CREATE INDEX IF NOT EXISTS idx_article_date_publication
    ON articles (date_publication DESC);

CREATE INDEX IF NOT EXISTS idx_article_auteur
    ON articles (auteur_id);

CREATE INDEX IF NOT EXISTS idx_favori_utilisateur
    ON favoris (utilisateur_id);


CREATE INDEX IF NOT EXISTS idx_article_statut_date
    ON articles (statut, date_publication DESC);