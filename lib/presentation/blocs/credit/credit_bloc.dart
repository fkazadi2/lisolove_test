import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/credit.dart';
import '../../../domain/usecases/convert_credits.dart' as domain;
import '../../../domain/usecases/get_credit_packages.dart';
import '../../../domain/usecases/get_user_credits.dart';
import '../../../domain/usecases/purchase_credits.dart' as domain;
import 'credit_event.dart';
import 'credit_state.dart';

/// BLoC pour la gestion des crédits
class CreditBloc extends Bloc<CreditEvent, CreditState> {
  /// Cas d'utilisation pour récupérer les crédits de l'utilisateur
  final GetUserCredits getUserCredits;
  
  /// Cas d'utilisation pour récupérer les packages de crédits
  final GetCreditPackages getCreditPackages;
  
  /// Cas d'utilisation pour acheter des crédits
  final domain.PurchaseCredits purchaseCredits;
  
  /// Cas d'utilisation pour convertir des crédits
  final domain.ConvertCredits convertCredits;
  
  /// Crédits actuels de l'utilisateur
  Credit? _currentCredits;
  
  /// Constructeur
  CreditBloc({
    required this.getUserCredits,
    required this.getCreditPackages,
    required this.purchaseCredits,
    required this.convertCredits,
  }) : super(CreditInitial()) {
    on<LoadUserCredits>(_onLoadUserCredits);
    on<LoadCreditPackages>(_onLoadCreditPackages);
    on<PurchaseCredits>(_onPurchaseCredits);
    on<ConvertCredits>(_onConvertCredits);
  }
  
  /// Gestionnaire pour l'événement [LoadUserCredits]
  Future<void> _onLoadUserCredits(
    LoadUserCredits event,
    Emitter<CreditState> emit,
  ) async {
    emit(CreditLoading());
    
    try {
      final credits = await getUserCredits.execute(event.userId);
      _currentCredits = credits;
      emit(CreditLoaded(credits));
    } on ServerFailure catch (failure) {
      emit(CreditError(failure.message));
    } on CacheFailure catch (failure) {
      emit(CreditError(failure.message));
    } catch (e) {
      emit(CreditError(e.toString()));
    }
  }
  
  /// Gestionnaire pour l'événement [LoadCreditPackages]
  Future<void> _onLoadCreditPackages(
    LoadCreditPackages event,
    Emitter<CreditState> emit,
  ) async {
    emit(CreditLoading());
    
    try {
      final packages = await getCreditPackages.execute();
      emit(CreditPackagesLoaded(packages));
    } on ServerFailure catch (failure) {
      emit(CreditError(failure.message));
    } on CacheFailure catch (failure) {
      emit(CreditError(failure.message));
    } catch (e) {
      emit(CreditError(e.toString()));
    }
  }
  
  /// Gestionnaire pour l'événement [PurchaseCredits]
  Future<void> _onPurchaseCredits(
    PurchaseCredits event,
    Emitter<CreditState> emit,
  ) async {
    // Vérifier si nous avons les crédits actuels
    if (_currentCredits == null) {
      try {
        _currentCredits = await getUserCredits.execute(event.userId);
      } catch (e) {
        emit(CreditError('Impossible de récupérer les crédits actuels: ${e.toString()}'));
        return;
      }
    }
    
    // Émettre l'état d'achat en cours
    emit(CreditPurchasing(_currentCredits!));
    
    try {
      // Effectuer l'achat
      final success = await purchaseCredits.execute(event.userId, event.packageId);
      
      if (success) {
        // Récupérer les nouveaux crédits
        final newCredits = await getUserCredits.execute(event.userId);
        _currentCredits = newCredits;
        emit(CreditPurchaseSuccess(newCredits));
      } else {
        emit(CreditPurchaseFailure(_currentCredits!, 'L\'achat a échoué sans raison spécifique'));
      }
    } on ServerFailure catch (failure) {
      emit(CreditPurchaseFailure(_currentCredits!, failure.message));
    } on CacheFailure catch (failure) {
      emit(CreditPurchaseFailure(_currentCredits!, failure.message));
    } on InsufficientCreditsFailure catch (failure) {
      emit(CreditPurchaseFailure(_currentCredits!, failure.toString()));
    } on CreditOperationFailure catch (failure) {
      emit(CreditPurchaseFailure(_currentCredits!, failure.message));
    } catch (e) {
      emit(CreditPurchaseFailure(_currentCredits!, e.toString()));
    }
  }
  
  /// Gestionnaire pour l'événement [ConvertCredits]
  Future<void> _onConvertCredits(
    ConvertCredits event,
    Emitter<CreditState> emit,
  ) async {
    // Vérifier si nous avons les crédits actuels
    if (_currentCredits == null) {
      try {
        _currentCredits = await getUserCredits.execute(event.userId);
      } catch (e) {
        emit(CreditError('Impossible de récupérer les crédits actuels: ${e.toString()}'));
        return;
      }
    }
    
    // Vérifier si l'utilisateur a suffisamment de crédits
    if (_currentCredits!.amount < event.amount) {
      emit(CreditConversionFailure(
        _currentCredits!,
        'Solde insuffisant (disponible: ${_currentCredits!.amount}, requis: ${event.amount})',
      ));
      return;
    }
    
    // Émettre l'état de conversion en cours
    emit(CreditConverting(_currentCredits!, event.amount, event.phoneNumber));
    
    try {
      // Effectuer la conversion
      final success = await convertCredits.execute(
        event.userId, 
        event.amount, 
        event.phoneNumber,
      );
      
      if (success) {
        // Récupérer les nouveaux crédits
        final newCredits = await getUserCredits.execute(event.userId);
        _currentCredits = newCredits;
        
        // Calculer la valeur monétaire convertie
        final monetaryValue = event.amount * _currentCredits!.conversionRate;
        
        emit(CreditConversionSuccess(newCredits, event.amount, monetaryValue));
      } else {
        emit(CreditConversionFailure(_currentCredits!, 'La conversion a échoué sans raison spécifique'));
      }
    } on ServerFailure catch (failure) {
      emit(CreditConversionFailure(_currentCredits!, failure.message));
    } on CacheFailure catch (failure) {
      emit(CreditConversionFailure(_currentCredits!, failure.message));
    } on InsufficientCreditsFailure catch (failure) {
      emit(CreditConversionFailure(_currentCredits!, failure.toString()));
    } on CreditOperationFailure catch (failure) {
      emit(CreditConversionFailure(_currentCredits!, failure.message));
    } catch (e) {
      emit(CreditConversionFailure(_currentCredits!, e.toString()));
    }
  }
} 