import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/credit.dart';
import '../../domain/entities/credit_package.dart';
import '../../domain/entities/credit_transaction.dart';
import '../../domain/repositories/credit_repository.dart';
import '../datasources/credit_local_datasource.dart';
import '../datasources/credit_remote_datasource.dart';
import '../models/credit_model.dart';
import '../models/credit_transaction_model.dart';

/// Clés pour le cache
class CacheKeys {
  /// Clé pour le solde de crédits
  static String userCredits(String userId) => 'user_credits_$userId';
  
  /// Clé pour les packages de crédits
  static const String creditPackages = 'credit_packages';
  
  /// Clé pour l'historique des transactions
  static String transactions(String userId) => 'transactions_$userId';
}

/// Implémentation de l'interface CreditRepository
class CreditRepositoryImpl implements CreditRepository {
  /// Source de données distante
  final CreditRemoteDataSource remoteDataSource;
  
  /// Source de données locale
  final CreditLocalDataSource localDataSource;
  
  /// Informations sur la connectivité réseau
  final NetworkInfo networkInfo;
  
  /// Durée de validité du cache en minutes
  final int cacheValidityInMinutes;
  
  /// Constructeur
  CreditRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    this.cacheValidityInMinutes = 30,
  });
  
  @override
  Future<Credit> getUserCredits(String userId) async {
    final cacheKey = CacheKeys.userCredits(userId);
    
    try {
      // Vérifier si les données en cache sont valides
      if (await localDataSource.isCacheValid(cacheKey, maxAgeInMinutes: cacheValidityInMinutes)) {
        final cachedCredits = await localDataSource.getCachedUserCredits(userId);
        return cachedCredits;
      }
      
      // Vérifier la connectivité
      if (await networkInfo.isConnected) {
        final remoteCredits = await remoteDataSource.getUserCredits(userId);
        
        // Mettre à jour le cache
        await localDataSource.cacheUserCredits(userId, remoteCredits);
        
        return remoteCredits;
      } else {
        // Si hors ligne, essayer quand même les données en cache même si expirées
        final cachedCredits = await localDataSource.getCachedUserCredits(userId);
        return cachedCredits;
      }
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    } on CacheException catch (e) {
      throw CacheFailure(message: e.message);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }
  
  @override
  Future<List<CreditPackage>> getAvailableCreditPackages() async {
    const cacheKey = CacheKeys.creditPackages;
    
    try {
      // Vérifier si les données en cache sont valides
      if (await localDataSource.isCacheValid(cacheKey, maxAgeInMinutes: cacheValidityInMinutes)) {
        final cachedPackages = await localDataSource.getCachedCreditPackages();
        return cachedPackages;
      }
      
      // Vérifier la connectivité
      if (await networkInfo.isConnected) {
        final remotePackages = await remoteDataSource.getAvailableCreditPackages();
        
        // Mettre à jour le cache
        await localDataSource.cacheCreditPackages(remotePackages);
        
        return remotePackages;
      } else {
        // Si hors ligne, essayer quand même les données en cache même si expirées
        final cachedPackages = await localDataSource.getCachedCreditPackages();
        return cachedPackages;
      }
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    } on CacheException catch (e) {
      throw CacheFailure(message: e.message);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }
  
  @override
  Future<bool> purchaseCredits(String userId, String packageId) async {
    try {
      // Cette opération nécessite une connexion Internet
      if (await networkInfo.isConnected) {
        final result = await remoteDataSource.purchaseCredits(userId, packageId);
        
        if (result) {
          // Mettre à jour le cache du solde de crédits
          final newCredits = await remoteDataSource.getUserCredits(userId);
          await localDataSource.cacheUserCredits(userId, newCredits);
        }
        
        return result;
      } else {
        throw CreditOperationFailure(
          message: 'Une connexion Internet est nécessaire pour acheter des crédits',
        );
      }
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure(message: e.toString());
    }
  }
  
  @override
  Future<bool> useCredits(String userId, int amount, String reason) async {
    try {
      // Vérifier la connectivité
      if (await networkInfo.isConnected) {
        // Vérifier si l'utilisateur a suffisamment de crédits
        final userCredits = await getUserCredits(userId);
        
        if (userCredits.amount < amount) {
          throw InsufficientCreditsFailure(
            currentBalance: userCredits.amount,
            requiredAmount: amount,
          );
        }
        
        final result = await remoteDataSource.useCredits(userId, amount, reason);
        
        if (result) {
          // Mettre à jour le cache du solde de crédits
          final newCredits = await remoteDataSource.getUserCredits(userId);
          await localDataSource.cacheUserCredits(userId, newCredits);
        }
        
        return result;
      } else {
        throw CreditOperationFailure(
          message: 'Une connexion Internet est nécessaire pour utiliser des crédits',
        );
      }
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure(message: e.toString());
    }
  }
  
  @override
  Future<bool> convertCreditsToMoney(String userId, int amount, String phoneNumber) async {
    try {
      // Cette opération nécessite une connexion Internet
      if (await networkInfo.isConnected) {
        // Vérifier si l'utilisateur a suffisamment de crédits
        final userCredits = await getUserCredits(userId);
        
        if (userCredits.amount < amount) {
          throw InsufficientCreditsFailure(
            currentBalance: userCredits.amount,
            requiredAmount: amount,
          );
        }
        
        final result = await remoteDataSource.convertCreditsToMoney(userId, amount, phoneNumber);
        
        if (result) {
          // Mettre à jour le cache du solde de crédits
          final newCredits = await remoteDataSource.getUserCredits(userId);
          await localDataSource.cacheUserCredits(userId, newCredits);
        }
        
        return result;
      } else {
        throw CreditOperationFailure(
          message: 'Une connexion Internet est nécessaire pour convertir des crédits',
        );
      }
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure(message: e.toString());
    }
  }
  
  @override
  Future<List<CreditTransaction>> getCreditTransactionHistory(String userId, {int? limit}) async {
    final cacheKey = CacheKeys.transactions(userId);
    
    try {
      // Vérifier si les données en cache sont valides
      if (await localDataSource.isCacheValid(cacheKey, maxAgeInMinutes: cacheValidityInMinutes)) {
        final cachedTransactions = await localDataSource.getCachedTransactionHistory(userId, limit: limit);
        return cachedTransactions;
      }
      
      // Vérifier la connectivité
      if (await networkInfo.isConnected) {
        final remoteTransactions = await remoteDataSource.getCreditTransactionHistory(userId, limit: limit);
        
        // Mettre à jour le cache (enregistrer chaque transaction)
        for (final transaction in remoteTransactions) {
          await localDataSource.cacheTransaction(transaction);
        }
        
        return remoteTransactions;
      } else {
        // Si hors ligne, essayer quand même les données en cache même si expirées
        final cachedTransactions = await localDataSource.getCachedTransactionHistory(userId, limit: limit);
        return cachedTransactions;
      }
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    } on CacheException catch (e) {
      throw CacheFailure(message: e.message);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }
} 