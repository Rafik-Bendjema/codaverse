import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:gdg_hack/backend/hachathon_db.dart';
import 'package:gdg_hack/game.dart';
import 'package:gdg_hack/models/Hackathon.dart';
import 'package:gdg_hack/playGround.dart';
import 'package:shared_preferences/shared_preferences.dart';

class YourHackathonPage extends StatefulWidget {
  const YourHackathonPage({super.key});

  @override
  State<YourHackathonPage> createState() => _YourHackathonPageState();
}

class _YourHackathonPageState extends State<YourHackathonPage> {
  Hackathon? hackathon;
  final HackathonDb _hackathonDb = FirestoreHackathonDb();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getHackathon();
  }

  void getHackathon() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('uid');
    hackathon = await _hackathonDb.getHackathonForUser(userId!);
    print("here is the return of the hackathon ${hackathon?.toMap()}");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Hackathon")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: hackathon == null
            ? Center(
                child: Text("YOU HAVE NO HACKATHON"),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hackathon!.name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text("Status: ${hackathon!.status}"),
                  Text("Max Teams: ${hackathon!.maxTeams}"),
                  const SizedBox(height: 20),
                  const Text("Mentors:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ...hackathon!.mentors
                      .map((mentor) => ListTile(title: Text(mentor.name))),
                  const Text("Teams:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ...hackathon!.teams
                      .map((team) => ListTile(title: Text(team.name))),
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
                                        builder: (context) =>
                                            Playground(hackathon: hackathon!)));
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
                ],
              ),
      ),
    );
  }
}
