import 'dart:io';
import 'dart:convert';

/// Script pour injecter les variables d'environnement dans les fichiers de configuration
/// Usage: dart scripts/inject_env.dart
void main() async {
  print('Starting environment variables injection...');
  
  // Charger les variables d'environnement depuis .env
  final envFile = File('.env');
  if (!await envFile.exists()) {
    print('Error: .env file not found! Please create one based on .env.example');
    exit(1);
  }
  
  final envContent = await envFile.readAsString();
  final envVars = parseEnvFile(envContent);
  
  // Injecter les variables dans les fichiers plist (iOS et macOS)
  await injectPlistVariables(envVars);
  
  // Injecter les variables dans les fichiers json (Android)
  await injectJsonVariables(envVars);
  
  // Injecter les variables dans les fichiers js (Web)
  await injectJsVariables(envVars);
  
  print('Environment variables injection completed!');
}

/// Injecte les variables dans les fichiers plist pour iOS et macOS
Future<void> injectPlistVariables(Map<String, String> envVars) async {
  // Liste des fichiers de configuration à modifier
  final configFiles = {
    'ios/Runner/GoogleService-Info.plist': 'FIREBASE_API_KEY_IOS',
    'macos/Runner/GoogleService-Info.plist': 'FIREBASE_API_KEY_IOS',
  };
  
  for (final entry in configFiles.entries) {
    final filePath = entry.key;
    final apiKeyVar = entry.value;
    
    final file = File(filePath);
    if (!await file.exists()) {
      print('Warning: $filePath not found, skipping...');
      continue;
    }
    
    var content = await file.readAsString();
    
    // Remplacer l'API_KEY spécifique à la plateforme
    if (envVars.containsKey(apiKeyVar)) {
      content = content.replaceAll(RegExp(r'<key>API_KEY<\/key>\s*<string>.*?<\/string>'), 
          '<key>API_KEY</key>\n\t<string>${envVars[apiKeyVar]}</string>');
    }
    
    // Remplacer les autres variables d'environnement
    for (final envEntry in envVars.entries) {
      if (!envEntry.key.startsWith('FIREBASE_API_KEY_')) { // Ignorer les clés API spécifiques aux plateformes
        content = content.replaceAll('\${${envEntry.key}}', envEntry.value);
      }
    }
    
    // Écrire le fichier modifié
    await file.writeAsString(content);
    print('✅ Successfully injected variables into $filePath with ${apiKeyVar} key');
  }
}

/// Injecte les variables dans les fichiers json pour Android
Future<void> injectJsonVariables(Map<String, String> envVars) async {
  // Fichier de configuration Android
  final androidConfigFile = 'android/app/google-services.json';
  final apiKeyVar = 'FIREBASE_API_KEY_ANDROID';
  
  final file = File(androidConfigFile);
  if (!await file.exists()) {
    print('Warning: $androidConfigFile not found, skipping...');
    return;
  }
  
  try {
    // Lire et parser le fichier JSON
    final content = await file.readAsString();
    final jsonData = json.decode(content);
    
    // Mettre à jour la clé API pour Android
    if (envVars.containsKey(apiKeyVar) && jsonData['client'] is List && jsonData['client'].isNotEmpty) {
      final client = jsonData['client'][0];
      if (client['api_key'] is List && client['api_key'].isNotEmpty) {
        client['api_key'][0]['current_key'] = envVars[apiKeyVar];
      }
    }
    
    // Écrire le fichier JSON modifié avec une indentation lisible
    const indent = '  ';
    final encoder = JsonEncoder.withIndent(indent);
    await file.writeAsString(encoder.convert(jsonData), flush: true);
    print('✅ Successfully injected variables into $androidConfigFile with $apiKeyVar key');
  } catch (e) {
    print('❌ Error updating $androidConfigFile: $e');
  }
}

/// Injecte les variables dans les fichiers js pour Web
Future<void> injectJsVariables(Map<String, String> envVars) async {
  // Fichier de configuration Web
  final webConfigFile = 'web/firebase-config.js';
  
  final file = File(webConfigFile);
  if (!await file.exists()) {
    print('Warning: $webConfigFile not found, skipping...');
    return;
  }
  
  try {
    var content = await file.readAsString();
    
    // Remplacer toutes les variables d'environnement
    for (final entry in envVars.entries) {
      content = content.replaceAll('\${${entry.key}}', entry.value);
    }
    
    // Écrire le fichier modifié
    await file.writeAsString(content);
    print('✅ Successfully injected variables into $webConfigFile');
  } catch (e) {
    print('❌ Error updating $webConfigFile: $e');
  }
}

/// Parse le fichier .env et retourne un Map des variables
Map<String, String> parseEnvFile(String content) {
  final result = <String, String>{};
  
  for (final line in content.split('\n')) {
    final trimmedLine = line.trim();
    
    // Ignorer les commentaires et les lignes vides
    if (trimmedLine.isEmpty || trimmedLine.startsWith('#')) {
      continue;
    }
    
    // Diviser la ligne au premier '='
    final equalsIndex = trimmedLine.indexOf('=');
    if (equalsIndex > 0) {
      final key = trimmedLine.substring(0, equalsIndex).trim();
      final value = trimmedLine.substring(equalsIndex + 1).trim();
      result[key] = value;
    }
  }
  
  return result;
} 