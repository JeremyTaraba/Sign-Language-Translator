import 'package:flutter/material.dart';
import 'package:sign_language_trasnlator2/pages/camera2/camera2_page.dart';
import 'package:sign_language_trasnlator2/pages/history/history_page.dart';
import 'package:sign_language_trasnlator2/pages/settings/settings_page.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({required this.selectedIndex});
  final int selectedIndex;

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  void onItemTap(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HistoryPage()));
    }
    if (index == 1) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Camera2Page()));
    }
    if (index == 2) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SettingsPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.deepOrangeAccent,
      currentIndex: widget.selectedIndex,
      onTap: onItemTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt_outlined),
          label: 'Camera',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
