# Deploiement : MongoDB Atlas + Render

Ce guide couvre la mise en production de l'API sur une base MongoDB Atlas
(gratuite) et un service web Render.

## 1. Creer le cluster MongoDB Atlas

1. Aller sur https://cloud.mongodb.com et creer un compte (ou se connecter).
2. Creer un projet, puis un cluster **M0 (Free)**. Choisir une region proche
   de la region Render choisie a l'etape 3 (moins de latence).
3. Dans **Database Access**, creer un utilisateur applicatif :
   - Authentication Method : Password
   - Nom d'utilisateur/mot de passe a noter, ils serviront dans l'URI de
     connexion.
   - Role : `readWrite` sur la base `actualites_db` suffit (pas besoin
     d'`atlasAdmin`).
4. Dans **Network Access**, ajouter une entree IP `0.0.0.0/0`. Render
   n'a pas d'IP sortante fixe sur le plan gratuit, donc il faut autoriser
   toutes les IP au niveau reseau et laisser Atlas s'appuyer sur
   l'authentification utilisateur/mot de passe pour la securite.
5. Dans **Database > Connect > Drivers**, copier la chaine de connexion.
   Elle ressemble a :

   ```
   mongodb+srv://<utilisateur>:<mot-de-passe>@<cluster>.mongodb.net/?retryWrites=true&w=majority
   ```

6. Ajouter le nom de la base juste apres le nom d'hote, avant les
   parametres :

   ```
   mongodb+srv://<utilisateur>:<mot-de-passe>@<cluster>.mongodb.net/actualites_db?retryWrites=true&w=majority
   ```

   C'est cette chaine complete qui devient la variable d'environnement
   `MONGODB_URI`. Sans le nom de base explicite, Spring Data Mongo se
   connecte a la base `test` par defaut.

## 2. Preparer le depot Git

Le `Dockerfile`, `.dockerignore` et `render.yaml` sont deja presents a la
racine du projet. Pousser le projet (avec ces fichiers) sur GitHub ou
GitLab : Render construit l'image a partir du depot, pas d'un upload
local.

## 3. Creer le service sur Render

### Option A - via render.yaml (Blueprint)

1. Sur https://dashboard.render.com, choisir **New > Blueprint**.
2. Selectionner le depot Git contenant `render.yaml`.
3. Render detecte le service `actualites-api` et demande les valeurs des
   variables marquees `sync: false` : `MONGODB_URI`, `JWT_SECRET`,
   `CORS_ORIGINES`.

### Option B - manuellement

1. **New > Web Service**, selectionner le depot.
2. Runtime : **Docker** (Render detecte le `Dockerfile` a la racine).
3. Region : proche du cluster Atlas choisi plus haut.
4. Plan : Free (suffisant pour un projet etudiant).
5. Health Check Path : `/actuator/health`.
6. Dans **Environment**, ajouter :

   | Variable         | Valeur                                                        |
   |------------------|----------------------------------------------------------------|
   | `MONGODB_URI`    | la chaine de connexion Atlas complete (etape 1.6)               |
   | `JWT_SECRET`     | une chaine aleatoire d'au moins 32 caracteres                   |
   | `CORS_ORIGINES`  | origines autorisees, separees par des virgules, sans espace     |

   Render fournit deja `PORT` automatiquement ; `application.properties`
   le lit via `server.port=${PORT:8080}`, aucune variable a ajouter pour
   ca.

   Pour generer un `JWT_SECRET` correct :

   ```bash
   openssl rand -base64 48
   ```

7. Lancer le deploiement.

## 4. Verifier le deploiement

Une fois le build termine (le premier build Docker prend quelques
minutes, le temps de telecharger les dependances Maven) :

1. `https://<nom-du-service>.onrender.com/actuator/health` doit repondre
   `{"status":"UP"}`.
2. `https://<nom-du-service>.onrender.com/swagger-ui.html` doit afficher
   la documentation OpenAPI.
3. Au premier demarrage, `DonneesInitiales` insere automatiquement les
   utilisateurs et articles de demonstration (voir la section suivante)
   si la base est vide.
4. Tester une inscription :

   ```bash
   curl -X POST https://<nom-du-service>.onrender.com/api/auth/inscription \
     -H "Content-Type: application/json" \
     -d '{"nom":"Test","email":"test@exemple.sn","motDePasse":"motdepasse123"}'
   ```

   Une reponse contenant `jetonAcces` confirme que l'API et la base
   Atlas communiquent correctement.

## 5. Donnees de demonstration

`DonneesInitiales` (dans `config/`) remplace `schema.sql`/`data.sql` :
au demarrage, si la collection `utilisateurs` est vide, il insere trois
comptes et cinq articles equivalents a l'ancien jeu de donnees SQL.

Comptes crees (mot de passe `motdepasse123` pour les trois) :

| Email                  | Role       |
|-------------------------|-----------|
| alex@actualites.sn      | ADMIN     |
| marie@actualites.sn     | ADMIN     |
| sam@actualites.sn       | LECTEUR   |

Pour forcer une reinitialisation des donnees de demo, il faut vider la
collection `utilisateurs` (et `articles`, `favoris`) depuis Atlas
(**Browse Collections**) : `DonneesInitiales` ne s'execute que si la base
est vide.

## 6. Limites du plan gratuit

- **Render Free** met le service en veille apres 15 minutes d'inactivite.
  La premiere requete apres une periode de veille prend 30 a 60 secondes
  (temps de redemarrage du conteneur). C'est normal, pas un bug.
- **Atlas M0** est limite a 512 Mo de stockage, largement suffisant pour
  ce projet.

## 7. Developpement local

Le profil `local` (`application-local.properties`, non versionne) pointe
vers le MongoDB du `docker-compose.yml` fourni :

```bash
docker compose up -d
./mvnw spring-boot:run -Dspring-boot.run.profiles=local
```

Sans profil actif, l'application exige la variable d'environnement
`MONGODB_URI` (comme en production).
