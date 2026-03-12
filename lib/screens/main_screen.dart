import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voiceapp/assets/constants.dart';
import 'package:voiceapp/providers/deep_link_provider.dart';
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

late final List<Widget> _screens;

@override
void initState() {
  super.initState();

  _screens = [
    HomeScreen(
      onProfileTap: () {
        setState(() {
          _selectedNavIndex = 3;
        });
      },
    ),
    const DiscoverScreen(),
    const NotificationScreen(),
    ProfileScreen(
      onBack: () => setState(() => _selectedNavIndex = 0),
    ),
  ];
}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final deepLink = context.watch<DeepLinkProvider>().pending;
    if (deepLink != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleDeepLink(deepLink);
        context.read<DeepLinkProvider>().consume();
      });
    }
  }

  void _handleDeepLink(DeepLinkData link) {
    if (link.destination == DeepLinkDestination.profile) {
      setState(() => _selectedNavIndex = 3);
    } else if (link.destination == DeepLinkDestination.post) {
      setState(() => _selectedNavIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedNavIndex, children: _screens),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        elevation: 6,
        backgroundColor: Constants.primaryColor,
        onPressed: () {
          Navigator.pushNamed(context, '/view');
        },
        child: const Icon(Icons.mic, color: Colors.black, size: 26),
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

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      color: Colors.black.withValues(alpha: 0.9),
      child: SizedBox(
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(0, navItems[0]),
            _navItem(1, navItems[1]),

            const SizedBox(width: 56),

            _navItem(2, navItems[2]),
            _navItem(3, navItems[3]),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, Map item) {
    return GestureDetector(
      onTap: () => onNavSelected(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            item['icon'],
            color: selectedIndex == index
                ? Constants.primaryColor
                : Colors.white30,
            size: 34,
          ),
          const SizedBox(height: 4),
          Text(
            item['label'],
            style: TextStyle(
              color: selectedIndex == index
                  ? Constants.primaryColor
                  : Colors.white30,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
