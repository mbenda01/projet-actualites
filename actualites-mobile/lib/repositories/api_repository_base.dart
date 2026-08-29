import '../core/client_http_interface.dart';

abstract class ApiRepositoryBase {
  final ClientHttpInterface client;

  const ApiRepositoryBase({required this.client});
  Future<T> executer<T>(
    Future<dynamic> Function() appel,
    T Function(dynamic donnees) transformer,
  ) async {
    try {
      final reponse = await appel();
      return transformer(reponse['data']);
    } catch (erreur) {
      throw client.traduireErreur(erreur);
    }
  }
}
