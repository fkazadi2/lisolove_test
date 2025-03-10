import '../entities/credit_package.dart';
import '../repositories/credit_repository.dart';

/// Cas d'utilisation pour récupérer la liste des packages de crédits disponibles
class GetCreditPackages {
  /// Repository utilisé pour accéder aux données
  final CreditRepository repository;

  /// Constructeur
  const GetCreditPackages(this.repository);

  /// Exécute le cas d'utilisation
  Future<List<CreditPackage>> execute() {
    return repository.getAvailableCreditPackages();
  }
} 