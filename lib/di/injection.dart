import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../core/network/network_info.dart';
import '../data/datasources/credit_local_datasource.dart';
import '../data/datasources/credit_remote_datasource.dart';
import '../data/models/credit_model.dart';
import '../data/models/credit_package_model.dart';
import '../data/models/credit_transaction_model.dart';
import '../data/repositories/credit_repository_impl.dart';
import '../domain/entities/credit_transaction.dart';
import '../domain/repositories/credit_repository.dart';
import '../domain/usecases/convert_credits.dart';
import '../domain/usecases/get_credit_packages.dart';
import '../domain/usecases/get_user_credits.dart';
import '../domain/usecases/purchase_credits.dart';
import '../presentation/blocs/credit/credit_bloc.dart';

/// Instance globale de l'injecteur de dépendances
final getIt = GetIt.instance;

/// Initialise l'injection de dépendances
Future<void> init() async {
  //! Fonctionnalités - Crédits
  // Bloc
  getIt.registerFactory(
    () => CreditBloc(
      getUserCredits: getIt(),
      getCreditPackages: getIt(),
      purchaseCredits: getIt(),
      convertCredits: getIt(),
    ),
  );

  // Cas d'utilisation
  getIt.registerLazySingleton(() => GetUserCredits(getIt()));
  getIt.registerLazySingleton(() => GetCreditPackages(getIt()));
  getIt.registerLazySingleton(() => PurchaseCredits(getIt()));
  getIt.registerLazySingleton(() => ConvertCredits(getIt()));

  // Repository
  getIt.registerLazySingleton<CreditRepository>(
    () => CreditRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Sources de données
  getIt.registerLazySingleton<CreditRemoteDataSource>(
    () => CreditRemoteDataSourceImpl(client: getIt()),
  );
  
  getIt.registerLazySingleton<CreditLocalDataSource>(
    () => CreditLocalDataSourceImpl(sharedPreferences: getIt()),
  );

  //! Core
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt()),
  );

  //! Dépendances externes
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
  getIt.registerLazySingleton(() => http.Client());
  getIt.registerLazySingleton(() => InternetConnectionChecker());
}

/// Classe d'implémentation de CreditRemoteDataSource
class CreditRemoteDataSourceImpl implements CreditRemoteDataSource {
  /// Client HTTP
  final http.Client client;
  
  /// URL de base de l'API
  final String baseUrl = 'https://api.lisolove.com/api/v1';
  
  /// Constructeur
  CreditRemoteDataSourceImpl({required this.client});
  
  @override
  Future<bool> convertCreditsToMoney(String userId, int amount, String phoneNumber) async {
    // TODO: Implémenter avec la vraie API
    // Simulation pour le développement
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
  
  @override
  Future<List<CreditPackageModel>> getAvailableCreditPackages() async {
    // TODO: Implémenter avec la vraie API
    // Simulation pour le développement
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      const CreditPackageModel(
        id: 'package1',
        creditAmount: 100,
        price: 1.99,
        description: 'Pack Débutant',
      ),
      const CreditPackageModel(
        id: 'package2',
        creditAmount: 500,
        price: 8.99,
        description: 'Pack Standard',
      ),
      const CreditPackageModel(
        id: 'package3',
        creditAmount: 1000,
        price: 15.99,
        description: 'Pack Premium',
        isPromotion: true,
        discountPercentage: 10,
      ),
    ];
  }
  
  @override
  Future<List<CreditTransactionModel>> getCreditTransactionHistory(String userId, {int? limit}) async {
    // TODO: Implémenter avec la vraie API
    // Simulation pour le développement
    await Future.delayed(const Duration(seconds: 1));
    
    final now = DateTime.now();
    
    return [
      CreditTransactionModel(
        id: 'tx1',
        userId: userId,
        type: CreditTransactionType.purchase,
        amount: 100,
        timestamp: now.subtract(const Duration(days: 1)),
        description: 'Achat de crédits - Pack Débutant',
        monetaryAmount: 1.99,
        currency: 'USD',
      ),
      CreditTransactionModel(
        id: 'tx2',
        userId: userId,
        type: CreditTransactionType.usage,
        amount: 20,
        timestamp: now.subtract(const Duration(hours: 12)),
        description: 'Boost de profil',
      ),
    ];
  }
  
  @override
  Future<CreditModel> getUserCredits(String userId) async {
    // TODO: Implémenter avec la vraie API
    // Simulation pour le développement
    await Future.delayed(const Duration(seconds: 1));
    
    return const CreditModel(amount: 580);
  }
  
