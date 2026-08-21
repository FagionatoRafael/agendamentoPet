import 'package:agendamento_pet/screens/home/home_screen_web.dart';
import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/add/add_appointment_screen.dart';
import '../screens/edit/edit_appointment_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String homeWeb = '/home-web';
  static const String add = '/add';
  static const String edit = '/edit';
  static const String details = '/details';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case homeWeb:
        return MaterialPageRoute(builder: (_) => const HomeScreenWeb());
      case add:
        return MaterialPageRoute(builder: (_) => const AddAppointmentScreen());
      case edit:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => EditAppointmentScreen(
            appointmentId: args['id'],
            appointment: args['appointment'],
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
