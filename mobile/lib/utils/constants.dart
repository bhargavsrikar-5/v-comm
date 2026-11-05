import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppConstants {
  // Application Name
  static const String appName = 'V-COMM';

  // API Base URL
  // For Android Emulator use: 'http://10.0.2.2:8080/api'
  // For iOS Simulator / Web / Desktop use: 'http://localhost:8080/api'
  // For Physical Device use your local machine IP, e.g., 'http://192.168.1.5:8080/api'
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    final configured = _configuredBaseUrl.trim();
    if (configured.isEmpty) {
      if (!kDebugMode) throw StateError('Set API_BASE_URL to the deployed HTTPS API before building a release app.');
      return 'http://localhost:8080/api';
    }
    final uri = Uri.tryParse(configured);
    if (uri == null || uri.host.isEmpty || (uri.scheme != 'https' && !(kDebugMode && uri.scheme == 'http' && _isLocalDebugHost(uri.host)))) {
      throw StateError('API_BASE_URL must use HTTPS; HTTP is allowed only for local debug hosts.');
    }
    return configured.replaceFirst(RegExp(r'/+$'), '');
  }

  static bool _isLocalDebugHost(String host) {
    if (const {'localhost', '127.0.0.1', '::1', '10.0.2.2'}.contains(host)) return true;
    final octets = host.split('.').map(int.tryParse).toList();
    if (octets.length != 4 || octets.any((part) => part == null || part < 0 || part > 255)) return false;
    final a = octets[0]!;
    final b = octets[1]!;
    return a == 10 || (a == 172 && b >= 16 && b <= 31) || (a == 192 && b == 168);
  }

  // Theme Colors
  static const Color backgroundColor = Colors.black;
  static const Color cardColor = Color(0xFF1A1A1A);
  static const Color cardBorderColor = Color(0x33FFFFFF); // White 20%
  static const Color primaryTextColor = Colors.white;
  static const Color secondaryTextColor = Color(0xB3FFFFFF); // White 70%
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentRed = Color(0xFFE53935);
  static const Color inputFillColor = Color(0x1AFFFFFF); // White 10%

  static Color availabilityColor(String status) => switch (status.toLowerCase()) {
    'present' || 'available' || 'in class' => accentGreen,
    'busy' => const Color(0xFFFFB74D),
    _ => accentRed,
  };
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
