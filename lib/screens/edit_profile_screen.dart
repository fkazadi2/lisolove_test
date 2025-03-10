import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Définition des couleurs de l'application
  static const Color roseColor = Color(0xFFF3004E);
  static const Color greyColor = Color(0xFF888888);
  static const Color lightGreyColor = Color(0xFFF5F5F5);
  
  bool _isLoading = false;
  
  // Données du profil organisées en sections
  Map<String, dynamic> _profileData = {
    'completion': 95, // Pourcentage de complétion du profil
    
    'about': 'Esse consectetur incididunt voluptate consequat elit consectetur in voluptate cilium fugiat.',
    
    'seeking': 'Rien de sérieux',
    
    'personalInfo': {
      'name': 'Fabrice Kazadi',
      'gender': 'Homme',
      'birthday': '05 05 1992',
      'location': 'Kinshasa, RDC',
      'languages': 'Français, Anglais, Tshiluba, Lingala',
      'relationship': 'Célibataire',
      'job': 'Technicien Infographiste',
      'education': 'Université',
    },
    
    'physical': {
      'bodyType': 'Quelques kilos en trop',
      'height': '183 cm',
      'weight': '96 kg',
      'hairColor': 'Noir',
    },
    
    'personality': {
      'character': 'Sincère, Fidèle',
      'children': 'Pas d\'enfant',
    },
    
    'interests': 'Cinema, Sport, Jeux vidéo, Série, Cuisine, Balade, Voyage.',
    
    'lifestyle': {
      'living': 'Seul',
      'car': 'J\'ai une voiture',
      'religion': 'Chrétien',
      'smoking': 'Non merci',
      'drinking': 'Occasionnellement',
      'travel': 'J\'adore voyager',
    },
    
    'favorites': {
      'musicGenre': 'The Beatles',
      'song': 'Let me love you',
      'hobby': 'Art',
      'dish': 'Fufu, Fumbwa Makayabu',
      'book': 'White Fang',
      'movie': 'Avengers',
      'series': 'Agent of S.H.I.E.L.D',
    },
    
    // Photos du profil (URLs ou chemins)
    'photos': [
      'https://randomuser.me/api/portraits/men/1.jpg',
      'https://randomuser.me/api/portraits/men/2.jpg',
      'https://randomuser.me/api/portraits/men/3.jpg',
      'https://randomuser.me/api/portraits/men/4.jpg',
      'https://randomuser.me/api/portraits/men/5.jpg',
    ],
    'currentPhotoIndex': 0, // Index de la photo actuelle
  };

  // Liste des champs qui utilisent des options prédéfinies
  final Map<String, List<String>> _fieldOptions = {
    'seeking': ['Rien de sérieux', 'Une relation sérieuse', 'Amitié', 'Réseau professionnel'],
    'bodyType': ['Athlétique', 'Mince', 'Musclé', 'Normal', 'Quelques kilos en trop', 'Costaud'],
    'gender': ['Homme', 'Femme', 'Non-binaire', 'Autre'],
    'relationship': ['Célibataire', 'En couple', 'Marié(e)', 'C\'est compliqué', 'Divorcé(e)', 'Veuf/Veuve'],
    'smoking': ['Non merci', 'Occasionnellement', 'Régulièrement', 'J\'essaie d\'arrêter'],
    'drinking': ['Non merci', 'Occasionnellement', 'Socialement', 'Régulièrement'],
    'children': ['Pas d\'enfant', 'Un enfant', 'Plusieurs enfants', 'Ne souhaite pas d\'enfant'],
    'car': ['J\'ai une voiture', 'Je n\'ai pas de voiture', 'Je préfère les transports en commun'],
    'living': ['Seul', 'Avec des colocataires', 'Avec ma famille', 'Avec mon/ma partenaire'],
    'religion': ['Chrétien', 'Musulman', 'Juif', 'Bouddhiste', 'Athée', 'Agnostique', 'Autre', 'Préfère ne pas dire'],
  };

  // Vérifier si un champ utilise des options prédéfinies
  bool _hasPresetOptions(String fieldKey) {
    return _fieldOptions.containsKey(fieldKey);
  }

  // Calculer le pourcentage de complétion du profil
  int _calculateProfileCompletion() {
    // Liste des champs à vérifier dans différentes sections
    final fieldsToCheck = {
      'about': _profileData['about'],
      'seeking': _profileData['seeking'],
      'photos': _profileData['photos'],
      'personalInfo': _profileData['personalInfo'],
      'physical': _profileData['physical'],
      'personality': _profileData['personality'],
      'interests': _profileData['interests'],
      'lifestyle': _profileData['lifestyle'],
      'favorites': _profileData['favorites'],
    };
    
    int totalFields = 0;
    int filledFields = 0;
    
    // Vérifier les champs simples
    if (fieldsToCheck['about'].toString().isNotEmpty) filledFields++;
    totalFields++;
    
    if (fieldsToCheck['seeking'].toString().isNotEmpty) filledFields++;
    totalFields++;
    
    if (fieldsToCheck['interests'].toString().isNotEmpty) filledFields++;
    totalFields++;
    
    // Vérifier les photos
    if ((fieldsToCheck['photos'] as List).isNotEmpty) filledFields++;
    totalFields++;
    
    // Vérifier les sections détaillées
    void checkSection(Map<String, dynamic> section) {
      section.forEach((key, value) {
        if (value.toString().isNotEmpty) filledFields++;
        totalFields++;
      });
    }
    
    checkSection(fieldsToCheck['personalInfo'] as Map<String, dynamic>);
    checkSection(fieldsToCheck['physical'] as Map<String, dynamic>);
    checkSection(fieldsToCheck['personality'] as Map<String, dynamic>);
    checkSection(fieldsToCheck['lifestyle'] as Map<String, dynamic>);
    checkSection(fieldsToCheck['favorites'] as Map<String, dynamic>);
    
    // Calculer le pourcentage
    return ((filledFields / totalFields) * 100).round();
  }
  
  @override
  void initState() {
    super.initState();
    // Charger les données de l'utilisateur
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
      
      // Mettre à jour le score de complétion du profil
      setState(() {
        _profileData['completion'] = _calculateProfileCompletion();
      });
    });
  }
  
  // Charger les données de l'utilisateur depuis le provider
  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userData = authProvider.userData;
    
    if (userData != null) {
      // Ici, vous pourriez mapper les données du userData vers _profileData
      // Pour l'instant, nous utiliserons les données fictives par défaut
    }
  }
  
  // Sauvegarder les modifications
  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      // Ici, on enverrait toutes les données mises à jour
      // Mais pour l'exemple, on n'envoie que quelques champs basiques
      await authProvider.updateProfile(
        fullName: _profileData['personalInfo']['name'],
        bio: _profileData['about'],
        location: _profileData['personalInfo']['location'],
      );
      
      // Afficher un message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // Afficher une erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Afficher les options pour choisir une image
  void _showImagePickerOptions() {
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
                  Navigator.pop(context);
                  _pickProfileImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Appareil photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickProfileImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Choisir une photo de profil
  Future<void> _pickProfileImage(ImageSource source) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _isLoading = true;
        });
        
        final File imageFile = File(image.path);
        final bool success = await authProvider.updateProfilePhoto(imageFile);
        
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success ? 'Photo mise à jour' : 'Erreur lors de la mise à jour de la photo',
              ),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Modifier une section du profil
  void _editSection(String section, {String? subsection}) {
    // Selon la section choisie, montrer un dialogue différent
    switch (section) {
      case 'À propos':
        _showTextEditDialog(
          title: section,
          initialValue: _profileData['about'],
          onSave: (value) => setState(() => _profileData['about'] = value),
        );
        break;
      
      case 'Je cherche':
        // Options prédéfinies pour "Je cherche"
        final options = ['Rien de sérieux', 'Relation sérieuse', 'Amitié', 'Réseau professionnel'];
        _showOptionsDialog(
          title: section,
          options: options,
          selectedOption: _profileData['seeking'],
          onSelect: (value) => setState(() => _profileData['seeking'] = value),
        );
        break;
      
      case 'Intérêts':
        _showTextEditDialog(
          title: section,
          initialValue: _profileData['interests'],
          onSave: (value) => setState(() => _profileData['interests'] = value),
          multiline: true,
          helperText: 'Séparez les intérêts par des virgules',
        );
        break;
      
      default:
        // Pour les sections avec sous-catégories (Infos, Physique, etc.)
        if (subsection != null) {
          // Déterminer quelle section principale contient cette sous-section
          Map<String, dynamic>? parentSection;
          String? key;
          
          // Correction: Utiliser des non-nullable Map
          Map<String, dynamic> personalInfo = Map<String, dynamic>.from(_profileData['personalInfo']);
          Map<String, dynamic> physical = Map<String, dynamic>.from(_profileData['physical']);
          Map<String, dynamic> personality = Map<String, dynamic>.from(_profileData['personality']);
          Map<String, dynamic> lifestyle = Map<String, dynamic>.from(_profileData['lifestyle']);
          Map<String, dynamic> favorites = Map<String, dynamic>.from(_profileData['favorites']);
          
          final String sectionKey = subsection.toLowerCase().replaceAll(' ', '');
          String initialValue = '';
          String sectionName = '';
          
          if (personalInfo.containsKey(sectionKey)) {
            initialValue = personalInfo[sectionKey]?.toString() ?? '';
            sectionName = 'personalInfo';
          } else if (physical.containsKey(sectionKey)) {
            initialValue = physical[sectionKey]?.toString() ?? '';
            sectionName = 'physical';
          } else if (personality.containsKey(sectionKey)) {
            initialValue = personality[sectionKey]?.toString() ?? '';
            sectionName = 'personality';
          } else if (lifestyle.containsKey(sectionKey)) {
            initialValue = lifestyle[sectionKey]?.toString() ?? '';
            sectionName = 'lifestyle';
          } else if (favorites.containsKey(sectionKey)) {
            initialValue = favorites[sectionKey]?.toString() ?? '';
            sectionName = 'favorites';
          }
          
          if (sectionName.isNotEmpty) {
            // Afficher un dialogue d'édition pour cette sous-section
            _showTextEditDialog(
              title: subsection,
              initialValue: initialValue,
              onSave: (String value) {
                setState(() {
                  // Mettre à jour la valeur dans la bonne section
                  switch (sectionName) {
                    case 'personalInfo':
                      _profileData['personalInfo'][sectionKey] = value;
                      break;
                    case 'physical':
                      _profileData['physical'][sectionKey] = value;
                      break;
                    case 'personality':
                      _profileData['personality'][sectionKey] = value;
                      break;
                    case 'lifestyle':
                      _profileData['lifestyle'][sectionKey] = value;
                      break;
                    case 'favorites':
                      _profileData['favorites'][sectionKey] = value;
                      break;
                  }
                });
              },
            );
          }
        } else {
          // Ouvrir un dialogue d'édition de section complète
          _showSectionEditDialog(section);
        }
    }
  }
  
  // Dialogue pour éditer une valeur texte simple
  void _showTextEditDialog({
    required String title,
    required String initialValue,
    required Function(String) onSave,
    bool multiline = false,
    String? helperText,
  }) {
    final controller = TextEditingController(text: initialValue);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier $title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              maxLines: multiline ? 5 : 1,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: roseColor),
                ),
                helperText: helperText,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: greyColor)),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
              // Afficher un feedback
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Modifications enregistrées'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: roseColor,
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
  
  // Dialogue pour sélectionner parmi des options prédéfinies
  void _showOptionsDialog({
    required String title,
    required List<String> options,
    required String selectedOption,
    required Function(String) onSelect,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier $title'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, index) {
              return RadioListTile<String>(
                title: Text(options[index]),
                value: options[index],
                groupValue: selectedOption,
                activeColor: roseColor,
                onChanged: (value) {
                  if (value != null) {
                    onSelect(value);
                    Navigator.pop(context);
                    // Afficher un feedback
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Modifications enregistrées'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: greyColor)),
          ),
        ],
      ),
    );
  }
  
  // Dialogue pour éditer une section complète
  void _showSectionEditDialog(String section) {
    Map<String, dynamic> sectionData;
    
    switch (section) {
      case 'Infos du Profil':
        sectionData = Map.from(_profileData['personalInfo']);
        break;
      case 'Physique':
        sectionData = Map.from(_profileData['physical']);
        break;
      case 'Personnalité':
        sectionData = Map.from(_profileData['personality']);
        break;
      case 'Style de vie':
        sectionData = Map.from(_profileData['lifestyle']);
        break;
      case 'Favoris':
        sectionData = Map.from(_profileData['favorites']);
        break;
      default:
        return;
    }
    
    // Créer un controller pour chaque champ
    Map<String, TextEditingController> controllers = {};
    sectionData.forEach((key, value) {
      controllers[key] = TextEditingController(text: value);
    });
    
    // Convertir les clés pour l'affichage
    Map<String, String> displayNames = {
      'name': 'Nom',
      'gender': 'Je suis un',
      'birthday': 'Anniversaire',
      'location': 'Localisation',
      'languages': 'Langue',
      'relationship': 'Relation',
      'job': 'Travail',
      'education': 'Niveau d\'éducation',
      'bodyType': 'Silhouette',
      'height': 'Taille',
      'weight': 'Poids',
      'hairColor': 'Cheveux',
      'character': 'Caractère',
      'children': 'Enfant',
      'living': 'Je vis',
      'car': 'Voiture',
      'religion': 'Religion',
      'smoking': 'Cigarette',
      'drinking': 'Alcool',
      'travel': 'Voyage',
      'musicGenre': 'Genre musical',
      'song': 'Son',
      'hobby': 'Hobby',
      'dish': 'Plat',
      'book': 'Livre',
      'movie': 'Film',
      'series': 'Série',
    };
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier $section'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...sectionData.keys.map((key) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayNames[key] ?? key,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: controllers[key],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: roseColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: greyColor)),
          ),
          ElevatedButton(
            onPressed: () {
              // Mettre à jour les données
              sectionData.forEach((key, value) {
                sectionData[key] = controllers[key]!.text;
              });
              
              // Enregistrer les changements dans le profil
              setState(() {
                switch (section) {
                  case 'Infos du Profil':
                    _profileData['personalInfo'] = sectionData;
                    break;
                  case 'Physique':
                    _profileData['physical'] = sectionData;
                    break;
                  case 'Personnalité':
                    _profileData['personality'] = sectionData;
                    break;
                  case 'Style de vie':
                    _profileData['lifestyle'] = sectionData;
                    break;
                  case 'Favoris':
                    _profileData['favorites'] = sectionData;
                    break;
                }
              });
              
              Navigator.pop(context);
              
              // Afficher un feedback
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Modifications enregistrées'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: roseColor,
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userData = authProvider.userData;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Modifier mon profil',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.normal,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.teal),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Bouton de sauvegarde
          TextButton.icon(
            onPressed: _saveProfile,
            icon: const Icon(Icons.check, color: roseColor, size: 16),
            label: const Text(
              'Enregistrer',
              style: TextStyle(
                color: roseColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: roseColor))
          : ListView(
              padding: const EdgeInsets.only(bottom: 40),
              children: [
                // Photo de profil
                _buildProfilePhotoSection(userData),
                
                // Détails du profil avec barre de progression
                _buildProfileCompletionSection(),
                
                // À propos
                _buildInfoSection('À propos', _profileData['about']),
                
                // Je cherche
                _buildInfoSection('Je cherche', _profileData['seeking']),
                
                // Infos du Profil
                _buildDetailedInfoSection(
                  'Infos du Profil',
                  {
                    'Nom': _profileData['personalInfo']['name'],
                    'Je suis un': _profileData['personalInfo']['gender'],
                    'Anniversaire': _profileData['personalInfo']['birthday'],
                    'Localisation': _profileData['personalInfo']['location'],
                    'Langue': _profileData['personalInfo']['languages'],
                    'Relation': _profileData['personalInfo']['relationship'],
                    'Travail': _profileData['personalInfo']['job'],
                    'Niveau d\'éducation': _profileData['personalInfo']['education'],
                  },
                ),
                
                // Physique
                _buildDetailedInfoSection(
                  'Physique',
                  {
                    'Silhouette': _profileData['physical']['bodyType'],
                    'Taille': _profileData['physical']['height'],
                    'Poids': _profileData['physical']['weight'],
                    'Cheveux': _profileData['physical']['hairColor'],
                  },
                ),
                
                // Personnalité
                _buildDetailedInfoSection(
                  'Personnalité',
                  {
                    'Caractère': _profileData['personality']['character'],
                    'Enfant': _profileData['personality']['children'],
                  },
                ),
                
                // Intérêts
                _buildInfoSection('Intérêts', _profileData['interests']),
                
                // Style de vie
                _buildDetailedInfoSection(
                  'Style de vie',
                  {
                    'Je vis': _profileData['lifestyle']['living'],
                    'Voiture': _profileData['lifestyle']['car'],
                    'Religion': _profileData['lifestyle']['religion'],
                    'Cigarette': _profileData['lifestyle']['smoking'],
                    'Alcool': _profileData['lifestyle']['drinking'],
                    'Voyage': _profileData['lifestyle']['travel'],
                  },
                ),
                
                // Favoris
                _buildDetailedInfoSection(
                  'Favoris',
                  {
                    'Genre musical': _profileData['favorites']['musicGenre'],
                    'Son': _profileData['favorites']['song'],
                    'Hobby': _profileData['favorites']['hobby'],
                    'Plat': _profileData['favorites']['dish'],
                    'Livre': _profileData['favorites']['book'],
                    'Film': _profileData['favorites']['movie'],
                    'Série': _profileData['favorites']['series'],
                  },
                ),
              ],
            ),
    );
  }
  
  // Construction de la section Photo de profil
  Widget _buildProfilePhotoSection(userData) {
    // Utiliser les photos de l'utilisateur ou les photos par défaut du profil
    List<String> photos = _profileData['photos'];
    final PageController pageController = PageController(initialPage: _profileData['currentPhotoIndex']);
    
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width, // Hauteur = largeur pour un carré
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // PageView pour défiler les photos
          PageView.builder(
            controller: pageController,
            itemCount: photos.length,
            onPageChanged: (index) {
              setState(() {
                _profileData['currentPhotoIndex'] = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    photos[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: lightGreyColor,
                        child: const Icon(
                          Icons.person,
                          size: 100,
                          color: greyColor,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          
          // Bouton de caméra
          Positioned(
            bottom: 30,
            child: GestureDetector(
              onTap: _showImagePickerOptions,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: roseColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          
          // Étoile favorite
          Positioned(
            bottom: 20,
            left: 20,
            child: GestureDetector(
              onTap: _toggleFavoritePhoto,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _profileData.containsKey('isFavoritePhoto') && _profileData['isFavoritePhoto'] == true
                      ? Icons.star
                      : Icons.star_border,
                  color: _profileData.containsKey('isFavoritePhoto') && _profileData['isFavoritePhoto'] == true
                      ? Colors.amber
                      : Colors.grey,
                  size: 20,
                ),
              ),
            ),
          ),
          
          // Bouton corbeille (supprimer)
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: _showDeletePhotoConfirmation,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
            ),
          ),
          
          // Indicateurs de position
          Positioned(
            bottom: 20,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                photos.length,
                (index) => GestureDetector(
                  onTap: () {
                    pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: index == _profileData['currentPhotoIndex'] ? 30 : 20,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index == _profileData['currentPhotoIndex'] ? roseColor : Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Section de complétion du profil
  Widget _buildProfileCompletionSection() {
    // Calculer la complétion à chaque reconstruction
    final completion = _calculateProfileCompletion();
    
    // Définir la couleur en fonction du niveau de complétion
    Color progressColor;
    if (completion < 30) {
      progressColor = Colors.red;
    } else if (completion < 70) {
      progressColor = Colors.orange;
    } else {
      progressColor = roseColor;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Détails du profil',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Text(
                '$completion%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Barre de progression
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: completion / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
  
  // Section d'information simple
  Widget _buildInfoSection(String title, String content) {
    final TextEditingController controller = TextEditingController(text: content);
    String sectionKey = '';
    
    switch (title) {
      case 'À propos':
        sectionKey = 'about';
        break;
      case 'Je cherche':
        sectionKey = 'seeking';
        break;
      case 'Intérêts':
        sectionKey = 'interests';
        break;
    }
    
    // Vérifier si ce champ utilise des options prédéfinies
    if (_hasPresetOptions(sectionKey)) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                _showOptionsDialog(
                  title: title,
                  options: _fieldOptions[sectionKey]!,
                  selectedOption: content,
                  onSelect: (value) {
                    setState(() {
                      _profileData[sectionKey] = value;
                    });
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey[300]!,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      content.isEmpty ? 'Sélectionner une option' : content,
                      style: TextStyle(
                        color: content.isEmpty ? Colors.grey[400] : Colors.black87,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Utiliser un champ de texte normal pour les autres champs
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              maxLines: title == 'À propos' ? 3 : 1,
              onChanged: (value) {
                setState(() {
                  _profileData[sectionKey] = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Entrez votre ${title.toLowerCase()}',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: roseColor),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }
  }
  
  // Section d'information détaillée avec plusieurs champs
  Widget _buildDetailedInfoSection(String title, Map<String, String> details) {
    // Créer un controller pour chaque champ
    Map<String, TextEditingController> controllers = {};
    details.forEach((key, value) {
      controllers[key] = TextEditingController(text: value);
    });
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Liste des détails avec édition directe
          ...details.keys.map((key) {
            // Déterminer dans quelle section principale se trouve cette clé
            Map<String, dynamic> parentSection;
            String internalKey;
            
            switch (title) {
              case 'Infos du Profil':
                parentSection = _profileData['personalInfo'];
                internalKey = _getInternalKey(key, 'personalInfo');
                break;
              case 'Physique':
                parentSection = _profileData['physical'];
                internalKey = _getInternalKey(key, 'physical');
                break;
              case 'Personnalité':
                parentSection = _profileData['personality'];
                internalKey = _getInternalKey(key, 'personality');
                break;
              case 'Style de vie':
                parentSection = _profileData['lifestyle'];
                internalKey = _getInternalKey(key, 'lifestyle');
                break;
              case 'Favoris':
                parentSection = _profileData['favorites'];
                internalKey = _getInternalKey(key, 'favorites');
                break;
              default:
                return const SizedBox.shrink(); // En cas d'erreur
            }
            
            // Vérifier si ce champ utilise des options prédéfinies
            if (_hasPresetOptions(internalKey)) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      key,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        _showOptionsDialog(
                          title: key,
                          options: _fieldOptions[internalKey]!,
                          selectedOption: details[key] ?? '',
                          onSelect: (value) {
                            setState(() {
                              if (parentSection.containsKey(internalKey)) {
                                parentSection[internalKey] = value;
                              }
                            });
                          },
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey[300]!,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              details[key]?.isEmpty ?? true ? 'Sélectionner une option' : details[key]!,
                              style: TextStyle(
                                color: details[key]?.isEmpty ?? true ? Colors.grey[400] : Colors.black87,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // Utiliser un champ de texte normal pour les autres champs
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      key,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: controllers[key],
                      onChanged: (value) {
                        setState(() {
                          // Mettre à jour la valeur dans le modèle
                          if (parentSection.containsKey(internalKey)) {
                            parentSection[internalKey] = value;
                          }
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Entrez votre ${key.toLowerCase()}',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: roseColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ],
                ),
              );
            }
          }).toList(),
        ],
      ),
    );
  }
  
  // Obtenir la clé interne à partir du nom d'affichage
  String _getInternalKey(String displayName, String section) {
    // Map de conversion des noms d'affichage en clés internes
    final Map<String, Map<String, String>> conversionMap = {
      'personalInfo': {
        'Nom': 'name',
        'Je suis un': 'gender',
        'Anniversaire': 'birthday',
        'Localisation': 'location',
        'Langue': 'languages',
        'Relation': 'relationship',
        'Travail': 'job',
        'Niveau d\'éducation': 'education',
      },
      'physical': {
        'Silhouette': 'bodyType',
        'Taille': 'height',
        'Poids': 'weight',
        'Cheveux': 'hairColor',
      },
      'personality': {
        'Caractère': 'character',
        'Enfant': 'children',
      },
      'lifestyle': {
        'Je vis': 'living',
        'Voiture': 'car',
        'Religion': 'religion',
        'Cigarette': 'smoking',
        'Alcool': 'drinking',
        'Voyage': 'travel',
      },
      'favorites': {
        'Genre musical': 'musicGenre',
        'Son': 'song',
        'Hobby': 'hobby',
        'Plat': 'dish',
        'Livre': 'book',
        'Film': 'movie',
        'Série': 'series',
      },
    };
    
    return conversionMap[section]?[displayName] ?? '';
  }
  
  // Définir une photo comme favorite
  void _toggleFavoritePhoto() {
    setState(() {
      if (_profileData.containsKey('isFavoritePhoto')) {
        _profileData['isFavoritePhoto'] = !_profileData['isFavoritePhoto'];
      } else {
        _profileData['isFavoritePhoto'] = true;
      }
    });
    
    // Afficher un feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_profileData['isFavoritePhoto'] 
            ? 'Photo définie comme favorite' 
            : 'Photo retirée des favoris'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  // Supprimer la photo de profil
  void _showDeletePhotoConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la photo'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette photo de profil ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: greyColor)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProfilePhoto();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
  
  // Fonction pour supprimer la photo
  void _deleteProfilePhoto() async {
    setState(() {
      _isLoading = true;
    });
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      // Cette fonction devrait être implémentée dans votre AuthProvider
      // await authProvider.deleteProfilePhoto();
      
      // Pour l'exemple, on simule avec un délai
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _isLoading = false;
      });
      
      // Feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo de profil supprimée'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
} 