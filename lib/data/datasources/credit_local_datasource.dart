import '../models/credit_model.dart';
import '../models/credit_package_model.dart';
import '../models/credit_transaction_model.dart';

/// Source de données locale pour les crédits (cache)
abstract class CreditLocalDataSource {
  /// Récupère le solde de crédits de l'utilisateur depuis le cache
  /// 
  /// Lève une [CacheException] en cas d'erreur
  Future<CreditModel> getCachedUserCredits(String userId);
  
  /// Sauvegarde le solde de crédits de l'utilisateur dans le cache
  Future<void> cacheUserCredits(String userId, CreditModel credits);
  
  /// Récupère la liste des packages de crédits depuis le cache
  /// 
  /// Lève une [CacheException] en cas d'erreur
  Future<List<CreditPackageModel>> getCachedCreditPackages();
  
  /// Sauvegarde la liste des packages de crédits dans le cache
  Future<void> cacheCreditPackages(List<CreditPackageModel> packages);
  
  /// Récupère l'historique des transactions de crédits depuis le cache
  /// 
  /// Lève une [CacheException] en cas d'erreur
  Future<List<CreditTransactionModel>> getCachedTransactionHistory(String userId, {int? limit});
  
  /// Sauvegarde une transaction de crédits dans l'historique local
  Future<void> cacheTransaction(CreditTransactionModel transaction);
  
  /// Vérifie si les données en cache sont encore valides
  /// 
  /// [key] - Clé identifiant le type de données à vérifier
  /// [maxAgeInMinutes] - Âge maximum en minutes pour considérer les données comme valides
  Future<bool> isCacheValid(String key, {int maxAgeInMinutes = 60});
  
  /// Nettoie le cache
  Future<void> clearCache();
} 