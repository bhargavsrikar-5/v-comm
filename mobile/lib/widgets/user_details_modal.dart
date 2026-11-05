import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../screens/chat_room_screen.dart';
import '../utils/constants.dart';
import '../screens/timetable_screen.dart';

class UserDetailsModal extends StatelessWidget {
  final UserModel user;

  const UserDetailsModal({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: AppConstants.cardBorderColor),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // User Avatar
          CircleAvatar(
            radius: 42,
            backgroundColor: Colors.white.withOpacity(0.1),
            backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                ? NetworkImage(user.photoUrl!)
                : null,
            child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                ? Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  )
                : null,
          ),
          const SizedBox(height: 16),

          // User Name
          Text(
            user.name,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),

          // Department & ID
          Text(
            "${user.dept} • ${user.customId}",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Presence Status Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppConstants.availabilityColor(user.availabilityStatus).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppConstants.availabilityColor(user.availabilityStatus),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  color: AppConstants.availabilityColor(user.availabilityStatus),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  user.availabilityStatus.toUpperCase(),
                  style: TextStyle(
                    color: AppConstants.availabilityColor(user.availabilityStatus),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            onPressed: () { final navigator = Navigator.of(context); navigator.pop(); navigator.push(MaterialPageRoute(builder: (_) => TimetableScreen(userId: user.id))); },
            icon: const Icon(Icons.calendar_view_week), label: const Text('View weekly timetable'),
          )),
          const SizedBox(height: 12),

          // Contact Details Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppConstants.cardBorderColor),
            ),
            child: Column(
              children: [
                _buildInfoRow(Icons.email_outlined, "Email", user.email),
                const Divider(color: Colors.white12, height: 20),
                _buildInfoRow(
                  Icons.phone_outlined,
                  "Phone",
                  user.phoneNumber.isNotEmpty ? user.phoneNumber : "Not provided",
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Button: Send Message
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatRoomScreen(otherUser: user),
                  ),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
              label: const Text(
                "Send Message",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.15),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: AppConstants.cardBorderColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}
