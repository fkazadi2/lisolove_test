import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Interface pour vérifier la connectivité Internet
abstract class NetworkInfo {
  /// Vérifie si le dispositif est connecté à Internet
  Future<bool> get isConnected;
}

/// Implémentation de l'interface NetworkInfo
class NetworkInfoImpl implements NetworkInfo {
  /// Un vérificateur de connexion Internet
  final InternetConnectionChecker connectionChecker;
  
  /// Constructeur
  NetworkInfoImpl(this.connectionChecker);
  
  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
} 