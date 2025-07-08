import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dream_seeker/screens/roleSelectionPage.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class Onboardingpage extends StatefulWidget {
  const Onboardingpage({super.key});

  @override
  State<Onboardingpage> createState() => _OnboardingpageState();
}

class _OnboardingpageState extends State<Onboardingpage> {
  // Introduction screen pages
  List<PageViewModel> get introPages => [
    PageViewModel(
      titleWidget: Column(
        children: [
          AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                'Welcome From Dream Seeker',
                textStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                speed: Duration(milliseconds: 100),
              ),
            ],
            totalRepeatCount: 1,
            pause: Duration(milliseconds: 1000),
            displayFullTextOnTap: true,
          ),
        ],
      ),

      bodyWidget: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          children: [
            Text(
              "There are many jobs available in the world, and you can find them all here!",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
          ],
        ),
      ),
      image: Center(child: Image.asset("assets/on1.png")),
    ),
    PageViewModel(
      titleWidget: Column(
        children: [
          AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                'Find Your Dream Job',
                textStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                speed: Duration(milliseconds: 100),
              ),
            ],
            totalRepeatCount: 1,
            pause: Duration(milliseconds: 1000),
            displayFullTextOnTap: true,
          ),
        ],
      ),

      bodyWidget: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          children: [
            Text(
              "Search and apply for jobs that match your skills and interests. Your perfect career is waiting!",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      image: Center(child: Image.asset("assets/on2.png")),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: IntroductionScreen(
        pages: introPages,
        onDone: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
          );
        },

        next: const Icon(Icons.arrow_forward, color: Colors.black),
        done: const Text(
          "Done",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ),
    );
  }
}
