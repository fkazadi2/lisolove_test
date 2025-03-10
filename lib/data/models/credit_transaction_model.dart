import '../../domain/entities/credit_transaction.dart';

/// Modèle de données pour les transactions de crédits, implémente l'entité [CreditTransaction]
class CreditTransactionModel extends CreditTransaction {
  /// Constructeur
  const CreditTransactionModel({
    required String id,
    required String userId,
    required CreditTransactionType type,
    required int amount,
    required DateTime timestamp,
    required String description,
    double? monetaryAmount,
    String? currency,
  }) : super(
          id: id,
          userId: userId,
          type: type,
          amount: amount,
          timestamp: timestamp,
          description: description,
          monetaryAmount: monetaryAmount,
          currency: currency,
        );

  /// Crée un modèle à partir d'un objet JSON
  factory CreditTransactionModel.fromJson(Map<String, dynamic> json) {
    return CreditTransactionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: _parseTransactionType(json['type'] as String),
      amount: json['amount'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      description: json['description'] as String,
      monetaryAmount: (json['monetaryAmount'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
    );
  }

  /// Convertit le modèle en objet JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': _transactionTypeToString(type),
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'monetaryAmount': monetaryAmount,
      'currency': currency,
    };
  }

  /// Crée un modèle à partir d'une entité
  factory CreditTransactionModel.fromEntity(CreditTransaction transaction) {
    return CreditTransactionModel(
      id: transaction.id,
      userId: transaction.userId,
      type: transaction.type,
      amount: transaction.amount,
      timestamp: transaction.timestamp,
      description: transaction.description,
      monetaryAmount: transaction.monetaryAmount,
      currency: transaction.currency,
    );
  }

  /// Convertit une chaîne de caractères en type de transaction
  static CreditTransactionType _parseTransactionType(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'purchase':
        return CreditTransactionType.purchase;
      case 'usage':
        return CreditTransactionType.usage;
      case 'conversion':
        return CreditTransactionType.conversion;
      case 'reward':
        return CreditTransactionType.reward;
      default:
        throw ArgumentError('Type de transaction inconnu: $typeStr');
    }
  }

  /// Convertit un type de transaction en chaîne de caractères
  static String _transactionTypeToString(CreditTransactionType type) {
    switch (type) {
      case CreditTransactionType.purchase:
        return 'purchase';
      case CreditTransactionType.usage:
        return 'usage';
      case CreditTransactionType.conversion:
        return 'conversion';
      case CreditTransactionType.reward:
        return 'reward';
    }
  }
} 