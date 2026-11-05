import 'dart:async';
import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_state.dart';
import '../utils/constants.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key});
  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  List<GroupModel> _groups = [];
  Timer? _timer;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 8), (_) => _load(silent: true));
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  Future<void> _load({bool silent = false}) async {
    final groups = await ApiService.getGroups();
    if (!mounted) return;
    setState(() { _groups = groups; _loading = false; });
  }

  Future<void> _createGroup() async {
    final name = TextEditingController();
    final description = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final created = await showDialog<GroupModel>(context: context, builder: (dialogContext) => AlertDialog(
      backgroundColor: AppConstants.cardColor,
      title: const Text('Create faculty group', style: TextStyle(color: Colors.white)),
      content: Form(key: formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: name, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Group name'),
          validator: (v) => v == null || v.trim().isEmpty ? 'Group name is required' : null),
        TextField(controller: description, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Description (optional)')),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
        FilledButton(onPressed: () async { if (!formKey.currentState!.validate()) return;
          final group = await ApiService.createGroup(name.text, description.text);
          if (dialogContext.mounted) Navigator.pop(dialogContext, group);
        }, child: const Text('Create'))],
    ));
    name.dispose(); description.dispose();
    if (created == null || !mounted) return;
    await _load();
    await Navigator.push(context, MaterialPageRoute(builder: (_) => GroupRoomScreen(group: created))).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppConstants.backgroundColor,
    appBar: AppBar(backgroundColor: AppConstants.cardColor, title: const Text('Group Chats', style: TextStyle(color: Colors.white)),
      iconTheme: const IconThemeData(color: Colors.white), actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))]),
    floatingActionButton: FloatingActionButton.extended(onPressed: _createGroup, icon: const Icon(Icons.group_add), label: const Text('Create Group')),
    body: _loading ? const Center(child: CircularProgressIndicator()) : RefreshIndicator(onRefresh: _load,
      child: _groups.isEmpty ? ListView(children: const [SizedBox(height: 160), Center(child: Text('No groups yet', style: TextStyle(color: Colors.white70)))])
        : ListView.separated(padding: const EdgeInsets.all(16), itemCount: _groups.length, separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) { final group = _groups[index]; return ListTile(
            tileColor: AppConstants.cardColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            leading: const CircleAvatar(child: Icon(Icons.groups)), title: Text(group.name, style: const TextStyle(color: Colors.white)),
            subtitle: Text(group.lastMessage.isNotEmpty ? group.lastMessage : '${group.members.length} members', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60)),
            trailing: group.unreadCount > 0 ? CircleAvatar(radius: 12, child: Text('${group.unreadCount}', style: const TextStyle(fontSize: 11))) : null,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GroupRoomScreen(group: group))).then((_) => _load()),
          );}),
    ),
  );
}

class GroupRoomScreen extends StatefulWidget {
  final GroupModel group;
  const GroupRoomScreen({super.key, required this.group});
  @override
  State<GroupRoomScreen> createState() => _GroupRoomScreenState();
}

