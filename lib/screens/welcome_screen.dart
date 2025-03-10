import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'dart:math' as math;

// Passage de StatelessWidget à StatefulWidget pour gérer les animations
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  // Définition des couleurs de l'application
  static const Color roseColor = Color(0xFFE300BB); // Remplacé par #E300BB
  static const Color blueColor = Color(0xFFF3004E); // Remplacé par #F3004E
  static const Color greyColor = Color(0xFF888888);
  
  // Contrôleur d'animation pour l'effet de flottement
  late AnimationController _floatingController;
  
  @override
  void initState() {
    super.initState();
    // Initialisation du contrôleur d'animation pour un effet continu
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Animation plus lente pour plus de fluidité
    )..repeat(); // Boucle unique sans aller-retour
  }
  
  @override
  void dispose() {
    // Nettoyage du contrôleur
    _floatingController.dispose();
    super.dispose();
  }
  
  // Widget pour créer un cœur flottant
  Widget _buildFloatingHeart({
    double? left,
    double? top,
    double? right,
    double? bottom,
    required double size,
    required double rotationAngle,
    required double floatFactor, // Facteur de flottement (amplitude)
    double floatOffset = 0.0, // Décalage pour désynchroniser les animations
  }) {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        // Calcul du mouvement de flottement avec effet sinusoïdal plus fluide
        final float = math.sin((_floatingController.value * math.pi * 2) + floatOffset) * floatFactor;
        
        return Positioned(
          left: left,
          top: top != null ? top + float : null,
          right: right,
          bottom: bottom != null ? bottom + float : null,
          child: Transform.rotate(
            angle: rotationAngle, // Rotation fixe, sans animation
            child: Icon(
              Icons.favorite_border_rounded,
              size: size,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calcul de la hauteur totale pour déterminer la position de l'icône cœur
    final screenHeight = MediaQuery.of(context).size.height;
    // On définit la position exacte du cercle pour qu'elle corresponde à la courbe
    final iconPosition = screenHeight * 0.45; // Position à 45% de la hauteur
    
    // Décalage vertical significativement augmenté pour descendre l'icône encore plus bas
    final verticalOffset = 40.0; 
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Fond avec dégradé et découpe courbe
          Positioned.fill(
            child: ClipPath(
              clipper: CurveClipper(),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    // Angle à environ 120 degrés (de supérieur droit vers inférieur gauche)
                    begin: const Alignment(0.8, -0.8), // Coin supérieur droit
                    end: const Alignment(-0.8, 0.8),   // Coin inférieur gauche
                    colors: [
                      roseColor.withOpacity(0.85), // Réduction de l'intensité du rose
                      blueColor,
                    ],
                    stops: const [0.0, 0.3], // Le rose s'arrête à 30% du dégradé
                  ),
                ),
              ),
            ),
          ),
          // Logo lisolove avec icône cœur - positionnement précis sur la courbe
          Positioned(
            top: iconPosition - 60 + verticalOffset, // Maintien de la position
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              child: Container(
                width: 120, // Taille augmentée à 120 comme demandé
                height: 120, // Taille augmentée à 120 comme demandé
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  size: 65, // Taille augmentée proportionnellement
                  color: blueColor,
                ),
              ),
            ),
          ),
          // Contenu principal
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'Flirtez, discutez et faites des rencontres inoubliables près de chez vous !',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Icônes cœur et images de profil
                    SizedBox(
                      height: 180,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Icônes cœur en arrière-plan avec effet de flottement
                          _buildFloatingHeart(
                            left: 40,
                            top: 0,
                            size: 50,
                            rotationAngle: 0.2,
                            floatFactor: 3.0, // Amplitude réduite pour plus de fluidité
                            floatOffset: 0.0,
                          ),
                          _buildFloatingHeart(
                            right: 30,
                            top: 60,
                            size: 60,
                            rotationAngle: -0.3,
                            floatFactor: 4.0, // Amplitude réduite
                            floatOffset: 2.0, // Décalage augmenté
                          ),
                          _buildFloatingHeart(
                            left: 60,
                            bottom: 15,
                            size: 40,
                            rotationAngle: 0.4,
                            floatFactor: 2.5, // Amplitude réduite
                            floatOffset: 4.0, // Décalage augmenté
                          ),
                          // Photos de profil superposées
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Photo de profil féminin
                              Positioned(
                                left: 95,
                                top: 35,
                                child: Container(
                                  width: 130,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(color: Colors.white, width: 4),
                                    image: const DecorationImage(
                                      image: NetworkImage('https://randomuser.me/api/portraits/women/43.jpg'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              // Photo de profil masculin
                              Positioned(
                                right: 95,
                                top: 50,
                                child: Container(
                                  width: 130,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(color: Colors.white, width: 4),
                                    image: const DecorationImage(
                                      image: NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Espace réservé pour l'icône cœur qui est maintenant positionnée avec Positioned
                    const SizedBox(height: 95), // Augmenté de 65 à 95 pour descendre le texte lisolove
                    const SizedBox(height: 15),
                    const Text(
                      'lisolove',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: blueColor,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Bouton Inscription
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        },
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
                        child: const Text(
                          'Inscription',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Bouton Connexion
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
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
                          'Connexion',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Conditions d'utilisation
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            color: greyColor,
                            fontSize: 12,
                          ),
                          children: [
                            const TextSpan(
                              text: 'En vous connectant, vous acceptez nos ',
                            ),
                            TextSpan(
                              text: 'conditions d\'utilisation',
                              style: const TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Clipper personnalisé pour créer la courbe
class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Hauteur de la courbe ajustée pour passer plus haut sur l'écran
    final curveHeight = size.height * 0.45; // Réduit à 45% au lieu de 50%
    
    // Commence en haut à gauche
    path.lineTo(0, curveHeight);
    
    // Crée une courbe encore moins prononcée
    final controlPoint = Offset(size.width * 0.5, size.height * 0.57); // Réduit à 57% au lieu de 65%
    final endPoint = Offset(size.width, curveHeight);
    
    // Utilise une courbe simple et harmonieuse, encore moins profonde
    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      endPoint.dx,
      endPoint.dy,
    );
    
    // Complète le chemin vers le haut et retour au début
    path.lineTo(size.width, 0);
    
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}