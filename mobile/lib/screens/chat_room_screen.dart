import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_state.dart';
import '../utils/constants.dart';

class ChatRoomScreen extends StatefulWidget {
  final UserModel otherUser;

  const ChatRoomScreen({super.key, required this.otherUser});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  List<MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    // Poll messages every 3 seconds for active live chat experience
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _loadMessages(silent: true);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages({bool silent = false}) async {
    final currentUser = AuthState().currentUser;
    if (currentUser == null) return;

    if (!silent) setState(() => _isLoading = true);

    final history = await ApiService.getChatHistory(widget.otherUser.id);

    if (!mounted) return;
    setState(() {
      _messages = history;
      if (!silent) _isLoading = false;
    });

    if (!silent) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    final currentUser = AuthState().currentUser;
    if (currentUser == null) return;

    _messageController.clear();
    setState(() => _isSending = true);

    final sent = await ApiService.sendMessage(
      receiverId: widget.otherUser.id,
      content: text,
    );

    if (!mounted) return;
    setState(() => _isSending = false);

    if (sent != null) {
      setState(() {
        _messages.add(sent);
      });
      _scrollToBottom();
    } else {
      showAppSnackBar(context, "Failed to send message", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthState().currentUser;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.12),
              backgroundImage: widget.otherUser.photoUrl != null && widget.otherUser.photoUrl!.isNotEmpty
                  ? NetworkImage(widget.otherUser.photoUrl!)
                  : null,
              child: (widget.otherUser.photoUrl == null || widget.otherUser.photoUrl!.isEmpty)
                  ? Text(
                      widget.otherUser.name.isNotEmpty ? widget.otherUser.name[0].toUpperCase() : 'U',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUser.name,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.otherUser.isPresent ? AppConstants.accentGreen : AppConstants.accentRed,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.otherUser.isPresent ? "Online / Present" : "Absent",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 11,
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
              // 1. Messages List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : _messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 48, color: Colors.white.withOpacity(0.2)),
                                const SizedBox(height: 12),
                                Text(
                                  "Say hello to ${widget.otherUser.name}!",
                                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final msg = _messages[index];
                              final bool isMe = currentUser != null && msg.senderId == currentUser.id;

                              return Align(
                                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? Colors.white.withOpacity(0.20)
                                        : AppConstants.cardColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(20),
                                      topRight: const Radius.circular(20),
                                      bottomLeft: Radius.circular(isMe ? 20 : 4),
                                      bottomRight: Radius.circular(isMe ? 4 : 20),
                                    ),
                                    border: Border.all(
                                      color: isMe
                                          ? Colors.white.withOpacity(0.35)
                                          : AppConstants.cardBorderColor,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        msg.content,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('hh:mm a').format(msg.sentAt),
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.4),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),

              // 2. Input Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppConstants.cardColor,
                  border: Border(
                    top: BorderSide(color: AppConstants.cardBorderColor),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppConstants.inputFillColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppConstants.cardBorderColor),
                        ),
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: InputDecoration(
                            hintText: "Type a message...",
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _isSending ? null : _sendMessage,
                      icon: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded, color: Colors.white, size: 24),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
