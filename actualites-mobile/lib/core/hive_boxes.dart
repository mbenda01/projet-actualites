import 'package:hive_flutter/hive_flutter.dart';

class HiveBoites {
  HiveBoites._();

  static const String articles = 'boite_articles';
  static const String favorisIdentifiants = 'boite_favoris_identifiants';
  static const String favorisArticles = 'boite_favoris_articles';
  static const String favorisFileAttente = 'boite_favoris_file_attente';

  static Future<void> initialiser() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(articles),
      Hive.openBox(favorisIdentifiants),
      Hive.openBox(favorisArticles),
      Hive.openBox(favorisFileAttente),
    ]);
  }
}
