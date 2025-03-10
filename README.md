# LisoLove

Application de rencontres basée sur Flutter pour aider les personnes à trouver l'amour en République Démocratique du Congo.

## Configuration de l'environnement

### Prérequis
- Flutter (dernière version stable)
- Dart (dernière version stable)
- Un éditeur de code (VS Code, Android Studio, etc.)
- Git

### Configuration des clés API (IMPORTANT)
Pour des raisons de sécurité, ce projet utilise des variables d'environnement pour stocker les clés API et autres informations sensibles. Suivez ces étapes pour configurer votre environnement de développement :

1. Créez un fichier `.env` à la racine du projet en vous basant sur le fichier `.env.example` :
   ```bash
   cp .env.example .env
   ```

2. Remplacez les valeurs de placeholder par vos propres clés API dans le fichier `.env`. Ces informations sont disponibles dans la console Firebase du projet.

3. Avant de compiler l'application, exécutez le script d'injection des variables d'environnement :
   ```bash
   dart scripts/inject_env.dart
   ```

4. Ce script va injecter les variables d'environnement dans les fichiers de configuration, notamment `GoogleService-Info.plist`.

### Note sur la sécurité
- Ne jamais committer les fichiers contenant des clés API ou informations sensibles (`GoogleService-Info.plist`, `.env`, etc.).
- Ces fichiers sont déjà inclus dans le `.gitignore` du projet.

## Architecture du projet

L'application utilise une architecture Clean Architecture avec les couches suivantes :
- **Domain** : Entités, cas d'utilisation et interfaces de repository
- **Data** : Modèles, implémentations de repository et sources de données
- **Presentation** : Blocs, états et widgets d'interface utilisateur

## Démarrage

1. Clonez le répertoire
   ```bash
   git clone [repo-url]
   ```

2. Installez les dépendances
   ```bash
   flutter pub get
   ```

3. Configurez votre environnement comme décrit ci-dessus

4. Exécutez l'application
   ```bash
   flutter run
   ```

## Construction pour la production

Pour générer des APKs optimisés pour différentes architectures :
```bash
flutter build apk --split-per-abi --release
```

Pour générer un App Bundle pour Google Play :
```bash
flutter build appbundle --release
```

## Contribuer au projet

1. Créez une branche pour vos modifications
2. Effectuez vos modifications
3. Testez vos modifications
4. Soumettez une pull request

## License

[Mentionner la licence si applicable]
