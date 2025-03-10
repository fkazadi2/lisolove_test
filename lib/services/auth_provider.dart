import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  User? _user;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _userData;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      if (user != null) {
        _fetchUserData();
      } else {
        _userData = null;
      }
      notifyListeners();
    });
  }

  // Getters
  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get userData => _userData;

  // Inscription
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String gender,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        fullName: fullName,
        gender: gender,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = _handleAuthError(e);
      notifyListeners();
      return false;
    }
  }

  // Connexion
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = _handleAuthError(e);
      notifyListeners();
      return false;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await _authService.signOut();
  }

  // Réinitialisation du mot de passe
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = _handleAuthError(e);
      notifyListeners();
      return false;
    }
  }

  // Récupérer les données utilisateur
  Future<void> _fetchUserData() async {
    _userData = await _authService.getUserData();
    notifyListeners();
  }

  // Mettre à jour le profil
  Future<bool> updateProfile({
    String? fullName,
    String? photoURL,
    String? bio,
    String? location,
    List<String>? interests,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.updateProfile(
        fullName: fullName,
        photoURL: photoURL,
        bio: bio,
        location: location,
        interests: interests,
      );

      await _fetchUserData();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Télécharger et mettre à jour la photo de profil
  Future<bool> updateProfilePhoto(File imageFile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Télécharger l'image et récupérer l'URL
      final String? photoURL = await _authService.uploadProfileImage(imageFile);
      
      if (photoURL != null) {
        // Mettre à jour le profil avec la nouvelle URL
        await _authService.updateProfile(photoURL: photoURL);
        await _fetchUserData();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _error = "Impossible de télécharger l'image";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Traitement des erreurs d'authentification
  String _handleAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'Aucun utilisateur trouvé avec cet email.';
        case 'wrong-password':
          return 'Mot de passe incorrect.';
        case 'email-already-in-use':
          return 'Cet email est déjà utilisé par un autre compte.';
        case 'weak-password':
          return 'Le mot de passe est trop faible.';
        case 'invalid-email':
          return 'Format d\'email invalide.';
        default:
          return 'Erreur d\'authentification: ${e.message}';
      }
    }
    return e.toString();
  }
}