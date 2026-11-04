import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';
import '../services/auth_state.dart';
import '../utils/constants.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/custom_text_field.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  List<EventModel> _allEvents = [];
  bool _isLoading = true;

  final _titleController = TextEditingController();
  final _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    final user = AuthState().currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    final events = await ApiService.getEvents();

    if (!mounted) return;
    setState(() {
      _allEvents = events;
      _isLoading = false;
    });
  }

  List<EventModel> _getEventsForDay(DateTime day) {
    return _allEvents.where((e) {
      return e.eventDate.year == day.year &&
          e.eventDate.month == day.month &&
          e.eventDate.day == day.day;
    }).toList();
  }

  void _showAddEventDialog() {
    _titleController.clear();
    _timeController.clear();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (dialogContext) => _buildEventDialog(
        title: "Add New Event",
        onSave: () async {
          final user = AuthState().currentUser;
          if (user == null) return;

          if (_titleController.text.trim().isEmpty || _timeController.text.trim().isEmpty) {
            showAppSnackBar(context, "Please fill all fields", isError: true);
            return;
          }

          final newEvent = await ApiService.createEvent(
            title: _titleController.text.trim(),
            time: _timeController.text.trim(),
            eventDate: _selectedDay,
          );

          if (dialogContext.mounted) {
            Navigator.pop(dialogContext);
          }

          if (!mounted) return;
          if (newEvent != null) {
            showAppSnackBar(context, "Event added successfully!");
            _loadEvents();
          } else {
            showAppSnackBar(context, "Failed to create event", isError: true);
          }
        },
      ),
    );
  }

  void _showEditEventDialog(EventModel event) {
    _titleController.text = event.title;
    _timeController.text = event.time;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (dialogContext) => _buildEventDialog(
        title: "Edit Event",
        onSave: () async {
          final user = AuthState().currentUser;
          if (user == null) return;

          if (_titleController.text.trim().isEmpty || _timeController.text.trim().isEmpty) {
            showAppSnackBar(context, "Please fill all fields", isError: true);
            return;
          }

          final updated = await ApiService.updateEvent(
            event.id,
            title: _titleController.text.trim(),
            time: _timeController.text.trim(),
            eventDate: event.eventDate,
          );

          if (dialogContext.mounted) {
            Navigator.pop(dialogContext);
          }

          if (!mounted) return;
          if (updated != null) {
            showAppSnackBar(context, "Event updated!");
            _loadEvents();
          } else {
            showAppSnackBar(context, "Failed to update event", isError: true);
          }
        },
      ),
    );
  }

  void _confirmDeleteEvent(EventModel event) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppConstants.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppConstants.cardBorderColor),
        ),
        title: const Text("Delete Event?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          "Are you sure you want to delete '${event.title}'?",
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("Cancel", style: TextStyle(color: Colors.white.withOpacity(0.7))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await ApiService.deleteEvent(event.id);
              if (!mounted) return;
              if (success) {
                showAppSnackBar(context, "Event deleted");
                _loadEvents();
              } else {
                showAppSnackBar(context, "Failed to delete event", isError: true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.3),
              foregroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _showEventOptions(EventModel event) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppConstants.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: AppConstants.cardBorderColor),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              event.title,
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              "${event.time} • ${event.eventDate.day}/${event.eventDate.month}/${event.eventDate.year}",
              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 24),

            // Edit Option
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: Colors.white),
              title: const Text("Edit Event", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: Colors.white.withOpacity(0.06),
              onTap: () {
                Navigator.pop(context);
                _showEditEventDialog(event);
              },
            ),
            const SizedBox(height: 12),

            // Delete Option
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text("Delete Event", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: Colors.red.withOpacity(0.1),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteEvent(event);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventDialog({required String title, required VoidCallback onSave}) {
    return AlertDialog(
      backgroundColor: AppConstants.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: AppConstants.cardBorderColor),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: _titleController,
              labelText: "Event Title",
              hintText: "e.g. AI Lab Viva or Seminar",
              prefixIcon: Icons.title,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _timeController,
              labelText: "Time",
              hintText: "e.g. 10:00 AM - 11:30 AM",
              prefixIcon: Icons.access_time,
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel", style: TextStyle(color: Colors.white.withOpacity(0.6))),
        ),
        ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text("Save Event", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvents = _getEventsForDay(_selectedDay);

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
          "Calendar & Events",
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 26),
            onPressed: _showAddEventDialog,
            tooltip: "Add Event",
          ),
        ],
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: [
                      // 1. Calendar Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppConstants.cardColor,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: AppConstants.cardBorderColor),
                        ),
                        child: TableCalendar(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                          calendarFormat: CalendarFormat.month,
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white70),
                            rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white70),
                          ),
                          calendarStyle: CalendarStyle(
                            defaultTextStyle: const TextStyle(color: Colors.white),
                            weekendTextStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                            outsideTextStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                            todayDecoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            selectedTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 2. Selected Day Header & Add Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Events on ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: _showAddEventDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppConstants.cardBorderColor),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.add, color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    "Add Event",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // 3. Events List for Selected Day
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Center(child: CircularProgressIndicator(color: Colors.white)),
                        )
                      else if (selectedEvents.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 36),
                          decoration: BoxDecoration(
                            color: AppConstants.cardColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppConstants.cardBorderColor),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.event_busy, color: Colors.white.withOpacity(0.3), size: 40),
                              const SizedBox(height: 10),
                              Text(
                                "No events for this date.",
                                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: selectedEvents.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final event = selectedEvents[index];
                            return GestureDetector(
                              onTap: () => _showEventOptions(event),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppConstants.cardColor,
                                  borderRadius: BorderRadius.circular(20),
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
                                      child: const Icon(Icons.schedule, color: Colors.white, size: 20),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            event.title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            event.time,
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.7),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.more_vert, color: Colors.white.withOpacity(0.4)),
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
              const CustomBottomNav(currentIndex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
