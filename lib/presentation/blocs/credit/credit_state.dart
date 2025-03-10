import 'package:equatable/equatable.dart';

import '../../../domain/entities/credit.dart';
import '../../../domain/entities/credit_package.dart';
import '../../../domain/entities/credit_transaction.dart';

/// État du BLoC de gestion des crédits
abstract class CreditState extends Equatable {
  /// Constructeur
  const CreditState();
  
  @override
  List<Object?> get props => [];
}

/// État initial
class CreditInitial extends CreditState {}

/// Chargement des données
class CreditLoading extends CreditState {}

/// Crédits chargés avec succès
class CreditLoaded extends CreditState {
  /// Les crédits de l'utilisateur
  final Credit credits;
  
  /// Constructeur
  const CreditLoaded(this.credits);
  
  @override
  List<Object?> get props => [credits];
}

/// Packages de crédits chargés avec succès
class CreditPackagesLoaded extends CreditState {
  /// Les packages de crédits disponibles
  final List<CreditPackage> packages;
  
  /// Constructeur
  const CreditPackagesLoaded(this.packages);
  
  @override
  List<Object?> get props => [packages];
}

/// Historique des transactions chargé avec succès
class CreditTransactionsLoaded extends CreditState {
  /// L'historique des transactions
  final List<CreditTransaction> transactions;
  
  /// Constructeur
  const CreditTransactionsLoaded(this.transactions);
  
  @override
  List<Object?> get props => [transactions];
}

/// En cours d'achat de crédits
class CreditPurchasing extends CreditState {
  /// Le montant actuel de crédits
  final Credit currentCredits;
  
  /// Constructeur
  const CreditPurchasing(this.currentCredits);
  
  @override
  List<Object?> get props => [currentCredits];
}

/// Achat de crédits réussi
class CreditPurchaseSuccess extends CreditState {
  /// Les nouveaux crédits après l'achat
  final Credit newCredits;
  
  /// Constructeur
  const CreditPurchaseSuccess(this.newCredits);
  
  @override
  List<Object?> get props => [newCredits];
}

/// Échec de l'achat de crédits
class CreditPurchaseFailure extends CreditState {
  /// Les crédits de l'utilisateur
  final Credit currentCredits;
  
  /// Message d'erreur
  final String errorMessage;
  
  /// Constructeur
  const CreditPurchaseFailure(this.currentCredits, this.errorMessage);
  
  @override
  List<Object?> get props => [currentCredits, errorMessage];
}

/// En cours d'utilisation de crédits
class CreditUsing extends CreditState {
  /// Le montant actuel de crédits
  final Credit currentCredits;
  
  /// Montant à utiliser
  final int amountToUse;
  
  /// Raison de l'utilisation
  final String reason;
  
  /// Constructeur
  const CreditUsing(this.currentCredits, this.amountToUse, this.reason);
  
  @override
  List<Object?> get props => [currentCredits, amountToUse, reason];
}

/// Utilisation de crédits réussie
class CreditUseSuccess extends CreditState {
  /// Les nouveaux crédits après l'utilisation
  final Credit newCredits;
  
  /// Montant utilisé
  final int amountUsed;
  
  /// Raison de l'utilisation
  final String reason;
  
  /// Constructeur
  const CreditUseSuccess(this.newCredits, this.amountUsed, this.reason);
  
  @override
  List<Object?> get props => [newCredits, amountUsed, reason];
}

/// Échec de l'utilisation de crédits
class CreditUseFailure extends CreditState {
  /// Les crédits de l'utilisateur
  final Credit currentCredits;
  
  /// Message d'erreur
  final String errorMessage;
  
  /// Constructeur
  const CreditUseFailure(this.currentCredits, this.errorMessage);
  
  @override
  List<Object?> get props => [currentCredits, errorMessage];
}

/// En cours de conversion de crédits
class CreditConverting extends CreditState {
  /// Le montant actuel de crédits
  final Credit currentCredits;
  
  /// Montant à convertir
  final int amountToConvert;
  
  /// Numéro de téléphone pour recevoir l'argent
  final String phoneNumber;
  
  /// Constructeur
  const CreditConverting(this.currentCredits, this.amountToConvert, this.phoneNumber);
  
  @override
  List<Object?> get props => [currentCredits, amountToConvert, phoneNumber];
}

/// Conversion de crédits réussie
class CreditConversionSuccess extends CreditState {
  /// Les nouveaux crédits après la conversion
  final Credit newCredits;
  
  /// Montant converti
  final int amountConverted;
  
  /// Valeur monétaire reçue
  final double monetaryValue;
  
  /// Constructeur
  const CreditConversionSuccess(
    this.newCredits,
    this.amountConverted,
    this.monetaryValue,
  );
  
  @override
  List<Object?> get props => [newCredits, amountConverted, monetaryValue];
}

/// Échec de la conversion de crédits
class CreditConversionFailure extends CreditState {
  /// Les crédits de l'utilisateur
  final Credit currentCredits;
  
  /// Message d'erreur
  final String errorMessage;
  
  /// Constructeur
  const CreditConversionFailure(this.currentCredits, this.errorMessage);
  
  @override
  List<Object?> get props => [currentCredits, errorMessage];
}

/// Erreur générale
class CreditError extends CreditState {
  /// Message d'erreur
  final String message;
  
  /// Constructeur
  const CreditError(this.message);
  
  @override
  List<Object?> get props => [message];
} 