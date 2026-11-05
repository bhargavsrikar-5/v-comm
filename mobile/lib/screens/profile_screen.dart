import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_state.dart';
import '../utils/constants.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/custom_text_field.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    setState(() {
      _user = AuthState().currentUser;
    });
  }

  void _showChangePasswordDialog() {
    if (_user == null) return;

    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (dialogContext) => StatefulBuilder(
        builder: (statefulContext, setDialogState) => AlertDialog(
          backgroundColor: AppConstants.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: AppConstants.cardBorderColor),
          ),
          title: Text(
            "Change Password",
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: oldPassController,
                  labelText: "Current Password",
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (val) => val == null || val.isEmpty ? "Current password required" : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: newPassController,
                  labelText: "New Password",
                  hintText: "Minimum 10 characters",
                  obscureText: true,
                  prefixIcon: Icons.lock_reset,
                  validator: (val) {
                    if (val == null || val.isEmpty) return "New password required";
                    if (val.length < 10) return "Must be at least 10 characters";
                    return null;
                  },
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text("Cancel", style: TextStyle(color: Colors.white.withOpacity(0.6))),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isSubmitting = true);

                      final res = await ApiService.changePassword(
                        oldPassword: oldPassController.text,
                        newPassword: newPassController.text,
                      );

                      if (dialogContext.mounted && res['success'] == true) {
                        Navigator.pop(dialogContext);
                      }

                      if (!mounted) return;
                      if (res['success'] == true) {
                        await AuthState().logout();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                        );
                      } else {
                        setDialogState(() => isSubmitting = false);
                        showAppSnackBar(context, res['message'] ?? "Failed to change password", isError: true);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text("Update", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppConstants.cardBorderColor),
        ),
        title: Row(
          children: [
            Text(
              "About ${AppConstants.appName}",
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "V-COMM is a faculty communication and presence platform built with Flutter and Java Spring Boot.",
              style: TextStyle(color: Colors.white.withOpacity(0.8), height: 1.4),
            ),
            const SizedBox(height: 12),
            Text(
              "Faculty Portal • Version: 1.0.0 (Release)",
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    await ApiService.logout();
    await AuthState().logout();
    if (!mounted) return;
    showAppSnackBar(context, "Logged out successfully");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "My Profile",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Color(0xFF111111), Colors.black],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // 1. Profile Header Card
                      _buildHeaderCard(),

                      const SizedBox(height: 28),

                      // 2. Account Settings Section
                      _buildSectionHeader("Account Settings"),
                      _buildSettingsTile(
                        icon: Icons.edit_outlined,
                        title: "Edit Profile",
                        subtitle: "Update name, department, or phone",
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                          );
                          _loadUser();
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildSettingsTile(
                        icon: Icons.lock_outline,
                        title: "Change Password",
                        subtitle: "Update your account password",
                        onTap: _showChangePasswordDialog,
                      ),

                      const SizedBox(height: 28),

                      // 3. Support & About Section
                      _buildSectionHeader("Support & Info"),
                      _buildSettingsTile(
                        icon: Icons.help_outline,
                        title: "Campus Support",
                        subtitle: "Contact your campus administrator",
                        onTap: () => showAppSnackBar(context, "Please contact your campus administrator for support."),
                      ),
                      const SizedBox(height: 10),
                      _buildSettingsTile(
                        icon: Icons.info_outline,
                        title: "About ${AppConstants.appName}",
                        subtitle: "Platform information and version",
                        onTap: _showAboutDialog,
                      ),

                      const SizedBox(height: 36),

                      // 4. Logout Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () => _handleLogout(),
                          icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                          label: const Text(
                            "Logout",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: BorderSide(color: Colors.red.withOpacity(0.3)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Bottom Navigation Bar
              const CustomBottomNav(currentIndex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppConstants.cardBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white.withOpacity(0.12),
            backgroundImage: _user!.photoUrl != null && _user!.photoUrl!.isNotEmpty
                ? NetworkImage(_user!.photoUrl!)
                : null,
            child: (_user!.photoUrl == null || _user!.photoUrl!.isEmpty)
                ? Text(
                    _user!.name.isNotEmpty ? _user!.name[0].toUpperCase() : 'U',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  )
                : null,
          ),
          const SizedBox(width: 16),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _user!.name,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _user!.email,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${_user!.dept} • ${_user!.customId}",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 4),
        child: Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.6),
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppConstants.cardBorderColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.3), size: 14),
        onTap: onTap,
      ),
    );
  }
}
