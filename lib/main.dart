import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Intentar crear usuario admin (si las rules lo permiten)
  try {
    await FirebaseService.seedUsuarioAdmin();
  } catch (e) {
    debugPrint('⚠️ No se pudo crear seed admin (revisa Firestore Rules): $e');
  }
  runApp(const EsvaroApp());
}

class EsvaroApp extends StatelessWidget {
  const EsvaroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESVARO Logística',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
