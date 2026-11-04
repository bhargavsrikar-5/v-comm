import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart' hide NavigationBar;
import 'package:image_picker/image_picker.dart';
import 'package:v_comm/HomePage/navigation_bar.dart';
import 'package:v_comm/HomePage/profile_card.dart';

class Homepage extends StatefulWidget {
  User? user;
  Homepage({super.key, required this.user});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String name = "";
  String dept = "";
  String customId = "";
  bool isOn = true;

  bool _selectedToday = false;
  bool _selectedFuture = false;
  bool _selectedTime = false;

  bool _showTodayEvents = false;
  bool _showFutureEvents = false;
  bool _showTimeTable = false;

  String? timetableUrl;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchTimetable();
  }

  Future<void> fetchUserData() async {
    if (widget.user == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.user!.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        setState(() {
          name = data?['name'] ?? "";
          dept = data?['dept'] ?? "";
          customId = data?['customId'] ?? "";
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  /// ✅ Stream for TODAY events
  Stream<List<Map<String, dynamic>>> streamTodayEvents() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    final now = DateTime.now();
    DateTime todayStart = DateTime(now.year, now.month, now.day);
    DateTime todayEnd = todayStart.add(const Duration(days: 1));

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('events')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .where('date', isLessThan: Timestamp.fromDate(todayEnd))
        .orderBy('date')
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        final d = doc.data();
        return {
          "id": doc.id,
          "title": d["title"],
          "time": d["time"],
          "date": (d["date"] as Timestamp).toDate(),
        };
      }).toList();
    });
  }

  /// ✅ Stream for FUTURE events
  Stream<List<Map<String, dynamic>>> streamFutureEvents() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('events')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
        .orderBy('date')
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        final d = doc.data();
        return {
          "id": doc.id,
          "title": d["title"],
          "time": d["time"],
          "date": (d["date"] as Timestamp).toDate(),
        };
      }).toList();
    });
  }

  /// ✅ Load timetable
  Future<void> fetchTimetable() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance.collection("users").doc(user.uid).get();

    if (doc.exists && doc.data()?["timetableUrl"] != null) {
      setState(() {
        timetableUrl = doc.data()?["timetableUrl"];
      });
    }
  }

  /// ✅ Upload timetable
  Future<void> uploadTimetable() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    File imageFile = File(picked.path);

    final ref = FirebaseStorage.instance
        .ref()
        .child("timetable")
        .child("${user.uid}.jpg");

    await ref.putFile(imageFile);
    final url = await ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .update({"timetableUrl": url});

    setState(() {
      timetableUrl = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 100),

                  ProfileCard(
                    name: name,
                    dept: dept,
                    customId: customId,
                    isOn: isOn,
                  ),

                  const SizedBox(height: 20),

                  /// ✅ TOP BUTTONS SCROLLABLE + PADDING
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          /// ✅ TODAY
                          _topButton("Today Events", _selectedToday, () {
                            setState(() {
                              if (_selectedToday) {
                                _selectedToday = false;
                                _showTodayEvents = false;
                              } else {
                                _selectedToday = true;
                                _selectedFuture = false;
                                _selectedTime = false;

                                _showTodayEvents = true;
                                _showFutureEvents = false;
                                _showTimeTable = false;
                              }
                            });
                          }),

                          const SizedBox(width: 10),

                          /// ✅ FUTURE
                          _topButton("Future Events", _selectedFuture, () {
                            setState(() {
                              if (_selectedFuture) {
                                _selectedFuture = false;
                                _showFutureEvents = false;
                              } else {
                                _selectedFuture = true;
                                _selectedToday = false;
                                _selectedTime = false;

                                _showFutureEvents = true;
                                _showTodayEvents = false;
                                _showTimeTable = false;
                              }
                            });
                          }),

                          const SizedBox(width: 10),

                          /// ✅ TIME TABLE
                          _topButton("Time Table", _selectedTime, () {
                            setState(() {
                              if (_selectedTime) {
                                _selectedTime = false;
                                _showTimeTable = false;
                              } else {
                                _selectedTime = true;
                                _selectedToday = false;
                                _selectedFuture = false;

                                _showTimeTable = true;
                                _showTodayEvents = false;
                                _showFutureEvents = false;
                              }
                            });
                          }),

                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  if (_showTodayEvents)
                    _eventsListSection(
                      title: "Today's Events",
                      stream: streamTodayEvents(),
                    ),

                  if (_showFutureEvents)
                    _eventsListSection(
                      title: "Upcoming Events",
                      stream: streamFutureEvents(),
                    ),

                  if (_showTimeTable) _timetableSection(),
                ],
              ),
            ),
          ),

          NavigationBar(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// ✅ BUTTON UI
  Widget _topButton(String text, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withOpacity(0.20)
              : Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected
                ? Colors.white.withOpacity(0.50)
                : Colors.white.withOpacity(0.25),
            width: selected ? 1.3 : 1,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// ✅ Timetable Section
  Widget _timetableSection() {
    return _wrapContainer(
      child: Column(
        children: [
          Row(
            children: const [
            Icon(Icons.table_chart, color: Colors.white, size: 26),
              SizedBox(width: 10),
              Text(
                "Time Table",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          timetableUrl == null
              ? Column(
                  children: [
                    const Text("No Time Table Uploaded",
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: uploadTimetable,
                      child: const Text("Upload Timetable"),
                    ),
                  ],
                )
              : Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        timetableUrl!,
                        height: 300,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: uploadTimetable,
                      child: const Text("Replace Timetable"),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  /// ✅ EVENTS LIST
  Widget _eventsListSection({
    required String title,
    required Stream<List<Map<String, dynamic>>> stream,
  }) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final events = snap.data!;

        return _wrapContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.event, color: Colors.white, size: 22),
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: events.length,
                itemBuilder: (_, i) {
                  final e = events[i];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.schedule,
                            color: Colors.white.withOpacity(0.9)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e["title"],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${e['time']} • ${e['date'].day}/${e['date'].month}/${e['date'].year}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.7),
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
      },
    );
  }

  /// ✅ Container Styling
  Widget _wrapContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: child,
    );
  }
}