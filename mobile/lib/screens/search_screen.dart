import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/search_history_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_state.dart';
import '../utils/constants.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/user_details_modal.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  List<UserModel> _allUsers = [];
  List<UserModel> _searchResults = [];
  List<SearchHistoryModel> _searchHistory = [];

  bool _isLoading = true;
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _syncTimer = Timer.periodic(const Duration(seconds: 20), (_) => _loadData(silent: true));
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _syncTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool silent = false}) async {
    final user = AuthState().currentUser;
    if (user == null) return;

    if (!silent) setState(() => _isLoading = true);

    final users = await ApiService.searchUsers();
    final history = await ApiService.getSearchHistory(user.id);

    if (!mounted) return;
    setState(() {
      // Exclude current user from member directory
      _allUsers = users.where((u) => u.id != user.id).toList();
      _searchHistory = history;
      final query = _searchController.text.trim().toLowerCase();
      _searchResults = query.isEmpty ? _allUsers : _allUsers.where((u) => u.name.toLowerCase().contains(query) || u.dept.toLowerCase().contains(query) || u.customId.toLowerCase().contains(query)).toList();
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _searchResults = _allUsers;
      } else {
        _searchResults = _allUsers.where((u) {
          final name = u.name.toLowerCase();
          final dept = u.dept.toLowerCase();
          final id = u.customId.toLowerCase();
          return name.contains(query) || dept.contains(query) || id.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _onUserTapped(UserModel targetUser) async {
    final currentUser = AuthState().currentUser;
    if (currentUser != null) {
      await ApiService.saveSearchHistory(currentUser.id, targetUser.id);
      final refreshedHistory = await ApiService.getSearchHistory(currentUser.id);
      if (mounted) setState(() => _searchHistory = refreshedHistory);
    }

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserDetailsModal(user: targetUser),
    );
  }

  Future<void> _deleteHistoryItem(int searchedUserId) async {
    final currentUser = AuthState().currentUser;
    if (currentUser == null) return;

    setState(() {
      _searchHistory.removeWhere((item) => item.searchedUserId == searchedUserId);
    });

    await ApiService.clearSearchHistory(currentUser.id, searchedUserId: searchedUserId);
  }

  Future<void> _clearAllHistory() async {
    final currentUser = AuthState().currentUser;
    if (currentUser == null) return;

    setState(() => _searchHistory = []);
    await ApiService.clearSearchHistory(currentUser.id);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSearchQuery = _searchController.text.isNotEmpty;

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
              // 1. Search Bar Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppConstants.cardColor,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: AppConstants.cardBorderColor),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          decoration: InputDecoration(
                            hintText: "Search faculty name, department, ID...",
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                            prefixIcon: const Icon(Icons.search, color: Colors.white60, size: 22),
                            suffixIcon: hasSearchQuery
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.white60, size: 18),
                                    onPressed: () => _searchController.clear(),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Body: Recent Searches & Search Results
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Recent Search History Section (shown when search field is empty)
                            if (!hasSearchQuery && _searchHistory.isNotEmpty) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Recent Searches",
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _clearAllHistory,
                                    child: Text(
                                      "Clear All",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _searchHistory.map((item) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppConstants.cardColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: AppConstants.cardBorderColor),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            _searchController.text = item.searchedUserName;
                                          },
                                          child: Row(
                                            children: [
                                              const Icon(Icons.history, size: 14, color: Colors.white60),
                                              const SizedBox(width: 6),
                                              Text(
                                                item.searchedUserName,
                                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        GestureDetector(
                                          onTap: () => _deleteHistoryItem(item.searchedUserId),
                                          child: const Icon(Icons.close, size: 14, color: Colors.white54),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Faculty Directory Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  hasSearchQuery ? "Search Results" : "Faculty Directory",
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${_searchResults.length} faculty",
                                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Faculty List
                            if (_searchResults.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40),
                                child: Center(
                                  child: Text(
                                    "No faculty found matching '$queryText'",
                                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                                  ),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _searchResults.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final user = _searchResults[index];
                                  return GestureDetector(
                                    onTap: () => _onUserTapped(user),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppConstants.cardColor,
                                        borderRadius: BorderRadius.circular(22),
                                        border: Border.all(color: AppConstants.cardBorderColor),
                                      ),
                                      child: Row(
                                        children: [
                                          // Member Avatar
                                          CircleAvatar(
                                            radius: 24,
                                            backgroundColor: Colors.white.withOpacity(0.12),
                                            backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                                                ? NetworkImage(user.photoUrl!)
                                                : null,
                                            child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                                                ? Text(
                                                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 14),

                                          // Member Info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  user.name,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  "${user.dept} • ${user.customId}",
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.65),
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Presence Status Pill
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: AppConstants.availabilityColor(user.availabilityStatus).withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: AppConstants.availabilityColor(user.availabilityStatus),
                                                width: 1.2,
                                              ),
                                            ),
                                            child: Text(
                                              user.availabilityStatus.toUpperCase(),
                                              style: TextStyle(
                                                color: AppConstants.availabilityColor(user.availabilityStatus),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
              ),

              // Bottom Navigation Bar
              const CustomBottomNav(currentIndex: 0),
            ],
          ),
        ),
      ),
    );
  }

  String get queryText => _searchController.text.trim();
}
