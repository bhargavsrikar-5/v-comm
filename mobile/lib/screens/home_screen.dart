import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_state.dart';
import '../utils/constants.dart';
import '../widgets/custom_bottom_nav.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _user;

  // Selected tab: 0 = Today, 1 = Future, 2 = Timetable, -1 = none
  int _selectedTab = 0;

  List<EventModel> _todayEvents = [];
  List<EventModel> _upcomingEvents = [];

  bool _isLoadingData = true;
  bool _isTogglingStatus = false;

  @override
  void initState() {
    super.initState();
    _user = AuthState().currentUser;
    if (_user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
    } else {
      _loadInitialData();
    }
  }

  Future<void> _loadInitialData() async {
    if (_user == null) return;
    setState(() => _isLoadingData = true);

    final refreshedUser = await ApiService.getUser(_user!.id);
    if (refreshedUser != null) {
      _user = refreshedUser;
      AuthState().setUser(refreshedUser);
    }

    final today = await ApiService.getTodayEvents();
    final upcoming = await ApiService.getUpcomingEvents();

    if (!mounted) return;
    setState(() {
      _todayEvents = today;
      _upcomingEvents = upcoming;
      _isLoadingData = false;
    });
  }

  Future<void> _toggleStatus() async {
    if (_user == null || _isTogglingStatus) return;

    setState(() => _isTogglingStatus = true);

    final newStatus = !_user!.isPresent;
    final updated = await ApiService.updateStatus(_user!.id, newStatus);

    if (!mounted) return;
    setState(() {
      _isTogglingStatus = false;
      if (updated != null) {
        _user = updated;
        AuthState().setUser(updated);
        showAppSnackBar(
          context,
          "Status changed to ${updated.isPresent ? 'PRESENT' : 'ABSENT'}",
        );
      }
    });
  }

  /// Converts Google Drive shareable link to a direct viewable image link
  String _convertGoogleDriveLink(String link) {
    try {
      final regExp = RegExp(r'(?:id=|\/d\/|\/file\/d\/)([a-zA-Z0-9_-]+)');
      final match = regExp.firstMatch(link);
      if (match != null && match.groupCount >= 1) {
        final fileId = match.group(1)!;
        return 'https://drive.google.com/uc?export=view&id=$fileId';
      }
    } catch (_) {}
    return link;
  }

  void _showUploadTimetableDialog() {
    final linkController = TextEditingController(text: _user?.timetableUrl ?? '');

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppConstants.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: AppConstants.cardBorderColor),
        ),
        title: const Text(
          "Set Timetable Link",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Paste a direct image URL or Google Drive sharing link for your class schedule.",
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppConstants.inputFillColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppConstants.cardBorderColor),
              ),
              child: TextField(
                controller: linkController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: "https://drive.google.com/... or image link",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                  contentPadding: const EdgeInsets.all(14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("Cancel", style: TextStyle(color: Colors.white.withOpacity(0.6))),
          ),
          ElevatedButton(
            onPressed: () async {
              if (linkController.text.trim().isNotEmpty) {
                final converted = _convertGoogleDriveLink(linkController.text.trim());
                final updated = await ApiService.updateTimetable(_user!.id, converted);
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                if (!mounted) return;
                if (updated != null) {
                  setState(() {
                    _user = updated;
                    AuthState().setUser(updated);
                  });
                  showAppSnackBar(context, "Timetable link updated!");
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text("Save Link", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showTimetableFullscreen(String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.92),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    padding: const EdgeInsets.all(24),
                    color: AppConstants.cardColor,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image, color: Colors.white54, size: 48),
                        SizedBox(height: 12),
                        Text(
                          "Failed to load image preview",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
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
                child: RefreshIndicator(
                  color: Colors.white,
                  backgroundColor: AppConstants.cardColor,
                  onRefresh: _loadInitialData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // App Bar Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppConstants.appName,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh, color: Colors.white70),
                                onPressed: _loadInitialData,
                              ),
                            ],
                          ),
                        ),

                        // 1. Profile Summary Card with Presence Toggle
                        _buildProfileCard(),

                        const SizedBox(height: 20),

                        // 2. Horizontal Action Filter Tabs
                        _buildTopTabs(),

                        const SizedBox(height: 18),

                        // 3. Tab Content Section
                        if (_isLoadingData)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          )
                        else ...[
                          if (_selectedTab == 0) _buildEventsList("Today's Events", _todayEvents),
                          if (_selectedTab == 1) _buildEventsList("Upcoming Events", _upcomingEvents),
                          if (_selectedTab == 2) _buildTimetableSection(),
                        ],

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Navigation Bar
              const CustomBottomNav(currentIndex: -1),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // --- Profile Card Widget ---
  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
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
          // User Info
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _user!.dept,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _user!.customId,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),

          // Presence Toggle Button
          GestureDetector(
            onTap: _toggleStatus,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _user!.isPresent
                    ? AppConstants.accentGreen.withOpacity(0.18)
                    : AppConstants.accentRed.withOpacity(0.18),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: _user!.isPresent ? AppConstants.accentGreen : AppConstants.accentRed,
                  width: 1.8,
                ),
              ),
              child: _isTogglingStatus
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _user!.isPresent ? Icons.check_circle : Icons.cancel,
                          color: _user!.isPresent ? AppConstants.accentGreen : AppConstants.accentRed,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _user!.isPresent ? "PRESENT" : "ABSENT",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Top Tabs Widget ---
  Widget _buildTopTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 48,
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          children: [
            _tabButton("Current Events", 0),
            const SizedBox(width: 10),
            _tabButton("Future Events", 1),
            const SizedBox(width: 10),
            _tabButton("Time Table", 2),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String title, int tabIndex) {
    final bool isSelected = _selectedTab == tabIndex;

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = tabIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.20) : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.white.withOpacity(0.6) : Colors.white.withOpacity(0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // --- Events List Widget ---
  Widget _buildEventsList(String title, List<EventModel> events) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppConstants.cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_note, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                "${events.length} items",
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (events.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  "No events scheduled.",
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final e = events[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppConstants.cardBorderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.schedule, color: Colors.white70, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "${e.time} • ${e.eventDate.day}/${e.eventDate.month}/${e.eventDate.year}",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.65),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // --- Timetable Section ---
  Widget _buildTimetableSection() {
    final hasTimetable = _user?.timetableUrl != null && _user!.timetableUrl!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppConstants.cardBorderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.table_chart, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                "Class Timetable",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (!hasTimetable)
            Column(
              children: [
                const SizedBox(height: 12),
                Icon(Icons.calendar_view_week, size: 48, color: Colors.white.withOpacity(0.3)),
                const SizedBox(height: 12),
                Text(
                  "No Timetable Uploaded",
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _showUploadTimetableDialog,
                  icon: const Icon(Icons.link, color: Colors.white),
                  label: const Text("Add Timetable Link", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                GestureDetector(
                  onTap: () => _showTimetableFullscreen(_user!.timetableUrl!),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          _user!.timetableUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 140,
                            color: Colors.white.withOpacity(0.05),
                            child: const Center(
                              child: Text(
                                "Invalid image URL or preview not available",
                                style: TextStyle(color: Colors.white54),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 200,
                          color: Colors.black.withOpacity(0.25),
                          child: const Center(
                            child: Icon(Icons.zoom_in, color: Colors.white, size: 40),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: _showUploadTimetableDialog,
                  icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                  label: const Text("Replace Timetable Link", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
