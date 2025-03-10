import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import 'home_screen.dart';
import '../widgets/google_logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedGender = 'Homme';
  bool _isRegistering = false;

  final List<String> _genders = ['Homme', 'Femme'];
  
  // Définition des couleurs de l'application
  static const Color roseColor = Color(0xFFE300BB);
  static const Color blueColor = Color(0xFFF3004E);
  static const Color greyColor = Color(0xFF888888);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() {
      _isRegistering = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        gender: _selectedGender,
      );

      setState(() {
        _isRegistering = false;
      });

      if (success && mounted) {
        // Inscription réussie, naviguer vers l'écran d'accueil ou profil
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else if (mounted) {
        // Afficher l'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error ?? 'Erreur d\'inscription')),
        );
      }
    } catch (e) {
      setState(() {
        _isRegistering = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Créer un compte',
          style: TextStyle(
            color: blueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: blueColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Créez votre profil',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nom complet',
                  labelStyle: const TextStyle(color: greyColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: blueColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: blueColor, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: greyColor.withOpacity(0.5)),
                  ),
                  prefixIcon: const Icon(Icons.person, color: blueColor),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: greyColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: blueColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: blueColor, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: greyColor.withOpacity(0.5)),
                  ),
                  prefixIcon: const Icon(Icons.email, color: blueColor),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  labelText: 'Genre',
                  labelStyle: const TextStyle(color: greyColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: blueColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: blueColor, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: greyColor.withOpacity(0.5)),
                  ),
                  prefixIcon: const Icon(Icons.people, color: blueColor),
                ),
                items: _genders.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
                dropdownColor: Colors.white,
                style: const TextStyle(color: blueColor, fontSize: 16),
                icon: const Icon(Icons.arrow_drop_down, color: blueColor),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  labelStyle: const TextStyle(color: greyColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: blueColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: blueColor, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: greyColor.withOpacity(0.5)),
                  ),
                  prefixIcon: const Icon(Icons.lock, color: blueColor),
                ),
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _register(),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isRegistering ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: blueColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 0),
                  elevation: 3,
                ),
                child: _isRegistering
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'S\'inscrire',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: blueColor,
                  side: const BorderSide(color: blueColor, width: 2.9),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 0),
                  backgroundColor: Colors.white,
                ),
                child: const Text(
                  'Retour',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Séparateur avec texte "ou"
              Row(
                children: [
                  const Expanded(child: Divider(color: greyColor, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'ou',
                      style: TextStyle(
                        color: greyColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: greyColor, thickness: 1)),
                ],
              ),
              const SizedBox(height: 20),
              // Boutons d'inscription avec réseaux sociaux
              Column(
                children: [
                  // Bouton Facebook
                  ElevatedButton.icon(
                    onPressed: () {
                      // Logique d'inscription Facebook à implémenter
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Inscription via Facebook à venir')),
                      );
                    },
                    icon: const Icon(Icons.facebook, size: 24),
                    label: const Text('Facebook'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1877F2), // Couleur Facebook
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(double.infinity, 0),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Bouton Google (officiel)
                  GoogleSignInButton(
                    onPressed: () {
                      // Logique d'inscription Google à implémenter
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Inscription via Google à venir')),
                      );
                    },
                    text: 'S\'inscrire avec Google',
                    height: 45,
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
} 