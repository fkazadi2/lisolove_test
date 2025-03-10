/// Type de transaction de crédits
enum CreditTransactionType {
  /// Achat de crédits
  purchase,
  /// Utilisation de crédits (ex: boost, premium)
  usage,
  /// Conversion de crédits en argent réel
  conversion,
  /// Crédits reçus gratuitement (bonus, etc.)
  reward,
}

/// Représente une transaction de crédits dans le système
class CreditTransaction {
  /// Identifiant unique de la transaction
  final String id;
  
  /// Identifiant de l'utilisateur concerné
  final String userId;
  
  /// Type de transaction
  final CreditTransactionType type;
  
  /// Montant de crédits impliqués dans la transaction
  final int amount;
  
  /// Date et heure de la transaction
  final DateTime timestamp;
  
  /// Description de la transaction
  final String description;
  
  /// Montant en argent réel (pour achat ou conversion)
  final double? monetaryAmount;
  
  /// Devise utilisée (pour achat ou conversion)
  final String? currency;
  
  /// Constructeur de la classe CreditTransaction
  const CreditTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.timestamp,
    required this.description,
    this.monetaryAmount,
    this.currency,
  });
  
  /// Indique si la transaction ajoute des crédits
  bool get isCredit => type == CreditTransactionType.purchase || 
                       type == CreditTransactionType.reward;
  
  /// Indique si la transaction retire des crédits
  bool get isDebit => type == CreditTransactionType.usage || 
                      type == CreditTransactionType.conversion;
  
  @override
  String toString() {
    return 'CreditTransaction(id: $id, type: $type, amount: $amount, timestamp: $timestamp)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreditTransaction &&
           other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
} 