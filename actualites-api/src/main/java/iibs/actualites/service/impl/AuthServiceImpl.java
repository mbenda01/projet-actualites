package iibs.actualites.service.impl;

import iibs.actualites.controller.dto.*;
import iibs.actualites.entity.*;
import iibs.actualites.exception.*;
import iibs.actualites.repository.*;
import iibs.actualites.security.*;
import iibs.actualites.service.*;
import iibs.actualites.service.mapper.*;
import lombok.*;
import lombok.extern.slf4j.*;
import org.springframework.security.crypto.password.*;
import org.springframework.stereotype.*;
import org.springframework.transaction.annotation.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UtilisateurRepository utilisateurRepository;
    private final UtilisateurMapper utilisateurMapper;
    private final PasswordEncoder encodeurMotDePasse;
    private final JwtService jwtService;
    private final ContexteSecurite contexte;

    @Override
    @Transactional
    public JetonReponseDto inscrire(InscriptionRequestDto dto) {
        log.debug("Demande d'inscription");

        String email = Utilisateur.normaliserEmail(dto.email());

        if (utilisateurRepository.existsByEmail(email)) {
            throw new ConflitMetierException("Cet email est deja utilise");
        }

        Utilisateur utilisateur = Utilisateur.inscrire(
                dto.nom(),
                email,
                encodeurMotDePasse.encode(dto.motDePasse()));

        Utilisateur enregistre = utilisateurRepository.save(utilisateur);

        log.info("Compte cree : id={}", enregistre.getId());

        return construireReponse(enregistre);
    }

    @Override
    @Transactional(readOnly = true)
    public JetonReponseDto connecter(ConnexionRequestDto dto) {
        log.debug("Demande de connexion");

        String email = Utilisateur.normaliserEmail(dto.email());

        Utilisateur utilisateur = utilisateurRepository.findByEmail(email)
                .orElseThrow(() -> {
                    log.warn("Echec de connexion : compte introuvable");
                    return new IdentifiantsInvalidesException();
                });

        if (!utilisateur.peutSeConnecter()) {
            log.warn("Echec de connexion : compte desactive, id={}",
                    utilisateur.getId());
            throw new IdentifiantsInvalidesException();
        }

        if (!encodeurMotDePasse.matches(dto.motDePasse(), utilisateur.getMotDePasse())) {
            log.warn("Echec de connexion : mot de passe incorrect, id={}",
                    utilisateur.getId());
            throw new IdentifiantsInvalidesException();
        }

        log.info("Connexion reussie : id={}", utilisateur.getId());

        return construireReponse(utilisateur);
    }

    @Override
    @Transactional(readOnly = true)
    public JetonReponseDto rafraichir(RafraichissementRequestDto dto) {
        log.debug("Demande de rafraichissement");

        String jeton = dto.jetonRafraichissement();

        if (!jwtService.estJetonRafraichissementValide(jeton)) {
            log.warn("Rafraichissement refuse : jeton invalide ou de mauvais type");
            throw new IdentifiantsInvalidesException(
                    "Jeton de rafraichissement invalide ou expire");
        }

        String email = jwtService.extraireEmail(jeton);

        Utilisateur utilisateur = utilisateurRepository.findByEmail(email)
                .orElseThrow(() -> {

                    log.warn("Rafraichissement refuse : compte introuvable");
                    return new IdentifiantsInvalidesException(
                            "Jeton de rafraichissement invalide ou expire");
                });

        if (!utilisateur.peutSeConnecter()) {
            log.warn("Rafraichissement refuse : compte desactive, id={}",
                    utilisateur.getId());
            throw new IdentifiantsInvalidesException(
                    "Jeton de rafraichissement invalide ou expire");
        }

        log.debug("Jetons renouveles pour l'utilisateur id={}", utilisateur.getId());

        return construireReponse(utilisateur);
    }

    @Override
    @Transactional(readOnly = true)
    public UtilisateurReponseDto profilCourant() {
        return utilisateurMapper.versReponse(contexte.utilisateurCourantRequis());
    }

    private JetonReponseDto construireReponse(Utilisateur utilisateur) {
        String jetonAcces = jwtService.genererJetonAcces(
                utilisateur.getEmail(),
                utilisateur.getRole().name(),
                utilisateur.getId());

        String jetonRafraichissement = jwtService.genererJetonRafraichissement(utilisateur.getEmail());

        return JetonReponseDto.bearer(
                jetonAcces,
                jetonRafraichissement,
                jwtService.accesValiditeSecondes(),
                utilisateurMapper.versReponse(utilisateur));
    }
}