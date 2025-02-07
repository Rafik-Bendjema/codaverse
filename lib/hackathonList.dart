import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gdg_hack/models/Hackathon.dart';
import 'package:gdg_hack/youHackathon.dart';

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
      body: StreamBuilder<List<Hackathon>>(
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
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(hackathon.name),
                  subtitle: Text(
                      "Status: ${hackathon.status} - Max Teams: ${hackathon.maxTeams}"),
                  onTap: () {
                    // Navigate to hackathon details if needed
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
