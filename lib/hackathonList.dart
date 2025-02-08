import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gdg_hack/auth/authService.dart';
import 'package:gdg_hack/models/Hackathon.dart';
import 'package:gdg_hack/youHackathon.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HackathonListPage extends StatelessWidget {
  const HackathonListPage({super.key});

  Stream<List<Hackathon>> getHackathons() {
    return FirebaseFirestore.instance
        .collection('hackathons')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) async {
            return await Hackathon.fromMap(doc.id, doc.data());
          }).toList(),
        )
        .asyncMap((futureList) async => await Future.wait(futureList));
  }

  Future<void> _joinHackathon(BuildContext context, Hackathon hackathon) async {
    TextEditingController teamController = TextEditingController();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("uid");

    if (userId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("User not logged in")));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Join ${hackathon.name}"),
        content: TextField(
          controller: teamController,
          decoration: const InputDecoration(labelText: "Enter team name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              String teamName = teamController.text.trim();
              if (teamName.isEmpty) {
                return;
              }

              FirebaseFirestore firestore = FirebaseFirestore.instance;
              DocumentReference userRef =
                  firestore.collection('users').doc(userId);
              DocumentReference hackathonRef =
                  firestore.collection('hackathons').doc(hackathon.id);

              try {
                // Update user's hackathon_id
                await userRef.update({'hackathon_id': hackathon.id});

                // Create a new team in the hackathon's teams subcollection
                DocumentReference newTeamRef =
                    hackathonRef.collection('teams').doc();
                await newTeamRef.set({
                  'name': teamName,
                  'members': [userId],
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text("Joined ${hackathon.name} successfully!")),
                );

                Navigator.pop(context); // Close the dialog
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error joining hackathon: $e")),
                );
              }
            },
            child: const Text("Join"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hackathons"),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => YourHackathonPage()));
              },
              child: Text("your hackathon"))
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: () async {
                    BaseAuthService authService = AuthService();
                    await authService.logout();
                  },
                  child: Text("logout")),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Hackathon>>(
              stream: getHackathons(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Error fetching hackathons"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No hackathons available"));
                }

                final hackathons = snapshot.data!;
                return ListView.builder(
                  itemCount: hackathons.length,
                  itemBuilder: (context, index) {
                    final hackathon = hackathons[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(hackathon.name),
                        subtitle: Text(
                            "Status: ${hackathon.status} - Max Teams: ${hackathon.maxTeams}"),
                        onTap: () => _joinHackathon(context, hackathon),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
