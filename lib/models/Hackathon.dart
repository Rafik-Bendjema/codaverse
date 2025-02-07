import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gdg_hack/models/Team.dart';
import 'package:uuid/uuid.dart';

class Hackathon {
  Uuid uuid = Uuid();
  String? id;
  String name;
  List<Team> teams;
  String companyId;
  int maxTeams;
  String status;

  Hackathon({
    this.id,
    required this.name,
    required this.companyId,
    required this.teams,
    required this.maxTeams,
    required this.status,
  }) {
    id = uuid.v1();
  }

  // Convert Hackathon to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'company_id': companyId,
      'maxTeams': maxTeams,
      'status': status,
      'teams': teams.map((team) => team.toMap()).toList(),
    };
  }

  // Create Hackathon from Firestore data (async to fetch teams)
  static Future<Hackathon> fromMap(String id, Map<String, dynamic> data) async {
    List<Team> teamList = [];

    // Fetch teams from the subcollection inside this hackathon document
    var teamsQuery = await FirebaseFirestore.instance
        .collection('hackathons') // Parent collection
        .doc(id) // Current Hackathon ID
        .collection('teams') // Subcollection
        .get();

    /*teamList = await Future.wait(teamsQuery.docs.map((doc) async {
      return Team.fromMap(doc.id, doc.data());
    }));*/

    return Hackathon(
      id: id,
      name: data['name'],
      companyId: data['company_id'],
      maxTeams: data['maxTeams'],
      status: data['status'],
      teams: teamList,
    );
  }
}
