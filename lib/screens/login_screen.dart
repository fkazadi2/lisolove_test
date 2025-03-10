import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import 'home_screen.dart';
import '../widgets/google_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoggingIn = false;

  // Définition des couleurs de l'application
  static const Color roseColor = Color(0xFFE300BB);
  static const Color blueColor = Color(0xFFF3004E);
  static const Color greyColor = Color(0xFF888888);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() {
      _isLoggingIn = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      setState(() {
        _isLoggingIn = false;
      });

      if (success && mounted) {
        // Connexion réussie, naviguer vers l'écran d'accueil
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else if (mounted) {
        // Afficher l'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error ?? 'Erreur de connexion')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoggingIn = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer votre email pour réinitialiser votre mot de passe'),
        ),
      );
      return;
    }

    setState(() {
      _isLoggingIn = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.resetPassword(_emailController.text.trim());

      setState(() {
        _isLoggingIn = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Un lien de réinitialisation a été envoyé à votre email'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoggingIn = false;
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
          'Connexion',
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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bon retour parmi nous!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 30),
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
                  onSubmitted: (_) => _login(),
                ),
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoggingIn ? null : _resetPassword,
                    child: const Text(
                      'Mot de passe oublié?',
                      style: TextStyle(
                        color: blueColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isLoggingIn ? null : _login,
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
                  child: _isLoggingIn
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Se connecter',
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
                // Boutons de connexion avec réseaux sociaux
                Column(
                  children: [
                    // Bouton Facebook
                    ElevatedButton.icon(
                      onPressed: () {
                        // Logique de connexion Facebook à implémenter
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Connexion Facebook à venir')),
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
                        // Logique de connexion Google à implémenter
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Connexion Google à venir')),
                        );
                      },
                      text: 'Se connecter avec Google',
                      height: 45,
                    ),
                  ],
                ),
                // Espace supplémentaire pour éviter que le contenu ne soit caché par le clavier
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 