-- Utilisateurs

INSERT INTO utilisateurs (nom, email, mot_de_passe, role, actif, date_creation, cree_par)
VALUES
    ('Alex Rivera', 'alex@actualites.sn',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     'ADMIN', TRUE, NOW(), 'systeme'),

    ('Marie Diallo', 'marie@actualites.sn',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     'ADMIN', TRUE, NOW(), 'systeme'),

    ('Sam Ndiaye', 'sam@actualites.sn',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
     'LECTEUR', TRUE, NOW(), 'systeme')
ON CONFLICT (email) DO NOTHING;

-- ------------------------------------------------------------
-- Articles

INSERT INTO articles (
    titre, chapeau, categorie, statut, url_image, libelle_image,
    duree_lecture_minutes, date_publication, auteur_id,
    date_creation, cree_par
)
SELECT
    'Apple dévoile la gamme iPhone 16',
    'Quatre modèles, un nouveau capteur photo et une puce gravée en 2 nanomètres.',
    'TECHNOLOGIE', 'PUBLIE',
    'https://picsum.photos/seed/iphone/600/400', 'iPhone 16',
    8, DATE '2023-09-21',
    (SELECT id FROM utilisateurs WHERE email = 'alex@actualites.sn'),
    NOW(), 'systeme'
WHERE NOT EXISTS (
    SELECT 1 FROM articles WHERE titre = 'Apple dévoile la gamme iPhone 16'
);

INSERT INTO articles (
    titre, chapeau, categorie, statut, url_image, libelle_image,
    duree_lecture_minutes, date_publication, auteur_id,
    date_creation, cree_par
)
SELECT
    'Ouverture du sommet climat à Londres',
    'Chercheurs, investisseurs et responsables publics se réunissent trois jours.',
    'ENVIRONNEMENT', 'PUBLIE',
    'https://picsum.photos/seed/london/600/400', 'Vue de Londres',
    5, DATE '2023-10-05',
    (SELECT id FROM utilisateurs WHERE email = 'marie@actualites.sn'),
    NOW(), 'systeme'
WHERE NOT EXISTS (
    SELECT 1 FROM articles WHERE titre = 'Ouverture du sommet climat à Londres'
);

INSERT INTO articles (
    titre, chapeau, categorie, statut, url_image, libelle_image,
    duree_lecture_minutes, date_publication, auteur_id,
    date_creation, cree_par
)
SELECT
    'Le bitcoin atteint son plus haut niveau annuel',
    'Les marchés progressent, les analystes restent partagés sur les causes.',
    'ECONOMIE', 'PUBLIE',
    'https://picsum.photos/seed/bitcoin/600/400', 'Graphique de marché',
    4, DATE '2023-10-12',
    (SELECT id FROM utilisateurs WHERE email = 'marie@actualites.sn'),
    NOW(), 'systeme'
WHERE NOT EXISTS (
    SELECT 1 FROM articles WHERE titre = 'Le bitcoin atteint son plus haut niveau annuel'
);

INSERT INTO articles (
    titre, chapeau, categorie, statut, url_image, libelle_image,
    duree_lecture_minutes, date_publication, auteur_id,
    date_creation, cree_par
)
SELECT
    'L''IA s''installe dans les usages quotidiens',
    'Des modèles issus de la recherche équipent désormais les logiciels grand public.',
    'TECHNOLOGIE', 'PUBLIE',
    'https://picsum.photos/seed/ai/600/400', 'Puce IA',
    10, DATE '2023-10-18',
    (SELECT id FROM utilisateurs WHERE email = 'alex@actualites.sn'),
    NOW(), 'systeme'
WHERE NOT EXISTS (
    SELECT 1 FROM articles WHERE titre = 'L''IA s''installe dans les usages quotidiens'
);

-- Un brouillon, pour verifier que les routes publiques ne le
-- retournent pas.
INSERT INTO articles (
    titre, chapeau, categorie, statut,
    duree_lecture_minutes, auteur_id, date_creation, cree_par
)
SELECT
    'Enquête en cours sur les transports urbains',
    'Article en cours de rédaction.',
    'GENERAL', 'BROUILLON',
    6,
    (SELECT id FROM utilisateurs WHERE email = 'alex@actualites.sn'),
    NOW(), 'systeme'
