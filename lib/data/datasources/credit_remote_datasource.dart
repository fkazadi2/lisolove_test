import '../models/credit_model.dart';
import '../models/credit_package_model.dart';
import '../models/credit_transaction_model.dart';

/// Source de données distante pour les crédits (API)
abstract class CreditRemoteDataSource {
  /// Récupère le solde de crédits de l'utilisateur
  Future<CreditModel> getUserCredits(String userId);
  
  /// Récupère la liste des packages de crédits disponibles à l'achat
  Future<List<CreditPackageModel>> getAvailableCreditPackages();
  
  /// Effectue un achat de crédits
  /// 
  /// Retourne true si l'achat a été effectué avec succès
  Future<bool> purchaseCredits(String userId, String packageId);
  
  /// Utilise des crédits pour une fonctionnalité (boost, premium, etc.)
  /// 
  /// Retourne true si l'utilisation a été effectuée avec succès
  Future<bool> useCredits(String userId, int amount, String reason);
  
  /// Convertit des crédits en argent réel
  /// 
  /// Retourne true si la conversion a été effectuée avec succès
  Future<bool> convertCreditsToMoney(String userId, int amount, String phoneNumber);
  
  /// Récupère l'historique des transactions de crédits de l'utilisateur
  Future<List<CreditTransactionModel>> getCreditTransactionHistory(String userId, {int? limit});
} 