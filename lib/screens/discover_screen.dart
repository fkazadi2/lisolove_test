import 'package:flutter/material.dart';
import '../services/auth_provider.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> with SingleTickerProviderStateMixin {
  // Définition des couleurs de l'application
  static const Color roseColor = Color(0xFFF3004E);
  static const Color greyColor = Color(0xFF888888);
  static const Color lightGreyColor = Color(0xFFF5F5F5);
  
  // Variables d'état pour les filtres
  double _distanceFilter = 50;
  RangeValues _ageRangeFilter = RangeValues(25, 35);
  bool _showVerifiedOnly = true;
  String _currentLocation = 'Kinshasa';
  
  // Variables pour l'animation de scroll
  late ScrollController _scrollController;
  late AnimationController _animationController;
  
  // Variables pour la fonctionnalité de boost
  double _visibilityLevel = 0.2;
  bool _profileBoosted = false;
  int _availableCredits = 100;
  
  // Variable pour la recherche
  String _searchQuery = '';
  bool _isSearching = false;
  
  // Variables pour les interactions
  Set<String> _likedProfiles = {};
  int _activeTab = 0;
  
  // Liste des profils suggérés
  final List<Map<String, dynamic>> _suggestedProfiles = [
    {
      'name': 'Aïcha',
      'image': 'https://randomuser.me/api/portraits/women/44.jpg',
      'isVerified': true,
      'isOnline': true,
    },
    {
      'name': 'Ornalla',
      'image': 'https://randomuser.me/api/portraits/women/68.jpg',
      'isVerified': false,
      'isOnline': false,
    },
    {
      'name': 'Anouchka',
      'image': 'https://randomuser.me/api/portraits/women/63.jpg',
      'isVerified': true,
      'isOnline': true,
    },
    {
      'name': 'Deborah',
      'image': 'https://randomuser.me/api/portraits/women/90.jpg',
      'isVerified': false,
      'isOnline': false,
    },
    {
      'name': 'Christelle',
      'image': 'https://randomuser.me/api/portraits/women/54.jpg',
      'isVerified': false,
      'isOnline': true,
    },
    {
      'name': 'Joella',
      'image': 'https://randomuser.me/api/portraits/women/72.jpg',
      'isVerified': true,
      'isOnline': true,
    },
    {
      'name': 'Laeticia',
      'image': 'https://randomuser.me/api/portraits/women/32.jpg',
      'isVerified': false,
      'isOnline': false,
    },
  ];
  
  // Profil populaires pour la zone centrale
  final List<Map<String, dynamic>> _popularProfiles = [
    {
      'name': 'Aïcha',
      'age': 23,
      'location': 'Kinshasa',
      'image': 'https://randomuser.me/api/portraits/women/44.jpg',
      'isVerified': true,
    },
    {
      'name': 'Ornalla',
      'age': 25,
      'location': 'Kinshasa',
      'image': 'https://randomuser.me/api/portraits/women/68.jpg',
      'isVerified': false,
    },
    {
      'name': 'Anouchka',
      'age': 27,
      'location': 'Kinshasa',
      'image': 'https://randomuser.me/api/portraits/women/63.jpg',
      'isVerified': true,
    },
    {
      'name': 'Deborah',
      'age': 22,
      'location': 'Kinshasa',
      'image': 'https://randomuser.me/api/portraits/women/90.jpg',
      'isVerified': false,
    },
    {
      'name': 'Christelle',
      'age': 26,
      'location': 'Kinshasa',
      'image': 'https://randomuser.me/api/portraits/women/54.jpg',
      'isVerified': false,
    },
    {
      'name': 'Joella',
      'age': 24,
      'location': 'Kinshasa',
      'image': 'https://randomuser.me/api/portraits/women/72.jpg',
      'isVerified': true,
    },
    {
      'name': 'Sarah',
      'age': 28,
      'location': 'Kinshasa',
      'image': 'https://randomuser.me/api/portraits/women/33.jpg',
      'isVerified': true,
    },
    {
      'name': 'Michèle',
      'age': 23,
      'location': 'Kinshasa',
      'image': 'https://randomuser.me/api/portraits/women/42.jpg',
      'isVerified': false,
    },
    {
      'name': 'Caroline',
      'age': 25,
      'location': 'Kinshasa',
      'image': 'https://randomuser.me/api/portraits/women/19.jpg',
      'isVerified': true,
    },
    {
      'name': 'Béatrice',
      'age': 27,
      'location': 'Kinshasa',
      'image': 'https://randomuser.me/api/portraits/women/56.jpg',
      'isVerified': false,
    },
    {
      'name': 'Pauline',
      'age': 24,
      'location': 'Kinshasa',
      'image': 'https://randomuser.me/api/portraits/women/86.jpg',
      'isVerified': true,
    },
    {
      'name': 'Naomi',
      'age': 26,
      'location': 'Kinshasa',
      'image': 'https://randomuser.me/api/portraits/women/64.jpg',
      'isVerified': false,
    },
  ];

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

  // Variables pour les statuts
  bool _isViewingStatus = false;
  int _currentStatusIndex = 0;
  bool _isPaused = false;
  double _statusProgress = 0.0;
  late Timer _statusTimer;
  final int _statusDuration = 5; // Durée en secondes (5s pour test, normalement 30 ou 60)
  
  // Liste des statuts (normalement ces données viendraient d'une API ou d'une base de données)
  final List<Map<String, dynamic>> _statuses = [
    {
      'id': '1',
      'userId': '1',
      'userName': 'Aïcha',
      'userImage': 'https://randomuser.me/api/portraits/women/44.jpg',
      'type': 'image',
      'url': 'https://picsum.photos/800/1200?random=1',
      'caption': 'Journée ensoleillée à Kinshasa ☀️',
      'timestamp': DateTime.now().subtract(Duration(hours: 2)),
      'duration': 30, // secondes
      'viewed': false,
    },
    {
      'id': '2',
      'userId': '2',
      'userName': 'Ornalla',
      'userImage': 'https://randomuser.me/api/portraits/women/68.jpg',
      'type': 'image',
      'url': 'https://picsum.photos/800/1200?random=2',
      'caption': 'Café du matin 😊 #goodvibes',
      'timestamp': DateTime.now().subtract(Duration(minutes: 45)),
      'duration': 60, // secondes
      'viewed': false,
    },
    {
      'id': '3',
      'userId': '3',
      'userName': 'Anouchka',
      'userImage': 'https://randomuser.me/api/portraits/women/63.jpg',
      'type': 'image',
      'url': 'https://picsum.photos/800/1200?random=3',
      'caption': 'Nouvelle coiffure! Vous aimez? 💕',
      'timestamp': DateTime.now().subtract(Duration(hours: 5)),
      'duration': 30, // secondes
      'viewed': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    
    // Charger les profils suggérés avec un léger délai pour simuler le chargement
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          // Simuler un chargement de données
        });
      }
    });
  }
  
  @override
  void dispose() {
    if (_isViewingStatus) {
      _statusTimer.cancel();
    }
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  // Méthode pour liker un profil
  void _likeProfile(String name) {
    setState(() {
      if (_likedProfiles.contains(name)) {
        _likedProfiles.remove(name);
      } else {
        _likedProfiles.add(name);
        
        // Montrer une animation ou un message de confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vous avez aimé le profil de $name!'),
            backgroundColor: roseColor,
            duration: Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Annuler',
              textColor: Colors.white,
              onPressed: () {
                setState(() {
                  _likedProfiles.remove(name);
                });
              },
            ),
          ),
        );
      }
    });
  }
  
  // Mettre à jour les filtres
  void _updateDistanceFilter(double value) {
    setState(() {
      _distanceFilter = value;
    });
  }
  
  void _updateAgeRangeFilter(RangeValues values) {
    setState(() {
      _ageRangeFilter = values;
    });
  }
  
  void _toggleVerifiedFilter(bool? value) {
    setState(() {
      _showVerifiedOnly = value ?? false;
    });
  }
  
  // Filtrer les profils selon les critères sélectionnés
  List<Map<String, dynamic>> _getFilteredProfiles() {
    final filteredProfiles = _popularProfiles.where((profile) {
      // Appliquer le filtre de localisation
      if (_currentLocation != 'Toutes' && profile['location'] != _currentLocation) {
        return false;
      }
      
      // Appliquer le filtre de vérification
      if (_showVerifiedOnly && !profile['isVerified']) {
        return false;
      }
      
      // Appliquer le filtre d'âge
      final age = profile['age'] as int;
      if (age < _ageRangeFilter.start || age > _ageRangeFilter.end) {
        return false;
      }
      
      // Simuler le filtrage par distance
      // En réalité, il faudrait calculer la distance entre l'utilisateur et le profil
      // Ici on simule en assumant que la distance est liée à l'âge (juste pour démonstration)
      if (_distanceFilter < 50 && age > 25) {
        return false;
      }
      
      // Appliquer le filtre de recherche si actif
      if (_isSearching && _searchQuery.isNotEmpty) {
        final name = profile['name'].toString().toLowerCase();
        final location = profile['location'].toString().toLowerCase();
        final ageStr = profile['age'].toString();
        final searchLower = _searchQuery.toLowerCase();
        
        return name.contains(searchLower) || 
               location.contains(searchLower) || 
               ageStr.contains(searchLower);
      }
      
      // Appliquer le filtre par catégorie
      switch (_activeTab) {
        case 1: // Populaires
          return true; // Supposons que tous sont populaires pour l'instant
        case 2: // Nouveaux (simulé)
          return profile['age'] < 25; // Simple exemple
        case 3: // En ligne (simulé)
          return profile['name'].length % 2 == 0; // Simple exemple
        case 4: // Vérifiés
          return profile['isVerified'];
        default:
          return true;
      }
    }).toList();
    
    // Tri des résultats (exemple simple)
    if (_isSearching && _searchQuery.isNotEmpty) {
      filteredProfiles.sort((a, b) {
        final aMatch = a['name'].toString().toLowerCase().startsWith(_searchQuery.toLowerCase());
        final bMatch = b['name'].toString().toLowerCase().startsWith(_searchQuery.toLowerCase());
        
        if (aMatch && !bMatch) return -1;
        if (!aMatch && bMatch) return 1;
        return 0;
      });
    }
    
    return filteredProfiles;
  }

  // Méthode pour changer la localisation
  void _changeLocation(String newLocation) {
    setState(() {
      _currentLocation = newLocation;
      
      // Mettre à jour les profils avec la nouvelle localisation
      for (var profile in _popularProfiles) {
        // Pour la démonstration, on met à jour les localisations de certains profils
        // Dans une application réelle, ce serait chargé depuis une base de données
        if (profile['name'].toString().length % 2 == 0) {
          profile['location'] = newLocation;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: authProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: roseColor))
          : SafeArea(
              child: Column(
                children: [
                  // En-tête avec logo et barre de recherche
                  _buildHeader(),
                  
                  // Contenu principal
                  Expanded(
                    child: ListView(
                      children: [
                        // Carrousel d'avatars horizontaux
                        SizedBox(
                          height: 110,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            itemCount: _suggestedProfiles.length,
                            itemBuilder: (context, index) {
                              // Ajouter une icône + pour le premier élément
                              if (index == 0) {
                                return _buildAddProfileItem();
                              }
                              return _buildProfileAvatar(_suggestedProfiles[index - 1]);
                            },
                          ),
                        ),
                        
                        // Divider en gris clair
                        Divider(
                          color: lightGreyColor,
                          thickness: 1,
                        ),
                        
                        // Localisation
                        _buildLocationIndicator(),
                        
                        // Grille de profils avec 3 colonnes
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _getFilteredProfiles().length,
                            itemBuilder: (context, index) {
                              return _buildProfileCard(_getFilteredProfiles()[index]);
                            },
                          ),
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
                        _buildNavBarItem(icon: Icons.explore_outlined, isSelected: true, route: '/discover'),
                        _buildNavBarItem(icon: Icons.whatshot, isSelected: false, route: '/trends'),
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
  
  // Construire l'élément "Ajouter un profil"
  Widget _buildAddProfileItem() {
    return Container(
      width: 80,
      height: 100, // Augmentation de la hauteur pour correspondre à _buildProfileAvatar
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        children: [
          // Cercle avec icône +
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: roseColor, width: 2),
            ),
            child: Center(
              child: Icon(Icons.add, color: roseColor, size: 30),
            ),
          ),
          const SizedBox(height: 4),
          // Texte
          Flexible(
            child: Text(
              'Vous',
              style: TextStyle(
                fontSize: 13, // Taille de police légèrement réduite
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  // Construire un avatar de profil avec indicateur de statut
  Widget _buildProfileAvatar(Map<String, dynamic> profile) {
    // Vérifier si l'utilisateur a un statut
    final hasStatus = _statuses.any((status) => status['userName'] == profile['name']);
    final hasViewedStatus = hasStatus && _statuses.firstWhere(
      (status) => status['userName'] == profile['name'],
      orElse: () => {'viewed': true},
    )['viewed'];
    
    return GestureDetector(
      onTap: hasStatus ? () => _openStatus(profile['name']) : null,
      child: Container(
        width: 80,
        height: 100, // Augmentation de la hauteur pour éviter le débordement
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          children: [
            // Avatar avec badge en ligne et vérifié
            Stack(
              children: [
                // Cercle de statut
                if (hasStatus)
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: hasViewedStatus 
                        ? LinearGradient(
                            colors: [greyColor, greyColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [Colors.purple, roseColor, Colors.orange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    ),
                    child: Center(
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                
                // Avatar
                Container(
                  width: 70,
                  height: 70,
                  margin: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: hasStatus ? null : Border.all(color: roseColor, width: 2),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      profile['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: lightGreyColor,
                          child: Icon(Icons.person, size: 40, color: greyColor),
                        );
                      },
                    ),
                  ),
                ),
                
                // Badge vérifié (si applicable)
                if (profile['isVerified'])
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.verified, color: Colors.blue, size: 18),
                    ),
                  ),
                
                // Indicateur en ligne (si applicable)
                if (profile['isOnline'])
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            // Nom du profil
            Flexible(
              child: Text(
                profile['name'],
                style: TextStyle(
                  fontSize: 13, // Taille de police légèrement réduite
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1, // Limite à une seule ligne
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Construire une carte de profil pour la grille avec animations
  Widget _buildProfileCard(Map<String, dynamic> profile) {
    final isLiked = _likedProfiles.contains(profile['name']);
    
    return Hero(
      tag: 'profile_${profile['name']}',
      child: GestureDetector(
        onTap: () {
          // Action quand on tape sur un profil
          _showProfileDetails(profile);
        },
        onDoubleTap: () {
          _likeProfile(profile['name']);
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _profileBoosted && profile['name'] == 'Vous' ? [
              BoxShadow(
                color: roseColor.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
              )
            ] : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Image du profil
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Image.network(
                    profile['image'],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: lightGreyColor,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: roseColor,
                            value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: lightGreyColor,
                        child: Icon(Icons.person, size: 40, color: greyColor),
                      );
                    },
                  ),
                ),
                
                // Gradient pour le texte
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${profile['name']}, ${profile['age']}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (profile['isVerified'])
                              Icon(Icons.verified, color: Colors.blue, size: 14),
                          ],
                        ),
                        Text(
                          profile['location'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Icône de like animée
                if (isLiked)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: roseColor,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Afficher les détails du profil
  void _showProfileDetails(Map<String, dynamic> profile) {
    final isLiked = _likedProfiles.contains(profile['name']);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Indicateur de swipe
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: greyColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                
                // Photo de profil avec boutons d'action et like
                Stack(
                  children: [
                    // Photo de profil
                    Hero(
                      tag: 'profile_${profile['name']}',
                      child: Container(
                        height: 300,
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                          image: DecorationImage(
                            image: NetworkImage(profile['image']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    
                    // Bouton de like flottant
                    Positioned(
                      top: 30,
                      right: 30,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            this.setState(() {
                              if (_likedProfiles.contains(profile['name'])) {
                                _likedProfiles.remove(profile['name']);
                              } else {
                                _likedProfiles.add(profile['name']);
                              }
                            });
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _likedProfiles.contains(profile['name']) 
                                ? roseColor 
                                : Colors.white,
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
                            _likedProfiles.contains(profile['name']) 
                                ? Icons.favorite 
                                : Icons.favorite_border,
                            color: _likedProfiles.contains(profile['name']) 
                                ? Colors.white 
                                : roseColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Informations du profil
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${profile['name']}, ${profile['age']}',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (profile['isVerified'])
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified, color: Colors.blue, size: 24),
                                    SizedBox(width: 4),
                                    Text(
                                      'Vérifié',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            children: [
                              Icon(Icons.location_on, color: roseColor, size: 18),
                              Text(
                                profile['location'],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: greyColor,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.circle, color: Colors.green, size: 12),
                              Text(
                                'En ligne maintenant',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          
                          // Section description
                          Text(
                            'À propos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Je suis une personne dynamique qui aime découvrir de nouvelles personnes. J\'adore la musique, le cinéma et les voyages. Je cherche quelqu\'un avec qui partager de bons moments.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 24),
                          
                          // Centres d'intérêt
                          Text(
                            'Centres d\'intérêt',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildInterestChip('Musique'),
                              _buildInterestChip('Cinéma'),
                              _buildInterestChip('Voyages'),
                              _buildInterestChip('Cuisine'),
                              _buildInterestChip('Sport'),
                              _buildInterestChip('Photographie'),
                            ],
                          ),
                          SizedBox(height: 32),
                          
                          // Boutons d'action
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildProfileActionButton(
                                icon: Icons.close,
                                color: Colors.red,
                                label: 'Passer',
                                onTap: () => Navigator.pop(context),
                              ),
                              _buildProfileActionButton(
                                icon: _likedProfiles.contains(profile['name']) 
                                    ? Icons.favorite 
                                    : Icons.favorite_border,
                                color: roseColor,
                                label: 'J\'aime',
                                onTap: () {
                                  setState(() {
                                    this.setState(() {
                                      _likeProfile(profile['name']);
                                    });
                                  });
                                },
                              ),
                              _buildProfileActionButton(
                                icon: Icons.chat_bubble_outline,
                                color: Colors.blue,
                                label: 'Message',
                                onTap: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Message envoyé à ${profile['name']}'),
                                      backgroundColor: Colors.blue,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  // Construire une puce d'intérêt
  Widget _buildInterestChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: roseColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: roseColor.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: roseColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  // Bouton d'action pour le profil
  Widget _buildProfileActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
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

  // Afficher la boîte de dialogue de boost
  void _showBoostDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.battery_0_bar, color: roseColor),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Améliore ta visibilité',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _visibilityLevel < 0.4 
                                      ? Icons.battery_0_bar 
                                      : _visibilityLevel < 0.7 
                                          ? Icons.battery_3_bar 
                                          : Icons.battery_full,
                                  color: roseColor
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Niveau: ${_visibilityLevel < 0.4 ? 'Faible' : _visibilityLevel < 0.7 ? 'Moyen' : 'Élevé'}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _visibilityLevel,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(roseColor),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Crédits disponibles: $_availableCredits',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Choisis une option pour augmenter ta visibilité',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                      ),
                      SizedBox(height: 16),
                      _buildBoostOption(
                        icon: Icons.photo_library,
                        title: 'Mets en avant ta photo de profil',
                        credits: '25 Crédits',
                        description: 'Obtiens 5 x plus de visites',
                        buttonColor: Color(0xFF00BFA5),
                        onTap: () {
                          if (_availableCredits >= 25) {
                            setState(() {
                              _availableCredits -= 25;
                              _visibilityLevel = (_visibilityLevel + 0.1).clamp(0.0, 1.0);
                            });
                            this.setState(() {
                              _profileBoosted = true;
                            });
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Votre photo de profil a été mise en avant !'),
                                backgroundColor: Color(0xFF00BFA5),
                              ),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Crédits insuffisants'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(height: 12),
                      _buildBoostOption(
                        icon: Icons.group,
                        title: 'Apparais plusieurs fois dans la section rencontres',
                        credits: '30 Crédits',
                        description: 'Obtiens 3 x plus de matches',
                        buttonColor: Colors.orange,
                        onTap: () {
                          if (_availableCredits >= 30) {
                            setState(() {
                              _availableCredits -= 30;
                              _visibilityLevel = (_visibilityLevel + 0.15).clamp(0.0, 1.0);
                            });
                            this.setState(() {
                              _profileBoosted = true;
                            });
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Votre profil apparaîtra plus souvent !'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Crédits insuffisants'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(height: 12),
                      _buildBoostOption(
                        icon: Icons.circle,
                        title: 'Fais savoir à tout le monde que tu es en ligne',
                        credits: '35 Crédits',
                        description: 'Obtiens 4 x plus de messages',
                        buttonColor: Colors.purple,
                        onTap: () {
                          if (_availableCredits >= 35) {
                            setState(() {
                              _availableCredits -= 35;
                              _visibilityLevel = (_visibilityLevel + 0.2).clamp(0.0, 1.0);
                            });
                            this.setState(() {
                              _profileBoosted = true;
                            });
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Tout le monde sait que vous êtes en ligne !'),
                                backgroundColor: Colors.purple,
                              ),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Crédits insuffisants'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Fermer',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Acheter des crédits'),
                                  content: Text('Cette fonctionnalité sera disponible prochainement.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Text(
                              'Acheter des crédits',
                              style: TextStyle(
                                color: roseColor,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }

  // Construire une option de boost
  Widget _buildBoostOption({
    required IconData icon,
    required String title,
    required String credits,
    required String description,
    required Color buttonColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 24, color: Colors.grey[600]),
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
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        credits,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: buttonColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  // Localisation
  Widget _buildLocationIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: GestureDetector(
        onTap: () => _showLocationSelector(),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: roseColor.withOpacity(0.3)),
            color: roseColor.withOpacity(0.05),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on, color: roseColor, size: 20),
              const SizedBox(width: 4),
              Text(
                _currentLocation,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_drop_down, color: roseColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Afficher le sélecteur de localisation
  void _showLocationSelector() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: roseColor),
                    SizedBox(width: 10),
                    Text(
                      'Choisir une localisation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Divider(),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      title: Text('Toutes les localisations'),
                      leading: Icon(Icons.public),
                      selected: _currentLocation == 'Toutes',
                      selectedTileColor: roseColor.withOpacity(0.1),
                      onTap: () {
                        _changeLocation('Toutes');
                        Navigator.pop(context);
                      },
                    ),
                    ..._availableLocations.map((location) => 
                      ListTile(
                        title: Text(location),
                        leading: Icon(Icons.location_city),
                        selected: _currentLocation == location,
                        selectedTileColor: roseColor.withOpacity(0.1),
                        onTap: () {
                          _changeLocation(location);
                          Navigator.pop(context);
                        },
                      )
                    ).toList(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // En-tête avec logo et barre de recherche
  Widget _buildHeader() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icône de boost (tonnerre)
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.bolt, color: roseColor, size: 26),
                    onPressed: () {
                      _showBoostDialog();
                    },
                  ),
                  if (_profileBoosted)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              
              // Logo Lisolove
              Row(
                children: [
                  Icon(Icons.favorite, color: roseColor, size: 24),
                  const SizedBox(width: 4),
                  Text(
                    'lisolove',
                    style: TextStyle(
                      color: roseColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              
              // Icônes de recherche et de filtre
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(),
                    icon: Icon(
                      _isSearching ? Icons.search_off : Icons.search,
                      color: _isSearching ? roseColor : greyColor,
                      size: 26,
                    ),
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                        if (!_isSearching) {
                          _searchQuery = '';
                        }
                      });
                    },
                  ),
                  SizedBox(width: 4),
                  IconButton(
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(),
                    icon: const Icon(Icons.filter_list, color: roseColor, size: 26),
                    onPressed: () {
                      _showFilterDialog();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Barre de recherche
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: _isSearching ? 60 : 0,
          child: Visibility(
            visible: _isSearching,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                autofocus: _isSearching,
                decoration: InputDecoration(
                  hintText: 'Rechercher un profil...',
                  prefixIcon: Icon(Icons.search, color: roseColor),
                  suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: greyColor),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Onglets de catégories
        Container(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildCategoryTab(0, 'Tous'),
              _buildCategoryTab(1, 'Populaires'),
              _buildCategoryTab(2, 'Nouveaux'),
              _buildCategoryTab(3, 'En ligne'),
              _buildCategoryTab(4, 'Vérifiés'),
            ],
          ),
        ),
        
        // Indicateur de recherche
        if (_isSearching && _searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Résultats pour "${_searchQuery}"',
                    style: TextStyle(
                      color: greyColor,
                      fontStyle: FontStyle.italic,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '${_getFilteredProfiles().length} profil(s)',
                  style: TextStyle(
                    color: roseColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  // Construire un onglet de catégorie
  Widget _buildCategoryTab(int index, String label) {
    final isActive = _activeTab == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = index;
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? roseColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? roseColor : greyColor.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : greyColor,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // Ouvrir le statut
  void _openStatus(String userName) {
    // Trouver les statuts de cet utilisateur
    List<Map<String, dynamic>> userStatuses = [];
    for (var status in _statuses) {
      if (status['userName'] == userName) {
        userStatuses.add(Map<String, dynamic>.from(status)); // Faire une copie pour éviter les problèmes de référence
      }
    }
    
    if (userStatuses.isEmpty) return;
    
    setState(() {
      _isViewingStatus = true;
      _currentStatusIndex = 0;
      _statusProgress = 0.0;
      _isPaused = false;
    });
    
    // Démarrer le timer pour le statut
    _startStatusTimer(userStatuses[0]['duration']);
    
    // Afficher le statut en plein écran
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return StatusScreenSimple(
            statuses: userStatuses,
            onClose: () {
              _statusTimer.cancel();
              setState(() {
                _isViewingStatus = false;
              });
              Navigator.of(context).pop();
            },
            onPauseToggle: (isPaused) {
              setState(() {
                _isPaused = isPaused;
              });
              
              if (isPaused) {
                _statusTimer.cancel();
              } else {
                _startStatusTimer(
                  userStatuses[_currentStatusIndex]['duration'],
                  initialProgress: _statusProgress,
                );
              }
            },
          );
        },
      ),
    ).then((_) {
      // Marquer le statut comme vu
      setState(() {
        for (var status in _statuses) {
          if (status['userName'] == userName) {
            status['viewed'] = true;
          }
        }
      });
    });
  }
  
  // Démarrer le timer pour le statut
  void _startStatusTimer(int duration, {double initialProgress = 0.0}) {
    final interval = Duration(milliseconds: 100);
    final totalSteps = (duration * 1000) ~/ interval.inMilliseconds;
    double progress = initialProgress;
    int step = (initialProgress * totalSteps).round();
    
    _statusTimer = Timer.periodic(interval, (timer) {
      if (_isPaused) return;
      
      step++;
      setState(() {
        _statusProgress = step / totalSteps;
      });
      
      // Mise à jour de l'écran de statut
      if (step >= totalSteps) {
        timer.cancel();
      }
    });
  }
}

// Écran de statut simplifié
class StatusScreenSimple extends StatefulWidget {
  final List<Map<String, dynamic>> statuses;
  final VoidCallback onClose;
  final Function(bool) onPauseToggle;
  
  const StatusScreenSimple({
    Key? key,
    required this.statuses,
    required this.onClose,
    required this.onPauseToggle,
  }) : super(key: key);
  
  @override
  _StatusScreenSimpleState createState() => _StatusScreenSimpleState();
}

class _StatusScreenSimpleState extends State<StatusScreenSimple> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isPaused = false;
  double _progress = 0.0;
  late Timer _statusTimer;
  
  @override
  void initState() {
    super.initState();
    _startStatusTimer();
  }
  
  @override
  void dispose() {
    _statusTimer.cancel();
    super.dispose();
  }
  
  void _startStatusTimer() {
    final duration = widget.statuses[_currentIndex]['duration'] as int;
    final interval = Duration(milliseconds: 100);
    final totalSteps = (duration * 1000) ~/ interval.inMilliseconds;
    int step = 0;
    
    _statusTimer = Timer.periodic(interval, (timer) {
      if (_isPaused) return;
      
      step++;
      setState(() {
        _progress = step / totalSteps;
      });
      
      if (step >= totalSteps) {
        timer.cancel();
        _moveToNextStatus();
      }
    });
  }
  
  void _moveToNextStatus() {
    if (_currentIndex < widget.statuses.length - 1) {
      setState(() {
        _currentIndex++;
        _progress = 0.0;
      });
      _startStatusTimer();
    } else {
      widget.onClose();
    }
  }
  
  void _moveToPreviousStatus() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _progress = 0.0;
      });
      _startStatusTimer();
    } else {
      widget.onClose();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final status = widget.statuses[_currentIndex];
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (_) {
          setState(() {
            _isPaused = true;
          });
          widget.onPauseToggle(true);
          _statusTimer.cancel();
        },
        onTapUp: (_) {
          setState(() {
            _isPaused = false;
          });
          widget.onPauseToggle(false);
          _startStatusTimer();
        },
        onTapCancel: () {
          setState(() {
            _isPaused = false;
          });
          widget.onPauseToggle(false);
          _startStatusTimer();
        },
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            // Balayage vers la gauche - statut suivant
            _moveToNextStatus();
          } else if (details.primaryVelocity! > 0) {
            // Balayage vers la droite - statut précédent
            _moveToPreviousStatus();
          }
        },
        child: Stack(
          children: [
            // Contenu du statut
            Center(
              child: status['type'] == 'image'
                ? Image.network(
                    status['url'],
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      'Vidéo non supportée',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
            ),
            
            // Indicateurs de progression
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              right: 10,
              child: Row(
                children: List.generate(
                  widget.statuses.length,
                  (index) => Expanded(
                    child: Container(
                      height: 2,
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(1),
                      ),
                      child: Stack(
                        children: [
                          if (index < _currentIndex)
                            Container(
                              width: double.infinity,
                              height: 2,
                              color: Colors.white,
                            ),
                          if (index == _currentIndex)
                            Container(
                              width: MediaQuery.of(context).size.width * _progress / widget.statuses.length,
                              height: 2,
                              color: Colors.white,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // En-tête
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 10,
              right: 10,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(status['userImage']),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          status['userName'],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getTimeAgo(status['timestamp']),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ),
            
            // Légende
            if (status['caption'] != null)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 20,
                left: 10,
                right: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status['caption'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              
            // Indicateur de pause
            if (_isPaused)
              Center(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.pause,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
                
            // Instructions de navigation
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 70,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 300),
                  opacity: _isPaused ? 1.0 : 0.0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Appuyez pour mettre en pause • Glissez pour naviguer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Obtenir le temps écoulé
  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }
} 