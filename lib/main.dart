import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gdg_hack/backend/hachathon_db.dart';
import 'package:gdg_hack/backend/user_db.dart';
import 'package:gdg_hack/companies/addHackathon.dart';
import 'package:gdg_hack/hackathonList.dart';
import 'package:gdg_hack/models/Hackathon.dart';
import 'package:gdg_hack/models/userModel.dart';
import 'package:gdg_hack/playGround.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final HackathonDb _hackathonDb = FirestoreHackathonDb();
  final UserDb _userDb = userDb_impl();

  UserModel? user;
  Hackathon? _userHackathon;
  bool _isLoading = true;

  String user_id = "nigG4lyZJrXXRgW6CTzn";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      user = await _userDb.getUser(user_id);

      if (user != null && user!.hackathonId != null) {
        _userHackathon = await _hackathonDb.getHackathon(user!.hackathonId!);
      }
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildHomeScreen(),
      ),
    );
  }

  Widget _buildHomeScreen() {
    if (user == null) {
      return const Center(child: Text("No user found"));
    }

    if (user!.isCompany) {
      return AddHackathon();
    }

    return _userHackathon != null
        ? HackathonListPage()
        : const Center(child: Text("No hackathon available"));
  }
}
