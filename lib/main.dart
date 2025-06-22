import 'package:dream_seeker/screens/navigationPage.dart';
import 'package:dream_seeker/screens/onBoardingPage.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://dfgygocadfyvbbjzsoqw.supabase.co",
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRmZ3lnb2NhZGZ5dmJianpzb3F3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA1NjExODAsImV4cCI6MjA2NjEzNzE4MH0.NSN8aufhNdegi1MjFviKTOcpwfenWvqi-ESjH3pmQUI',
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final hasUser = Supabase.instance.client.auth.currentUser != null;

    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: hasUser ? const Navigationpage() : const Onboardingpage(),
    );
  }
}
