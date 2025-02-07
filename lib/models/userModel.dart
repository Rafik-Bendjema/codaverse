import 'package:flame/components.dart';

class UserModel {
  String id;
  String name;
  String role;
  bool isCompany;
  String? hackathonId;

  UserModel(
      {required this.id,
      required this.name,
      required this.role,
      required this.isCompany,
      required this.hackathonId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'hackathon_id': hackathonId,
      'isCompany': isCompany,
    };
  }

  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      name: data['name'],
      role: data['role'],
      hackathonId: data['hackathon_id'],
      isCompany: data['isCompany'],
    );
  }
}
