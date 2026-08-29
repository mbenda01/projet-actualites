import 'package:equatable/equatable.dart';

import '../../models/utilisateur.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthEnChargement extends AuthState {
  const AuthEnChargement();
}

class AuthAuthentifie extends AuthState {
  final Utilisateur utilisateur;

  const AuthAuthentifie(this.utilisateur);

  @override
  List<Object?> get props => [utilisateur];
}

class AuthNonAuthentifie extends AuthState {
  const AuthNonAuthentifie();
}

class AuthEchec extends AuthState {
  final String message;
  final Map<String, String> champs;

  const AuthEchec(this.message, {this.champs = const {}});

  @override
  List<Object?> get props => [message, champs];
}