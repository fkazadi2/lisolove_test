import 'package:equatable/equatable.dart';

/// Événement du BLoC de gestion des crédits
abstract class CreditEvent extends Equatable {
  /// Constructeur
  const CreditEvent();
  
  @override
  List<Object?> get props => [];
}

/// Charger les crédits de l'utilisateur
class LoadUserCredits extends CreditEvent {
  /// Identifiant de l'utilisateur
  final String userId;
  
  /// Constructeur
  const LoadUserCredits(this.userId);
  
  @override
  List<Object?> get props => [userId];
}

/// Charger les packages de crédits disponibles
class LoadCreditPackages extends CreditEvent {
  /// Constructeur
  const LoadCreditPackages();
}

/// Charger l'historique des transactions
class LoadCreditTransactionHistory extends CreditEvent {
  /// Identifiant de l'utilisateur
  final String userId;
  
  /// Limite du nombre de transactions à récupérer
  final int? limit;
  
  /// Constructeur
  const LoadCreditTransactionHistory(this.userId, {this.limit});
  
  @override
  List<Object?> get props => [userId, limit];
}

/// Acheter des crédits
class PurchaseCredits extends CreditEvent {
  /// Identifiant de l'utilisateur
  final String userId;
  
  /// Identifiant du package de crédits à acheter
  final String packageId;
  
  /// Constructeur
  const PurchaseCredits(this.userId, this.packageId);
  
  @override
  List<Object?> get props => [userId, packageId];
}

/// Utiliser des crédits
class UseCredits extends CreditEvent {
  /// Identifiant de l'utilisateur
  final String userId;
  
  /// Montant de crédits à utiliser
  final int amount;
  
  /// Raison de l'utilisation
  final String reason;
  
  /// Constructeur
  const UseCredits(this.userId, this.amount, this.reason);
  
  @override
  List<Object?> get props => [userId, amount, reason];
}

/// Convertir des crédits en argent réel
class ConvertCredits extends CreditEvent {
  /// Identifiant de l'utilisateur
  final String userId;
  
  /// Montant de crédits à convertir
  final int amount;
  
  /// Numéro de téléphone pour recevoir l'argent
  final String phoneNumber;
  
  /// Constructeur
  const ConvertCredits(this.userId, this.amount, this.phoneNumber);
  
  @override
  List<Object?> get props => [userId, amount, phoneNumber];
} 