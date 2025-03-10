import 'package:flutter/material.dart';
import '../services/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Définition des couleurs de l'application
  static const Color roseColor = Color(0xFFF3004E);
  static const Color greyColor = Color(0xFF888888);
  static const Color lightGreyColor = Color(0xFFF5F5F5);
  
  // Exemples de notifications
  final List<Map<String, dynamic>> _notifications = [
    {
      'type': 'like',
      'message': 'Emma a aimé votre profil',
      'image': 'https://randomuser.me/api/portraits/women/68.jpg',
      'time': DateTime.now().subtract(const Duration(minutes: 5)),
      'read': false,
    },
    {
      'type': 'match',
      'message': 'Vous avez un nouveau match avec Sophie',
      'image': 'https://randomuser.me/api/portraits/women/44.jpg',
      'time': DateTime.now().subtract(const Duration(hours: 3)),
      'read': false,
    },
    {
      'type': 'message',
      'message': 'Julie vous a envoyé un message',
      'image': 'https://randomuser.me/api/portraits/women/63.jpg',
      'time': DateTime.now().subtract(const Duration(hours: 12)),
      'read': true,
    },
    {
      'type': 'system',
      'message': 'Complétez votre profil pour augmenter vos chances',
      'image': '',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'read': true,
    },
    {
      'type': 'like',
      'message': 'Clara a aimé votre profil',
      'image': 'https://randomuser.me/api/portraits/women/90.jpg',
      'time': DateTime.now().subtract(const Duration(days: 2)),
      'read': true,
    },
  ];

  // Formater l'heure des notifications
  String _formatNotificationTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inSeconds < 60) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} j';
    } else {
      return DateFormat('dd/MM').format(time);
    }
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
                        const Text(
                          'Notifications',
                          style: TextStyle(
                            color: roseColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                        Flexible(
                          child: TextButton(
                            onPressed: () {
                              // Marquer toutes les notifications comme lues
                              setState(() {
                                for (var notification in _notifications) {
                                  notification['read'] = true;
                                }
                              });
                            },
                            child: const Text(
                              'Tout marquer comme lu',
                              style: TextStyle(
                                color: roseColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Liste des notifications
                  Expanded(
                    child: _notifications.isNotEmpty
                        ? ListView.builder(
                            itemCount: _notifications.length,
                            itemBuilder: (context, index) {
                              return _buildNotificationTile(_notifications[index]);
                            },
                          )
                        : const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.notifications_none, 
                                  size: 80, color: lightGreyColor),
                                SizedBox(height: 16),
                                Text(
                                  'Pas de notifications',
                                  style: TextStyle(
                                    color: greyColor,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    'Restez à l\'écoute pour les activités sur votre profil',
                                    style: TextStyle(
                                      color: greyColor,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
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
                        _buildNavBarItem(icon: Icons.notifications_outlined, isSelected: true, route: '/notifications'),
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
  
  // Construire une tuile de notification
  Widget _buildNotificationTile(Map<String, dynamic> notification) {
    // Déterminer l'icône en fonction du type de notification
    IconData icon;
    Color iconColor;
    
    switch(notification['type']) {
      case 'like':
        icon = Icons.favorite;
        iconColor = roseColor;
        break;
      case 'match':
        icon = Icons.favorite_border;
        iconColor = roseColor;
        break;
      case 'message':
        icon = Icons.chat_bubble;
        iconColor = Colors.blue;
        break;
      case 'system':
      default:
        icon = Icons.notifications;
        iconColor = Colors.amber;
        break;
    }
    
    return InkWell(
      onTap: () {
        // Marquer la notification comme lue
        setState(() {
          notification['read'] = true;
        });
        
        // Action spécifique selon le type de notification
        switch(notification['type']) {
          case 'like':
            // Aller au profil qui a liké
            break;
          case 'match':
          case 'message':
            // Ouvrir la conversation
            if (notification['image'].isNotEmpty) {
              Navigator.pushNamed(
                context,
                '/chat',
                arguments: {
                  'userId': 'user_${notification['message'].hashCode}', // Fictif pour l'exemple
                  'userName': notification['message'].split(' ')[0], // Extraire le nom
                  'userImage': notification['image'],
                },
              );
            }
            break;
          case 'system':
            // Aller à l'écran approprié (ex: édition de profil)
            Navigator.pushNamed(context, '/edit_profile');
            break;
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: notification['read'] ? Colors.white : lightGreyColor.withOpacity(0.3),
          border: Border(
            bottom: BorderSide(
              color: lightGreyColor,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Photo de profil ou icône
            notification['image'].isNotEmpty
                ? CircleAvatar(
                    radius: 24,
                    backgroundColor: lightGreyColor,
                    child: ClipOval(
                      child: Image.network(
                        notification['image'],
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                          Icon(icon, color: iconColor),
                      ),
                    ),
                  )
                : CircleAvatar(
                    radius: 24,
                    backgroundColor: lightGreyColor,
                    child: Icon(icon, color: iconColor),
                  ),
            const SizedBox(width: 16),
            // Contenu de la notification
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    notification['message'],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: notification['read'] 
                          ? FontWeight.normal 
                          : FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatNotificationTime(notification['time']),
                    style: const TextStyle(
                      fontSize: 13,
                      color: greyColor,
                    ),
                  ),
                ],
              ),
            ),
            // Indicateur de non lu
            if (!notification['read'])
              Container(
                height: 10,
                width: 10,
                margin: const EdgeInsets.only(left: 8),
                decoration: const BoxDecoration(
                  color: roseColor,
                  shape: BoxShape.circle,
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
} 