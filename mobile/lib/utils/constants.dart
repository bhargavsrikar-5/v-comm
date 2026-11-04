import 'package:flutter/material.dart';

class AppConstants {
  // Application Name
  static const String appName = 'V-COMM';

  // API Base URL
  // For Android Emulator use: 'http://10.0.2.2:8080/api'
  // For iOS Simulator / Web / Desktop use: 'http://localhost:8080/api'
  // For Physical Device use your local machine IP, e.g., 'http://192.168.1.5:8080/api'
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api',
  );

  // Theme Colors
  static const Color backgroundColor = Colors.black;
  static const Color cardColor = Color(0xFF1A1A1A);
  static const Color cardBorderColor = Color(0x33FFFFFF); // White 20%
  static const Color primaryTextColor = Colors.white;
  static const Color secondaryTextColor = Color(0xB3FFFFFF); // White 70%
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentRed = Color(0xFFE53935);
  static const Color inputFillColor = Color(0x1AFFFFFF); // White 10%
}

// Global Helper Functions for SnackBars
void showAppSnackBar(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      backgroundColor: isError ? Colors.red.shade800 : Colors.green.shade800,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ),
  );
}
