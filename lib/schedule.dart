import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// --- Data Model ---
class SymposiumEvent {
  final String title;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final String shortDescription;
  final String? longDescription;

  SymposiumEvent({
    required this.title,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.shortDescription,
    this.longDescription,
  });

  bool get isLive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }
}

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  static const Color hornetGreen = Color(0xFF043927);
  static const Color hornetGold = Color(0xFFC4B581);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  Timer? _liveTimer;

  late final List<SymposiumEvent> _allEvents;

  @override
  void initState() {
    super.initState();

    final today = DateTime.now();
    _allEvents = [
      SymposiumEvent(
        title: "Registration | Welcome",
        location: "Foothill Suite",
        startTime: DateTime(today.year, today.month, today.day, 8, 0),
        endTime: DateTime(today.year, today.month, today.day, 10, 0),
        shortDescription:
            "Greeting - Dr. Sheree L. Meyer, Dean of the College of Arts and Letters.",
      ),
      SymposiumEvent(
        title: "Shifting American Landscapes",
        location: "Pacific I Room",
        startTime: DateTime(today.year, today.month, today.day, 10, 0),
        endTime: DateTime(today.year, today.month, today.day, 14, 0),
        shortDescription:
            "Chair: Dr. Khal Schneider. Panel discussion on territorial shifts.",
        longDescription:
            "This interactive session will delve deep into the geographical and political shifting of boundaries during the early colonial period. Scholars will present primary source maps and lead a multidisciplinary discussion on how engaging with historical topography redefines our understanding of early settlements.",
      ),
      SymposiumEvent(
        title: "Keynote: Minutemen Revisited",
        location: "Main Hall",
        startTime: DateTime(today.year, today.month, today.day + 1, 9, 0),
        endTime: DateTime(today.year, today.month, today.day + 1, 10, 30),
        shortDescription:
            "Dr. Robert A. Gross, Draper Professor of Early American History.",
        longDescription:
            "A comprehensive re-evaluation of the social dynamics surrounding the colonial militias.",
      ),
    ];

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });

    _liveTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _liveTimer?.cancel();
    super.dispose();
  }

  List<SymposiumEvent> _getFilteredEventsForDay(int dayOffset) {
    final targetDate = DateTime.now().add(Duration(days: dayOffset));

    return _allEvents.where((event) {
      final isSameDay =
          event.startTime.year == targetDate.year &&
          event.startTime.month == targetDate.month &&
          event.startTime.day == targetDate.day;
      if (!isSameDay) return false;

      if (_searchQuery.isEmpty) return true;
      return event.title.toLowerCase().contains(_searchQuery) ||
          event.location.toLowerCase().contains(_searchQuery) ||
          event.shortDescription.toLowerCase().contains(_searchQuery) ||
          (event.longDescription?.toLowerCase().contains(_searchQuery) ??
              false);
    }).toList();
  }

  String _formatTime(DateTime time) {
    int hour = time.hour > 12 ? time.hour - 12 : time.hour;
    if (hour == 0) hour = 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? "PM" : "AM";
    return "$hour:$minute$period";
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F7),
        body: Column(
          children: [
            _buildHeader(context),
            Container(
              color: hornetGreen,
              child: const TabBar(
                indicatorColor: hornetGold,
                labelColor: hornetGold,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(text: "Day 1"),
                  Tab(text: "Day 2"),
                  Tab(text: "Day 3"),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: "Search events, locations, or speakers...",
                    prefixIcon: Icon(CupertinoIcons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildEventList(_getFilteredEventsForDay(0)),
                  _buildEventList(_getFilteredEventsForDay(1)),
                  _buildEventList(_getFilteredEventsForDay(2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: hornetGreen,
      padding: const EdgeInsets.only(bottom: 16),
      child: SafeArea(
        bottom: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 8,
              top: 0,
              child: IconButton(
                icon: const Icon(
                  CupertinoIcons.back,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: const [
                    Text(
                      "The ",
                      style: TextStyle(
                        fontFamily: 'LuxuriousScript',
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      "SHATTUCK",
                      style: TextStyle(
                        fontFamily: 'Cinzel',
                        color: hornetGold,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  "SYMPOSIUM",
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    color: hornetGold,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList(List<SymposiumEvent> events) {
    if (events.isEmpty) {
      return const Center(
        child: Text(
          "No events found.",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return EventCard(
          event: events[index],
          timeString:
              "${_formatTime(events[index].startTime)} - ${_formatTime(events[index].endTime)}",
        );
      },
    );
  }
}

// --- Expandable Event Card ---
class EventCard extends StatefulWidget {
  final SymposiumEvent event;
  final String timeString;

  const EventCard({super.key, required this.event, required this.timeString});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final bool isLive = widget.event.isLive;

    return GestureDetector(
      onTap: () {
        if (widget.event.longDescription != null) {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isLive
              ? Border.all(color: const Color(0xFFC4B581), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.event.location,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.event.title,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.timeString,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLive) ...[
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        "Live",
                        style: TextStyle(
                          color: Color(0xFFC4B581),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.event.shortDescription,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: SizedBox(
                width: double.infinity,
                child: _isExpanded && widget.event.longDescription != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          widget.event.longDescription!,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            if (widget.event.longDescription != null) ...[
              const SizedBox(height: 12),
              Center(
                child: Icon(
                  _isExpanded
                      ? CupertinoIcons.chevron_up
                      : CupertinoIcons.chevron_down,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
