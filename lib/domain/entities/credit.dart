/// Représente les crédits d'un utilisateur dans le système
class Credit {
  /// Le montant de crédits
  final int amount;
  
  /// Taux de conversion des crédits en argent réel
  final double conversionRate;
  
  /// Constructeur de la classe Credit
  const Credit({
    required this.amount,
    this.conversionRate = 0.01, // Valeur par défaut: 1 crédit = 0.01$
  });
  
  /// Calcule la valeur monétaire des crédits
  double get monetaryValue => amount * conversionRate;
  
  /// Crée une nouvelle instance de Credit avec un montant mis à jour
  Credit copyWith({int? amount, double? conversionRate}) {
    return Credit(
      amount: amount ?? this.amount,
      conversionRate: conversionRate ?? this.conversionRate,
    );
  }
  
  @override
  String toString() => 'Credit(amount: $amount, conversionRate: $conversionRate)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Credit && 
           other.amount == amount && 
           other.conversionRate == conversionRate;
  }
  
  @override
  int get hashCode => amount.hashCode ^ conversionRate.hashCode;
} 