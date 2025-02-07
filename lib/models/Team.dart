import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gdg_hack/models/userModel.dart';

class Team {
  final String id;
  final String name;
  final List<String> members;

  Team({
    required this.id,
    required this.name,
    required this.members,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'members': members,
    };
  }

  static Future<Team> fromMap(String id, Map<String, dynamic> data) async {
    // Fetch all the users based on the member IDs

    return Team(
      id: id,
      name: data['name'],
      members: (data['members'] as List<dynamic>).cast<String>(),
    );
  }
}
