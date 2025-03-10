import '../../domain/entities/credit.dart';

/// Modèle de données pour les crédits, implémente l'entité [Credit]
class CreditModel extends Credit {
  /// Constructeur
  const CreditModel({
    required int amount,
    double conversionRate = 0.01,
  }) : super(
          amount: amount,
          conversionRate: conversionRate,
        );

  /// Crée un modèle à partir d'un objet JSON
  factory CreditModel.fromJson(Map<String, dynamic> json) {
    return CreditModel(
      amount: json['amount'] as int,
      conversionRate: (json['conversionRate'] as num?)?.toDouble() ?? 0.01,
    );
  }

  /// Convertit le modèle en objet JSON
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'conversionRate': conversionRate,
    };
  }

  /// Crée un modèle à partir d'une entité
  factory CreditModel.fromEntity(Credit credit) {
    return CreditModel(
      amount: credit.amount,
      conversionRate: credit.conversionRate,
    );
  }
} 