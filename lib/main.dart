import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'di/injection.dart' as di;
import 'services/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/trends_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialiser l'injection de dépendances
  await di.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'Lisolove',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFFF3004E), // Rose vif
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFFF3004E),
            elevation: 0,
          ),
        ),
        home: const LandingPage(),
        routes: {
          '/welcome': (context) => const WelcomeScreen(),
          '/home': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/discover': (context) => const DiscoverScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/messages': (context) => const MessagesScreen(),
          '/chat': (context) => ChatScreen(
            userId: (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>)['userId'] as String,
            userName: (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>)['userName'] as String,
            userImage: (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>)['userImage'] as String,
          ),
          '/settings': (context) => const SettingsScreen(),
          '/edit_profile': (context) => const EditProfileScreen(),
          '/trends': (context) => const TrendsScreen(),
        },
      ),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Vérifier directement l'état d'authentification
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      // Rediriger en fonction de l'état d'authentification
      if (authProvider.isLoggedIn) {
        return const HomeScreen();
      } else {
        return const WelcomeScreen();
      }
    }
  }
}