import 'package:flutter/material.dart';
import '../screens/calendar_screen.dart';
import '../screens/chat_home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/search_screen.dart';
import '../utils/constants.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget targetScreen;
    switch (index) {
      case 0:
        targetScreen = const SearchScreen();
        break;
      case 1:
        targetScreen = const CalendarScreen();
        break;
      case 2:
        targetScreen = const ChatHomeScreen();
        break;
      case 3:
        targetScreen = const ProfileScreen();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 65,
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppConstants.cardBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, icon: Icons.search, index: 0, label: "Search"),
          _buildNavItem(context, icon: Icons.calendar_today, index: 1, label: "Calendar"),
          _buildNavItem(context, icon: Icons.message_outlined, index: 2, label: "Messages"),
          _buildNavItem(context, icon: Icons.person_outline, index: 3, label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {
    required IconData icon,
    required int index,
    required String label,
  }) {
    final bool isSelected = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(context, index),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
            ),
            const SizedBox(height: 3),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.white : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
