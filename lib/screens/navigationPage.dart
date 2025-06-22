import 'package:dream_seeker/screens/homePage.dart';
import 'package:dream_seeker/screens/profilePage.dart';
import 'package:dream_seeker/screens/searchPage.dart';
import 'package:flutter/material.dart';

class Navigationpage extends StatefulWidget {
  const Navigationpage({super.key});

  @override
  State<Navigationpage> createState() => _NavigationpageState();
}

class _NavigationpageState extends State<Navigationpage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          HomePage(
            onSearchTap: () {
              setState(() {
                currentIndex = 1; // Go to search page
              });
            },
          ),
          const JobSearchPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: currentIndex, // Change this index to switch views
        onTap: (index) {
          setState(() {
            // Update the index to switch views
            currentIndex = index;
          });
        },
      ),
    );
  }
}
