import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String userImage;
  
  const ChatScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Définition des couleurs de l'application
  static const Color roseColor = Color(0xFFF3004E);
  static const Color greyColor = Color(0xFF888888);
  static const Color lightGreyColor = Color(0xFFF5F5F5);
  
  // Contrôleur pour le champ de texte du message
  final TextEditingController _messageController = TextEditingController();
  
  // États d'UI
  bool _isSending = false;
  bool _isRecording = false;
  bool _showAudioOptions = false;
  bool _imageLoadingError = false;
  
  // Simuler le solde de crédits de l'utilisateur
  int _userCredits = 500;
  
  // Liste des cadeaux disponibles
  final List<Map<String, dynamic>> _availableGifts = [
    {
      'id': 'rose',
      'name': 'Rose',
      'icon': '🌹',
      'price': 50,
      'description': 'Une rose pour montrer votre affection'
    },
    {
      'id': 'heart',
      'name': 'Cœur',
      'icon': '❤️',
      'price': 100,
      'description': 'Un cœur pour déclarer votre amour'
    },
    {
      'id': 'diamond',
      'name': 'Diamant',
      'icon': '💎',
      'price': 200,
      'description': 'Un diamant pour impressionner'
    },
    {
      'id': 'gift',
      'name': 'Cadeau',
      'icon': '🎁',
      'price': 150,
      'description': 'Un cadeau mystérieux'
    },
    {
      'id': 'credits',
      'name': '100 Crédits',
      'icon': '💰',
      'price': 100,
      'description': 'Envoyez 100 crédits directement'
    },
  ];
  
  // Exemples de messages (à remplacer par des messages réels)
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Salut ! Comment vas-tu ?',
      'isMe': true,
      'time': DateTime.now().subtract(const Duration(hours: 1)),
      'read': true,
      'type': 'text',
    },
    {
      'text': 'Très bien merci, et toi ?',
      'isMe': false,
      'time': DateTime.now().subtract(const Duration(minutes: 55)),
      'read': true,
      'type': 'text',
    },
    {
      'text': 'Ça va ! Qu\'est-ce que tu fais ce week-end ?',
      'isMe': true,
      'time': DateTime.now().subtract(const Duration(minutes: 50)),
      'read': true,
      'type': 'text',
    },
    {
      'text': '0:12', // Durée du message audio
      'isMe': false,
      'time': DateTime.now().subtract(const Duration(minutes: 45)),
      'read': true,
      'type': 'audio',
    },
    {
      'text': 'On pourrait aller prendre un verre si ça te dit ?',
      'isMe': true,
      'time': DateTime.now().subtract(const Duration(minutes: 25)),
      'read': true,
      'type': 'text',
    },
    {
      'text': 'Oui, ça me plairait beaucoup !',
      'isMe': false,
      'time': DateTime.now().subtract(const Duration(minutes: 5)),
      'read': false,
      'type': 'text',
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
  
  // Formater l'heure des messages
  String _formatMessageTime(DateTime time) {
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
  
  // Envoyer un message
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    setState(() {
      _isSending = true;
    });
    
    // Simuler l'envoi d'un message
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'text': _messageController.text.trim(),
            'isMe': true,
            'time': DateTime.now(),
            'read': false,
            'type': 'text',
          });
          _messageController.clear();
          _isSending = false;
        });
      }
    });
  }
  
  // Simuler l'envoi d'un message audio
  void _sendAudioMessage() {
    setState(() {
      _isRecording = false;
      _showAudioOptions = false;
      _isSending = true;
    });
    
    // Simuler l'envoi d'un message audio (durée fictive de 0:08)
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'text': '0:08',
            'isMe': true,
            'time': DateTime.now(),
            'read': false,
            'type': 'audio',
          });
          _isSending = false;
        });
      }
    });
  }
  
  // Envoyer un cadeau
  void _sendGift(Map<String, dynamic> gift) {
    if (_userCredits < gift['price']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Crédits insuffisants pour envoyer ce cadeau'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isSending = true;
    });
    
    // Simuler l'envoi d'un cadeau
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          // Déduire le coût du cadeau
          _userCredits -= gift['price'] as int;
          
          // Ajouter le message de cadeau
          _messages.add({
            'text': gift['id'] == 'credits' ? '100' : gift['icon'],
            'isMe': true,
            'time': DateTime.now(),
            'read': false,
            'type': 'gift',
            'giftName': gift['name'],
            'giftId': gift['id'],
          });
          
          _isSending = false;
        });
      }
    });
  }
  
  // Afficher le menu des cadeaux
  void _showGiftsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Envoyer un cadeau',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.monetization_on, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '$_userCredits crédits',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: roseColor),
                            onPressed: () {
                              Navigator.pop(context);
                              _showBuyCreditsDialog();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: _availableGifts.length,
                      itemBuilder: (context, index) {
                        final gift = _availableGifts[index];
                        final bool canAfford = _userCredits >= gift['price'];
                        
                        return GestureDetector(
                          onTap: canAfford ? () {
                            Navigator.pop(context);
                            _showGiftConfirmation(gift);
                          } : null,
                          child: Container(
                            decoration: BoxDecoration(
                              color: canAfford ? lightGreyColor : lightGreyColor.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: canAfford ? roseColor : greyColor,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  gift['icon'],
                                  style: const TextStyle(fontSize: 32),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  gift['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: canAfford ? Colors.black : greyColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.monetization_on, 
                                      size: 16, 
                                      color: canAfford ? Colors.amber : greyColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${gift['price']}',
                                      style: TextStyle(
                                        color: canAfford ? Colors.black : greyColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  // Afficher la boîte de dialogue de confirmation d'envoi de cadeau
  void _showGiftConfirmation(Map<String, dynamic> gift) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Envoyer ${gift['name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: lightGreyColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    gift['icon'],
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(gift['description']),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Coût: '),
                  const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                  Text(
                    ' ${gift['price']} crédits',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
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
              style: ElevatedButton.styleFrom(backgroundColor: roseColor),
              onPressed: () {
                Navigator.pop(context);
                _sendGift(gift);
              },
              child: const Text('Envoyer'),
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Sélectionnez un montant de crédits à acheter'),
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
    final String currency = '\$'; // ou 'FC' pour francs congolais
    
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$amount crédits',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '$currency$price',
                  style: const TextStyle(
                    color: greyColor,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
  
  // Afficher les options de chat
  void _showChatOptions() {
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
              _buildOptionTile(
                icon: Icons.edit,
                title: 'Éditer surnom',
                onTap: () => Navigator.pop(context),
              ),
              _buildOptionTile(
                icon: Icons.lock,
                title: 'Conversation secrète',
                onTap: () => Navigator.pop(context),
              ),
              _buildOptionTile(
                icon: Icons.search,
                title: 'Rechercher dans la conversation',
                onTap: () => Navigator.pop(context),
              ),
              _buildOptionTile(
                icon: Icons.photo_library,
                title: 'Médias partagés',
                onTap: () => Navigator.pop(context),
              ),
              _buildOptionTile(
                icon: Icons.notifications_off,
                title: 'Désactiver les notifications',
                onTap: () => Navigator.pop(context),
              ),
              _buildOptionTile(
                icon: Icons.flag,
                title: 'Signaler',
                onTap: () => Navigator.pop(context),
                isDestructive: true,
              ),
              _buildOptionTile(
                icon: Icons.block,
                title: 'Bloquer',
                onTap: () => Navigator.pop(context),
                isDestructive: true,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
  
  // Construire une tuile d'option
  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black,
        ),
      ),
      onTap: onTap,
    );
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
  
  // Simuler un appel
  void _initiateCall(bool isVideo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: roseColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildProfileAvatar(
                      imageUrl: widget.userImage,
                      radius: 50,
                      iconSize: 50,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isVideo ? 'Appel vidéo en cours...' : 'Appel en cours...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey.shade200,
                      child: IconButton(
                        icon: Icon(
                          isVideo ? Icons.videocam_off : Icons.mic_off,
                          color: Colors.black,
                        ),
                        onPressed: () {},
                      ),
                    ),
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.red,
                      child: IconButton(
                        icon: const Icon(
                          Icons.call_end,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey.shade200,
                      child: IconButton(
                        icon: const Icon(
                          Icons.volume_up,
                          color: Colors.black,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () {
            // Naviguer vers la vue de profil ou vers la page d'accueil si la vue de profil n'existe pas
            try {
              Navigator.pushNamed(
                context,
                '/profile_view',
                arguments: {
                  'userId': widget.userId,
                  'userName': widget.userName,
                  'userImage': widget.userImage,
                },
              );
            } catch (e) {
              // Si la route profile_view n'existe pas, on revient à la page d'accueil
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vue de profil en cours de développement'),
                  duration: Duration(seconds: 2),
                ),
              );
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
          child: Row(
            children: [
              _buildProfileAvatar(
                imageUrl: widget.userImage,
                radius: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.userName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Bouton d'appel audio
          IconButton(
            icon: const Icon(Icons.call, color: roseColor),
            onPressed: () => _initiateCall(false),
          ),
          // Bouton d'appel vidéo
          IconButton(
            icon: const Icon(Icons.videocam, color: roseColor),
            onPressed: () => _initiateCall(true),
          ),
          // Options
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: _showChatOptions,
          ),
        ],
      ),
      body: authProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: roseColor))
          : Column(
              children: [
                // Liste des messages
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      // Les messages sont affichés du plus récent au plus ancien
                      final message = _messages[_messages.length - 1 - index];
                      return _buildMessageBubble(message);
                    },
                  ),
                ),
                
                // Barre d'envoi de message
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    children: [
                      // Bouton d'ajout de médias
                      IconButton(
                        icon: const Icon(Icons.add_photo_alternate, color: greyColor),
                        onPressed: () {
                          // Ajouter une image ou autre média
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fonctionnalité en développement'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      
                      // Bouton d'envoi de cadeau
                      IconButton(
                        icon: const Icon(Icons.card_giftcard, color: roseColor),
                        onPressed: _showGiftsMenu,
                      ),
                      
                      // Champ de texte (masqué pendant l'enregistrement audio)
                      if (!_isRecording)
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Tapez un message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: lightGreyColor,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: null,
                          ),
                        )
                      // Affichage pendant l'enregistrement audio
                      else
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: lightGreyColor,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.mic, 
                                  color: roseColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Enregistrement audio...',
                                    style: TextStyle(color: greyColor),
                                  ),
                                ),
                                if (_showAudioOptions) ...[
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isRecording = false;
                                        _showAudioOptions = false;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ],
                            ),
                          ),
                        ),
                      
                      const SizedBox(width: 8),
                      
                      // Bouton d'envoi ou microphone
                      if (!_isRecording && _messageController.text.isNotEmpty)
                        // Bouton d'envoi de texte
                        _isSending
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: roseColor,
                                ),
                              )
                            : GestureDetector(
                                onTap: _sendMessage,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: roseColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              )
                      else if (_isRecording)
                        // Bouton d'envoi du message audio
                        GestureDetector(
                          onTap: _sendAudioMessage,
                          onLongPress: () {
                            setState(() {
                              _showAudioOptions = true;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: roseColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        )
                      else
                        // Bouton pour démarrer l'enregistrement audio
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isRecording = true;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: lightGreyColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.mic,
                              color: roseColor,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
  
  // Construire une bulle de message
  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['isMe'] as bool;
    final isAudio = message['type'] == 'audio';
    final isDeleted = message['type'] == 'deleted';
    final isGift = message['type'] == 'gift';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Message
          GestureDetector(
            onLongPress: isMe && !isDeleted && !isGift ? () => _showMessageOptions(message) : null,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isGift 
                      ? Colors.amber.withOpacity(0.2)
                      : (isDeleted 
                          ? lightGreyColor.withOpacity(0.5) 
                          : (isMe ? roseColor : lightGreyColor)),
                  borderRadius: BorderRadius.circular(16).copyWith(
                    bottomRight: isMe ? const Radius.circular(0) : null,
                    bottomLeft: !isMe ? const Radius.circular(0) : null,
                  ),
                  border: isGift ? Border.all(color: Colors.amber) : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Contenu du message (texte, audio, cadeau)
                    if (isDeleted)
                      // Message supprimé
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.do_not_disturb_on,
                            color: greyColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Message supprimé',
                            style: TextStyle(
                              color: greyColor,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      )
                    else if (isGift)
                      // Message cadeau
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            message['text'],
                            style: const TextStyle(fontSize: 40),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            message['giftId'] == 'credits'
                                ? 'Vous avez envoyé 100 crédits'
                                : 'Vous avez envoyé ${message['giftName']}',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    else if (isAudio)
                      // Message audio
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_arrow,
                            color: isMe ? Colors.white : Colors.black,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 120,
                            height: 30,
                            decoration: BoxDecoration(
                              color: isMe 
                                  ? Colors.white.withOpacity(0.2) 
                                  : Colors.black.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Stack(
                                      alignment: Alignment.centerLeft,
                                      children: [
                                        Container(
                                          height: 2,
                                          color: isMe 
                                              ? Colors.white.withOpacity(0.6) 
                                              : Colors.black.withOpacity(0.3),
                                        ),
                                        Container(
                                          height: 2,
                                          width: 40,
                                          color: isMe ? Colors.white : Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Text(
                                    message['text'], // Durée
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      // Message texte
                      Text(
                        message['text'],
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatMessageTime(message['time']),
                          style: TextStyle(
                            color: isGift
                                ? Colors.black54
                                : (isDeleted 
                                    ? greyColor
                                    : (isMe ? Colors.white.withOpacity(0.7) : greyColor)),
                            fontSize: 12,
                          ),
                        ),
                        if (isMe && !isDeleted) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message['read'] ? Icons.done_all : Icons.done,
                            size: 16,
                            color: isGift
                                ? Colors.black54
                                : (message['read'] 
                                    ? Colors.white.withOpacity(0.7) 
                                    : Colors.white.withOpacity(0.5)),
                          ),
                        ],
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
  }
  
  // Afficher les options pour un message
  void _showMessageOptions(Map<String, dynamic> message) {
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
              _buildOptionTile(
                icon: Icons.reply,
                title: 'Répondre',
                onTap: () => Navigator.pop(context),
              ),
              _buildOptionTile(
                icon: Icons.content_copy,
                title: 'Copier',
                onTap: () => Navigator.pop(context),
              ),
              _buildOptionTile(
                icon: Icons.forward,
                title: 'Transférer',
                onTap: () => Navigator.pop(context),
              ),
              _buildOptionTile(
                icon: Icons.delete,
                title: 'Supprimer',
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessage(message);
                },
                isDestructive: true,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
  
  // Supprimer un message
  void _deleteMessage(Map<String, dynamic> message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer ce message ?'),
          content: const Text('Le message sera supprimé pour tout le monde.'),
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
                  final index = _messages.indexWhere((m) => 
                    m['text'] == message['text'] && 
                    m['time'] == message['time']);
                  
                  if (index != -1) {
                    // Convertir le message en "supprimé"
                    _messages[index] = {
                      'text': 'Message supprimé',
                      'isMe': message['isMe'],
                      'time': message['time'],
                      'read': message['read'],
                      'type': 'deleted',
                    };
                  }
                });
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