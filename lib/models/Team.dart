import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gdg_hack/models/userModel.dart';

class Team {
  final String id;
  final String name;
  final List<UserModel> members;

  Team({
    required this.id,
    required this.name,
    required this.members,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'members': members.map((member) => member.toMap()).toList(),
    };
  }

  static Future<Team> fromMap(String id, Map<String, dynamic> data) async {
    // Fetch all the users based on the member IDs
    List<UserModel> memberList = await Future.wait(
      (data['members'] as List<dynamic>).map((memberId) async {
        var userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(memberId)
            .get();
        return UserModel.fromMap(
            userSnapshot.id, userSnapshot.data() as Map<String, dynamic>);
      }).toList(),
    );

    return Team(
      id: id,
      name: data['name'],
      members: memberList,
    );
  }
}
