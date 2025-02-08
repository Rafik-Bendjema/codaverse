import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gdg_hack/models/userModel.dart';

import '../models/Hackathon.dart';

abstract class HackathonDb {
  Future<Hackathon?> getHackathon(String hackathonId);
  Future<bool> addHackathon(Hackathon hackathon);
  Future<bool> startHackathon(String hackathonId);
  Future<Hackathon?> getHackathonForUser(String userId);
  Future<List<Hackathon>> getHackathonsByCompany(String companyId);
  Future<void> updateHackathonState(String hackathonId, String newState);
}

class FirestoreHackathonDb implements HackathonDb {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'hackathons';

  @override
  Future<List<UserModel>> getUsersByType(String userType) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .where('type', isEqualTo: userType)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print("Error fetching users by type: $e");
      return []; // Or handle error appropriately
    }
  }

  @override
  Future<List<Hackathon>> getHackathonsByCompany(String companyId) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('hackathons')
          .where('company_id', isEqualTo: companyId)
          .get();

      List<Hackathon> hackathons = await Future.wait(
        querySnapshot.docs.map((doc) async {
          return Hackathon.fromMap(doc.id, doc.data());
        }),
      );

      return hackathons;
    } catch (e) {
      print("Error fetching hackathons: $e");
      return [];
    }
  }

  @override
  Future<Hackathon?> getHackathon(String hackathonId) async {
    try {
      print("i am here and here is the hackathon id $hackathonId");
      DocumentSnapshot doc =
          await _firestore.collection(_collectionPath).doc(hackathonId).get();
      if (doc.exists) {
        print("doc exist");
        return Hackathon.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Error getting hackathon: $e");
      return null;
    }
  }

  @override
  Future<void> updateHackathonState(String hackathonId, String newState) async {
    try {
      await _firestore.collection('hackathons').doc(hackathonId).update({
        'state': newState,
      });
    } catch (e) {
      print("Error updating hackathon state: $e");
      rethrow;
    }
  }

  @override
  Future<bool> addHackathon(Hackathon hackathon) async {
    try {
      await _firestore
          .collection(_collectionPath)
          .doc(hackathon.id)
          .set(hackathon.toMap());
      return true;
    } catch (e) {
      print("Error adding hackathon: $e");
      return false;
    }
  }

  @override
  Future<bool> startHackathon(String hackathonId) async {
    try {
      print("i am chaning the hackathon with id $hackathonId");
      await _firestore
          .collection(_collectionPath)
          .doc(hackathonId)
          .update({'status': 'running'});
      return true;
    } catch (e) {
      print("Error starting hackathon: $e");
      return false;
    }
  }

  @override
  Future<Hackathon?> getHackathonForUser(String userId) async {
    try {
      // Fetch all hackathons
      QuerySnapshot hackathonsSnapshot =
          await _firestore.collection(_collectionPath).get();

      for (var hackathonDoc in hackathonsSnapshot.docs) {
        // Fetch teams subcollection
        QuerySnapshot teamsSnapshot =
            await hackathonDoc.reference.collection('teams').get();

        for (var teamDoc in teamsSnapshot.docs) {
          List<dynamic> members = teamDoc['members'] ?? [];

          if (members.contains(userId)) {
            return Hackathon.fromMap(
                hackathonDoc.id, hackathonDoc.data() as Map<String, dynamic>);
          }
        }
      }

      return null; // No hackathon found for this user
    } catch (e) {
      print("Error finding user's hackathon: $e");
      return null;
    }
  }
}
