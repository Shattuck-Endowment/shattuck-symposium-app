import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SymposiumEvent {
  final String title;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final String? shortDescription;
  final String? longDescription;
  final bool isSpecial;

  SymposiumEvent({
    required this.title,
    required this.location,
    required this.startTime,
    required this.endTime,
    this.shortDescription,
    this.longDescription,
    this.isSpecial = false,
  });

  factory SymposiumEvent.fromJson(Map<String, dynamic> json) {
    return SymposiumEvent(
      title: json['title'] as String,
      location: json['location'] as String,

      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      shortDescription: json['shortDescription'] as String?,
      longDescription: json['longDescription'] as String?,
      isSpecial: json['isSpecial'] as bool? ?? false,
    );
  }

  // Returns true if current time is within the event window
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

  List<SymposiumEvent> _allEvents = [];
  List<DateTime> _eventDates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });

    _liveTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _liveTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    try {
      final String response = await rootBundle.loadString('assets/events.json');
      final List<dynamic> data = jsonDecode(response);

      final List<SymposiumEvent> loadedEvents = data
          .map((json) => SymposiumEvent.fromJson(json))
          .toList();
      final Set<String> uniqueDateStrings = {};
      final List<DateTime> dates = [];

      loadedEvents.sort((a, b) => a.startTime.compareTo(b.startTime));

      for (var event in loadedEvents) {
        String dateKey =
            "${event.startTime.year}-${event.startTime.month}-${event.startTime.day}";
        if (!uniqueDateStrings.contains(dateKey)) {
          uniqueDateStrings.add(dateKey);
          dates.add(
            DateTime(
              event.startTime.year,
              event.startTime.month,
              event.startTime.day,
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _allEvents = loadedEvents;
          _eventDates = dates;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading events: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<SymposiumEvent> _getFilteredEventsForTab(int tabIndex) {
    if (tabIndex >= _eventDates.length) return [];

    final targetDate = _eventDates[tabIndex];

    return _allEvents.where((event) {
      final isSameDay =
          event.startTime.year == targetDate.year &&
          event.startTime.month == targetDate.month &&
          event.startTime.day == targetDate.day;
      if (!isSameDay) return false;
      if (_searchQuery.isEmpty) return true;
      return event.title.toLowerCase().contains(_searchQuery) ||
          event.location.toLowerCase().contains(_searchQuery) ||
          (event.shortDescription?.toLowerCase().contains(_searchQuery) ??
              false) ||
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
    int tabCount = _eventDates.isEmpty ? 3 : _eventDates.length;

    return DefaultTabController(
      length: tabCount,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F7),
        body: Column(
          children: [
            _buildHeader(context),
            Container(
              color: hornetGreen,
              child: TabBar(
                indicatorColor: hornetGold,
                labelColor: hornetGold,
                unselectedLabelColor: Colors.white70,
                tabs: List.generate(
                  tabCount,
                  (index) => Tab(text: "Day ${index + 1}"),
                ),
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
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: hornetGold),
                    )
                  : TabBarView(
                      children: List.generate(tabCount, (index) {
                        return _buildEventList(_getFilteredEventsForTab(index));
                      }),
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
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(
                    CupertinoIcons.back,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: const [
                    Text(
                      "BECOMING AMERICANS",
                      style: TextStyle(
                        fontFamily: 'Cinzel',
                        color: Color(0xFFC4B581),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "The Shattuck American History Symposium",
                  style: TextStyle(
                    // fontFamily: 'LuxuriousScript',
                    color: Colors.white,
                    fontSize: 16,
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
          "No events found for this day.",
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
    final bool isSpecial = widget.event.isSpecial;

    return GestureDetector(
      onTap: () {
        if (widget.event.longDescription != null) {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: (isSpecial && !isLive)
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  colors: [Colors.redAccent, Colors.white, Colors.blueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              )
            : null,
        padding: (isSpecial && !isLive)
            ? const EdgeInsets.all(3.0)
            : EdgeInsets.zero,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: isLive
                ? Border.all(color: const Color(0xFFC4B581), width: 2)
                : null,
            boxShadow: (!isSpecial && !isLive)
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
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
                  // Live Badge
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

              if (widget.event.shortDescription != null) ...[
                const SizedBox(height: 16),
                Text(
                  widget.event.shortDescription!,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],

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
      ),
    );
  }
}