  @override
  Future<bool> purchaseCredits(String userId, String packageId) async {
    // TODO: Implémenter avec la vraie API
    // Simulation pour le développement
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
  
  @override
  Future<bool> useCredits(String userId, int amount, String reason) async {
    // TODO: Implémenter avec la vraie API
    // Simulation pour le développement
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}

/// Classe d'implémentation de CreditLocalDataSource
class CreditLocalDataSourceImpl implements CreditLocalDataSource {
  /// Preferences partagées
  final SharedPreferences sharedPreferences;
  
  /// Constructeur
  CreditLocalDataSourceImpl({required this.sharedPreferences});
  
  // Clés pour le stockage local
  static const String lastCacheTimeKey = 'last_cache_time';
  
  @override
  Future<void> cacheTransaction(CreditTransactionModel transaction) async {
    final transactions = await getCachedTransactionHistory(transaction.userId);
    transactions.add(transaction);
    
    final jsonList = transactions.map((tx) => jsonEncode(tx.toJson())).toList();
    final key = 'transactions_${transaction.userId}';
    
    await sharedPreferences.setStringList(key, jsonList);
    await _updateCacheTime(key);
  }
  
  @override
  Future<void> cacheUserCredits(String userId, CreditModel credits) async {
    final key = 'credits_$userId';
    await sharedPreferences.setString(key, jsonEncode(credits.toJson()));
    await _updateCacheTime(key);
  }
  
  @override
  Future<void> cacheCreditPackages(List<CreditPackageModel> packages) async {
    const key = 'credit_packages';
    final jsonList = packages.map((p) => jsonEncode(p.toJson())).toList();
    await sharedPreferences.setStringList(key, jsonList);
    await _updateCacheTime(key);
  }
  
  @override
  Future<void> clearCache() async {
    // Effacer toutes les données liées aux crédits
    final keys = sharedPreferences.getKeys().where((key) => 
      key.startsWith('credits_') || 
      key.startsWith('transactions_') || 
      key == 'credit_packages' ||
      key.startsWith('cache_time_')
    );
    
    for (final key in keys) {
      await sharedPreferences.remove(key);
    }
  }
  
  @override
  Future<List<CreditPackageModel>> getCachedCreditPackages() async {
    const key = 'credit_packages';
    
    final jsonList = sharedPreferences.getStringList(key);
    if (jsonList == null || jsonList.isEmpty) {
      return [];
    }
    
    return jsonList.map((json) => 
      CreditPackageModel.fromJson(
        jsonDecode(json) as Map<String, dynamic>
      )
    ).toList();
  }
  
  @override
  Future<List<CreditTransactionModel>> getCachedTransactionHistory(String userId, {int? limit}) async {
    final key = 'transactions_$userId';
    
    final jsonList = sharedPreferences.getStringList(key);
    if (jsonList == null || jsonList.isEmpty) {
      return [];
    }
    
    final transactions = jsonList.map((json) => 
      CreditTransactionModel.fromJson(
        jsonDecode(json) as Map<String, dynamic>
      )
    ).toList();
    
    // Trier par date décroissante (plus récent en premier)
    transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    // Limiter le nombre de transactions si demandé
    if (limit != null && limit > 0 && transactions.length > limit) {
      return transactions.sublist(0, limit);
    }
    
    return transactions;
  }
  
  @override
  Future<CreditModel> getCachedUserCredits(String userId) async {
    final key = 'credits_$userId';
    
    final json = sharedPreferences.getString(key);
    if (json == null || json.isEmpty) {
      throw CacheNotFoundError();
    }
    
    return CreditModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }
  
  @override
  Future<bool> isCacheValid(String key, {int maxAgeInMinutes = 60}) async {
    final cacheTimeKey = 'cache_time_$key';
    final cacheTimeStr = sharedPreferences.getString(cacheTimeKey);
    
    if (cacheTimeStr == null) {
      return false;
    }
    
    final cacheTime = DateTime.parse(cacheTimeStr);
    final now = DateTime.now();
    final difference = now.difference(cacheTime).inMinutes;
    
    return difference <= maxAgeInMinutes;
  }
  
  // Mettre à jour l'horodatage du cache
  Future<void> _updateCacheTime(String key) async {
    final cacheTimeKey = 'cache_time_$key';
    final now = DateTime.now().toIso8601String();
    await sharedPreferences.setString(cacheTimeKey, now);
  }
}

/// Exception levée quand les données demandées ne sont pas trouvées dans le cache
class CacheNotFoundError implements Exception {
  @override
  String toString() => 'Données non trouvées dans le cache';
} 