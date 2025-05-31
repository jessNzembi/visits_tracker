import 'package:flutter/material.dart';
import 'package:visits_tracker/pages/activities/activities.dart';
import 'package:visits_tracker/pages/home/home_page.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedPage = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // extendBody: true,
      body: IndexedStack(
        index: _selectedPage,
        children: [
          HomePage(),
          Activities(),
          Activities(),
          Activities(),
          Activities(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedPage,
        onDestinationSelected: (index) {
          setState(() {
            _selectedPage = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_outlined),
            selectedIcon: Icon(Icons.directions),
            label: "Discover",
          ),
          NavigationDestination(
            icon: Icon(Icons.radio),
            selectedIcon: Icon(Icons.radio),
            label: "Radio",
          ),
          NavigationDestination(
            icon: Icon(Icons.videocam_outlined),
            selectedIcon: Icon(Icons.videocam),
            label: "Videos",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}