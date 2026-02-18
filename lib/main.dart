import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'schedule.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const SymposiumApp());
}

class SymposiumApp extends StatelessWidget {
  const SymposiumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Symposium App',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF4F4F7),
        primarySwatch: Colors.blue,
      ),
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
  int _selectedIndex = 0;

  final List<Widget> _pages = [const HomeView(), const InfoView()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNav(),
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
      onTap: () => _onItemTapped(index),
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

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  Future<void> _launchRegistration() async {
    // TODO: Replace this with the actual registration URL
    final Uri url = Uri.parse(
      'https://www.csus.edu/college/arts-letters/history/shattuck-endowment/programs.html',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SharedHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 120.0),
            children: [
              _buildIntroduction(),
              const SizedBox(height: 24),
              _buildActionCard(
                context,
                title: "Schedule",
                subtitle: "View",
                iconIOS: CupertinoIcons.calendar,
                iconAndroid: Icons.calendar_month,
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
                context,
                title: "Register Here",
                subtitle: "Go",
                iconIOS:
                    CupertinoIcons.arrow_up_right_circle, // Ticket icon for iOS
                iconAndroid: Icons.arrow_outward, // Ticket icon for Android
                onTap: _launchRegistration,
              ),
            ],
          ),
        ),
      ],
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
            "A bi-annual forum for scholars who explore the colonial and revolutionary history of America. The symposium features prominent scholars in early American history as keynote speakers.",
            style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required IconData iconIOS, // Now required
    required IconData iconAndroid, // Now required
  }) {
    final bool isIOS = Platform.isIOS;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          // Optional: Add a subtle shadow for depth
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            // Use the passed icons
            Icon(
              isIOS ? iconIOS : iconAndroid,
              color: Colors.blueAccent,
              size: 22,
            ),
            const SizedBox(width: 8),
            Icon(
              isIOS ? CupertinoIcons.chevron_right : Icons.chevron_right,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class InfoView extends StatelessWidget {
  const InfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SharedHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24.0, 40.0, 24.0, 120.0),
            child: Column(
              children: [
                Image.asset(
                  'assets/img/shattuck_logo_inspyrenet.png',
                  height: 280,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 40),
                const Text(
                  "About the Endowment",
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF043927), // Hornet Green
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    "The Shattuck Endowment honors the memory and legacy of Professor Peter H. Shattuck. Dr. Shattuck had a long and distinguished career in the History Department at Sacramento State. Started in September 2016 with a gift from Elizabeth H. Shattuck, the Shattuck Endowment is a foundation for the promotion of colonial American studies at Sac State. The Peter H. Shattuck Endowment supports the bi-annual Colonial American History Symposium.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  "Team",
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF043927), // Hornet Green
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    "The Shattuck Symposium App was developed in 2026 for the Shattuck Symposium held at CSU, Sacramento in honor of America's 250th Anniversary. The application was developed under guidance from the Shattuck Endowed Chair in Colonial History, Dr. Antonio T. Bly (antonio.bly@csus.edu). Akal Ustat Singh (CSUS Computer Science C/O 2026) developed this application (akalustat.singh@gmail.com).",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SharedHeader extends StatelessWidget {
  const SharedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF043927), // Hornet Green
      padding: const EdgeInsets.only(bottom: 24),
      child: SafeArea(
        bottom: false,
        child: Column(
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
      ),
    );
  }
}
