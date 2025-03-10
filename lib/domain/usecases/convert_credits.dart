import '../repositories/credit_repository.dart';

/// Cas d'utilisation pour convertir des crédits en argent réel
class ConvertCredits {
  /// Repository utilisé pour accéder aux données
  final CreditRepository repository;

  /// Constructeur
  const ConvertCredits(this.repository);

  /// Exécute le cas d'utilisation
  /// 
  /// [userId] - L'identifiant de l'utilisateur
  /// [amount] - Le montant de crédits à convertir
  /// [phoneNumber] - Le numéro de téléphone pour recevoir l'argent (Mobile Money)
  Future<bool> execute(String userId, int amount, String phoneNumber) {
    // Validation des paramètres
    if (amount <= 0) {
      throw ArgumentError('Le montant doit être supérieur à 0');
    }
    
    if (phoneNumber.isEmpty) {
      throw ArgumentError('Le numéro de téléphone est requis');
    }
    
    return repository.convertCreditsToMoney(userId, amount, phoneNumber);
  }
} 