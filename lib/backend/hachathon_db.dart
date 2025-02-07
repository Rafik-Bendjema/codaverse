import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/Hackathon.dart';

abstract class HackathonDb {
  Future<Hackathon?> getHackathon(String hackathonId);
  Future<bool> addHackathon(Hackathon hackathon);
  Future<bool> startHackathon(String hackathonId);
  Future<Hackathon?> getHackathonForUser(String userId);
}

class FirestoreHackathonDb implements HackathonDb {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'hackathons';

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
      await _firestore
          .collection(_collectionPath)
          .doc(hackathonId)
          .update({'status': 'started'});
      return true;
    } catch (e) {
      print("Error starting hackathon: $e");
      return false;
    }
  }

  @override
  Future<Hackathon?> getHackathonForUser(String userId) async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection(_collectionPath).get();

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> teams = data['teams'] ?? [];

        for (var team in teams) {
          List<dynamic> members = team['members'] ?? [];
          if (members.any((member) => member['id'] == userId)) {
            return Hackathon.fromMap(doc.id, data);
          }
        }
      }

      return null;
    } catch (e) {
      print("Error finding user's hackathon: $e");
      return null;
    }
  }
}
