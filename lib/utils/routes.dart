import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/patient_registration_screen.dart';
import '../screens/cough_recording_screen.dart';
import '../screens/skin_scan_screen.dart';
import '../screens/anemia_scan_screen.dart';
import '../screens/maternal_health_screen.dart';
import '../screens/symptom_triage_screen.dart';
import '../screens/ai_processing_screen.dart';
import '../screens/result_screen.dart';
import '../screens/patient_history_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String patientRegistration = '/patient-registration';
  static const String coughRecording = '/cough-recording';
  static const String skinScan = '/skin-scan';
  static const String anemiaScan = '/anemia-scan';
  static const String maternalHealth = '/maternal-health';
  static const String symptomTriage = '/symptom-triage';
  static const String aiProcessing = '/ai-processing';
  static const String result = '/result';
  static const String patientHistory = '/patient-history';
  
  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
    patientRegistration: (context) => const PatientRegistrationScreen(),
    patientHistory: (context) => const PatientHistoryScreen(),
  };
  
  // For routes that need arguments
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case coughRecording:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => CoughRecordingScreen(
            patientId: args['patientId'],
            patientName: args['patientName'],
          ),
        );
      case skinScan:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => SkinScanScreen(
            patientId: args['patientId'],
            patientName: args['patientName'],
          ),
        );
      case anemiaScan:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => AnemiaScanScreen(
            patientId: args['patientId'],
            patientName: args['patientName'],
          ),
        );
      case maternalHealth:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => MaternalHealthScreen(
            patientId: args['patientId'],
            patientName: args['patientName'],
          ),
        );
      case symptomTriage:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => SymptomTriageScreen(
            patientId: args['patientId'],
            patientName: args['patientName'],
          ),
        );
      case aiProcessing:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => AIProcessingScreen(
            patientId: args['patientId'],
            audioPath: args['audioPath'],
          ),
        );
      case result:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => ResultScreen(
            patientId: args['patientId'],
            screeningId: args['screeningId'],
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('Route not found'),
            ),
          ),
        );
    }
  }
}
