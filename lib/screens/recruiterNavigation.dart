import 'package:dream_seeker/screens/applied_seekers.dart';
import 'package:dream_seeker/screens/recruiterProfilePage.dart';
import 'package:dream_seeker/screens/recruiter_home.dart';
import 'package:flutter/material.dart';

class Recruiternavigation extends StatefulWidget {
  const Recruiternavigation({super.key});

  @override
  State<Recruiternavigation> createState() => _RecruiternavigationState();
}

class _RecruiternavigationState extends State<Recruiternavigation> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const RecruiterHome(),
    const AppliedSeekers(),
    const RecruiterProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.white,
        backgroundColor: Colors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Applied'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _getCurrentPage() {
    // If you want to handle onSearchTap, you can use a switch here
    if (currentIndex == 0) {
      return RecruiterHome();
    }
    return pages[currentIndex];
  }
}
