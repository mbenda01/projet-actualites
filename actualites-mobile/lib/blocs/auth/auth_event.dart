import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthDemarrageDemande extends AuthEvent {
  const AuthDemarrageDemande();
}

class AuthInscriptionDemandee extends AuthEvent {
  final String nom;
  final String email;
  final String motDePasse;

  const AuthInscriptionDemandee({
    required this.nom,
    required this.email,
    required this.motDePasse,
  });

  @override
  List<Object?> get props => [nom, email, motDePasse];
}

class AuthConnexionDemandee extends AuthEvent {
  final String email;
  final String motDePasse;

  const AuthConnexionDemandee({
    required this.email,
    required this.motDePasse,
  });

  @override
  List<Object?> get props => [email, motDePasse];
}

class AuthDeconnexionDemandee extends AuthEvent {
  const AuthDeconnexionDemandee();
}