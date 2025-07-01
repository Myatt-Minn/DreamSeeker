import 'package:dream_seeker/screens/navigationPage.dart';
import 'package:dream_seeker/screens/onBoardingPage.dart';
import 'package:dream_seeker/screens/recruiterNavigation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  bool _loading = true;
  String? _role;

  @override
  void initState() {
    super.initState();
    Supabase.instance.client.auth.signOut();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        _loading = false;
        _role = null;
      });
      return;
    }
    final response = await Supabase.instance.client
        .from('users')
        .select('role')
        .eq('user_id', user.id)
        .single();

    setState(() {
      _role = response != null ? response['role'] as String? : null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasUser = Supabase.instance.client.auth.currentUser != null;

    if (_loading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Dream Seeker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: hasUser
          ? (_role == 'seeker'
                ? const Navigationpage()
                : const Recruiternavigation())
          : const Onboardingpage(),
    );
  }
}
