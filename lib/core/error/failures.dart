import 'package:equatable/equatable.dart';

/// Classe de base pour tous les échecs
abstract class Failure extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Échec général pour les erreurs serveur
class ServerFailure extends Failure {
  /// Message d'erreur
  final String message;
  
  /// Code d'erreur HTTP
  final int? statusCode;
  
  /// Constructeur
  ServerFailure({
    this.message = 'Une erreur est survenue lors de la communication avec le serveur',
    this.statusCode,
  });
  
  @override
  List<Object?> get props => [message, statusCode];
}

/// Échec général pour les erreurs de cache
class CacheFailure extends Failure {
  /// Message d'erreur
  final String message;
  
  /// Constructeur
  CacheFailure({
    this.message = 'Une erreur est survenue lors de l\'accès aux données locales',
  });
  
  @override
  List<Object?> get props => [message];
}

/// Échec lors de l'authentification
class AuthFailure extends Failure {
  /// Message d'erreur
  final String message;
  
  /// Constructeur
  AuthFailure({
    this.message = 'Erreur d\'authentification',
  });
  
  @override
  List<Object?> get props => [message];
}

/// Échec lorsqu'une opération n'est pas autorisée
class PermissionFailure extends Failure {
  /// Message d'erreur
  final String message;
  
  /// Constructeur
  PermissionFailure({
    this.message = 'Vous n\'êtes pas autorisé à effectuer cette opération',
  });
  
  @override
  List<Object?> get props => [message];
}

/// Échec lors d'une opération de crédit
class CreditOperationFailure extends Failure {
  /// Message d'erreur
  final String message;
  
  /// Constructeur
  CreditOperationFailure({
    this.message = 'L\'opération de crédit a échoué',
  });
  
  @override
  List<Object?> get props => [message];
}

/// Échec lorsque le solde de crédits est insuffisant
class InsufficientCreditsFailure extends Failure {
  /// Solde actuel
  final int currentBalance;
  
  /// Montant requis
  final int requiredAmount;
  
  /// Constructeur
  InsufficientCreditsFailure({
    required this.currentBalance,
    required this.requiredAmount,
  });
  
  @override
  List<Object?> get props => [currentBalance, requiredAmount];
  
  @override
  String toString() => 
      'Solde insuffisant (disponible: $currentBalance, requis: $requiredAmount)';
} 