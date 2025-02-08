import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/userModel.dart';

/// Abstract authentication service
abstract class BaseAuthService {
  Future<String?> signUp(String name, String email, String password,
      String role, bool isCompany, String? hackathonId);
  Future<String?> login(String email, String password);
  Future<void> logout();
  Future<UserModel?> getUserData();
}

/// Implementation of the authentication service
class AuthService implements BaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();

  /// Saves user data in SharedPreferences
  Future<void> _saveUserToLocal(UserModel user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("uid", user.id ?? "");
    await prefs.setString("name", user.name);
    await prefs.setString("role", user.role);
    await prefs.setBool("isCompany", user.isCompany);
    if (user.hackathonId != null) {
      await prefs.setString("hackathon_id", user.hackathonId!);
    }
  }

  /// Retrieves user data from SharedPreferences
  @override
  Future<UserModel?> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString("uid");
    String? name = prefs.getString("name");
    String? role = prefs.getString("role");
    bool? isCompany = prefs.getBool("isCompany");
    String? hackathonId = prefs.getString("hackathon_id");

    if (uid != null && name != null && role != null && isCompany != null) {
      return UserModel(
        id: uid,
        name: name,
        role: role,
        isCompany: isCompany,
        hackathonId: hackathonId,
      );
    }
    return null;
  }

  @override
  Future<String?> signUp(String name, String email, String password,
      String role, bool isCompany, String? hackathonId) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create UserModel instance
      UserModel user = UserModel(
        id: userCredential.user!.uid,
        name: name,
        role: role,
        isCompany: isCompany,
        hackathonId: hackathonId,
      );

      // Save user to Firestore
      await _firestore.collection("users").doc(user.id).set(user.toMap());

      // Save user data locally
      await _saveUserToLocal(user);

      return null; // Success
    } catch (e) {
      return e.toString(); // Return error message
    }
  }

  @override
  Future<String?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // Retrieve user data from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection("users")
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        UserModel user = UserModel.fromMap(
            userCredential.user!.uid, userDoc.data() as Map<String, dynamic>);

        // Save user data locally
        await _saveUserToLocal(user);
      }

      return null; // Success
    } catch (e) {
      return e.toString(); // Return error
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear saved user data
  }
}
