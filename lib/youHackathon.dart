import 'package:flutter/material.dart';
import 'package:gdg_hack/backend/hachathon_db.dart';
import 'package:gdg_hack/backend/user_db.dart';
import 'package:gdg_hack/models/Hackathon.dart';
import 'package:gdg_hack/playGround.dart';
import 'package:shared_preferences/shared_preferences.dart';

class YourHackathonPage extends StatefulWidget {
  const YourHackathonPage({super.key});

  @override
  State<YourHackathonPage> createState() => _YourHackathonPageState();
}

class _YourHackathonPageState extends State<YourHackathonPage> {
  final HackathonDb _hackathonDb = FirestoreHackathonDb();
  final UserDb _userDb = userDb_impl(); // Instantiate UserDb
  String? userId;
  Hackathon? hackathon; // To hold the user's hackathon
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserHackathon();
  }

  Future<void> _fetchUserHackathon() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString("uid");
    print("here is the current uid of the user $uid");

    if (uid != null) {
      userId = uid;
      hackathon = await _userDb.inHackathon(uid); // Use userDb.inHackathon
      if (hackathon != null) {
        print("User is in hackathon: ${hackathon?.name}");
      } else {
        print("User is not in any hackathon.");
      }
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Hackathon")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hackathon == null
              ? const Center(
                  child: Text(
                      "You are not currently参加ing in a hackathon.")) // Updated message
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Hackathon Name:",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(hackathon!.name, style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                      Text("Status:",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(hackathon!.status, style: TextStyle(fontSize: 16)),
                      SizedBox(height: 20),
                      // You can add more details here, like teams, mentors, etc.
                      Text("Teams:",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      hackathon!.teams.isEmpty
                          ? Text("No teams yet.",
                              style: TextStyle(fontSize: 16))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics:
                                  NeverScrollableScrollPhysics(), // Disable scrolling within ListView
                              itemCount: hackathon!.teams.length,
                              itemBuilder: (context, index) {
                                final team = hackathon!.teams[index];
                                return ListTile(
                                  title: Text(team.name),
                                  subtitle: Text(
                                      "Members: ${team.members.length}"), // Display team member count
                                );
                              },
                            ),
                      Expanded(child: SizedBox()),
                      Center(
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: TextButton(
                                onPressed: () {
                                  if (hackathon!.status == "running") {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Playground(
                                                hackathon: hackathon!)));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "the hackathon is still not running"),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  "PlayGround",
                                ))),
                      )
                      // ... more widgets to display mentor info, etc. ...
                    ],
                  ),
                ),
    );
  }
}
