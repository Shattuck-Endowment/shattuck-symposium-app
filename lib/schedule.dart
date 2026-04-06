import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'map.dart';

class EventAbstract {
  final String title;
  final String content;

  EventAbstract({required this.title, required this.content});

  factory EventAbstract.fromJson(Map<String, dynamic> json) {
    return EventAbstract(
      // Mapping explicitly to the capitalization you specified
      title: json['title']?.toString().trim() ?? 'Untitled',
      content: json['abstract']?.toString().trim() ?? 'No content provided.',
    );
  }
}

class SymposiumEvent {
  final String title;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final String? shortDescription;
  final String? longDescription;
  final String? session;
  final String? isSpecial;
  final List<EventAbstract>? abstracts;

  SymposiumEvent({
    required this.title,
    required this.location,
    required this.startTime,
    required this.endTime,
    this.shortDescription,
    this.longDescription,
    this.session,
    this.isSpecial,
    this.abstracts,
  });

  factory SymposiumEvent.fromJson(Map<String, dynamic> json) {
    List<EventAbstract>? parsedAbstracts;
    if (json['abstracts'] != null && json['abstracts'] is List) {
      parsedAbstracts = (json['abstracts'] as List)
          .map((e) => EventAbstract.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return SymposiumEvent(
      title: json['title']?.toString().trim() ?? 'Untitled Event',
      location: json['location']?.toString().trim() ?? 'Location TBD',
      startTime: DateTime.parse(json['startTime'].toString().trim()),
      endTime: DateTime.parse(json['endTime'].toString().trim()),
      shortDescription: json['shortDescription']?.toString().trim(),
      longDescription: json['longDescription']?.toString().trim(),
      session: json['session']?.toString().trim(),
      isSpecial: json['isSpecial']?.toString().trim(),
      abstracts: parsedAbstracts,
    );
  }

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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "BECOMING AMERICANS",
                        style: GoogleFonts.cinzel(
                          color: Color(0xFFC4B581),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "The Shattuck Colonial American History Symposium",
                    style: GoogleFonts.notoSerif(
                      fontSize: 12,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "March 18-20, 2026",
                    style: GoogleFonts.notoSerif(
                      fontSize: 12,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
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

  void _showAbstractsDialog(BuildContext context) {
    if (widget.event.abstracts == null || widget.event.abstracts!.isEmpty)
      return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AbstractsDialog(abstracts: widget.event.abstracts!);
      },
    );
  }

  void _presentSpatialMap(BuildContext context, String locationString) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      showDragHandle: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24.0),
            ),
            // Ensure map.dart exports DynamicMapViewer so this resolves correctly
            child: DynamicMapViewer(eventLocation: locationString),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLive = widget.event.isLive;
    final String? specialType = widget.event.isSpecial;
    final bool hasSpecialBadge = specialType == '250' || specialType == 'women';
    final bool hasAbstracts =
        widget.event.abstracts != null && widget.event.abstracts!.isNotEmpty;

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
        decoration: (hasSpecialBadge && !isLive)
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: specialType == '250'
                    ? const LinearGradient(
                        colors: [
                          Colors.redAccent,
                          Colors.white,
                          Colors.blueAccent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF6A1B9A), Color(0xFFF3E5F5)],
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
        padding: (hasSpecialBadge && !isLive)
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
            boxShadow: (!hasSpecialBadge && !isLive)
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
                        if (widget.event.session != null) ...[
                          Text(
                            widget.event.session!.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF043927),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],

                        // --- NEW INTERACTIVE LOCATION ROW ---
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _presentSpatialMap(
                              context,
                              widget.event.location,
                            ),
                            borderRadius: BorderRadius.circular(6.0),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    CupertinoIcons.map_pin_ellipse,
                                    size: 16,
                                    color: Color(0xFF043927),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      widget.event.location,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF043927),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    CupertinoIcons.chevron_right,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // --- END INTERACTIVE LOCATION ROW ---
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
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (specialType == '250') _buildAmerica250Badge(),
                      if (specialType == 'women') _buildWomensHistoryBadge(),
                      if (hasSpecialBadge && isLive) const SizedBox(height: 8),
                      if (isLive) _buildLiveBadge(),
                      if (hasAbstracts) ...[
                        const SizedBox(height: 8),
                        IconButton(
                          icon: const Icon(
                            CupertinoIcons.info_circle,
                            color: Color(0xFF043927),
                          ),
                          onPressed: () => _showAbstractsDialog(context),
                          tooltip: 'View Abstracts',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ],
                  ),
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

  Widget _buildAmerica250Badge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0A3161), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text("🇺🇸", style: TextStyle(fontSize: 14)),
          SizedBox(width: 4),
          Text(
            "America 250",
            style: TextStyle(
              color: Color(0xFF0A3161),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWomensHistoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5), // Soft purple background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6A1B9A), // Deep purple border
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.female, size: 14, color: Color(0xFF6A1B9A)),
          SizedBox(width: 4),
          Text(
            "Women's History",
            style: TextStyle(
              color: Color(0xFF6A1B9A),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
    );
  }
}

class AbstractsDialog extends StatefulWidget {
  final List<EventAbstract> abstracts;

  const AbstractsDialog({super.key, required this.abstracts});

  @override
  State<AbstractsDialog> createState() => _AbstractsDialogState();
}

class _AbstractsDialogState extends State<AbstractsDialog> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < widget.abstracts.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // Rigorously enforce a white background, overriding global theme inheritance
      backgroundColor: Colors.white,
      // Disable Material 3's dynamic elevation color blending
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Session Abstracts",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF043927),
                  ),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.clear_circled),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Divider(height: 24),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.abstracts.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = widget.abstracts[index];
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.content,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (widget.abstracts.length > 1) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(CupertinoIcons.left_chevron),
                    onPressed: _currentIndex > 0 ? _previousPage : null,
                    color: _currentIndex > 0
                        ? const Color(0xFF043927)
                        : Colors.grey.shade300,
                  ),
                  Text(
                    "${_currentIndex + 1} of ${widget.abstracts.length}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.right_chevron),
                    onPressed: _currentIndex < widget.abstracts.length - 1
                        ? _nextPage
                        : null,
                    color: _currentIndex < widget.abstracts.length - 1
                        ? const Color(0xFF043927)
                        : Colors.grey.shade300,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
