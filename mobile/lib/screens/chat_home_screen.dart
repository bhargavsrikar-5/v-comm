import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_state.dart';
import '../utils/constants.dart';
import '../widgets/custom_bottom_nav.dart';
import 'chat_room_screen.dart';
import 'search_screen.dart';
import 'group_chat_screen.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  List<ConversationModel> _conversations = [];
  bool _isLoading = true;
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _syncTimer = Timer.periodic(const Duration(seconds: 8), (_) => _loadConversations(silent: true));
  }

  @override
  void dispose() { _syncTimer?.cancel(); super.dispose(); }

  Future<void> _loadConversations({bool silent = false}) async {
    final user = AuthState().currentUser;
    if (user == null) return;

    if (!silent) setState(() => _isLoading = true);
    final convs = await ApiService.getConversations();

    if (!mounted) return;
    setState(() {
      _conversations = convs;
      _isLoading = false;
    });
  }

  void _openChat(UserModel otherUser) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomScreen(otherUser: otherUser),
      ),
    ).then((_) => _loadConversations());
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (time.year == now.year && time.month == now.month && time.day == now.day) {
      return DateFormat('hh:mm a').format(time);
    }
    return DateFormat('dd/MM').format(time);
  }

  @override
  Widget build(BuildContext context) {
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
          "Messages",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Group chats',
            icon: const Icon(Icons.groups_outlined, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GroupChatScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            tooltip: "Find Members to Chat",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.chat),
        label: const Text("New Chat", style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchScreen()),
          );
        },
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
                child: RefreshIndicator(
                  color: Colors.white,
                  backgroundColor: AppConstants.cardColor,
                  onRefresh: _loadConversations,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : _conversations.isEmpty
                          ? ListView(
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                                Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.mark_chat_unread_outlined, size: 54, color: Colors.white.withOpacity(0.3)),
                                      const SizedBox(height: 14),
                                      Text(
                                        "No conversations yet",
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Search for members to start messaging.",
                                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const SearchScreen()),
                                          );
                                        },
                                        icon: const Icon(Icons.search, color: Colors.white),
                                        label: const Text("Browse Directory", style: TextStyle(color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white.withOpacity(0.15),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              itemCount: _conversations.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final conv = _conversations[index];
                                final other = conv.otherUser;

                                return GestureDetector(
                                  onTap: () => _openChat(other),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppConstants.cardColor,
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(color: AppConstants.cardBorderColor),
                                    ),
                                    child: Row(
                                      children: [
                                        // User Avatar
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundColor: Colors.white.withOpacity(0.12),
                                          backgroundImage: other.photoUrl != null && other.photoUrl!.isNotEmpty
                                              ? NetworkImage(other.photoUrl!)
                                              : null,
                                          child: (other.photoUrl == null || other.photoUrl!.isEmpty)
                                              ? Text(
                                                  other.name.isNotEmpty ? other.name[0].toUpperCase() : 'U',
                                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 14),

                                        // Name & Last Message
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      other.name,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Text(
                                                    _formatTime(conv.lastMessageTime),
                                                    style: TextStyle(
                                                      color: Colors.white.withOpacity(0.45),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      conv.lastMessage,
                                                      style: TextStyle(
                                                        color: Colors.white.withOpacity(0.65),
                                                        fontSize: 13,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  if (conv.unreadCount > 0)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Text(
                                                        "${conv.unreadCount}",
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ),

              // Bottom Navigation Bar
              const CustomBottomNav(currentIndex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
