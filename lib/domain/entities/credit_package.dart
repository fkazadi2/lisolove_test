/// Représente un package de crédits disponible à l'achat
class CreditPackage {
  /// Identifiant unique du package
  final String id;
  
  /// Montant de crédits inclus dans le package
  final int creditAmount;
  
  /// Prix du package en monnaie réelle
  final double price;
  
  /// Devise utilisée pour le prix (ex: USD, EUR, etc.)
  final String currency;
  
  /// Description optionnelle du package
  final String? description;
  
  /// Indique si ce package a une promotion
  final bool isPromotion;
  
  /// Pourcentage de réduction si promotion
  final double? discountPercentage;
  
  /// Constructeur de la classe CreditPackage
  const CreditPackage({
    required this.id,
    required this.creditAmount,
    required this.price,
    this.currency = '\$',
    this.description,
    this.isPromotion = false,
    this.discountPercentage,
  });
  
  /// Calcule le prix par crédit
  double get pricePerCredit => price / creditAmount;
  
  /// Vérifie si ce package offre une meilleure valeur qu'un autre
  bool isBetterValueThan(CreditPackage other) {
    return pricePerCredit < other.pricePerCredit;
  }
  
  @override
  String toString() {
    return 'CreditPackage(id: $id, creditAmount: $creditAmount, price: $price, currency: $currency)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreditPackage &&
           other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
} 