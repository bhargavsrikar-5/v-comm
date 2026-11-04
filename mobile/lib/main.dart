import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_state.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await AuthState().initialize();
  runApp(const VCommApp());
}

class VCommApp extends StatelessWidget {
  const VCommApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        primaryColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.transparent,
          surface: AppConstants.cardColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.cardColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.white,
          selectionColor: Colors.white.withOpacity(0.3),
          selectionHandleColor: Colors.white,
        ),
      ),
      home: AuthState().isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
