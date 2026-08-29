import 'package:flutter/foundation.dart';

enum NiveauJournal {
  debug(0, 'DEBUG'),
  info(1, 'INFO'),
  avertissement(2, 'AVERT'),
  erreur(3, 'ERREUR');

  final int rang;

  final String libelle;

  const NiveauJournal(this.rang, this.libelle);
}

abstract class Journal {
  void debug(String origine, String message);
  void info(String origine, String message);
  void avertissement(String origine, String message);

  void erreur(
    String origine,
    String message, [
    Object? erreur,
    StackTrace? trace,
  ]);
}

class JournalConsole implements Journal {
  final NiveauJournal niveauMinimum;

  JournalConsole({NiveauJournal? niveauMinimum})
      : niveauMinimum = niveauMinimum ??
            (kDebugMode ? NiveauJournal.debug : NiveauJournal.avertissement);

  @override
  void debug(String origine, String message) =>
      _ecrire(NiveauJournal.debug, origine, message);

  @override
  void info(String origine, String message) =>
      _ecrire(NiveauJournal.info, origine, message);

  @override
  void avertissement(String origine, String message) =>
      _ecrire(NiveauJournal.avertissement, origine, message);

  @override
  void erreur(
    String origine,
    String message, [
    Object? erreur,
    StackTrace? trace,
  ]) {
    _ecrire(NiveauJournal.erreur, origine, message);

    if (erreur != null) {
      _ecrire(NiveauJournal.erreur, origine, '  cause : $erreur');
    }

    if (trace != null && kDebugMode) {
      _ecrire(NiveauJournal.erreur, origine, '  trace : $trace');
    }
  }

  void _ecrire(NiveauJournal niveau, String origine, String message) {
    if (niveau.rang < niveauMinimum.rang) return;

    debugPrint('[${niveau.libelle}] $origine : $message');
  }
}

class JournalMuet implements Journal {
  const JournalMuet();

  @override
  void debug(String origine, String message) {}

  @override
  void info(String origine, String message) {}

  @override
  void avertissement(String origine, String message) {}

  @override
  void erreur(
    String origine,
    String message, [
    Object? erreur,
    StackTrace? trace,
  ]) {}
}

class JournalMemoire implements Journal {
  final List<EntreeJournal> entrees = [];

  @override
  void debug(String origine, String message) =>
      entrees.add(EntreeJournal(NiveauJournal.debug, origine, message));

  @override
  void info(String origine, String message) =>
      entrees.add(EntreeJournal(NiveauJournal.info, origine, message));

  @override
  void avertissement(String origine, String message) => entrees
      .add(EntreeJournal(NiveauJournal.avertissement, origine, message));

  @override
  void erreur(
    String origine,
    String message, [
    Object? erreur,
    StackTrace? trace,
  ]) =>
      entrees.add(EntreeJournal(NiveauJournal.erreur, origine, message));

  void vider() => entrees.clear();

  List<EntreeJournal> filtrerParNiveau(NiveauJournal niveau) =>
      entrees.where((entree) => entree.niveau == niveau).toList();
}

class EntreeJournal {
  final NiveauJournal niveau;
  final String origine;
  final String message;

  const EntreeJournal(this.niveau, this.origine, this.message);

  @override
  String toString() => '[${niveau.libelle}] $origine : $message';
}