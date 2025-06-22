import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dream_seeker/screens/jobSeekerFormPage.dart';
import 'package:dream_seeker/screens/navigationPage.dart';
import 'package:dream_seeker/screens/recruiterFormPage.dart';
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
                'Achieve Your Dream by Selecting Your Role',
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choose Your Role',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            _buildRoleCard(
              context,
              title: 'Job Seeker',
              icon: Icons.person,
              description: 'Find your next career opportunity.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const JobSeekerFormPage(),
                ),
              ),
              color: Colors.indigo[100]!,
            ),
            const SizedBox(height: 24),
            _buildRoleCard(
              context,
              title: 'Job Recruiter',
              icon: Icons.business_center,
              description: 'Post jobs and find candidates.',
              onTap: () {},
              // onTap: () => Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const CompanyFormPage(),
              //   ),
              // ),
              color: Colors.green[100]!,
            ),
          ],
        ),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: IntroductionScreen(
        pages: introPages,
        onDone: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Choose your role to continue!')),
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

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String description,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Icon(icon, size: 30, color: Colors.black),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
