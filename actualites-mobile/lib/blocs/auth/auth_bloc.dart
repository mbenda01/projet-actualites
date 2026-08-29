import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/erreur_api.dart';
import '../../core/journal.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/jeton_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const String _origine = 'AuthBloc';

  final AuthRepository _depot;
  final JetonRepository _depotJetons;
  final Journal _journal;

  AuthBloc({
    required AuthRepository depot,
    required JetonRepository depotJetons,
    required Journal journal,
  })  : _depot = depot,
        _depotJetons = depotJetons,
        _journal = journal,
        super(const AuthInitial()) {
    on<AuthDemarrageDemande>(_surDemarrage);
    on<AuthInscriptionDemandee>(_surInscription);
    on<AuthConnexionDemandee>(_surConnexion);
    on<AuthDeconnexionDemandee>(_surDeconnexion);
  }

  Future<void> _surDemarrage(
    AuthDemarrageDemande evenement,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthEnChargement());

    final jetons = await _depotJetons.lireJetons();

    if (jetons == null) {
      _journal.debug(_origine, 'Aucun jeton stocké');
      emit(const AuthNonAuthentifie());
      return;
    }

    try {
      final utilisateur = await _depot.profilCourant();
      _journal.info(_origine, 'Session restaurée : id=${utilisateur.id}');
      emit(AuthAuthentifie(utilisateur));
    } catch (erreur) {
      _journal.avertissement(_origine, 'Session invalide, déconnexion');
      await _depotJetons.effacerJetons();
      emit(const AuthNonAuthentifie());
    }
  }

  Future<void> _surInscription(
    AuthInscriptionDemandee evenement,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthEnChargement());

    try {
      await _depot.inscrire(
        evenement.nom,
        evenement.email,
        evenement.motDePasse,
      );

      final utilisateur = await _depot.profilCourant();

      _journal.info(_origine, 'Inscription réussie : id=${utilisateur.id}');
      emit(AuthAuthentifie(utilisateur));
    } catch (erreur) {
      emit(_traduireEchec(erreur));
    }
  }

  Future<void> _surConnexion(
    AuthConnexionDemandee evenement,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthEnChargement());

    try {
      await _depot.connecter(evenement.email, evenement.motDePasse);

      final utilisateur = await _depot.profilCourant();

      _journal.info(_origine, 'Connexion réussie : id=${utilisateur.id}');
      emit(AuthAuthentifie(utilisateur));
    } catch (erreur) {
      emit(_traduireEchec(erreur));
    }
  }

  Future<void> _surDeconnexion(
    AuthDeconnexionDemandee evenement,
    Emitter<AuthState> emit,
  ) async {
    await _depot.deconnecter();
    _journal.info(_origine, 'Déconnexion');
    emit(const AuthNonAuthentifie());
  }

  AuthState _traduireEchec(Object erreur) {
    if (erreur is ErreurValidation) {
      return AuthEchec(erreur.message, champs: erreur.champs);
    }

    if (erreur is ErreurApi) {
      _journal.avertissement(_origine, 'Échec : ${erreur.runtimeType}');
      return AuthEchec(erreur.message);
    }

    _journal.erreur(_origine, 'Erreur inattendue', erreur);
    return const AuthEchec('Une erreur est survenue');
  }
}