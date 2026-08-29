package iibs.actualites.security;

import iibs.actualites.repository.*;
import lombok.*;
import lombok.extern.slf4j.*;
import org.springframework.security.core.userdetails.*;
import org.springframework.stereotype.*;
import org.springframework.transaction.annotation.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class UtilisateurDetailsService implements UserDetailsService {

    private final UtilisateurRepository utilisateurRepository;

    @Override
    @Transactional(readOnly = true)
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        return utilisateurRepository.findByEmail(email)
                .map(UtilisateurDetails::new)
                .orElseThrow(() -> {
                    log.debug("Utilisateur introuvable a l'authentification");
                    return new UsernameNotFoundException("Identifiants invalides");
                });
    }
}