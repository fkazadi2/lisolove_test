import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/auth_provider.dart';
import 'welcome_screen.dart';
import 'discover_screen.dart';
import 'trends_screen.dart';
import 'notifications_screen.dart';
import 'messages_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Définition des couleurs de l'application
  static const Color roseColor = Color(0xFFF3004E); // Rose vif comme sur l'image
  static const Color greyColor = Color(0xFF888888);
  static const Color lightGreyColor = Color(0xFFF5F5F5);
  
  // Simuler le solde de crédits de l'utilisateur
  int _userCredits = 500;
  
  // Niveau de popularité (0-100)
  int _popularityLevel = 20;
  
  // Boost actif ou non
  bool _hasActiveBoost = false;
  // Durée du boost actif en heures
  int _boostRemainingHours = 0;
  
  // Premium actif ou non
  bool _hasPremium = false;
  // Type de premium actif (bronze, silver, gold)
  String _premiumType = '';
  
  // Profil vérifié ou non
  bool _isProfileVerified = false;
  
  // Taux de conversion des crédits en argent
  final double _conversionRate = 0.01; // 1 crédit = 0.01$ ou FC
  final String _currency = '\$'; // ou 'FC' pour francs congolais

  // Obtenir la représentation textuelle du niveau de popularité
  String get _popularityText {
    if (_popularityLevel < 25) return 'Faible';
    if (_popularityLevel < 50) return 'Moyen';
    if (_popularityLevel < 75) return 'Bon';
    return 'Excellent';
  }
  
  // Obtenir l'icône correspondant au niveau de popularité
  IconData get _popularityIcon {
    if (_popularityLevel < 25) return Icons.battery_0_bar;
    if (_popularityLevel < 50) return Icons.battery_2_bar;
    if (_popularityLevel < 75) return Icons.battery_3_bar;
    return Icons.battery_full;
  }
  
  // Obtenir la couleur correspondant au niveau de popularité
  Color get _popularityColor {
    if (_popularityLevel < 25) return Colors.red;
    if (_popularityLevel < 50) return Colors.orange;
    if (_popularityLevel < 75) return Colors.yellow;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final userData = authProvider.userData;
    
    // Nom d'utilisateur par défaut
    final userName = user?.displayName ?? 'Patrick';
    // Extraction du prénom (premier mot)
    final firstName = userName.split(' ')[0];
    // Âge par défaut (si non spécifié)
    final userAge = userData?['age'] ?? '22';

    return Scaffold(
      backgroundColor: Colors.white,
      body: authProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: roseColor))
          : Stack(
              children: [
                // Contenu principal fixe (sans défilement)
                Column(
                  children: [
                    // Partie supérieure avec fond rose et courbe
                    Expanded(
                      flex: 5, // 50% de l'écran pour la partie supérieure
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Fond rose avec courbe
                          ClipPath(
                            clipper: ProfileCurveClipper(),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: double.infinity,
                              color: roseColor,
                            ),
                          ),
                          
                          // En-tête et photo de profil
                          Column(
                            children: [
                              // AppBar personnalisée
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 40, 16, 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.settings, color: Colors.white, size: 30),
                                      onPressed: () {
                                        // Action pour les paramètres
                                        Navigator.pushNamed(context, '/settings');
                                      },
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.favorite, color: Colors.white, size: 30),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'lisolove',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 28,
                                          ),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.white, size: 30),
                                      onPressed: () {
                                        // Action pour modifier le profil
                                        Navigator.pushNamed(context, '/edit_profile');
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Espace sous la photo avant le texte
                              SizedBox(height: 20),
                              
                              // Photo de profil (positionnée plus haut)
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    width: 160, // Réduit légèrement la taille
                                    height: 160, // Réduit légèrement la taille
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 4),
                                      color: lightGreyColor,
                                    ),
                                    child: userData != null && userData['photoURL'] != null && userData['photoURL'].toString().startsWith('http')
                                        ? ClipOval(
                                            child: Image.network(
                                              userData['photoURL'],
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                // Afficher l'icône par défaut en cas d'erreur de chargement
                                                return const Icon(
                                                  Icons.person,
                                                  size: 110, // Ajusté pour la nouvelle taille
                                                  color: greyColor,
                                                );
                                              },
                                            ),
                                          )
                                        : const Icon(
                                            Icons.person,
                                            size: 110, // Ajusté pour la nouvelle taille
                                            color: greyColor,
                                          ),
                                  ),
                                  
                                  // Bouton d'ajout de photo
                                  GestureDetector(
                                    onTap: () {
                                      _showImagePickerOptions(context, authProvider);
                                    },
                                    child: Container(
                                      width: 45,
                                      height: 45,
                                      decoration: const BoxDecoration(
                                        color: roseColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add_a_photo,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 20), // Espace après la photo
                              
                              // Nom, âge et badge de vérification
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.8, // Limite la largeur
                                ),
                                child: Column(
                                  children: [
                                    // Nom et âge avec ellipsis pour éviter le dépassement
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            '$firstName, $userAge ans',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 24, // Réduit encore la taille
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF4A4A4A),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (_isProfileVerified)
                                          Container(
                                            margin: EdgeInsets.only(left: 4),
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Icon(Icons.verified, color: Colors.white, size: 12),
                                          ),
                                      ],
                                    ),
                                    
                                    SizedBox(height: 8),
                                    
                                    // Bouton aperçu du profil
                                    ElevatedButton(
                                      onPressed: () {
                                        _showProfilePreview();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: roseColor,
                                        side: BorderSide(color: roseColor, width: 1.5), // Bordure plus fine
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.remove_red_eye, color: roseColor, size: 14),
                                          SizedBox(width: 4),
                                          Flexible(
                                            child: Text('Aperçu du profil', 
                                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Espace en bas de la photo
                              const Spacer(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Partie inférieure (contenu sous la courbe)
                    Expanded(
                      flex: 5, // 50% de l'écran pour la partie inférieure
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
                            // Espace pour compenser le positionnement du nom avec la photo plus grande
                            const SizedBox(height: 20),
                            
                            // Statistiques (3 carrés)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatCard(
                                  icon: _popularityIcon,
                                  value: _popularityText,
                                  label: 'Popularité',
                                  iconColor: _popularityColor,
                                  onTap: () {
                                    // Afficher la boîte de dialogue des boosts
                                    _showPopularityBoostDialog();
                                  },
                                  showBadge: _hasActiveBoost,
                                  badgeText: '$_boostRemainingHours h',
                                  isActive: _hasActiveBoost,
                                ),
                                _buildStatCard(
                                  icon: Icons.attach_money,
                                  value: '$_userCredits',
                                  label: 'Vos crédits',
                                  iconColor: Colors.amber,
                                  onTap: () {
                                    // Ouvrir le menu des crédits
                                    _showCreditsOptionsDialog();
                                  },
                                  isActive: _userCredits > 0,
                                ),
                                _buildStatCard(
                                  icon: Icons.diamond,
                                  value: _hasPremium ? _premiumType : 'Activer',
                                  label: 'Premium',
                                  iconColor: _getPremiumColor(),
                                  onTap: () {
                                    // Action pour premium
                                    _showPremiumDialog();
                                  },
                                  isActive: _hasPremium,
                                ),
                              ],
                            ),
                            
                            const Spacer(),
                            
                            // Bouton "Vérifie ton profil"
                            if (!_isProfileVerified)
                              ElevatedButton(
                                onPressed: () {
                                  // Action pour vérifier le profil
                                  _startProfileVerification();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: roseColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  minimumSize: const Size(double.infinity, 0),
                                  elevation: 3,
                                ),
                                child: const Text(
                                  'Vérifie ton profil',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            
                            const SizedBox(height: 10),
                            
                            // Texte explicatif (version plus courte)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                'Un compte vérifié prouve que vous êtes une personne réelle.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: greyColor,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            
                            const Spacer(),
                            
                            // Bouton "Inviter des amis"
                            TextButton(
                              onPressed: () {
                                // Action pour inviter des amis
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: roseColor,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              child: const Text(
                                'Inviter des amis',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Barre de navigation en bas
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: lightGreyColor,
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavBarItem(icon: Icons.explore_outlined, isSelected: false, route: '/discover'),
                        _buildNavBarItem(icon: Icons.whatshot, isSelected: false, route: '/trends'),
                        _buildNavBarItem(icon: Icons.notifications_outlined, isSelected: false, route: '/notifications'),
                        _buildNavBarItem(icon: Icons.forum_outlined, isSelected: false, route: '/messages'),
                        _buildNavBarItem(icon: Icons.person_outline, isSelected: true, route: '/home'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // Méthode pour construire un élément de barre de navigation
  Widget _buildNavBarItem({
    required IconData icon, 
    required bool isSelected,
    required String route,
  }) {
    String label = '';
    
    // Déterminer l'étiquette en fonction de l'icône
    switch (icon) {
      case Icons.explore_outlined:
        label = 'Explorer';
        break;
      case Icons.whatshot:
        label = 'Tendances';
        break;
      case Icons.notifications_outlined:
        label = 'Alertes';
        break;
      case Icons.forum_outlined:
        label = 'Messages';
        break;
      case Icons.person_outline:
        label = 'Profil';
        break;
    }
    
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: roseColor.withOpacity(0.1),
          highlightColor: roseColor.withOpacity(0.05),
          onTap: () {
            if (!isSelected) {
              // Utiliser une route sans transition
              final Widget destinationScreen;
              switch (route) {
                case '/discover':
                  destinationScreen = const DiscoverScreen();
                  break;
                case '/trends':
                  destinationScreen = const TrendsScreen();
                  break;
                case '/notifications':
                  destinationScreen = const NotificationsScreen();
                  break;
                case '/messages':
                  destinationScreen = const MessagesScreen();
                  break;
                case '/home':
                  destinationScreen = const HomeScreen();
                  break;
                default:
                  return;
              }
              
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => destinationScreen,
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? roseColor : greyColor,
                  size: 26,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? roseColor : greyColor,
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Méthode pour construire une carte de statistique
  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
    bool showBadge = false,
    String badgeText = '',
    bool isActive = false,
  }) {
    // Couleur de l'icône : grise si inactive, couleur spécifiée si active
    final Color displayedIconColor = isActive ? iconColor : greyColor;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 90, // Réduit la largeur
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6), // Réduit le padding
        decoration: BoxDecoration(
          color: lightGreyColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: greyColor.withOpacity(0.5), width: 1), // Ajoute un contour gris fin
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Indicateur de niveau avec icône
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 22, color: displayedIconColor), // Réduit la taille de l'icône
                  ],
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 20, // Taille maximale de la police
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A4A4A),
                    ),
                    maxLines: 1, // Limite à une ligne
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 10, // Taille maximale de la police
                      color: greyColor,
                    ),
                    maxLines: 1, // Limite à une ligne
                  ),
                ),
              ],
            ),
            // Badge pour indiquer un boost actif
            if (showBadge)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: roseColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // Afficher les options de crédits (acheter ou convertir)
  void _showCreditsOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Vos crédits: $_userCredits'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Que souhaitez-vous faire avec vos crédits ?',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showBuyCreditsDialog();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Acheter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: roseColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _userCredits >= 100 ? () {
                          Navigator.pop(context);
                          _showConvertCreditsDialog();
                        } : null,
                        icon: const Icon(Icons.currency_exchange),
                        label: const Text('Convertir'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Minimum de 100 crédits pour la conversion',
                  style: TextStyle(
                    fontSize: 12,
                    color: greyColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Fermer',
                style: TextStyle(color: greyColor),
              ),
            ),
          ],
        );
      },
    );
  }
  
  // Afficher la boîte de dialogue d'achat de crédits
  void _showBuyCreditsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Acheter des crédits'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sélectionnez un montant de crédits à acheter',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _buildCreditPackage(100, 1),
                const SizedBox(height: 8),
                _buildCreditPackage(500, 4.5),
                const SizedBox(height: 8),
                _buildCreditPackage(1000, 8),
                const SizedBox(height: 16),
                const Text(
                  'Les crédits peuvent être utilisés pour envoyer des cadeaux ou être convertis en argent réel.',
                  style: TextStyle(
                    fontSize: 12,
                    color: greyColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Annuler',
                style: TextStyle(color: greyColor),
              ),
            ),
          ],
        );
      },
    );
  }
  
  // Construire un package de crédits
  Widget _buildCreditPackage(int amount, double price) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        
        // Simuler l'achat réussi
        setState(() {
          _userCredits += amount;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Achat de $amount crédits réussi !'),
            backgroundColor: Colors.green,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: roseColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.monetization_on, color: Colors.amber, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$amount crédits',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$_currency$price',
                    style: const TextStyle(
                      color: greyColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
  
  // Afficher la boîte de dialogue de conversion de crédits
  void _showConvertCreditsDialog() {
    // Définir les options de conversion disponibles
    final List<int> conversionOptions = [100, 500, 1000];
    
    // Filtrer en fonction des crédits disponibles
    final List<int> availableOptions = conversionOptions
        .where((amount) => amount <= _userCredits)
        .toList();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Convertir des crédits en argent'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choisissez le montant de crédits à convertir:',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ...availableOptions.map((amount) {
                  final double moneyValue = amount * _conversionRate;
                  return _buildConversionOption(amount, moneyValue);
                }).toList(),
                const SizedBox(height: 16),
                const Text(
                  'La conversion sera effectuée dans les 48h ouvrables',
                style: TextStyle(
                    fontSize: 12,
                    color: greyColor,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Annuler',
                style: TextStyle(color: greyColor),
              ),
            ),
          ],
        );
      },
    );
  }
  
  // Construire une option de conversion
  Widget _buildConversionOption(int credits, double moneyValue) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _confirmConversion(credits, moneyValue);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green),
          borderRadius: BorderRadius.circular(8),
          color: Colors.green.withOpacity(0.1),
        ),
        child: Row(
          children: [
            const Icon(Icons.currency_exchange, color: Colors.green, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '$credits crédits → $_currency${moneyValue.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Confirmer la conversion
  void _confirmConversion(int credits, double moneyValue) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Contrôleur pour le numéro mobile money
        final TextEditingController phoneController = TextEditingController();
        
        return AlertDialog(
          title: const Text('Confirmer la conversion'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Vous allez convertir $credits crédits en $_currency${moneyValue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Numéro Mobile Money',
                    hintText: '+243 XXX XXX XXX',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Veuillez entrer un numéro valide pour recevoir votre paiement.',
                  style: TextStyle(
                    fontSize: 12,
                    color: greyColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Annuler',
                style: TextStyle(color: greyColor),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                
                // Vérifier si le champ est rempli
                if (phoneController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez entrer un numéro de téléphone valide'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                // Simuler la conversion réussie
                setState(() {
                  _userCredits -= credits;
                });
                
                // Afficher une confirmation
                _showConversionConfirmation(credits, moneyValue, phoneController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }
  
  // Afficher la confirmation de conversion
  void _showConversionConfirmation(int credits, double moneyValue, String phoneNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conversion en cours'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Votre demande de conversion de $credits crédits en $_currency${moneyValue.toStringAsFixed(2)} a été soumise avec succès.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Le paiement sera envoyé au numéro $phoneNumber dans les 48 heures ouvrables.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: greyColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: roseColor,
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Afficher les options pour choisir une image
  void _showImagePickerOptions(BuildContext context, AuthProvider authProvider) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie photo'),
                onTap: () {
                  _pickImage(ImageSource.gallery, authProvider);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Appareil photo'),
                onTap: () {
                  _pickImage(ImageSource.camera, authProvider);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Sélectionner et télécharger une image
  Future<void> _pickImage(ImageSource source, AuthProvider authProvider) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        // Afficher un indicateur de chargement
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: roseColor),
                  SizedBox(height: 16),
                  Text('Téléchargement en cours...')
                ],
              ),
            );
          },
        );
        
        // Télécharger l'image
        final File imageFile = File(image.path);
        final bool success = await authProvider.updateProfilePhoto(imageFile);
        
        // Fermer le dialogue de chargement
        Navigator.of(context).pop();
        
        // Afficher un message de succès ou d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Photo de profil mise à jour avec succès' : 'Erreur lors de la mise à jour de la photo',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Afficher la boîte de dialogue des boosts de popularité
  void _showPopularityBoostDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_popularityIcon, color: _popularityColor),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  'Améliore ta visibilité',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Afficher l'état actuel de la popularité
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: lightGreyColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(_popularityIcon, color: _popularityColor, size: 30),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Niveau: $_popularityText',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: _popularityLevel / 100,
                                backgroundColor: Colors.grey.withOpacity(0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(_popularityColor),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Afficher le boost actif s'il y en a un
                  if (_hasActiveBoost)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: roseColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: roseColor),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Boost Actif',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: roseColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Temps restant: $_boostRemainingHours heures',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Texte explicatif
                  const Text(
                    'Choisis une option pour augmenter ta visibilité',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  
                  // Nouvelles options de visibilité basées sur l'image
                  _buildPopularityOption(
                    icon: Icons.photo,
                    title: 'Mets en avant ta photo de profil',
                    credits: 25,
                    buttonText: 'Obtiens 5 x plus de visites',
                    buttonColor: Colors.teal,
                    onTap: () => _purchaseVisibilityBoost('photo', 25, 24),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildPopularityOption(
                    icon: Icons.people,
                    title: 'Apparais plusieurs fois dans la section rencontres',
                    credits: 30,
                    buttonText: 'Obtiens 3 x plus de matches',
                    buttonColor: Colors.orange,
                    onTap: () => _purchaseVisibilityBoost('rencontres', 30, 24),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildPopularityOption(
                    icon: Icons.circle,
                    title: 'Fais savoir à tout le monde que tu es en ligne',
                    credits: 35,
                    buttonText: 'Obtiens 4 x plus de messages',
                    buttonColor: Colors.purple,
                    onTap: () => _purchaseVisibilityBoost('online', 35, 24),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Fermer',
                style: TextStyle(color: greyColor),
              ),
            ),
          ],
        );
      },
    );
  }
  
  // Construire une option de popularité
  Widget _buildPopularityOption({
    required IconData icon,
    required String title,
    required int credits,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onTap,
  }) {
    final bool canAfford = _userCredits >= credits;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec icône et crédits
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  radius: 24,
                  child: Icon(icon, color: Colors.grey.shade700, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '$credits Crédits',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Bouton d'action
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canAfford ? onTap : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canAfford ? buttonColor : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Acheter un boost de visibilité
  void _purchaseVisibilityBoost(String type, int price, int duration) {
    if (_userCredits < price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Crédits insuffisants pour acheter ce boost'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Traduction du type pour l'affichage
    String boostName = '';
    String benefit = '';
    
    switch (type) {
      case 'photo':
        boostName = 'Mise en avant de photo';
        benefit = '5x plus de visites';
        break;
      case 'rencontres':
        boostName = 'Apparition multiple';
        benefit = '3x plus de matches';
        break;
      case 'online':
        boostName = 'Statut en ligne';
        benefit = '4x plus de messages';
        break;
    }
    
    // Fermer la boîte de dialogue actuelle
    Navigator.of(context).pop();
    
    // Simuler l'achat réussi
    setState(() {
      // Déduire les crédits
      _userCredits -= price;
      
      // Activer le boost
      _hasActiveBoost = true;
      _boostRemainingHours = duration;
      
      // Augmenter la popularité
      _popularityLevel = _calculateNewPopularityLevel(_popularityLevel, type);
    });
    
    // Afficher une confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Boost "$boostName" activé pour $benefit !'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  // Calculer le nouveau niveau de popularité en fonction du boost
  int _calculateNewPopularityLevel(int currentLevel, String boostType) {
    int increase = 0;
    
    switch (boostType) {
      case 'Basic':
        increase = 20;
        break;
      case 'Plus':
        increase = 35;
        break;
      case 'Premium':
        increase = 50;
        break;
      case 'Ultimate':
        increase = 80;
        break;
    }
    
    // Calculer le nouveau niveau, ne pas dépasser 100
    int newLevel = currentLevel + increase;
    return newLevel > 100 ? 100 : newLevel;
  }

  // Afficher la boîte de dialogue d'activation du Premium
  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.diamond, color: Colors.purple),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Deviens membre Premium',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Texte explicatif
                const Text(
                  'Profite des avantages exclusifs réservés aux membres Premium',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                
                // Options d'abonnement Premium
                _buildPremiumOption(
                  title: 'Premium Bronze',
                  duration: '1 mois',
                  price: 200,
                  features: [
                    'Voir qui t\'a liké',
                    'Mode incognito',
                    'Messages illimités',
                  ],
                  color: Colors.brown,
                  onTap: () => _purchasePremium('bronze', 200, 30),
                ),
                
                const SizedBox(height: 16),
                
                _buildPremiumOption(
                  title: 'Premium Argent',
                  duration: '3 mois',
                  price: 500,
                  features: [
                    'Voir qui t\'a liké',
                    'Mode incognito',
                    'Messages illimités',
                    'Priorité dans les recherches',
                    '10% de remise sur les boosts',
                  ],
                  color: Colors.blueGrey,
                  bestValue: true,
                  onTap: () => _purchasePremium('silver', 500, 90),
                ),
                
                const SizedBox(height: 16),
                
                _buildPremiumOption(
                  title: 'Premium Or',
                  duration: '6 mois',
                  price: 800,
                  features: [
                    'Voir qui t\'a liké',
                    'Mode incognito',
                    'Messages illimités',
                    'Priorité dans les recherches',
                    '20% de remise sur les boosts',
                    'Filtres de recherche avancés',
                    'Support prioritaire',
                  ],
                  color: Colors.amber,
                  onTap: () => _purchasePremium('gold', 800, 180),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Logique pour afficher l'aperçu du profil
                    _showProfilePreview();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Aperçu du profil'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Fermer',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }
  
  // Méthode pour afficher l'aperçu du profil
  void _showProfilePreview() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Aperçu du Profil'),
          content: Text('Voici un aperçu de votre profil.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
  
  // Construire une option Premium
  Widget _buildPremiumOption({
    required String title,
    required String duration,
    required int price,
    required List<String> features,
    required Color color,
    bool bestValue = false,
    required VoidCallback onTap,
  }) {
    final bool canAfford = _userCredits >= price;
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: bestValue ? Colors.purple : Colors.transparent,
              width: bestValue ? 2 : 0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec titre et prix
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: color,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            '$price crédits',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      duration,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Liste des fonctionnalités
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: color,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ),
              
              // Bouton d'activation
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canAfford ? onTap : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAfford ? color : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Activer maintenant',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Badge "Meilleure offre"
        if (bestValue)
          Positioned(
            top: -10,
            right: -10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Meilleure offre',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  // Acheter un abonnement Premium
  void _purchasePremium(String type, int price, int durationDays) {
    if (_userCredits < price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Crédits insuffisants pour acheter cet abonnement'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Traduction du type pour l'affichage
    String premiumName = '';
    String durationText = '';
    
    switch (type) {
      case 'bronze':
        premiumName = 'Bronze';
        durationText = '1 mois';
        break;
      case 'silver':
        premiumName = 'Argent';
        durationText = '3 mois';
        break;
      case 'gold':
        premiumName = 'Or';
        durationText = '6 mois';
        break;
    }
    
    // Fermer la boîte de dialogue actuelle
    Navigator.of(context).pop();
    
    // Simuler l'achat réussi
    setState(() {
      // Déduire les crédits
      _userCredits -= price;
      
      // Activer le premium
      _hasPremium = true;
      _premiumType = premiumName;
    });
    
    // Afficher une confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abonnement Premium $premiumName activé pour $durationText !'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Obtenir la couleur pour l'icône premium en fonction du type
  Color _getPremiumColor() {
    switch (_premiumType.toLowerCase()) {
      case 'bronze':
        return Colors.brown;
      case 'argent':
        return Colors.blueGrey;
      case 'or':
        return Colors.amber;
      default:
        return Colors.purple;
    }
  }

  // Démarrer le processus de vérification de profil
  void _startProfileVerification() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_user, color: roseColor),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Vérification de profil',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'La vérification de profil améliore votre visibilité et votre crédibilité auprès des autres utilisateurs.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                
                // Instructions de vérification
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: lightGreyColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      _buildVerificationStep(
                        icon: Icons.photo_camera,
                        title: 'Prendre un selfie',
                        description: 'Nous allons vous demander de prendre un selfie pour confirmer votre identité.',
                      ),
                      Divider(height: 24),
                      _buildVerificationStep(
                        icon: Icons.check_circle_outline,
                        title: 'Revue',
                        description: 'Notre équipe vérifiera votre selfie dans les 24h.',
                      ),
                      Divider(height: 24),
                      _buildVerificationStep(
                        icon: Icons.verified,
                        title: 'Badge vérifié',
                        description: 'Une fois approuvé, vous recevrez un badge vérifié sur votre profil.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Annuler',
                style: TextStyle(color: greyColor),
              ),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text('Commencer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: roseColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                _takeVerificationSelfie();
              },
            ),
          ],
        );
      },
    );
  }
  
  // Construire une étape de vérification
  Widget _buildVerificationStep({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: roseColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: roseColor, size: 22),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: greyColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Prendre un selfie pour la vérification
  void _takeVerificationSelfie() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );
      
      if (image != null) {
        // Simuler le téléchargement
        _showVerificationInProgressDialog();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Afficher la progression de la vérification
  void _showVerificationInProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Téléchargement en cours'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: roseColor),
              SizedBox(height: 16),
              Text('Nous traitons votre selfie...'),
            ],
          ),
        );
      },
    );
    
    // Simuler un temps de traitement
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pop(context); // Fermer le dialogue de progression
      _showVerificationSuccessDialog();
    });
  }
  
  // Afficher le dialogue de succès
  void _showVerificationSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Selfie reçu avec succès !'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                'Votre selfie a été reçu avec succès. Notre équipe va maintenant vérifier votre identité.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'Vous recevrez une notification dès que la vérification sera terminée (généralement sous 24h).',
                style: TextStyle(
                  fontSize: 12,
                  color: greyColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                
                // Simuler la vérification après quelques secondes (pour la démo)
                _simulateProfileVerification();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: roseColor,
              ),
              child: Text('Compris'),
            ),
          ],
        );
      },
    );
  }
  
  // Simuler la vérification du profil
  void _simulateProfileVerification() {
    // Dans une application réelle, cela serait fait par le backend
    Future.delayed(Duration(seconds: 5), () {
      // Simuler une notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.verified, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('Votre profil a été vérifié avec succès !'),
              ),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 4),
          action: SnackBarAction(
            label: 'VOIR',
            textColor: Colors.white,
            onPressed: () {
              // Mettre à jour l'état pour afficher le badge
              setState(() {
                _isProfileVerified = true;
              });
            },
          ),
        ),
      );
      
      // Mettre à jour l'état pour afficher le badge
      setState(() {
        _isProfileVerified = true;
      });
    });
  }
}

/// Clipper personnalisé pour créer la courbe qui traverse la photo de profil
class ProfileCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Position pour que la courbe traverse la photo de profil positionnée plus haut
    final curveHeight = 170.0; // Position encore plus haute pour suivre la photo
    
    // Commence en haut à gauche
    path.lineTo(0, curveHeight);
    
    // Crée une courbe plus prononcée qui traverse la photo de profil
    final controlPoint = Offset(size.width * 0.5, curveHeight + 160);
    final endPoint = Offset(size.width, curveHeight);
    
    // Utilise une courbe quadratique pour la forme arrondie
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
    return false;
  }
}