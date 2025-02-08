import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gdg_hack/models/Team.dart';
import 'package:gdg_hack/models/userModel.dart';
import 'package:gdg_hack/player.dart';
import 'package:uuid/uuid.dart';

class Hackathon {
  Uuid uuid = Uuid();
  String? id;
  String name;
  List<Team> teams;
  List<UserModel> mentors = []; // Initialize as empty list
  String companyId;
  int maxTeams;
  String status;

  Hackathon({
    this.id,
    required this.name,
    required this.companyId,
    required this.teams,
    required this.mentors,
    required this.maxTeams,
    required this.status,
  }) {
    id ??= uuid.v1(); // Generate id only if it's null
  }

  // Convert Hackathon to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'company_id': companyId,
      'maxTeams': maxTeams,
      'mentors':
          mentors.map((mentor) => mentor.id).toList(), // Store mentor IDs
      'status': status,
    };
  }

  // Create Hackathon from Firestore data (async to fetch teams)
  static Future<Hackathon> fromMap(String id, Map<String, dynamic> data) async {
    // Fetch teams
    var teamsQuery = await FirebaseFirestore.instance
        .collection('hackathons')
        .doc(id)
        .collection('teams')
        .get();

    print("Hackathon.fromMap - Here are the teams: ${teamsQuery.docs.length}");

    var listTeams = await Future.wait(
      teamsQuery.docs.map((doc) => Team.fromMap(doc.id, doc.data())),
    );

    // Fetch mentors
    List<String> mentorIds = List<String>.from(data['mentors'] ?? []);
    print(
        "Hackathon.fromMap - mentorIds from hackathon doc: $mentorIds"); // LOG 1

    List<UserModel> mentors = [];

    if (mentorIds.isNotEmpty) {
      print(
          "Hackathon.fromMap - Fetching mentors with IDs: $mentorIds"); // LOG 2
      var mentorsQuery = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: mentorIds)
          .get();
      print(
          "Hackathon.fromMap - MentorsQuery snapshot size: ${mentorsQuery.size}"); // LOG 3

      mentors = mentorsQuery.docs
          .map((doc) => UserModel.fromMap(doc.id, doc.data()))
          .toList();
      print(
          "Hackathon.fromMap - Number of mentors fetched: ${mentors.length}"); // LOG 4
    } else {
      print(
          "Hackathon.fromMap - No mentor IDs found in hackathon doc."); // LOG 5
    }

    return Hackathon(
      id: id,
      name: data['name'] ?? '',
      companyId: data['company_id'] ?? '',
      maxTeams: data['maxTeams'] ?? 0,
      status: data['status'] ?? 'pending',
      teams: listTeams,
      mentors: mentors, // ✅ Now fetching mentors
    );
  }
}
