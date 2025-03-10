import '../../domain/entities/credit_package.dart';

/// Modèle de données pour les packages de crédits, implémente l'entité [CreditPackage]
class CreditPackageModel extends CreditPackage {
  /// Constructeur
  const CreditPackageModel({
    required String id,
    required int creditAmount,
    required double price,
    String currency = '\$',
    String? description,
    bool isPromotion = false,
    double? discountPercentage,
  }) : super(
          id: id,
          creditAmount: creditAmount,
          price: price,
          currency: currency,
          description: description,
          isPromotion: isPromotion,
          discountPercentage: discountPercentage,
        );

  /// Crée un modèle à partir d'un objet JSON
  factory CreditPackageModel.fromJson(Map<String, dynamic> json) {
    return CreditPackageModel(
      id: json['id'] as String,
      creditAmount: json['creditAmount'] as int,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? '\$',
      description: json['description'] as String?,
      isPromotion: json['isPromotion'] as bool? ?? false,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
    );
  }

  /// Convertit le modèle en objet JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creditAmount': creditAmount,
      'price': price,
      'currency': currency,
      'description': description,
      'isPromotion': isPromotion,
      'discountPercentage': discountPercentage,
    };
  }

  /// Crée un modèle à partir d'une entité
  factory CreditPackageModel.fromEntity(CreditPackage package) {
    return CreditPackageModel(
      id: package.id,
      creditAmount: package.creditAmount,
      price: package.price,
      currency: package.currency,
      description: package.description,
      isPromotion: package.isPromotion,
      discountPercentage: package.discountPercentage,
    );
  }
} 