import 'dart:async';
import 'package:flutter/material.dart';
import '../models/timetable_slot_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class TimetableScreen extends StatefulWidget {
  final int userId;
  final bool canEdit;
  const TimetableScreen({super.key, required this.userId, this.canEdit = false});
  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  static const _days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];
  List<TimetableSlotModel> _slots = [];
  Timer? _timer;
  bool _loading = true;
  @override
  void initState() { super.initState(); _load(); _timer = Timer.periodic(const Duration(seconds: 20), (_) => _load(silent: true)); }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }
  Future<void> _load({bool silent = false}) async {
    final slots = await ApiService.getTimetableSlots(widget.userId);
    if (mounted) setState(() { _slots = slots; _loading = false; });
  }

  Future<void> _edit([TimetableSlotModel? slot]) async {
    if (!widget.canEdit) return;
    final course = TextEditingController(text: slot?.courseName ?? '');
    final details = TextEditingController(text: slot?.activityDetails ?? '');
    final location = TextEditingController(text: slot?.location ?? '');
    final start = TextEditingController(text: slot?.startTime.substring(0, 5) ?? '09:00');
    final end = TextEditingController(text: slot?.endTime.substring(0, 5) ?? '10:00');
    String day = slot?.dayOfWeek ?? 'MONDAY';
    final formKey = GlobalKey<FormState>();
    await showDialog<void>(context: context, builder: (dialogContext) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
      backgroundColor: AppConstants.cardColor,
      title: Text(slot == null ? 'Add timetable slot' : 'Edit timetable slot', style: const TextStyle(color: Colors.white)),
      content: SingleChildScrollView(child: Form(key: formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<String>(value: day, dropdownColor: AppConstants.cardColor, style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: 'Day', labelStyle: TextStyle(color: Colors.white70)),
          items: _days.map((d) => DropdownMenuItem(value: d, child: Text(d[0] + d.substring(1).toLowerCase()))).toList(),
          onChanged: (value) { if (value != null) setDialogState(() => day = value); }),
        _field(course, 'Course or activity', requiredField: true), _field(details, 'Details (optional)'),
        _field(start, 'Start (24-hour HH:mm)', requiredField: true), _field(end, 'End (24-hour HH:mm)', requiredField: true), _field(location, 'Location (optional)'),
      ]))),
      actions: [
        if (slot != null) TextButton(onPressed: () async { if (await ApiService.deleteTimetableSlot(widget.userId, slot.id) && dialogContext.mounted) Navigator.pop(dialogContext); }, child: const Text('Delete', style: TextStyle(color: Colors.redAccent))),
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
        FilledButton(onPressed: () async {
          if (!formKey.currentState!.validate()) return;
          if (!_validTime(start.text) || !_validTime(end.text) || end.text.compareTo(start.text) <= 0) {
            showAppSnackBar(context, 'Use valid HH:mm times and an end time after the start', isError: true); return;
          }
          final saved = await ApiService.saveTimetableSlot(widget.userId, slotId: slot?.id, dayOfWeek: day,
            startTime: start.text, endTime: end.text, courseName: course.text, activityDetails: details.text, location: location.text);
          if (saved != null && dialogContext.mounted) Navigator.pop(dialogContext);
        }, child: const Text('Save')),
      ],
    )));
    course.dispose(); details.dispose(); location.dispose(); start.dispose(); end.dispose();
    await _load();
  }

  Widget _field(TextEditingController c, String label, {bool requiredField = false}) => Padding(padding: const EdgeInsets.only(top: 10),
    child: TextFormField(controller: c, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.white70)),
      validator: requiredField ? (v) => v == null || v.trim().isEmpty ? 'Required' : null : null));
  bool _validTime(String value) => RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(value.trim());

  @override
  Widget build(BuildContext context) {
    final ordered = [..._slots]..sort((a,b) => _days.indexOf(a.dayOfWeek).compareTo(_days.indexOf(b.dayOfWeek)) != 0
      ? _days.indexOf(a.dayOfWeek).compareTo(_days.indexOf(b.dayOfWeek)) : a.startTime.compareTo(b.startTime));
    return Scaffold(backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(backgroundColor: AppConstants.cardColor, title: Text(widget.canEdit ? 'My Weekly Timetable' : 'Weekly Timetable', style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white)),
      floatingActionButton: widget.canEdit ? FloatingActionButton.extended(onPressed: () => _edit(), icon: const Icon(Icons.add), label: const Text('Add slot')) : null,
      body: _loading ? const Center(child: CircularProgressIndicator()) : RefreshIndicator(onRefresh: _load,
        child: ordered.isEmpty ? ListView(children: [const SizedBox(height: 160), Center(child: Text(widget.canEdit ? 'No weekly slots yet' : 'No timetable slots shared', style: const TextStyle(color: Colors.white70)))])
          : ListView(padding: const EdgeInsets.all(16), children: [for (final day in _days) ...[
            if (ordered.any((s) => s.dayOfWeek == day)) ...[
              Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(day[0] + day.substring(1).toLowerCase(), style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
              ...ordered.where((s) => s.dayOfWeek == day).map((s) => Card(color: AppConstants.cardColor, child: ListTile(
                onTap: widget.canEdit ? () => _edit(s) : null, leading: Text('${s.startTime.substring(0,5)}\n${s.endTime.substring(0,5)}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                title: Text(s.courseName, style: const TextStyle(color: Colors.white)),
                subtitle: Text([s.activityDetails, s.location].where((v) => v != null && v.isNotEmpty).join(' • '), style: const TextStyle(color: Colors.white60)),
              ))),
            ],
          ]]),
      ),
    );
  }
}
