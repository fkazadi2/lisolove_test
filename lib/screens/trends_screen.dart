import 'package:flutter/material.dart';
import '../services/auth_provider.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> with SingleTickerProviderStateMixin {
  // Définition des couleurs de l'application
  static const Color roseColor = Color(0xFFF3004E);
  static const Color greyColor = Color(0xFF888888);
  static const Color lightGreyColor = Color(0xFFF5F5F5);
  
  // Variables pour les filtres
  double _distanceFilter = 50;
  RangeValues _ageRangeFilter = RangeValues(25, 35);
  bool _showVerifiedOnly = true;
  String _currentLocation = 'Kinshasa';
  String _selectedRelationType = 'all'; // 'serious', 'casual', 'all'
  
  // Liste des localisations disponibles
  final List<String> _availableLocations = [
    'Kinshasa', 
    'Lubumbashi', 
    'Goma', 
    'Bukavu', 
    'Kisangani',
    'Matadi',
    'Kananga'
  ];
  
  // Index du profil actuellement affiché
  int _currentProfileIndex = 0;
  
  // Contrôleur d'animation pour le swipe
  late AnimationController _swipeController;
  
  // Variables pour le swipe
  Offset _dragPosition = Offset.zero;
  double _dragExtent = 0;
  double _dragAngle = 0;
  
  // Direction du swipe (1 pour droite, -1 pour gauche)
  int _swipeDirection = 0;
  
  // Pour limiter l'étendue du swipe
  final double _maxSwipe = 250.0;
  
  // Profils likés
  Set<String> _likedProfiles = {};
  
  // Tutoriel affiché
  bool _tutorialShown = false;
  
  // Exemples de profils à proximité avec propriétés supplémentaires pour le filtrage
  final List<Map<String, dynamic>> _nearbyProfiles = [
    {
      'name': 'Sophie',
      'age': 25,
      'distance': 5,
      'location': 'Kinshasa',
      'image': 'https://randomuser.me/api/portraits/women/44.jpg',
      'bio': 'Passionnée de photographie et de voyages.',
      'isVerified': true,
      'searchingFor': 'serious',
    },
    {
      'name': 'Emma',
      'age': 28,
      'distance': 3,
      'location': 'Lubumbashi',
      'image': 'https://randomuser.me/api/portraits/women/68.jpg',
      'bio': 'Adore la cuisine et les randonnées en montagne.',
      'isVerified': false,
      'searchingFor': 'casual',
    },
    {
      'name': 'Julie',
      'age': 24,
      'distance': 7,
      'location': 'Goma',
      'image': 'https://randomuser.me/api/portraits/women/63.jpg',
      'bio': 'Sportive, j\'adore le fitness et la danse.',
      'isVerified': true,
      'searchingFor': 'serious',
    },
    {
      'name': 'Laeticia',
      'age': 26,
      'distance': 4,
      'location': 'Kinshasa',
      'image': 'https://randomuser.me/api/portraits/women/32.jpg',
      'bio': 'Artiste peintre, passionnée de culture et de voyages.',
      'isVerified': true,
      'searchingFor': 'casual',
    },
    {
      'name': 'Caroline',
      'age': 23,
      'distance': 6,
      'location': 'Bukavu',
      'image': 'https://randomuser.me/api/portraits/women/19.jpg',
      'bio': 'Étudiante en médecine, j\'aime les soirées cinéma et la natation.',
      'isVerified': false,
      'searchingFor': 'serious',
    },
  ];

  // Profils filtrés
  List<Map<String, dynamic>> _filteredProfiles = [];

  @override
  void initState() {
    super.initState();
    
    // Initialiser les profils filtrés
    _filteredProfiles = _getFilteredProfiles();
    
    // Initialiser le contrôleur d'animation
    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Ajouter un listener pour détecter la fin de l'animation
    _swipeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          // Si swipe à droite (like)
          if (_swipeDirection == 1) {
            final profile = _filteredProfiles[_currentProfileIndex];
            _likedProfiles.add(profile['name']);
            
            // Afficher un message temporaire
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Vous avez aimé ${profile['name']}!'),
                backgroundColor: roseColor,
                duration: Duration(seconds: 2),
              ),
            );
          }
          
          // Passer au profil suivant ou revenir au début de la liste
          if (_currentProfileIndex < _filteredProfiles.length - 1) {
            _currentProfileIndex++;
          } else {
            _currentProfileIndex = 0;
          }
          
          // Réinitialiser les variables de drag
          _dragPosition = Offset.zero;
          _dragExtent = 0;
          _dragAngle = 0;
          _swipeDirection = 0;
          _swipeController.reset();
        });
      }
    });
    
    // Attendre un peu pour afficher le tutoriel
    Future.delayed(Duration(seconds: 1), () {
      if (mounted && !_tutorialShown) {
        setState(() {
          _tutorialShown = true;
        });
      }
    });
  }
  
  // Obtenir les profils filtrés selon les critères
  List<Map<String, dynamic>> _getFilteredProfiles() {
    return _nearbyProfiles.where((profile) {
      // Vérifier le type de relation recherchée
      if (_selectedRelationType != 'all' && profile['searchingFor'] != _selectedRelationType) {
        return false;
      }
      
      // Vérifier la localisation
      if (_currentLocation != 'Toutes' && profile['location'] != _currentLocation) {
        return false;
      }
      
      // Vérifier le statut de vérification
      if (_showVerifiedOnly && !profile['isVerified']) {
        return false;
      }
      
      // Vérifier l'âge
      int age = profile['age'] as int;
      if (age < _ageRangeFilter.start || age > _ageRangeFilter.end) {
        return false;
      }
      
      // Vérifier la distance
      int distance = profile['distance'] as int;
      if (distance > _distanceFilter) {
        return false;
      }
      
      return true;
    }).toList();
  }
  
  // Changer la localisation et rafraîchir les profils
  void _changeLocation(String newLocation) {
    setState(() {
      _currentLocation = newLocation;
      _filteredProfiles = _getFilteredProfiles();
      _currentProfileIndex = 0;
    });
  }
  
  @override
  void dispose() {
    _swipeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: authProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: roseColor))
          : SafeArea(
              child: Column(
                children: [
                  // En-tête personnalisé
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tendances',
                              style: TextStyle(
                                color: roseColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                              ),
                            ),
                            // Bouton de filtrage
                            IconButton(
                              icon: const Icon(Icons.filter_list, color: roseColor, size: 26),
                              onPressed: () {
                                _showFilterDialog();
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        // Options de type de relation
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedRelationType = _selectedRelationType == 'serious' ? 'all' : 'serious';
                                    _filteredProfiles = _getFilteredProfiles();
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _selectedRelationType == 'serious' ? roseColor : Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: roseColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.favorite,
                                        size: 18,
                                        color: _selectedRelationType == 'serious' ? Colors.white : roseColor,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Relation sérieuse',
                                        style: TextStyle(
                                          color: _selectedRelationType == 'serious' ? Colors.white : roseColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedRelationType = _selectedRelationType == 'casual' ? 'all' : 'casual';
                                    _filteredProfiles = _getFilteredProfiles();
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _selectedRelationType == 'casual' ? roseColor : Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: roseColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.celebration,
                                        size: 18,
                                        color: _selectedRelationType == 'casual' ? Colors.white : roseColor,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Rien de sérieux',
                                        style: TextStyle(
                                          color: _selectedRelationType == 'casual' ? Colors.white : roseColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Profil principal avec swipe
                  Expanded(
                    child: GestureDetector(
                      onHorizontalDragStart: (details) {
                        setState(() {
                          _dragPosition = details.localPosition;
                          // Masquer le tutoriel lors du premier swipe
                          _tutorialShown = false;
                        });
                      },
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          // Calculer la distance de déplacement horizontale
                          final dragDeltaX = details.localPosition.dx - _dragPosition.dx;
                          _dragExtent = dragDeltaX.clamp(-_maxSwipe, _maxSwipe);
                          
                          // Calculer l'angle de rotation en fonction du déplacement
                          // Plus on déplace loin, plus la rotation est grande, mais avec une limite
                          _dragAngle = (_dragExtent / _maxSwipe) * 0.3; // Réduire légèrement l'angle pour plus de stabilité
                        });
                      },
                      onHorizontalDragEnd: (details) {
                        try {
                          // Déterminer la direction du swipe en fonction de la vélocité et de la position
                          double velocity = details.primaryVelocity ?? 0;
                          
                          if (velocity.abs() > 200 || _dragExtent.abs() > _maxSwipe / 3) {
                            // Réduire les seuils pour rendre le swipe plus réactif
                            if (velocity > 0 || _dragExtent > 0) {
                              // Swipe à droite (like)
                              _completeSwipe(1);
                            } else {
                              // Swipe à gauche (dislike)
                              _completeSwipe(-1);
                            }
                          } else {
                            // Revenir au centre
                            _resetSwipe();
                          }
                        } catch (e) {
                          // En cas d'erreur, revenir simplement à l'état initial
                          _resetSwipe();
                          print('Erreur lors du swipe: $e');
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildSwipeableProfile(screenSize),
                      ),
                    ),
                  ),
                  
                  // Actions de swipe
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          icon: Icons.close,
                          color: Colors.red,
                          onTap: () => _completeSwipe(-1),
                        ),
                        _buildActionButton(
                          icon: Icons.favorite,
                          color: roseColor,
                          onTap: () => _completeSwipe(1),
                        ),
                      ],
                    ),
                  ),
                  
                  // Barre de navigation
                  Container(
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
                        _buildNavBarItem(icon: Icons.whatshot, isSelected: true, route: '/trends'),
                        _buildNavBarItem(icon: Icons.notifications_outlined, isSelected: false, route: '/notifications'),
                        _buildNavBarItem(icon: Icons.forum_outlined, isSelected: false, route: '/messages'),
                        _buildNavBarItem(icon: Icons.person_outline, isSelected: false, route: '/home'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  // Construire le profil swipeable
  Widget _buildSwipeableProfile(Size screenSize) {
    if (_filteredProfiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: greyColor.withOpacity(0.5)),
            SizedBox(height: 16),
            Text(
              'Aucun profil disponible',
              style: TextStyle(fontSize: 18, color: greyColor),
            ),
            SizedBox(height: 8),
            Text(
              'Essayez de modifier vos filtres',
              style: TextStyle(fontSize: 14, color: greyColor),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.filter_alt),
              label: Text('Modifier les filtres'),
              style: ElevatedButton.styleFrom(
                backgroundColor: roseColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: () => _showFilterDialog(),
            ),
          ],
        ),
      );
    }
    
    final profile = _filteredProfiles[_currentProfileIndex];
    final isLiked = _likedProfiles.contains(profile['name']);
    
    // Calculer la position pour l'animation de swipe en fonction du drag
    final position = Offset(_dragExtent, 0);
    
    // Calculer l'opacité des indicateurs LIKE/NOPE en fonction de la distance
    final rightSwipeOpacity = (_dragExtent / 80).clamp(0.0, 1.0); // Plus réactif
    final leftSwipeOpacity = (-_dragExtent / 80).clamp(0.0, 1.0); // Plus réactif
    
    return AnimatedBuilder(
      animation: _swipeController,
      builder: (context, child) {
        double animValue = _swipeController.value;
        
        // Si une animation est en cours, utilisez la position animée
        Offset finalPosition = position;
        double finalAngle = _dragAngle;
        
        if (_swipeController.isAnimating) {
          try {
            if (_swipeDirection != 0) {
              // Animation de sortie: déplacer la carte hors de l'écran dans la direction du swipe
              final endX = _swipeDirection * (screenSize.width + 100); // Assurer qu'elle sort complètement
              finalPosition = Offset(
                position.dx + ((endX - position.dx) * animValue),
                position.dy + (20 * animValue), // Légère élévation pendant l'animation
              );
              finalAngle = _dragAngle + (_swipeDirection * 0.3 * animValue);
            } else {
              // Animation de retour au centre
              finalPosition = Offset(
                position.dx * (1 - animValue),
                position.dy * (1 - animValue),
              );
              finalAngle = _dragAngle * (1 - animValue);
            }
          } catch (e) {
            // En cas d'erreur, utiliser les valeurs actuelles
            print('Erreur d\'animation: $e');
          }
        }
        
        return Transform(
          transform: Matrix4.identity()
            ..translate(finalPosition.dx, finalPosition.dy)
            ..rotateZ(finalAngle),
          alignment: Alignment.center,
          child: Stack(
            children: [
              // Carte de profil
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // Image du profil
                      Image.network(
                        profile['image'],
                        height: double.infinity,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: double.infinity,
                          color: lightGreyColor,
                          child: const Icon(Icons.person, size: 100, color: greyColor),
                        ),
                      ),
                      
                      // Gradient de bas en haut pour rendre le texte lisible
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Informations du profil
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${profile['name']}, ${profile['age']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 3.0,
                                        color: Color.fromARGB(150, 0, 0, 0),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_on, color: Colors.white, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${profile['distance']} km',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(0, 1),
                                              blurRadius: 2.0,
                                              color: Color.fromARGB(150, 0, 0, 0),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (profile['isVerified'])
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.7),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.verified,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              profile['bio'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 2.0,
                                    color: Color.fromARGB(150, 0, 0, 0),
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      
                      // Indicateur LIKE
                      Positioned(
                        top: 30,
                        left: 30,
                        child: Opacity(
                          opacity: rightSwipeOpacity,
                          child: Transform.rotate(
                            angle: -0.5,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: roseColor,
                                border: Border.all(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'LIKE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Indicateur NOPE
                      Positioned(
                        top: 30,
                        right: 30,
                        child: Opacity(
                          opacity: leftSwipeOpacity,
                          child: Transform.rotate(
                            angle: 0.5,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                border: Border.all(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'NOPE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Badge "Aimé" si le profil est déjà liké
                      if (isLiked)
                        Positioned(
                          top: 20,
                          right: 20,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: roseColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              // Tutoriel de swipe au premier lancement
              if (_tutorialShown && _currentProfileIndex == 0)
                Positioned.fill(
                  child: GestureDetector(
                    // Permettre de fermer le tutoriel en tapant dessus
                    onTap: () {
                      setState(() {
                        _tutorialShown = false;
                      });
                    },
                    child: Container(
                      color: Colors.transparent, // Pour capturer les taps
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: 0.8,
                          duration: Duration(milliseconds: 1000),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.swipe, color: Colors.white, size: 24),
                                    SizedBox(width: 8),
                                    Text(
                                      'Balayez pour découvrir',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.arrow_back, color: Colors.white, size: 20),
                                    Text('  Ignorer  ', style: TextStyle(color: Colors.white)),
                                    Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                                    Text('  Aimer  ', style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Touchez pour fermer',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  
  // Compléter l'animation de swipe
  void _completeSwipe(int direction) {
    if (_swipeController.isAnimating) return; // Éviter les animations multiples
    
    setState(() {
      _swipeDirection = direction;
      _swipeController.forward(from: 0.0);
    });
  }
  
  // Réinitialiser le swipe
  void _resetSwipe() {
    if (_swipeController.isAnimating) return; // Éviter les animations multiples
    
    setState(() {
      _swipeDirection = 0;
      _swipeController.forward(from: 0.0);
    });
  }
  
  // Afficher la boîte de dialogue de filtre
  void _showFilterDialog() {
    // Variables locales pour stocker les valeurs temporaires
    double tempDistance = _distanceFilter;
    RangeValues tempAgeRange = _ageRangeFilter;
    bool tempShowVerified = _showVerifiedOnly;
    String tempLocation = _currentLocation;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.filter_list, color: roseColor),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Filtrer les profils',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Localisation
                    Text(
                      'Localisation',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: greyColor.withOpacity(0.3)),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<String>(
                        value: tempLocation,
                        isExpanded: true,
                        underline: SizedBox(),
                        items: [
                          DropdownMenuItem(
                            value: 'Toutes',
                            child: Text('Toutes les localisations'),
                          ),
                          ..._availableLocations.map((location) => 
                            DropdownMenuItem(
                              value: location,
                              child: Text(location),
                            )
                          ).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            tempLocation = value!;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Distance
                    Text(
                      'Distance',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Slider(
                      value: tempDistance,
                      min: 1,
                      max: 100,
                      divisions: 20,
                      activeColor: roseColor,
                      inactiveColor: lightGreyColor,
                      label: '${tempDistance.round()} km',
                      onChanged: (value) {
                        setState(() {
                          tempDistance = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Âge
                    Text(
                      'Âge',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    RangeSlider(
                      values: tempAgeRange,
                      min: 18,
                      max: 60,
                      divisions: 42,
                      activeColor: roseColor,
                      inactiveColor: lightGreyColor,
                      labels: RangeLabels('${tempAgeRange.start.round()} ans', '${tempAgeRange.end.round()} ans'),
                      onChanged: (values) {
                        setState(() {
                          tempAgeRange = values;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Statut de vérification
                    Text(
                      'Statut de vérification',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: tempShowVerified,
                          activeColor: roseColor,
                          onChanged: (value) {
                            setState(() {
                              tempShowVerified = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            'Afficher uniquement les profils vérifiés',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
                    // Appliquer les filtres
                    this.setState(() {
                      _distanceFilter = tempDistance;
                      _ageRangeFilter = tempAgeRange;
                      _showVerifiedOnly = tempShowVerified;
                      
                      // Si la localisation a changé
                      if (_currentLocation != tempLocation) {
                        _changeLocation(tempLocation);
                      } else {
                        _filteredProfiles = _getFilteredProfiles();
                        _currentProfileIndex = 0;
                      }
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: roseColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Appliquer'),
                ),
              ],
            );
          }
        );
      },
    );
  }
  
  // Bouton d'action (like/dislike)
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: 30,
        ),
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
              Navigator.pushReplacementNamed(context, route);
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
} 