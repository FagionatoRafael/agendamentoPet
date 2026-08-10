import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/AppTheme.dart';
import 'core/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/appointment_provider.dart';
import 'firebase_options.dart';
import 'core/config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _loadEnvSilently();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  }
  runApp(const MyApp());
}

Future<void> _loadEnvSilently() async {
  try {
    await dotenv.load(fileName: '.env');
    print('.env carregado com sucesso');
  } catch (e) {
    print('.env não encontrado, usando fallback');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
      ],
      child: MaterialApp(
        title: 'Agendamento Pet',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: AppRoutes.generateRoute,
        initialRoute: AppRoutes.splash,
      ),
    );
  }
}