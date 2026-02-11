import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shattuck_app/schedule.dart';

void main() {
  runApp(const SymposiumApp());
}

class SymposiumApp extends StatelessWidget {
  const SymposiumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'The Shattuck Symposium',
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFF4F4F7)),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Brand Colors
  static const Color hornetGreen = Color(0xFF043927);
  static const Color hornetGold = Color(0xFFC4B581);

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 120.0),
              children: [
                _buildIntroduction(),
                const SizedBox(height: 24),
                _buildActionCard(
                  title: "Schedule",
                  subtitle: "View Daily Schedule",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SchedulePage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildActionCard(
                  title: "Abstracts",
                  subtitle: "View Presentation Info",
                  onTap: () {
                    // TODO: Navigate to Abstracts
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: hornetGreen,
      padding: const EdgeInsets.only(bottom: 24),
      child: SafeArea(
        bottom: false,
        child: Column(
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
      ),
    );
  }

  Widget _buildIntroduction() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Introduction",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "A bi-annual forum for scholars who explore the colonial and revolutionary history of America. The symposium features prominent scholars in early American history as keynote speakers. The symposium also invites public historians to lead interactive discussions about multi-disciplinary ways of engaging history.",
            style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    // Dynamically checks platform to serve OS-native icons
    final bool isIOS = Platform.isIOS;
    final IconData calendarIcon = isIOS
        ? CupertinoIcons.calendar
        : Icons.calendar_month;
    final IconData chevronIcon = isIOS
        ? CupertinoIcons.chevron_right
        : Icons.chevron_right;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Icon(calendarIcon, color: Colors.blueAccent, size: 22),
            const SizedBox(width: 8),
            Icon(chevronIcon, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 60, right: 60, bottom: 20),
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                iconIOS: CupertinoIcons.home,
                iconAndroid: Icons.home_filled,
                label: "Home",
                index: 0,
              ),
              _buildNavItem(
                iconIOS: CupertinoIcons.info,
                iconAndroid: Icons.info_outline,
                label: "Info",
                index: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData iconIOS,
    required IconData iconAndroid,
    required String label,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;
    final IconData icon = Platform.isIOS ? iconIOS : iconAndroid;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blueAccent : Colors.black54,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blueAccent : Colors.black54,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
