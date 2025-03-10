import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // État de l'utilisateur actuel
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Inscription avec email et mot de passe
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String gender,
  }) async {
    try {
      // Créer l'utilisateur avec email et mot de passe
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Ajouter les informations utilisateur à Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'fullName': fullName,
        'email': email,
        'gender': gender,
        'createdAt': FieldValue.serverTimestamp(),
        'photoURL': '',
        'bio': '',
        'location': '',
        'interests': [],
      });

      // Mettre à jour le nom d'affichage de l'utilisateur
      await result.user!.updateDisplayName(fullName);

      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Connexion avec email et mot de passe
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Récupération du mot de passe
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Récupérer les données utilisateur depuis Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUser == null) return null;

    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Erreur lors de la récupération des données utilisateur: $e');
      return null;
    }
  }

  // Mettre à jour les informations du profil
  Future<void> updateProfile({
    String? fullName,
    String? photoURL,
    String? bio,
    String? location,
    List<String>? interests,
  }) async {
    if (currentUser == null) return;

    Map<String, dynamic> data = {};

    if (fullName != null) data['fullName'] = fullName;
    if (photoURL != null) data['photoURL'] = photoURL;
    if (bio != null) data['bio'] = bio;
    if (location != null) data['location'] = location;
    if (interests != null) data['interests'] = interests;

    await _firestore.collection('users').doc(currentUser!.uid).update(data);

    if (fullName != null) {
      await currentUser!.updateDisplayName(fullName);
    }

    if (photoURL != null) {
      await currentUser!.updatePhotoURL(photoURL);
    }
  }

  // Télécharger une image de profil
  Future<String?> uploadProfileImage(File imageFile) async {
    if (currentUser == null) return null;

    try {
      // Créer un nom de fichier unique avec l'extension
      final String fileName = '${currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      
      // Référence au fichier dans Firebase Storage
      final Reference storageRef = _storage.ref().child('profile_images/$fileName');
      
      // Télécharger le fichier
      final UploadTask uploadTask = storageRef.putFile(imageFile);
      
      // Attendre que le téléchargement soit terminé
      final TaskSnapshot taskSnapshot = await uploadTask;
      
      // Récupérer l'URL de téléchargement
      final String downloadURL = await taskSnapshot.ref.getDownloadURL();
      
      return downloadURL;
    } catch (e) {
      print('Erreur lors du téléchargement de l\'image: $e');
      return null;
    }
  }
}