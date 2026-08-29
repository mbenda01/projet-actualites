import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';

class EcranConnexion extends StatefulWidget {
  const EcranConnexion({super.key});

  @override
  State<EcranConnexion> createState() => _EcranConnexionState();
}

class _EcranConnexionState extends State<EcranConnexion> {
  final _formulaireCle = GlobalKey<FormState>();

  final _controleurNom = TextEditingController();
  final _controleurEmail = TextEditingController();
  final _controleurMotDePasse = TextEditingController();

  bool _modeInscription = false;
  bool _motDePasseVisible = false;

  @override
  void dispose() {
    _controleurNom.dispose();
    _controleurEmail.dispose();
    _controleurMotDePasse.dispose();
    super.dispose();
  }

  void _basculerMode() {
    setState(() {
      _modeInscription = !_modeInscription;
    });
  }

  void _valider() {
    if (!_formulaireCle.currentState!.validate()) return;

    final email = _controleurEmail.text.trim();
    final motDePasse = _controleurMotDePasse.text;

    if (_modeInscription) {
      context.read<AuthBloc>().add(AuthInscriptionDemandee(
            nom: _controleurNom.text.trim(),
            email: email,
            motDePasse: motDePasse,
          ));
    } else {
      context.read<AuthBloc>().add(AuthConnexionDemandee(
            email: email,
            motDePasse: motDePasse,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: _surChangementEtat,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formulaireCle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  _construireEntete(context),
                  const SizedBox(height: 40),
                  if (_modeInscription) ...[
                    _construireChampNom(),
                    const SizedBox(height: 16),
                  ],
                  _construireChampEmail(),
                  const SizedBox(height: 16),
                  _construireChampMotDePasse(),
                  const SizedBox(height: 8),
                  _construireErreur(),
                  const SizedBox(height: 24),
                  _construireBoutonPrincipal(),
                  const SizedBox(height: 16),
                  _construireBoutonBascule(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _surChangementEtat(BuildContext context, AuthState etat) {
    if (etat is AuthEchec && etat.champs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(etat.message)),
      );
    }
  }

  Widget _construireEntete(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: couleurs.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.article_outlined,
            size: 36,
            color: couleurs.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _modeInscription ? 'Créer un compte' : 'Bienvenue',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          _modeInscription
              ? 'Inscrivez-vous pour enregistrer vos articles'
              : 'Connectez-vous pour continuer',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _construireChampNom() {
    return TextFormField(
      controller: _controleurNom,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'Nom',
        prefixIcon: Icon(Icons.person_outline),
      ),
      validator: (valeur) {
        if (!_modeInscription) return null;
        if (valeur == null || valeur.trim().length < 2) {
          return 'Le nom doit contenir au moins 2 caractères';
        }
        return null;
      },
    );
  }

  Widget _construireChampEmail() {
    return TextFormField(
      controller: _controleurEmail,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      decoration: const InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      validator: (valeur) {
        if (valeur == null || !valeur.contains('@')) {
          return 'Adresse email invalide';
        }
        return null;
      },
    );
  }

  Widget _construireChampMotDePasse() {
    return TextFormField(
      controller: _controleurMotDePasse,
      obscureText: !_motDePasseVisible,
      decoration: InputDecoration(
        labelText: 'Mot de passe',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _motDePasseVisible ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() => _motDePasseVisible = !_motDePasseVisible);
          },
        ),
      ),
      validator: (valeur) {
        if (valeur == null || valeur.isEmpty) {
          return 'Le mot de passe est obligatoire';
        }
        if (_modeInscription && valeur.length < 8) {
          return 'Au moins 8 caractères';
        }
        return null;
      },
    );
  }

  Widget _construireErreur() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, etat) {
        if (etat is! AuthEchec || etat.champs.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            etat.champs.values.first,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        );
      },
    );
  }

  Widget _construireBoutonPrincipal() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, etat) {
        final enChargement = etat is AuthEnChargement;

        return FilledButton(
          onPressed: enChargement ? null : _valider,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: enChargement
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_modeInscription ? "S'inscrire" : 'Se connecter'),
        );
      },
    );
  }

  Widget _construireBoutonBascule() {
    return TextButton(
      onPressed: _basculerMode,
      child: Text(
        _modeInscription
            ? 'Déjà un compte ? Se connecter'
            : "Pas de compte ? S'inscrire",
      ),
    );
  }
}