WHERE NOT EXISTS (
    SELECT 1 FROM articles WHERE titre = 'Enquête en cours sur les transports urbains'
);

-- ------------------------------------------------------------
-- Paragraphes

INSERT INTO article_paragraphes (article_id, position, contenu)
SELECT a.id, 0,
    'La créativité n''est pas un trait figé : elle se cultive au quotidien. Beaucoup attendent le moment d''inspiration, alors que la régularité dans de petites routines produit les vraies avancées.'
FROM articles a
WHERE a.titre = 'Apple dévoile la gamme iPhone 16'
  AND NOT EXISTS (
      SELECT 1 FROM article_paragraphes p
      WHERE p.article_id = a.id AND p.position = 0
  );

INSERT INTO article_paragraphes (article_id, position, contenu)
SELECT a.id, 1,
    'Aménager un espace de travail dédié, ménager des temps de réflexion et rester curieux sont les composantes essentielles de ce processus.'
FROM articles a
WHERE a.titre = 'Apple dévoile la gamme iPhone 16'
  AND NOT EXISTS (
      SELECT 1 FROM article_paragraphes p
      WHERE p.article_id = a.id AND p.position = 1
  );

INSERT INTO article_paragraphes (article_id, position, contenu)
SELECT a.id, 0,
    'Le sommet réunit chercheurs, investisseurs et responsables publics autour d''une seule question : comment déployer les technologies climatiques assez vite pour peser.'
FROM articles a
WHERE a.titre = 'Ouverture du sommet climat à Londres'
  AND NOT EXISTS (
      SELECT 1 FROM article_paragraphes p
      WHERE p.article_id = a.id AND p.position = 0
  );

INSERT INTO article_paragraphes (article_id, position, contenu)
SELECT a.id, 1,
    'Les tables rondes portent cette année sur le stockage réseau, la chaleur industrielle et le déficit de financement dans les pays émergents.'
FROM articles a
WHERE a.titre = 'Ouverture du sommet climat à Londres'
  AND NOT EXISTS (
      SELECT 1 FROM article_paragraphes p
      WHERE p.article_id = a.id AND p.position = 1
  );

INSERT INTO article_paragraphes (article_id, position, contenu)
SELECT a.id, 0,
    'Les marchés ont progressé toute la semaine, portant l''actif à des niveaux inédits depuis le début de l''année.'
FROM articles a
WHERE a.titre = 'Le bitcoin atteint son plus haut niveau annuel'
  AND NOT EXISTS (
      SELECT 1 FROM article_paragraphes p
      WHERE p.article_id = a.id AND p.position = 0
  );

INSERT INTO article_paragraphes (article_id, position, contenu)
SELECT a.id, 1,
    'Les analystes restent partagés : renouveau de la demande pour les uns, simple effet de volumes réduits pour les autres.'
FROM articles a
WHERE a.titre = 'Le bitcoin atteint son plus haut niveau annuel'
  AND NOT EXISTS (
      SELECT 1 FROM article_paragraphes p
      WHERE p.article_id = a.id AND p.position = 1
  );

INSERT INTO article_paragraphes (article_id, position, contenu)
SELECT a.id, 0,
    'Assistants, traduction, retouche photo : des modèles qui relevaient de la recherche il y a trois ans sont aujourd''hui intégrés aux logiciels grand public.'
FROM articles a
WHERE a.titre = 'L''IA s''installe dans les usages quotidiens'
  AND NOT EXISTS (
      SELECT 1 FROM article_paragraphes p
      WHERE p.article_id = a.id AND p.position = 0
  );

INSERT INTO article_paragraphes (article_id, position, contenu)
SELECT a.id, 1,
    'La prochaine bascule est moins visible : des modèles plus compacts, exécutés directement sur l''appareil, sans aller-retour avec un serveur.'
FROM articles a
WHERE a.titre = 'L''IA s''installe dans les usages quotidiens'
  AND NOT EXISTS (
      SELECT 1 FROM article_paragraphes p
      WHERE p.article_id = a.id AND p.position = 1
  );