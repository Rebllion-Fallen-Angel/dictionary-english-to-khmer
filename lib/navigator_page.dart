import 'package:directionay_english_khmer/home.dart';
import 'package:directionay_english_khmer/favorite.dart';
import 'package:directionay_english_khmer/setting.dart';
import 'package:flutter/material.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => NavigationPageState();
}

class NavigationPageState extends State<NavigationPage> {
  int currentIndex = 0;

  final List<Widget> pages = [
    HomeScreen(),
    Favorite(),
    Setting(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home), 
            label: "Home"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: "Favorite",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings), 
            label: "Setting"
          ),
        ],
      ),
    );
  }
}
