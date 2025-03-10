import '../entities/credit.dart';
import '../repositories/credit_repository.dart';

/// Cas d'utilisation pour récupérer le solde de crédits d'un utilisateur
class GetUserCredits {
  /// Repository utilisé pour accéder aux données
  final CreditRepository repository;

  /// Constructeur
  const GetUserCredits(this.repository);

  /// Exécute le cas d'utilisation
  /// 
  /// [userId] - L'identifiant de l'utilisateur
  Future<Credit> execute(String userId) {
    return repository.getUserCredits(userId);
  }
} 