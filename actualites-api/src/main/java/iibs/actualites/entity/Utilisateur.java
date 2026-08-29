package iibs.actualites.entity;

import iibs.actualites.entity.enums.*;
import lombok.*;
import org.springframework.data.annotation.*;
import org.springframework.data.mongodb.core.index.*;
import org.springframework.data.mongodb.core.mapping.*;

import java.util.*;

@Document(collection = "utilisateurs")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Utilisateur extends Auditable {

    @Id
    private Long id;

    private String nom;

    @Indexed(unique = true)
    private String email;

    private String motDePasse;

    private Role role = Role.LECTEUR;

    private boolean actif = true;

    private Utilisateur(String nom, String email, String empreinteMotDePasse, Role role) {
        this.nom = nom;
        this.email = email;
        this.motDePasse = empreinteMotDePasse;
        this.role = role;
        this.actif = true;
    }

    public static Utilisateur inscrire(
            String nom,
            String email,
            String empreinteMotDePasse
    ) {
        Objects.requireNonNull(nom, "Le nom est obligatoire");
        Objects.requireNonNull(email, "L'email est obligatoire");
        Objects.requireNonNull(empreinteMotDePasse, "Le mot de passe est obligatoire");

        return new Utilisateur(
                nom.trim(),
                normaliserEmail(email),
                empreinteMotDePasse,
                Role.LECTEUR
        );
    }

    public static Utilisateur creerAdministrateur(
            String nom,
            String email,
            String empreinteMotDePasse
    ) {
        Objects.requireNonNull(nom, "Le nom est obligatoire");
        Objects.requireNonNull(email, "L'email est obligatoire");
        Objects.requireNonNull(empreinteMotDePasse, "Le mot de passe est obligatoire");

        return new Utilisateur(
                nom.trim(),
                normaliserEmail(email),
                empreinteMotDePasse,
                Role.ADMIN
        );
    }

    public static String normaliserEmail(String email) {
        return email == null ? null : email.trim().toLowerCase();
    }

    public void renommer(String nouveauNom) {
        Objects.requireNonNull(nouveauNom, "Le nom est obligatoire");
        this.nom = nouveauNom.trim();
    }

    public void changerMotDePasse(String nouvelleEmpreinte) {
        Objects.requireNonNull(nouvelleEmpreinte, "Le mot de passe est obligatoire");
        this.motDePasse = nouvelleEmpreinte;
    }

    public void promouvoirAdministrateur() {
        if (role == Role.ADMIN) {
            throw new IllegalStateException("Le compte est deja administrateur");
        }
        this.role = Role.ADMIN;
    }

    public void retrograderLecteur() {
        if (role == Role.LECTEUR) {
            throw new IllegalStateException("Le compte est deja lecteur");
        }
        this.role = Role.LECTEUR;
    }

    public void desactiver() {
        if (!actif) {
            throw new IllegalStateException("Le compte est deja desactive");
        }
        this.actif = false;
    }

    public void reactiver() {
        if (actif) {
            throw new IllegalStateException("Le compte est deja actif");
        }
        this.actif = true;
    }

    public boolean estAdmin() {
        return role == Role.ADMIN;
    }

    public boolean peutSeConnecter() {
        return actif;
    }

    @Override
    public String toString() {
        return "Utilisateur(%d, %s)".formatted(id, role);
    }
}