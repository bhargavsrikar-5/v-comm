import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/auth_state.dart';
import '../utils/constants.dart';
import '../widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _deptController = TextEditingController();
  final _customIdController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = AuthState().currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _deptController.text = user.dept;
      _customIdController.text = user.customId;
      _phoneController.text = user.phoneNumber;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _deptController.dispose();
    _customIdController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final user = AuthState().currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    final updated = await ApiService.updateUser(
      user.id,
      name: _nameController.text,
      dept: _deptController.text,
      customId: _customIdController.text,
      phoneNumber: _phoneController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (updated != null) {
      AuthState().setUser(updated);
      showAppSnackBar(context, "Profile updated successfully!");
      Navigator.pop(context);
    } else {
      showAppSnackBar(context, "Failed to update profile", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthState().currentUser;

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
          "Edit Profile",
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Avatar Section
                  Center(
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: Colors.white.withOpacity(0.12),
                      backgroundImage: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: (user?.photoUrl == null || user!.photoUrl!.isEmpty)
                          ? Text(
                              (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : 'U',
                              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Edit Fields Container
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppConstants.cardColor,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppConstants.cardBorderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        CustomTextField(
                          controller: _nameController,
                          labelText: "Full Name",
                          prefixIcon: Icons.person_outline,
                          validator: (val) => val == null || val.trim().isEmpty ? "Name is required" : null,
                        ),
                        const SizedBox(height: 16),

                        // Department
                        CustomTextField(
                          controller: _deptController,
                          labelText: "Department",
                          prefixIcon: Icons.business_outlined,
                          validator: (val) => val == null || val.trim().isEmpty ? "Department is required" : null,
                        ),
                        const SizedBox(height: 16),

                        // Custom ID
                        CustomTextField(
                          controller: _customIdController,
                          labelText: "Campus ID / Roll No",
                          prefixIcon: Icons.badge_outlined,
                          validator: (val) => val == null || val.trim().isEmpty ? "Campus ID is required" : null,
                        ),
                        const SizedBox(height: 16),

                        // Phone Number
                        CustomTextField(
                          controller: _phoneController,
                          labelText: "Phone Number",
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (val) {
                            if (val != null && val.isNotEmpty && val.length < 10) {
                              return "Enter a valid 10-digit phone number";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Save Changes Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                          side: BorderSide(color: AppConstants.cardBorderColor),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : Text(
                              "Save Changes",
                              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
