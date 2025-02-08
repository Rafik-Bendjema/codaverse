import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gdg_hack/auth/signIn.dart';
import 'package:gdg_hack/backend/hachathon_db.dart';
import 'package:gdg_hack/backend/user_db.dart';
import 'package:gdg_hack/companies/addHackathon.dart';
import 'package:gdg_hack/hackathonList.dart';
import 'package:gdg_hack/models/Hackathon.dart';
import 'package:gdg_hack/models/userModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const AuthHandler());
}

class AuthHandler extends StatelessWidget {
  const AuthHandler({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const MyApp(); // ✅ Logged in, go to app
        } else {
          return const MaterialApp(
            home: LoginPage(), // ❌ Not logged in, show sign-in page
          );
        }
      },
    );
  }
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

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('uid');
    print("connected user is $userId");

    if (userId == null) {
      final User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        userId = firebaseUser.uid;
        await prefs.setString('uid', userId);
      } else {
        setState(() => _isLoading = false);
        return;
      }
    }

    try {
      user = await _userDb.getUser(userId);
      print("here is the user class $user");
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

    return HackathonListPage();
  }
}
