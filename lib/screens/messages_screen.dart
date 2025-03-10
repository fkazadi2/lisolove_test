import 'package:flutter/material.dart';
import '../services/auth_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  // Définition des couleurs de l'application
  static const Color roseColor = Color(0xFFF3004E);
  static const Color greyColor = Color(0xFF888888);
  static const Color lightGreyColor = Color(0xFFF5F5F5);
  
  // État de filtrage actuel
  String _currentFilter = 'Tous';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  
  // Exemples de conversations
  final List<Map<String, dynamic>> _conversations = [
    {
      'name': 'Emma',
      'image': 'https://randomuser.me/api/portraits/women/68.jpg',
      'lastMessage': 'J\'adorerais continuer cette conversation...',
      'time': '14:27',
      'unread': true,
      'isMatch': true,
    },
    {
      'name': 'Sophie',
      'image': 'https://randomuser.me/api/portraits/women/44.jpg',
      'lastMessage': 'Ça me semble être une bonne idée !',
      'time': 'Hier',
      'unread': false,
      'isMatch': true,
    },
    {
      'name': 'Julie',
      'image': 'https://randomuser.me/api/portraits/women/63.jpg',
      'lastMessage': 'On se retrouve où exactement ?',
      'time': 'Hier',
      'unread': true,
      'isMatch': true,
    },
    {
      'name': 'Clara',
      'image': 'https://randomuser.me/api/portraits/women/90.jpg',
      'lastMessage': 'Merci pour cette soirée, c\'était génial.',
      'time': 'Lun.',
      'unread': false,
      'isMatch': false,
    },
    {
      'name': 'Marie',
      'image': 'https://randomuser.me/api/portraits/women/54.jpg',
      'lastMessage': 'J\'ai hâte de te revoir !',
      'time': '02/05',
      'unread': false,
      'isMatch': false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filtrer les conversations selon le critère actuel
  List<Map<String, dynamic>> get _filteredConversations {
    List<Map<String, dynamic>> result = List.from(_conversations);
    
    // Applique le filtre de recherche si actif
    if (_isSearching && _searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      result = result.where((conversation) => 
        conversation['name'].toLowerCase().contains(searchTerm) ||
        conversation['lastMessage'].toLowerCase().contains(searchTerm)
      ).toList();
    }
    
    // Ensuite applique le filtre de catégorie
    switch (_currentFilter) {
      case 'Non lus':
        return result.where((conversation) => conversation['unread']).toList();
      case 'Matchs':
        return result.where((conversation) => conversation['isMatch']).toList();
      case 'Tous':
      default:
        return result;
    }
  }
  
  // Construire un avatar avec gestion d'erreur
  Widget _buildProfileAvatar({
    required String imageUrl,
    required double radius,
    double iconSize = 20,
    Color backgroundColor = Colors.transparent,
  }) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: lightGreyColor,
      child: ClipOval(
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.person,
                    size: iconSize,
                    color: greyColor,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                    color: roseColor,
                  );
                },
              )
            : Icon(
                Icons.person,
                size: iconSize,
                color: greyColor,
              ),
      ),
    );
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
                  // En-tête personnalisé
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!_isSearching)
                          const Text(
                            'Messages',
                            style: TextStyle(
                              color: roseColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          )
                        else
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Rechercher...',
                                hintStyle: TextStyle(color: greyColor),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                              onChanged: (value) {
                                setState(() {});
                              },
                              autofocus: true,
                            ),
                          ),
                        IconButton(
                          icon: Icon(
                            _isSearching ? Icons.close : Icons.search, 
                            color: roseColor, 
                            size: 30
                          ),
                          onPressed: () {
                            setState(() {
                              _isSearching = !_isSearching;
                              if (!_isSearching) {
                                _searchController.clear();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Section de nouveaux matchs (masqué si recherche active)
                  if (!_isSearching)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Text(
                            '459 nouveaux Matchs',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 120,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            children: [
                              // Section des likes (verrouillée)
                              GestureDetector(
                                onTap: () => _showPremiumDialog(context),
                                child: Container(
                                  width: 90,
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Column(
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Photo de profil floutée
                                          Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: roseColor,
                                                width: 2,
                                              ),
                                            ),
                                            child: ClipOval(
                                              child: Stack(
                                                children: [
                                                  Icon(
                                                    Icons.person,
                                                    size: 60,
                                                    color: greyColor,
                                                  ),
                                                  Container(
                                                    width: 80,
                                                    height: 80,
                                                    color: Colors.black.withOpacity(0.5),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Badge avec le nombre de likes
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: roseColor,
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.favorite, color: Colors.white, size: 16),
                                                SizedBox(width: 4),
                                                Text(
                                                  '10',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Likes',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              // Profils des matchs
                              ..._buildMatchProfiles(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  
                  // Filtres de messages
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildFilterChip(label: 'Tous', isSelected: _currentFilter == 'Tous'),
                        const SizedBox(width: 8),
                        _buildFilterChip(label: 'Non lus', isSelected: _currentFilter == 'Non lus'),
                        const SizedBox(width: 8),
                        _buildFilterChip(label: 'Matchs', isSelected: _currentFilter == 'Matchs'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Liste des conversations
                  Expanded(
                    child: _filteredConversations.isNotEmpty
                        ? ListView.builder(
                            itemCount: _filteredConversations.length,
                            itemBuilder: (context, index) {
                              return _buildConversationTile(_filteredConversations[index]);
                            },
                          )
                        : const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.chat_bubble_outline, 
                                  size: 80, color: lightGreyColor),
                                SizedBox(height: 16),
                                Text(
                                  'Pas encore de messages',
                                  style: TextStyle(
                                    color: greyColor,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Commencez à discuter avec vos matchs',
                                  style: TextStyle(
                                    color: greyColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
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
                        _buildNavBarItem(icon: Icons.whatshot, isSelected: false, route: '/trends'),
                        _buildNavBarItem(icon: Icons.notifications_outlined, isSelected: false, route: '/notifications'),
                        _buildNavBarItem(icon: Icons.forum_outlined, isSelected: true, route: '/messages'),
                        _buildNavBarItem(icon: Icons.person_outline, isSelected: false, route: '/home'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  // Filtre de messages
  Widget _buildFilterChip({required String label, required bool isSelected}) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : greyColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: roseColor,
      backgroundColor: lightGreyColor,
      onSelected: (selected) {
        // Mettre à jour le filtre sélectionné
        if (selected) {
          setState(() {
            _currentFilter = label;
          });
        }
      },
    );
  }
  
  // Construire une tuile de conversation
  Widget _buildConversationTile(Map<String, dynamic> conversation) {
    return InkWell(
      onTap: () {
        // Ouvrir la conversation
        Navigator.pushNamed(
          context,
          '/chat',
          arguments: {
            'userId': 'user_${conversation['name'].hashCode}', // Fictif pour l'exemple
            'userName': conversation['name'],
            'userImage': conversation['image'],
          },
        );
        
        // Marquer comme lu
        if (conversation['unread']) {
          setState(() {
            final index = _conversations.indexWhere((c) => c['name'] == conversation['name']);
            if (index != -1) {
              _conversations[index]['unread'] = false;
            }
          });
        }
      },
      onLongPress: () {
        // Afficher le menu de suppression
        _showConversationOptions(conversation);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: conversation['unread'] ? lightGreyColor.withOpacity(0.2) : Colors.white,
          border: Border(
            bottom: BorderSide(
              color: lightGreyColor,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Photo de profil
            Stack(
              children: [
                _buildProfileAvatar(
                  imageUrl: conversation['image'],
                  radius: 28,
                  iconSize: 30,
                ),
                if (conversation['unread'])
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      height: 14,
                      width: 14,
                      decoration: const BoxDecoration(
                        color: roseColor,
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                          BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Informations de la conversation
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        conversation['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: conversation['unread'] 
                            ? FontWeight.bold 
                            : FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        conversation['time'],
                        style: TextStyle(
                          fontSize: 12,
                          color: conversation['unread'] 
                            ? roseColor 
                            : greyColor,
                          fontWeight: conversation['unread'] 
                            ? FontWeight.bold 
                            : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation['lastMessage'],
                    style: TextStyle(
                      fontSize: 14,
                      color: conversation['unread'] 
                        ? Colors.black 
                        : greyColor,
                      fontWeight: conversation['unread'] 
                        ? FontWeight.bold 
                        : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
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
  
  // Méthode pour construire les profils de matchs
  List<Widget> _buildMatchProfiles() {
    final matchProfiles = [
      {
        'name': 'Sandrine',
        'image': 'https://randomuser.me/api/portraits/women/68.jpg',
        'hasIndicator': true,
      },
      {
        'name': 'Haras',
        'image': 'https://randomuser.me/api/portraits/women/44.jpg',
        'hasIndicator': false,
      },
      {
        'name': 'Ariel',
        'image': 'https://randomuser.me/api/portraits/women/63.jpg',
        'hasIndicator': true,
      },
      {
        'name': 'Marina',
        'image': 'https://randomuser.me/api/portraits/women/90.jpg',
        'hasIndicator': true,
      },
      {
        'name': 'Grâce Mal...',
        'image': 'https://randomuser.me/api/portraits/women/54.jpg',
        'hasIndicator': true,
      },
      {
        'name': 'Mignonne',
        'image': 'https://randomuser.me/api/portraits/women/72.jpg',
        'hasIndicator': true,
      },
    ];
    
    return matchProfiles.map((profile) {
      return GestureDetector(
        onTap: () {
          // Ouvrir le chat avec ce match
          Navigator.pushNamed(
            context,
            '/chat',
            arguments: {
              'userId': 'user_${profile['name'].hashCode}', // Fictif pour l'exemple
              'userName': profile['name'] as String,
              'userImage': profile['image'] as String,
            },
          );
          
          // Supprimer l'indicateur rouge
          setState(() {
            final index = matchProfiles.indexWhere((p) => p['name'] == profile['name']);
            if (index != -1) {
              matchProfiles[index]['hasIndicator'] = false;
            }
          });
        },
        child: Container(
          width: 90,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              Stack(
                children: [
                  // Photo de profil
                  _buildProfileAvatar(
                    imageUrl: profile['image'] as String,
                    radius: 40,
                    iconSize: 40,
                  ),
                  // Indicateur rouge (nouveau match)
                  if (profile['hasIndicator'] as bool)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: roseColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                profile['name'] as String,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
  
  // Afficher la boîte de dialogue premium
  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Accès Premium requis',
            style: TextStyle(
              color: roseColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Découvrez qui vous a aimé en passant à Lisolove Premium !',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '10 personnes ont aimé votre profil. Souscrivez à Premium pour voir qui elles sont et augmenter vos chances de match !',
                style: TextStyle(
                  color: greyColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Plus tard',
                style: TextStyle(color: greyColor),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Action pour acheter Premium
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Redirection vers la page d\'abonnement'),
                    backgroundColor: roseColor,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: roseColor,
                foregroundColor: Colors.white,
              ),
              child: Text('Souscrire maintenant'),
            ),
          ],
        );
      },
    );
  }
  
  // Afficher les options pour une conversation
  void _showConversationOptions(Map<String, dynamic> conversation) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: greyColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(
                  Icons.notifications_off,
                  color: Colors.black,
                ),
                title: Text(
                  'Désactiver les notifications',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(
                  Icons.block,
                  color: Colors.red.shade700,
                ),
                title: Text(
                  'Bloquer',
                  style: TextStyle(
                    color: Colors.red.shade700,
                  ),
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                title: Text(
                  'Supprimer la conversation',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteConversation(conversation);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
  
  // Supprimer une conversation
  void _deleteConversation(Map<String, dynamic> conversation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer cette conversation ?'),
          content: Text('Votre conversation avec ${conversation['name']} sera supprimée. Cette action est irréversible.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Annuler',
                style: TextStyle(color: greyColor),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  // Supprimer la conversation de la liste
                  _conversations.removeWhere((c) => c['name'] == conversation['name']);
                });
                
                // Afficher une confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Conversation avec ${conversation['name']} supprimée'),
                    duration: const Duration(seconds: 3),
                    action: SnackBarAction(
                      label: 'Annuler',
                      textColor: Colors.white,
                      onPressed: () {
                        setState(() {
                          // Remettre la conversation dans la liste
                          _conversations.add(conversation);
                          // Trier les conversations selon l'ordre original (ici simplement par nom)
                          _conversations.sort((a, b) => a['name'].compareTo(b['name']));
                        });
                      },
                    ),
                  ),
                );
              },
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
} 