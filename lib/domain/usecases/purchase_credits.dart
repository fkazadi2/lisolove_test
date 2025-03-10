import '../repositories/credit_repository.dart';

/// Cas d'utilisation pour effectuer un achat de crédits
class PurchaseCredits {
  /// Repository utilisé pour accéder aux données
  final CreditRepository repository;

  /// Constructeur
  const PurchaseCredits(this.repository);

  /// Exécute le cas d'utilisation
  /// 
  /// [userId] - L'identifiant de l'utilisateur
  /// [packageId] - L'identifiant du package de crédits à acheter
  Future<bool> execute(String userId, String packageId) {
    return repository.purchaseCredits(userId, packageId);
  }
} 