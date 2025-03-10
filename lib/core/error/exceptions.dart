/// Exception lancée lorsqu'un problème survient avec le serveur
class ServerException implements Exception {
  /// Message d'erreur
  final String message;
  
  /// Code d'erreur HTTP
  final int? statusCode;
  
  /// Constructeur
  ServerException({this.message = 'Erreur serveur', this.statusCode});
  
  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

/// Exception lancée lorsqu'un problème survient avec le cache
class CacheException implements Exception {
  /// Message d'erreur
  final String message;
  
  /// Constructeur
  CacheException({this.message = 'Erreur de cache'});
  
  @override
  String toString() => 'CacheException: $message';
}

/// Exception lancée lorsqu'une tentative d'authentification échoue
class AuthException implements Exception {
  /// Message d'erreur
  final String message;
  
  /// Constructeur
  AuthException({this.message = 'Erreur d\'authentification'});
  
  @override
  String toString() => 'AuthException: $message';
}

/// Exception lancée lorsqu'une opération n'est pas autorisée
class PermissionException implements Exception {
  /// Message d'erreur
  final String message;
  
  /// Constructeur
  PermissionException({this.message = 'Opération non autorisée'});
  
  @override
  String toString() => 'PermissionException: $message';
}

/// Exception lancée lorsqu'un problème survient avec une opération de crédit
class CreditOperationException implements Exception {
  /// Message d'erreur
  final String message;
  
  /// Constructeur
  CreditOperationException({this.message = 'Erreur lors de l\'opération de crédit'});
  
  @override
  String toString() => 'CreditOperationException: $message';
}

/// Exception lancée lorsque le solde de crédits est insuffisant
class InsufficientCreditsException implements Exception {
  /// Solde actuel
  final int currentBalance;
  
  /// Montant requis
  final int requiredAmount;
  
  /// Constructeur
  InsufficientCreditsException({
    required this.currentBalance,
    required this.requiredAmount,
  });
  
  @override
  String toString() => 
      'InsufficientCreditsException: Solde insuffisant (disponible: $currentBalance, requis: $requiredAmount)';
} 