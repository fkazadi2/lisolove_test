import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Définition des couleurs de l'application
  static const Color roseColor = Color(0xFFF3004E);
  static const Color tealColor = Colors.teal;
  static const Color greyColor = Color(0xFF888888);
  static const Color lightGreyColor = Color(0xFFF5F5F5);
  // Status en ligne
  bool _isOnlineStatus = true;
  
  // Options de confidentialité
  bool _showProfileInSearch = true;
  bool _showProfileInNearby = true;
  bool _showProfileInMatches = true;
  
  // Nouvelles options pour les notifications
  bool _enablePushNotifications = true;
  bool _enableEmailNotifications = false;
  bool _enableMatchNotifications = true;
  bool _enableMessageNotifications = true;
  
  // Indicateurs de chargement
  bool _isLoadingCache = false;
  bool _isLoadingSettings = true;
  
  @override
  void initState() {
    super.initState();
    // Charger les paramètres utilisateur
    _loadUserSettings();
  }
  
  // Simuler le chargement des paramètres utilisateur depuis l'API
  Future<void> _loadUserSettings() async {
    setState(() {
      _isLoadingSettings = true;
    });
    
    // Simuler un délai de chargement
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Récupérer les paramètres depuis le provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userData = authProvider.userData;
    
    // On pourrait charger les paramètres réels ici si disponibles
    // Pour l'exemple, nous utilisons des valeurs par défaut
    setState(() {
      _isOnlineStatus = userData?.containsKey('isOnline') == true 
          ? userData!['isOnline'] : true;
      _showProfileInSearch = userData?.containsKey('showInSearch') == true 
          ? userData!['showInSearch'] : true;
      _showProfileInNearby = userData?.containsKey('showInNearby') == true 
          ? userData!['showInNearby'] : true;
      _showProfileInMatches = userData?.containsKey('showInMatches') == true 
          ? userData!['showInMatches'] : true;
      
      _enablePushNotifications = true;
      _enableEmailNotifications = false;
      _enableMatchNotifications = true;
      _enableMessageNotifications = true;
      
      _isLoadingSettings = false;
    });
  }
  
  // Sauvegarder les paramètres de l'utilisateur
  Future<void> _saveUserSettings() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Ici, on enverrait les paramètres mis à jour à l'API
    // Pour l'exemple, on affiche simplement un message de succès
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Paramètres mis à jour avec succès'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  // Calculer la taille du cache (valeur simulée)
  String _getCacheSize() {
    return '24.5 MB';
  }
  
  // Vider le cache
  Future<void> _clearCache() async {
    setState(() {
      _isLoadingCache = true;
    });
    
    // Simuler un délai pour le vidage du cache
    await Future.delayed(const Duration(milliseconds: 1200));
    
    setState(() {
      _isLoadingCache = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cache vidé avec succès'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Réglages',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: tealColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Bouton de sauvegarde des paramètres
          TextButton.icon(
            onPressed: _saveUserSettings,
            icon: const Icon(Icons.save_outlined, size: 18, color: roseColor),
            label: const Text(
              'Enregistrer',
              style: TextStyle(color: roseColor),
            ),
          ),
        ],
      ),
      body: _isLoadingSettings
          ? const Center(
              child: CircularProgressIndicator(color: roseColor),
            )
          : ListView(
              children: [
                // Mon compte
                _buildSettingItem(
                  title: 'Mon compte',
                  subtitle: authProvider.userData?['name'] ?? 'Non défini',
                  icon: Icons.person_outline,
                  iconColor: roseColor,
                  onTap: () {
                    // Naviguer vers l'écran de compte
                    Navigator.of(context).pushNamed('/edit-profile');
                  },
                ),
                _buildDivider(),
                
                // Mot de passe
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSettingItem(
                      title: 'Mot de passe',
                      subtitle: 'Dernière modification: il y a 30 jours',
                      icon: Icons.lock_outline,
                      iconColor: roseColor,
                      showArrow: false,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                      child: GestureDetector(
                        onTap: () {
                          // Afficher la boîte de dialogue de changement de mot de passe
                          _showChangePasswordDialog();
                        },
                        child: const Text(
                          'Changer de mot de passe',
                          style: TextStyle(
                            color: roseColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                _buildDivider(),
                
                // Mes réseaux sociaux
                _buildSettingItem(
                  title: 'Mes réseaux sociaux',
                  subtitle: 'Facebook, Instagram, Twitter',
                  icon: Icons.public,
                  iconColor: roseColor,
                  onTap: () {
                    // Naviguer vers l'écran des réseaux sociaux
                  },
                ),
                _buildDivider(),
                
                // Utilisateurs bloqués
                _buildSettingItem(
                  title: 'Utilisateurs bloqués',
                  subtitle: '0 utilisateur',
                  icon: Icons.block,
                  iconColor: roseColor,
                  onTap: () {
                    // Naviguer vers l'écran des utilisateurs bloqués
                  },
                ),
                _buildDivider(),
                
                // Messenger
                _buildSectionTitle('Messenger'),
                _buildToggleItem(
                  title: 'Statut En ligne',
                  subtitle: 'Les autres utilisateurs verront quand vous êtes en ligne',
                  icon: Icons.circle,
                  iconColor: _isOnlineStatus ? Colors.green : Colors.grey,
                  value: _isOnlineStatus,
                  onChanged: (value) {
                    setState(() {
                      _isOnlineStatus = value;
                    });
                  },
                ),
                _buildDivider(),
                
                // Confidentialité
                _buildSectionTitle('Confidentialité'),
                _buildToggleItem(
                  title: 'Afficher mon profil dans les moteurs de recherches?',
                  subtitle: 'Permet aux utilisateurs de vous trouver via les moteurs de recherche',
                  icon: Icons.search,
                  iconColor: roseColor,
                  value: _showProfileInSearch,
                  onChanged: (value) {
                    setState(() {
                      _showProfileInSearch = value;
                    });
                  },
                ),
                _buildDivider(),
                
                _buildToggleItem(
                  title: 'Afficher mon profil dans « À proximité »?',
                  subtitle: 'Les utilisateurs proches pourront voir votre profil',
                  icon: Icons.location_on_outlined,
                  iconColor: roseColor,
                  value: _showProfileInNearby,
                  onChanged: (value) {
                    setState(() {
                      _showProfileInNearby = value;
                    });
                  },
                ),
                _buildDivider(),
                
                _buildToggleItem(
                  title: 'Afficher mon profil dans la page de matches?',
                  subtitle: 'Votre profil sera visible dans les suggestions de matches',
                  icon: Icons.favorite_border,
                  iconColor: roseColor,
                  value: _showProfileInMatches,
                  onChanged: (value) {
                    setState(() {
                      _showProfileInMatches = value;
                    });
                  },
                ),
                _buildDivider(),
                
                // Notifications (Nouvelle section)
                _buildSectionTitle('Notifications'),
                _buildToggleItem(
                  title: 'Notifications push',
                  subtitle: 'Recevoir des notifications push sur votre appareil',
                  icon: Icons.notifications_outlined,
                  iconColor: roseColor,
                  value: _enablePushNotifications,
                  onChanged: (value) {
                    setState(() {
                      _enablePushNotifications = value;
                    });
                  },
                ),
                _buildDivider(),
                
                _buildToggleItem(
                  title: 'Notifications par email',
                  subtitle: 'Recevoir des notifications par email',
                  icon: Icons.email_outlined,
                  iconColor: roseColor,
                  value: _enableEmailNotifications,
                  onChanged: (value) {
                    setState(() {
                      _enableEmailNotifications = value;
                    });
                  },
                ),
                _buildDivider(),
                
                _buildToggleItem(
                  title: 'Notifications de match',
                  subtitle: 'Être notifié quand vous avez un nouveau match',
                  icon: Icons.favorite_border,
                  iconColor: roseColor,
                  value: _enableMatchNotifications,
                  onChanged: (value) {
                    setState(() {
                      _enableMatchNotifications = value;
                    });
                  },
                ),
                _buildDivider(),
                
                _buildToggleItem(
                  title: 'Notifications de message',
                  subtitle: 'Être notifié quand vous recevez un nouveau message',
                  icon: Icons.message_outlined,
                  iconColor: roseColor,
                  value: _enableMessageNotifications,
                  onChanged: (value) {
                    setState(() {
                      _enableMessageNotifications = value;
                    });
                  },
                ),
                _buildDivider(),
                
                // Paiements
                _buildSettingItem(
                  title: 'Paiements',
                  subtitle: 'Gérer vos méthodes de paiement et abonnements',
                  icon: Icons.payment,
                  iconColor: roseColor,
                  onTap: () {
                    // Naviguer vers l'écran des paiements
                  },
                ),
                _buildDivider(),
                
                // Stockage
                _buildSectionTitle('Stockage'),
                _buildSettingItem(
                  title: 'Cache',
                  subtitle: 'Taille actuelle: ${_getCacheSize()}',
                  icon: Icons.storage_outlined,
                  iconColor: roseColor,
                  trailing: _isLoadingCache 
                      ? const SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2, color: roseColor)
                        )
                      : null,
                  onTap: () {
                    // Afficher les informations de cache
                    _showClearCacheDialog();
                  },
                ),
                _buildDivider(),
                
                // Support
                _buildSectionTitle('Support'),
                _buildSettingItem(
                  title: 'Aide',
                  subtitle: 'FAQs et guides d\'utilisation',
                  icon: Icons.help_outline,
                  iconColor: roseColor,
                  onTap: () {
                    // Naviguer vers l'écran d'aide
                  },
                ),
                _buildDivider(),
                
                // À propos
                _buildSettingItem(
                  title: 'À propos',
                  subtitle: 'Version 1.0.0',
                  icon: Icons.info_outline,
                  iconColor: roseColor,
                  onTap: () {
                    // Afficher les informations sur l'application
                    _showAboutDialog();
                  },
                ),
                _buildDivider(),
                
                // Contact
                _buildSettingItem(
                  title: 'Contact',
                  subtitle: 'Contactez notre équipe de support',
                  icon: Icons.mail_outline,
                  iconColor: roseColor,
                  onTap: () {
                    // Naviguer vers l'écran de contact
                  },
                ),
                _buildDivider(),
                
                // Supprimer mon compte
                _buildSettingItem(
                  title: 'Supprimer mon compte',
                  subtitle: 'Supprimer définitivement votre compte et vos données',
                  icon: Icons.delete_outline,
                  textColor: Colors.red,
                  iconColor: Colors.red,
                  onTap: () {
                    // Afficher la confirmation de suppression de compte
                    _showDeleteAccountDialog();
                  },
                ),
                _buildDivider(),
                
                // Se déconnecter
                _buildSettingItem(
                  title: 'Se déconnecter',
                  subtitle: 'Déconnecter votre compte',
                  icon: Icons.exit_to_app,
                  iconColor: roseColor,
                  onTap: () {
                    // Déconnecter l'utilisateur
                    _showLogoutDialog(authProvider);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
  
  Widget _buildSettingItem({
    required String title,
    String? subtitle,
    IconData? icon,
    Color textColor = Colors.black,
    Color iconColor = Colors.blue,
    VoidCallback? onTap,
    bool showArrow = true,
    Widget? trailing,
  }) {
    return ListTile(
      leading: icon != null 
          ? Icon(icon, color: iconColor) 
          : null,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: textColor,
        ),
      ),
      subtitle: subtitle != null 
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            )
          : null,
      onTap: onTap,
      trailing: trailing ?? (showArrow ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey) : null),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
  
  Widget _buildToggleItem({
    required String title,
    String? subtitle,
    IconData? icon,
    Color iconColor = Colors.blue,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: icon != null 
          ? Icon(icon, color: iconColor) 
          : null,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: roseColor,
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: Colors.grey.shade300,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: roseColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFEEEEEE),
    );
  }
  
  // Boîte de dialogue pour changer le mot de passe
  void _showChangePasswordDialog() {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer de mot de passe'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe actuel',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // Vérifier que les mots de passe correspondent
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Les mots de passe ne correspondent pas'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              // Simuler le changement de mot de passe
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mot de passe modifié avec succès'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Changer'),
          ),
        ],
      ),
    );
  }
  
  // Boîte de dialogue pour vider le cache
  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cache'),
        content: const Text('Taille du cache: 24.5 MB'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // Simuler le vidage du cache
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache vidé avec succès'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Vider le cache'),
          ),
        ],
      ),
    );
  }
  
  // Boîte de dialogue à propos
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('À propos de Lisolove'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/lisolove_logo.png', height: 100, width: 100),
            const SizedBox(height: 16),
            const Text('Version 1.0.0'),
            const SizedBox(height: 8),
            const Text(
              'Lisolove est une application de rencontres conçue pour aider les personnes à trouver l\'amour en République Démocratique du Congo.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              '© 2023 Lisolove. Tous droits réservés.',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
  
  // Boîte de dialogue pour supprimer le compte
  void _showDeleteAccountDialog() {
    final TextEditingController passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer votre compte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Cette action est irréversible. Toutes vos données seront définitivement supprimées.',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Confirmez votre mot de passe',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // Simuler la suppression du compte
              Navigator.pop(context);
              Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
            },
            child: const Text(
              'Supprimer définitivement',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
  
  // Boîte de dialogue pour se déconnecter
  void _showLogoutDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // Déconnecter l'utilisateur
              authProvider.signOut();
              Navigator.pop(context);
              Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
            },
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }
} 