class _GroupRoomScreenState extends State<GroupRoomScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  List<GroupMessageModel> _messages = [];
  GroupModel? _group;
  Timer? _timer;
  bool _sending = false;

  GroupModel get group => _group ?? widget.group;
  bool get canManage => group.myRole == 'ADMIN';

  @override
  void initState() { super.initState(); _load(); _timer = Timer.periodic(const Duration(seconds: 3), (_) => _load(silent: true)); }
  @override
  void dispose() { _timer?.cancel(); _controller.dispose(); _scroll.dispose(); super.dispose(); }

  Future<void> _load({bool silent = false}) async {
    final results = await Future.wait([ApiService.getGroupMessages(widget.group.id), ApiService.getGroups()]);
    if (!mounted) return;
    final groups = results[1] as List<GroupModel>;
    final matches = groups.where((g) => g.id == widget.group.id).toList();
    setState(() { _messages = results[0] as List<GroupMessageModel>; if (matches.isNotEmpty) _group = matches.first; });
    if (!silent) WidgetsBinding.instance.addPostFrameCallback((_) { if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent); });
  }

  Future<void> _send() async {
    final text = _controller.text.trim(); if (text.isEmpty || _sending) return;
    setState(() => _sending = true); _controller.clear();
    final message = await ApiService.sendGroupMessage(widget.group.id, text);
    if (!mounted) return;
    setState(() => _sending = false);
    if (message != null) { setState(() => _messages.add(message)); WidgetsBinding.instance.addPostFrameCallback((_) { if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent); }); }
    else { showAppSnackBar(context, 'Message could not be sent', isError: true); }
  }

  Future<void> _manageMembers() async {
    if (!canManage) return;
    final candidates = await ApiService.searchUsers();
    final currentUserId = AuthState().currentUser?.id;
    final eligible = candidates.where((u) => u.id != currentUserId && !group.members.any((m) => m.userId == u.id)).toList();
    if (!mounted) return;
    await showModalBottomSheet<void>(context: context, backgroundColor: AppConstants.cardColor,
      builder: (sheetContext) => SafeArea(child: ListView(padding: const EdgeInsets.all(16), shrinkWrap: true, children: [
        const Text('Group membership', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...group.members.map((member) => ListTile(title: Text(member.name, style: const TextStyle(color: Colors.white)),
          subtitle: Text(member.role, style: const TextStyle(color: Colors.white54)),
          trailing: member.userId == group.ownerId ? const Icon(Icons.shield, color: Colors.amber) : IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
            onPressed: () async { if (await ApiService.removeGroupMember(group.id, member.userId) && sheetContext.mounted) { Navigator.pop(sheetContext); await _load(); } }),)),
        const Divider(color: Colors.white24), const Text('Add faculty', style: TextStyle(color: Colors.white70)),
        ...eligible.map((UserModel user) => ListTile(title: Text(user.name, style: const TextStyle(color: Colors.white)), subtitle: Text(user.dept, style: const TextStyle(color: Colors.white54)),
          trailing: IconButton(icon: const Icon(Icons.person_add_alt_1, color: Colors.white), onPressed: () async {
            if (await ApiService.addGroupMember(group.id, user.id) != null && sheetContext.mounted) { Navigator.pop(sheetContext); await _load(); }
          }))),
      ])));
    await _load(silent: true);
  }

  @override
  Widget build(BuildContext context) {
    final me = AuthState().currentUser;
    return Scaffold(backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(backgroundColor: AppConstants.cardColor, iconTheme: const IconThemeData(color: Colors.white),
        title: Text(group.name, style: const TextStyle(color: Colors.white)),
        actions: [if (canManage) IconButton(tooltip: 'Manage members', onPressed: _manageMembers, icon: const Icon(Icons.group_add))]),
      body: Column(children: [
        Expanded(child: ListView.builder(controller: _scroll, padding: const EdgeInsets.all(14), itemCount: _messages.length,
          itemBuilder: (context, index) { final message = _messages[index]; final mine = message.senderId == me?.id; final senders = group.members.where((m) => m.userId == message.senderId).toList(); final sender = senders.isEmpty ? null : senders.first;
            return Align(alignment: mine ? Alignment.centerRight : Alignment.centerLeft, child: Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(12),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .78), decoration: BoxDecoration(color: AppConstants.cardColor, borderRadius: BorderRadius.circular(16)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (!mine) Text(sender?.name ?? 'Faculty', style: const TextStyle(color: Colors.white60, fontSize: 11)),
                Text(message.content, style: const TextStyle(color: Colors.white)), Text(TimeOfDay.fromDateTime(message.sentAt.toLocal()).format(context), style: const TextStyle(color: Colors.white38, fontSize: 10))])));
          })),
        SafeArea(top: false, child: Padding(padding: const EdgeInsets.all(10), child: Row(children: [Expanded(child: TextField(controller: _controller, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'Message the group'))),
          IconButton(onPressed: _sending ? null : _send, icon: const Icon(Icons.send, color: Colors.white))]))),
      ]));
  }
}
