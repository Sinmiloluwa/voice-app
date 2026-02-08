import 'package:flutter/material.dart';
import 'package:voiceapp/assets/constants.dart';
import 'package:voiceapp/screens/discover_screen.dart';
import 'package:voiceapp/screens/home_screen.dart';
import 'package:voiceapp/screens/notification_screen.dart';
import 'package:voiceapp/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedTabIndex = 0;
  int _selectedNavIndex = 0;

   final List<Widget> _screens = const [
    HomeScreen(),
    DiscoverScreen(),
    NotificationScreen(),
    ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedNavIndex,
        children: _screens,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Constants.primaryColor,
        onPressed: () {
          Navigator.pushNamed(context, '/view');
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Constants.primaryColor,
            boxShadow: [
              BoxShadow(
                color: Constants.primaryColor.withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.mic, color: Colors.black, size: 24),
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: _selectedNavIndex,
        onNavSelected: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onNavSelected;

  const _BottomNavBar({
    required this.selectedIndex,
    required this.onNavSelected,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
      {'icon': Icons.home, 'label': 'Home'},
      {'icon': Icons.explore, 'label': 'Explore'},
      {'icon': Icons.notifications, 'label': 'Alerts'},
      {'icon': Icons.person, 'label': 'Profile'},
    ];

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          navItems.length,
          (index) => GestureDetector(
            onTap: () => onNavSelected(index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  navItems[index]['icon'] as IconData,
                  color: selectedIndex == index
                      ? HomeScreen.primaryColor
                      : Colors.white30,
                ),
                const SizedBox(height: 4),
                Text(
                  navItems[index]['label'] as String,
                  style: TextStyle(
                    color: selectedIndex == index
                        ? HomeScreen.primaryColor
                        : Colors.white30,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}