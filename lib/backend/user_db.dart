import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flame/game.dart';
import 'package:gdg_hack/backend/hachathon_db.dart';
import 'package:gdg_hack/models/Hackathon.dart';
import 'package:gdg_hack/models/userModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class UserDb {
  Future<UserModel> createUser();
  Future<UserModel?> getUser(String userId);
  Future<Hackathon?> inHackathon(String userId);
  Future<bool> assignHackathon(String id);
  Future<Vector2?> moveUser(Vector2 pos);
}

class userDb_impl implements UserDb {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'hackathons';
  final HackathonDb _hackathonDb = FirestoreHackathonDb();

  @override
  Future<UserModel?> getUser(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        bool isCompany = userData['isCompany'] ?? false;

        if (isCompany) {
          // Return a simplified UserModel for companies
          return UserModel(
              id: userId,
              name: userData['name'],
              role: "null",
              isCompany: isCompany,
              hackathonId: null);
        } else {
          // Return a normal user model
          return UserModel.fromMap(userId, userData);
        }
      } else {
        return null; // User not found
      }
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }

  @override
  Future<bool> assignHackathon(String hackathonId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId =
          prefs.getString("uid"); // Get user ID from SharedPreferences

      if (userId == null) {
        print("User ID not found. Cannot assign hackathon.");
        return false; // Or handle this case as needed
      }

      await _firestore.collection('users').doc(userId).update({
        'hackathon_id': hackathonId,
      });
      print(
          "Hackathon assigned successfully for user: $userId, hackathonId: $hackathonId");
      return true;
    } catch (e) {
      print("Error assigning hackathon to user: $e");
      return false;
    }
  }

  @override
  Future<UserModel> createUser() {
    // TODO: implement createUser
    throw UnimplementedError();
  }

  @override
  Future<Hackathon?> inHackathon(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        var hackathonId = userDoc['hackathon_id'];
        Hackathon? hackathon = await _hackathonDb.getHackathon(hackathonId);
        return hackathon;
      } else {
        return null;
      }
    } catch (e) {
      print("Error checking hackathon status: $e");
      return null;
    }
  }

  @override
  Future<Vector2?> moveUser(Vector2 pos) {
    // TODO: implement moveUser
    throw UnimplementedError();
  }
}
